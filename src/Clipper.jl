"""
    Clipper

A Julia wrapper for the Clipper2 polygon-clipping and offsetting library.

This module exposes Clipper2's integer-coordinate API:

  - `Clipper64`, the boolean-operation engine
    - `add_subject!`/`add_clip!`/`add_open_subject!` to add geometry
    - `ClipType`/`FillRule` enums to specify Boolean operations
    - `execute`, `execute_polytree`, and `clear!`
  - `ClipperOffset`, the offsetting engine
    - `add_path!` to add geometry
    - `JoinType` and `EndType` enums to specify offsetting behavior
    - `execute` and `clear!`
  - Free functions such as `union_paths`, `intersect_paths`, `difference_paths`,
    `xor_paths`, `inflate_paths`, and `minkowski_sum`

All geometry crosses the FFI boundary through the C shim `libcclipper2` (`cclipper2.cpp`),
which calls Clipper2's C++ API. Results are returned via Julia callbacks.
"""
module Clipper

import Libdl

# Enums
export ClipType, ClipTypeNone, ClipTypeIntersection, ClipTypeUnion, ClipTypeDifference,
       ClipTypeXor
export FillRule, FillRuleEvenOdd, FillRuleNonZero, FillRulePositive, FillRuleNegative
export JoinType, JoinTypeSquare, JoinTypeBevel, JoinTypeRound, JoinTypeMiter
export EndType, EndTypePolygon, EndTypeJoined, EndTypeButt, EndTypeSquare, EndTypeRound

# Engine
export Clipper64, ClipperError, Path64, Paths64, Point64, PolyPath64, PolyTree64, Rect64
export add_clip!, add_open_subject!, add_subject!, children, clear!, contour, execute,
       execute_polytree, ishole

# Offsetting
export ClipperOffset
export add_path!

# Free functions
export area, difference_paths, inflate_paths, intersect_paths, is_positive, minkowski_diff,
       minkowski_sum, point_in_polygon, rect_clip, trim_collinear, union_paths, union_self,
       xor_paths

# ============================================================
# Library handle
# ============================================================
# Local builds place the platform-specific C shim in deps/.
const libcclipper2 = abspath(
    joinpath(@__DIR__, "..", "deps", "libcclipper2.$(Libdl.dlext)"),
)

# ============================================================
# Enums — the wrapper-owned ABI values defined in cclipper2.cpp (mapped to
# Clipper2's native enums inside the shim, so upstream renumbering can't
# shift them). `::Cint`-backed so they pass cleanly through the `int` C ABI.
# ============================================================
"""
    ClipType

Boolean operation passed to [`execute`](@ref) and [`execute_polytree`](@ref).
"""
@enum ClipType::Cint begin
    ClipTypeNone = 0
    ClipTypeIntersection = 1
    ClipTypeUnion = 2
    ClipTypeDifference = 3
    ClipTypeXor = 4
end

"""
    FillRule

Rule used to determine whether a region is inside the subject and clip paths.
"""
@enum FillRule::Cint begin
    FillRuleEvenOdd = 0
    FillRuleNonZero = 1
    FillRulePositive = 2
    FillRuleNegative = 3
end

"""
    JoinType

Corner treatment used by [`ClipperOffset`](@ref) and [`inflate_paths`](@ref).
"""
@enum JoinType::Cint begin
    JoinTypeSquare = 0
    JoinTypeBevel = 1
    JoinTypeRound = 2
    JoinTypeMiter = 3
end

"""
    EndType

End treatment used when offsetting closed polygons and open paths.
"""
@enum EndType::Cint begin
    EndTypePolygon = 0
    EndTypeJoined = 1
    EndTypeButt = 2
    EndTypeSquare = 3
    EndTypeRound = 4
end

# ============================================================
# Types — layout-compatible with the C ABI structs (CPoint64/CRect64).
# ============================================================
"""
    Point64(x, y)

An integer-coordinate 2D point. Layout-compatible with Clipper2Lib::Point64
(two `Int64`).
"""
struct Point64
    x::Int64
    y::Int64
end
Point64(x::Integer, y::Integer) = Point64(Int64(x), Int64(y))

"""A polygon or polyline represented by a vector of [`Point64`](@ref) values."""
const Path64 = Vector{Point64}

"""A collection of [`Path64`](@ref) values."""
const Paths64 = Vector{Path64}

"""
    Rect64(left, top, right, bottom)

An axis-aligned integer bounding box. Layout-compatible with Clipper2Lib::Rect64.
"""
struct Rect64
    left::Int64
    top::Int64
    right::Int64
    bottom::Int64
end

"""
    PolyPath64(polygon, ishole, children)

A node in a `PolyTree64`. `polygon` is the node's contour, `ishole` is true for
holes, `children` are nested `PolyPath64`. Clipper2 PolyTree nodes carry no
`isopen` flag — open paths are returned separately by `execute_polytree`.
"""
mutable struct PolyPath64
    polygon::Path64
    ishole::Bool
    children::Vector{PolyPath64}
end
PolyPath64() = PolyPath64(Point64[], false, PolyPath64[])

"""
    PolyTree64()

The root of a polygon hierarchy returned by `execute_polytree`. The root itself
holds no contour; its `children` are the outermost contours.
"""
mutable struct PolyTree64
    children::Vector{PolyPath64}
end
PolyTree64() = PolyTree64(PolyPath64[])

"""Return the contour stored in a [`PolyPath64`](@ref) node."""
contour(n::PolyPath64) = n.polygon

"""Return whether a [`PolyPath64`](@ref) node represents a hole."""
ishole(n::PolyPath64) = n.ishole

"""Return the child nodes of a [`PolyPath64`](@ref) or [`PolyTree64`](@ref)."""
children(n::Union{PolyPath64,PolyTree64}) = n.children

"""
    ClipperError(fn)

Thrown when a result-producing C call reports failure (a C++ exception at the
FFI boundary or an invalid enum value; the C++ message goes to stderr).
"""
struct ClipperError <: Exception
    fn::Symbol
end
Base.showerror(io::IO, e::ClipperError) =
    print(io, "Clipper2 operation failed in $(e.fn) (see stderr for the C++ message)")

include("engine.jl")
include("offset.jl")
include("freefuncs.jl")

end # module Clipper
