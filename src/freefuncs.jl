# freefuncs.jl — the idiomatic free-function layer.
#
# Some of these map directly to C exports (cclipper2_area / cclipper2_is_positive
# / cclipper2_point_in_polygon / cclipper2_minkowski_* / cclipper2_union_self /
# cclipper2_trim_collinear / cclipper2_rect_clip — the shim prefixes its free
# functions; the engine entry points are namespaced by their handle prefixes).
# The boolean convenience functions (union/intersect/difference/xor) and
# inflate_paths are built on the stateful engine/offset — Clipper2 offers C++
# free-function forms, but the C shim is engine-based, so we compose them here.
# The result shape is identical; only the surface is convenience.

# ------------------------------------------------------------
# Direct C exports
# ------------------------------------------------------------
"""
    area(path) -> Float64

Signed area of a polygon (positive for counter-clockwise / positive orientation).
"""
area(path::Path64) =
    ccall((:cclipper2_area, libcclipper2), Cdouble, (Ptr{Point64}, Csize_t), path, length(path))

"""
    is_positive(path) -> Bool

True if the polygon has positive orientation (counter-clockwise). Clipper2's
`IsPositive`.
"""
is_positive(path::Path64) =
    ccall((:cclipper2_is_positive, libcclipper2), Bool, (Ptr{Point64}, Csize_t), path, length(path))

"""
    point_in_polygon(pt, path) -> Symbol

`:inside`, `:outside`, or `:on` (boundary).
"""
function point_in_polygon(pt::Point64, path::Path64)
    # C returns the wrapper's PointInPolygonResult: IsOn=0, IsInside=1, IsOutside=2.
    r = ccall((:cclipper2_point_in_polygon, libcclipper2), Cint,
        (Point64, Ptr{Point64}, Csize_t), pt, path, length(path))
    return r == 1 ? :inside : (r == 0 ? :on : :outside)
end

"""
    rect_clip(rect::Rect64, paths) -> Paths64

Clip closed `paths` against the axis-aligned rectangle `rect` — Clipper2's
`RectClip`, O(n) per path versus a full sweep-line boolean. The tile-cutting
primitive for tiled operations over large geometry.

Each path is clipped independently: results are not unioned, and hole/owner
relationships are not resolved. Follow with a boolean op per tile when input
paths overlap or carry holes.
"""
function rect_clip(rect::Rect64, paths)
    ps = _as_paths(paths)
    isempty(ps) && return Paths64()
    sink = _PathsSink(Point64[])
    cb = @cfunction(_paths_append, Cvoid, (Ptr{Cvoid}, Csize_t, Point64))
    ptrs = [pointer(p) for p in ps]
    counts = Csize_t[length(p) for p in ps]
    # `ps` is only referenced through raw pointers, so it needs an explicit
    # preserve; the other objects are ccall arguments (rooted automatically).
    ok = GC.@preserve ps begin
        ccall((:cclipper2_rect_clip, libcclipper2), Bool,
            (Int64, Int64, Int64, Int64,
             Ptr{Ptr{Point64}}, Ptr{Csize_t}, Csize_t, Any, Ptr{Cvoid}),
            rect.left, rect.top, rect.right, rect.bottom,
            ptrs, counts, length(ps), sink, cb)
    end
    ok || throw(ClipperError(:rect_clip))
    return sink.paths
end

"""
    minkowski_sum(pattern, path, closed) -> Paths64

Compute the Minkowski sum of `pattern` and `path`. `closed` specifies whether
`path` is closed.
"""
function minkowski_sum(pattern::Path64, path::Path64, closed::Bool)
    sink = _PathsSink(Point64[])
    cb = @cfunction(_paths_append, Cvoid, (Ptr{Cvoid}, Csize_t, Point64))
    ok = ccall((:cclipper2_minkowski_sum, libcclipper2), Bool,
        (Ptr{Point64}, Csize_t, Ptr{Point64}, Csize_t, Any, Ptr{Cvoid}, Bool),
        pattern, length(pattern), path, length(path), sink, cb, closed)
    ok || throw(ClipperError(:minkowski_sum))
    return sink.paths
end

"""
    minkowski_diff(pattern, path, closed) -> Paths64

Compute the Minkowski difference of `pattern` and `path`. `closed` specifies
whether `path` is closed.
"""
function minkowski_diff(pattern::Path64, path::Path64, closed::Bool)
    sink = _PathsSink(Point64[])
    cb = @cfunction(_paths_append, Cvoid, (Ptr{Cvoid}, Csize_t, Point64))
    ok = ccall((:cclipper2_minkowski_difference, libcclipper2), Bool,
        (Ptr{Point64}, Csize_t, Ptr{Point64}, Csize_t, Any, Ptr{Cvoid}, Bool),
        pattern, length(pattern), path, length(path), sink, cb, closed)
    ok || throw(ClipperError(:minkowski_diff))
    return sink.paths
