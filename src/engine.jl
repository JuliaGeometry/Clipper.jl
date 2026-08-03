# engine.jl — the Clipper64 stateful boolean-operation engine.
#
# Wraps an owning handle around Clipper2Lib::Clipper64. Results come back through
# the `append`/`newnode` callbacks defined here.

# ------------------------------------------------------------
# Result marshalling — flat Paths64 (Execute → Paths64 solution)
# ------------------------------------------------------------
# The C side calls `append(output, path_index, point)` once per point. We accumulate
# into a Vector of Paths64 keyed by the (0-based) path index. (Index gaps are filled
# with empty paths; a trailing empty path would be invisible here, but Clipper2
# never emits empty output paths.)
mutable struct _PathsSink
    paths::Paths64
end

# append(output::Ptr, idx::Csize_t, pt::Point64): grow `paths` to cover idx, push pt.
function _paths_append(sink_ptr::Ptr{Cvoid}, idx::Csize_t, pt::Point64)
    sink = unsafe_pointer_to_objref(sink_ptr)::_PathsSink
    i = Int(idx) + 1
    while length(sink.paths) < i
        push!(sink.paths, Point64[])
    end
    push!(sink.paths[i], pt)
    return nothing
end

# ------------------------------------------------------------
# Result marshalling — PolyTree64 (Execute → PolyTree64)
# ------------------------------------------------------------
# The C side calls:
#   newnode(parent_jl_ptr, ishole::Bool) -> child_jl_ptr
#   append(node_jl_ptr, pt::Point64)
# Nodes stay GC-reachable because _tree_newnode links each child into its parent's
# `children` before returning the raw pointer, so every node is reachable from the
# root (which ccall roots for the duration of the call).

function _tree_newnode(parent_ptr::Ptr{Cvoid}, ish::Bool)
    # parent_ptr is either the root PolyTree64 or a PolyPath64.
    parent = unsafe_pointer_to_objref(parent_ptr)
    child = PolyPath64(Point64[], ish, PolyPath64[])
    push!(parent.children, child)
    return pointer_from_objref(child)
end

function _tree_append(node_ptr::Ptr{Cvoid}, pt::Point64)
    node = unsafe_pointer_to_objref(node_ptr)::PolyPath64
    push!(node.polygon, pt)
    return nothing
end

# ------------------------------------------------------------
# Clipper64 engine handle
# ------------------------------------------------------------
"""
    Clipper64(; preserve_collinear=true, reverse_solution=false)

A stateful boolean-operation engine. Add geometry with [`add_subject!`](@ref),
[`add_clip!`](@ref), or [`add_open_subject!`](@ref); compute a result with
[`execute`](@ref) or [`execute_polytree`](@ref); reuse after [`clear!`](@ref).

`preserve_collinear=true` keeps output vertices that lie on a straight edge
between their neighbours. Pass `false` for minimal-vertex contours.
`reverse_solution` flips the orientation of output contours.

The underlying C++ engine is freed by a finalizer.
"""
mutable struct Clipper64
    ptr::Ptr{Cvoid}
    function Clipper64(; preserve_collinear::Bool = true, reverse_solution::Bool = false)
        p = ccall(
            (:clipper64_create, libcclipper2), Ptr{Cvoid}, (Bool, Bool),
            preserve_collinear, reverse_solution
        )
        c = new(p)
        finalizer(c) do x
            if x.ptr != C_NULL
                ccall((:clipper64_delete, libcclipper2), Cvoid, (Ptr{Cvoid},), x.ptr)
                x.ptr = C_NULL
            end
        end
        return c
    end
end

# ccall lowers a `Clipper64` argument declared `Ptr{Cvoid}` through cconvert /
# unsafe_convert and roots the object for the duration of the call, so a GC pass
# triggered from a result callback (or another thread) cannot finalize the engine
# while C code is still using it. Never pass the raw `.ptr` field to ccall.
Base.cconvert(::Type{Ptr{Cvoid}}, c::Clipper64) = c
Base.unsafe_convert(::Type{Ptr{Cvoid}}, c::Clipper64) = c.ptr

# Each add mode is its own C entry point (clipper64_add_subject / _open_subject /
# _clip, plus plural batch variants). ccall needs a constant symbol, so the six
# helpers are generated per mode.
for (mode, single, batch) in (
        (:subject, :clipper64_add_subject, :clipper64_add_subjects),
        (:open_subject, :clipper64_add_open_subject, :clipper64_add_open_subjects),
        (:clip, :clipper64_add_clip, :clipper64_add_clips),
    )
    single_fn = Symbol(:_add_, mode, :_path!)
    batch_fn = Symbol(:_add_, mode, :_paths!)
    @eval begin
        function $single_fn(c::Clipper64, path::Path64)
            return ccall(
                ($(QuoteNode(single)), libcclipper2), Bool,
                (Ptr{Cvoid}, Ptr{Point64}, Csize_t),
                c, path, length(path)
            )
        end
        function $batch_fn(c::Clipper64, paths::Paths64)
            isempty(paths) && return true
            # Build the (Ptr, count) arrays the C batch adds expect. `ptrs` and
            # `counts` are ccall arguments (rooted automatically); `paths` is only
            # referenced through raw pointers, so it needs an explicit preserve.
            ptrs = [pointer(p) for p in paths]
            counts = Csize_t[length(p) for p in paths]
            return GC.@preserve paths begin
                ccall(
                    ($(QuoteNode(batch)), libcclipper2), Bool,
                    (Ptr{Cvoid}, Ptr{Ptr{Point64}}, Ptr{Csize_t}, Csize_t),
                    c, ptrs, counts, length(paths)
                )
            end
        end
    end
