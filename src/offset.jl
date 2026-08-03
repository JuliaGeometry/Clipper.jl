# offset.jl — ClipperOffset (polygon inflation/deflation).

"""
    ClipperOffset(; miter_limit=2.0, arc_tolerance=0.0,
                  preserve_collinear=false, reverse_solution=false)

A polygon-offsetting engine. Add geometry with [`add_path!`](@ref) (tagging each
path with a [`JoinType`](@ref) and [`EndType`](@ref)), then [`execute`](@ref) with
a signed `delta`.

`arc_tolerance=0.0` selects Clipper2's automatic arc tolerance. Pass a positive
value to set an explicit maximum deviation from the ideal arc.

The offset engine defaults `preserve_collinear=false`, while `Clipper64` defaults
to `preserve_collinear=true`.
"""
mutable struct ClipperOffset
    ptr::Ptr{Cvoid}
    function ClipperOffset(; miter_limit::Real=2.0, arc_tolerance::Real=0.0,
            preserve_collinear::Bool=false, reverse_solution::Bool=false)
        p = ccall((:clipperoffset_create, libcclipper2), Ptr{Cvoid},
            (Cdouble, Cdouble, Bool, Bool),
            Float64(miter_limit), Float64(arc_tolerance),
            preserve_collinear, reverse_solution)
        c = new(p)
        finalizer(c) do x
            if x.ptr != C_NULL
                ccall((:clipperoffset_delete, libcclipper2), Cvoid, (Ptr{Cvoid},), x.ptr)
                x.ptr = C_NULL
            end
        end
        return c
    end
end

# ccall lowers a `ClipperOffset` argument declared `Ptr{Cvoid}` through cconvert /
# unsafe_convert and roots the object for the duration of the call, so a GC pass
# triggered from a result callback (or another thread) cannot finalize the engine
# while C code is still using it. Never pass the raw `.ptr` field to ccall.
Base.cconvert(::Type{Ptr{Cvoid}}, o::ClipperOffset) = o
Base.unsafe_convert(::Type{Ptr{Cvoid}}, o::ClipperOffset) = o.ptr

"""
    add_path!(o::ClipperOffset, path, jointype, endtype)

Add a path to be offset, with the given join and end behavior.
"""
function add_path!(o::ClipperOffset, path::Path64, jt::JoinType, et::EndType)
    ok = ccall((:clipperoffset_add_path, libcclipper2), Bool,
        (Ptr{Cvoid}, Ptr{Point64}, Csize_t, Cint, Cint),
        o, path, length(path), Cint(jt), Cint(et))
    ok || throw(ClipperError(:add_path!))
    return o
end

function add_path!(o::ClipperOffset, paths::Paths64, jt::JoinType, et::EndType)
    isempty(paths) && return o
    # `ptrs` and `counts` are ccall arguments (rooted automatically); `paths` is
    # only referenced through raw pointers, so it needs an explicit preserve.
    ptrs = [pointer(p) for p in paths]
    counts = Csize_t[length(p) for p in paths]
    ok = GC.@preserve paths begin
        ccall((:clipperoffset_add_paths, libcclipper2), Bool,
            (Ptr{Cvoid}, Ptr{Ptr{Point64}}, Ptr{Csize_t}, Csize_t, Cint, Cint),
            o, ptrs, counts, length(paths), Cint(jt), Cint(et))
    end
    ok || throw(ClipperError(:add_path!))
    return o
end

"""
    execute(o::ClipperOffset, delta) -> Paths64

Offset all added paths by `delta` (positive inflates, negative deflates) and return
the result.
"""
function execute(o::ClipperOffset, delta::Real)
    sink = _PathsSink(Point64[])
    cb = @cfunction(_paths_append, Cvoid, (Ptr{Cvoid}, Csize_t, Point64))
    # `o` and `sink` are ccall arguments and stay rooted for the duration of the
    # call, even if a GC pass runs inside the append callback.
    ok = ccall((:clipperoffset_execute, libcclipper2), Bool,
        (Ptr{Cvoid}, Cdouble, Any, Ptr{Cvoid}),
        o, Float64(delta), sink, cb)
    ok || throw(ClipperError(:execute))
    return sink.paths
end

"""
    clear!(o::ClipperOffset)

Discard all added paths; the handle can be reused.
"""
function clear!(o::ClipperOffset)
    ccall((:clipperoffset_clear, libcclipper2), Cvoid, (Ptr{Cvoid},), o)
    return o
end