end

"""
    union_self(paths, fillrule) -> Paths64

Resolve self-intersections and merge overlapping contours within `paths` using
`fillrule`.
"""
function union_self(paths, fillrule::FillRule)
    ps = _as_paths(paths)
    isempty(ps) && return Paths64()
    sink = _PathsSink(Point64[])
    cb = @cfunction(_paths_append, Cvoid, (Ptr{Cvoid}, Csize_t, Point64))
    ptrs = [pointer(p) for p in ps]
    counts = Csize_t[length(p) for p in ps]
    ok = GC.@preserve ps begin
        ccall((:cclipper2_union_self, libcclipper2), Bool,
            (Ptr{Ptr{Point64}}, Ptr{Csize_t}, Csize_t, Cint, Any, Ptr{Cvoid}),
            ptrs, counts, length(ps), Cint(fillrule), sink, cb)
    end
    ok || throw(ClipperError(:union_self))
    return sink.paths
end

"""
    trim_collinear(paths; is_open=false) -> Paths64

Drop vertices that lie on the straight edge between their neighbours, per path.
Set `is_open=true` to preserve the endpoints of open paths.
"""
function trim_collinear(paths; is_open::Bool=false)
    ps = _as_paths(paths)
    isempty(ps) && return Paths64()
    sink = _PathsSink(Point64[])
    cb = @cfunction(_paths_append, Cvoid, (Ptr{Cvoid}, Csize_t, Point64))
    ptrs = [pointer(p) for p in ps]
    counts = Csize_t[length(p) for p in ps]
    ok = GC.@preserve ps begin
        ccall((:cclipper2_trim_collinear, libcclipper2), Bool,
            (Ptr{Ptr{Point64}}, Ptr{Csize_t}, Csize_t, Bool, Any, Ptr{Cvoid}),
            ptrs, counts, length(ps), is_open, sink, cb)
    end
    ok || throw(ClipperError(:trim_collinear))
    return sink.paths
end

# ------------------------------------------------------------
# Boolean convenience functions (composed on the engine)
# ------------------------------------------------------------
_as_paths(p::Path64) = Paths64([p])
_as_paths(p::Paths64) = p

function _boolean(ct::ClipType, subjects, clips, fr::FillRule)
    c = Clipper64()
    add_subject!(c, _as_paths(subjects))
    cl = _as_paths(clips)
    isempty(cl) || add_clip!(c, cl)
    # Closed solution only — these convenience functions take closed subjects.
    return first(execute(c, ct, fr))
end

"""
    intersect_paths(subjects, clips, fillrule) -> Paths64

Intersect `subjects` and `clips` using `fillrule`.
"""
intersect_paths(subjects, clips, fillrule::FillRule) =
    _boolean(ClipTypeIntersection, subjects, clips, fillrule)

"""
    union_paths(subjects, fillrule) -> Paths64
    union_paths(subjects, clips, fillrule) -> Paths64

Union `subjects`, optionally with `clips`, using `fillrule`.
"""
union_paths(subjects, fillrule::FillRule) =
    _boolean(ClipTypeUnion, subjects, Paths64(), fillrule)
union_paths(subjects, clips, fillrule::FillRule) =
    _boolean(ClipTypeUnion, subjects, clips, fillrule)

"""
    difference_paths(subjects, clips, fillrule) -> Paths64

Subtract `clips` from `subjects` using `fillrule`.
"""
difference_paths(subjects, clips, fillrule::FillRule) =
    _boolean(ClipTypeDifference, subjects, clips, fillrule)

"""
    xor_paths(subjects, clips, fillrule) -> Paths64

Compute the symmetric difference of `subjects` and `clips` using `fillrule`.
"""
xor_paths(subjects, clips, fillrule::FillRule) =
    _boolean(ClipTypeXor, subjects, clips, fillrule)

"""
    inflate_paths(paths, delta, jointype, endtype;
                  miter_limit=2.0, arc_tolerance=0.0) -> Paths64

Offset `paths` by `delta` using `jointype` and `endtype`.
"""
function inflate_paths(paths, delta::Real, jointype::JoinType, endtype::EndType;
        miter_limit::Real=2.0, arc_tolerance::Real=0.0)
    o = ClipperOffset(; miter_limit=miter_limit, arc_tolerance=arc_tolerance)
    add_path!(o, _as_paths(paths), jointype, endtype)
    return execute(o, delta)
end