end

"""
    add_subject!(c, path_or_paths; closed=true)

Add closed (or, with `closed=false`, open) subject geometry to the engine.
Returns `c`; throws [`ClipperError`](@ref) on failure. Single-path adds reject
degenerate paths (closed paths need ≥ 3 vertices, open ≥ 2); batch adds pass
everything through and leave degenerate paths to the engine, which ignores them.
"""
function add_subject!(c::Clipper64, path::Path64; closed::Bool = true)
    ok = closed ? _add_subject_path!(c, path) : _add_open_subject_path!(c, path)
    ok || throw(ClipperError(:add_subject!))
    return c
end
function add_subject!(c::Clipper64, paths::Paths64; closed::Bool = true)
    ok = closed ? _add_subject_paths!(c, paths) : _add_open_subject_paths!(c, paths)
    ok || throw(ClipperError(:add_subject!))
    return c
end

"""
    add_open_subject!(c, path_or_paths)

Add open (polyline) subject geometry. Equivalent to `add_subject!(...; closed=false)`.
Returns `c`; throws [`ClipperError`](@ref) on failure.
"""
function add_open_subject!(c::Clipper64, path::Path64)
    _add_open_subject_path!(c, path) || throw(ClipperError(:add_open_subject!))
    return c
end
function add_open_subject!(c::Clipper64, paths::Paths64)
    _add_open_subject_paths!(c, paths) || throw(ClipperError(:add_open_subject!))
    return c
end

"""
    add_clip!(c, path_or_paths)

Add clip geometry (always treated as closed). Returns `c`; throws
[`ClipperError`](@ref) on failure.
"""
function add_clip!(c::Clipper64, path::Path64)
    _add_clip_path!(c, path) || throw(ClipperError(:add_clip!))
    return c
end
function add_clip!(c::Clipper64, paths::Paths64)
    _add_clip_paths!(c, paths) || throw(ClipperError(:add_clip!))
    return c
end

"""
    execute(c, cliptype, fillrule) -> (Paths64, Paths64)

Run the boolean operation `cliptype` with the single `fillrule` and return
`(closed, open)` solution paths, both flat `Paths64`. (Clipper2 uses one fill
rule for both subject and clip; `open` is empty unless open subjects were
added.) Mirrors [`execute_polytree`](@ref)'s two-part return.
"""
function execute(c::Clipper64, cliptype::ClipType, fillrule::FillRule)
    sink = _PathsSink(Point64[])
    open_sink = _PathsSink(Point64[])
    cb = @cfunction(_paths_append, Cvoid, (Ptr{Cvoid}, Csize_t, Point64))
    # `c`, `sink`, and `open_sink` are all ccall arguments and stay rooted for the
    # duration of the call, even if a GC pass runs inside the append callbacks.
    ok = ccall(
        (:clipper64_execute, libcclipper2), Bool,
        (Ptr{Cvoid}, Cint, Cint, Any, Ptr{Cvoid}, Any, Ptr{Cvoid}),
        c, Cint(cliptype), Cint(fillrule), sink, cb, open_sink, cb
    )
    ok || throw(ClipperError(:execute))
    return (sink.paths, open_sink.paths)
end

"""
    execute_polytree(c, cliptype, fillrule) -> (PolyTree64, Paths64)

Run the boolean operation and return the closed-path solution as a `PolyTree64`
hierarchy (outer contours with nested holes) plus the open-path solution as flat
`Paths64` (empty unless open subjects were added — Clipper2 returns open paths
separately from the tree).
"""
function execute_polytree(c::Clipper64, cliptype::ClipType, fillrule::FillRule)
    root = PolyTree64()
    open_sink = _PathsSink(Point64[])
    newnode_cb = @cfunction(_tree_newnode, Ptr{Cvoid}, (Ptr{Cvoid}, Bool))
    append_cb = @cfunction(_tree_append, Cvoid, (Ptr{Cvoid}, Point64))
    open_cb = @cfunction(_paths_append, Cvoid, (Ptr{Cvoid}, Csize_t, Point64))
    # The C walk holds raw node pointers only transiently: ccall roots `root` (and
    # `c` and `open_sink`), and _tree_newnode links each child into its parent's
    # `children` *before* the pointer is returned, so each node is reachable from
    # the root the instant it exists — a GC pass mid-callback cannot collect one.
    ok = ccall(
        (:clipper64_execute_polytree, libcclipper2), Bool,
        (Ptr{Cvoid}, Cint, Cint, Any, Ptr{Cvoid}, Ptr{Cvoid}, Any, Ptr{Cvoid}),
        c, Cint(cliptype), Cint(fillrule),
        root, newnode_cb, append_cb, open_sink, open_cb
    )
    ok || throw(ClipperError(:execute_polytree))
    return (root, open_sink.paths)
end

"""
    clear!(c)

Reset the engine, discarding all added geometry. The handle can be reused.
"""
function clear!(c::Clipper64)
    ccall((:clipper64_clear, libcclipper2), Cvoid, (Ptr{Cvoid},), c)
    return c
end
