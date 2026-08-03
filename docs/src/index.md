# Clipper.jl

Clipper.jl exposes Clipper2's integer-coordinate polygon clipping and offsetting
API through a C-compatible library. It provides stateful clipping and offsetting
engines together with convenience functions for common one-shot operations.

## Geometry types

A point is represented by [`Point64`](@ref), whose coordinates are signed
64-bit integers. A [`Path64`](@ref) is a vector of points, and [`Paths64`](@ref)
is a vector of paths.

```julia
using Clipper

square = Point64[
    Point64(0, 0),
    Point64(10, 0),
    Point64(10, 10),
    Point64(0, 10),
]
```

[`Rect64`](@ref) represents an axis-aligned rectangle. Its fields follow
Clipper2's convention: `top` is the minimum y-coordinate and `bottom` is the
maximum y-coordinate.

## Boolean operations

[`Clipper64`](@ref) stores subject and clip geometry across calls. Add paths,
execute an operation with an explicit [`ClipType`](@ref) and [`FillRule`](@ref),
and call [`clear!`](@ref) before reusing the engine for unrelated geometry.

```julia
other = Point64[
    Point64(5, 5),
    Point64(15, 5),
    Point64(15, 15),
    Point64(5, 15),
]

clipper = Clipper64()
add_subject!(clipper, square)
add_clip!(clipper, other)
closed, open = execute(clipper, ClipTypeUnion, FillRuleNonZero)
```

`execute` returns separate closed and open `Paths64` collections. Open subject
paths can be added with [`add_open_subject!`](@ref), or with
`add_subject!(clipper, path; closed=false)`.

Use [`execute_polytree`](@ref) when nesting information is required. It returns
a [`PolyTree64`](@ref) for closed contours and a separate `Paths64` collection
for open results.

## Offsetting

[`ClipperOffset`](@ref) offsets closed polygons or open paths. Each path requires
an explicit [`JoinType`](@ref) and [`EndType`](@ref).

```julia
offset = ClipperOffset(; miter_limit=2.0, arc_tolerance=0.0)
add_path!(offset, square, JoinTypeMiter, EndTypePolygon)
inflated = execute(offset, 5.0)
```

Positive deltas inflate closed polygons and negative deltas deflate them.
[`inflate_paths`](@ref) provides the equivalent one-shot operation:

```julia
inflated = inflate_paths(
    square,
    5.0,
    JoinTypeMiter,
    EndTypePolygon,
)
```

## One-shot boolean operations

The boolean convenience functions require an explicit fill rule:

```julia
union_paths(square, other, FillRuleNonZero)
intersect_paths(square, other, FillRuleNonZero)
difference_paths(square, other, FillRuleNonZero)
xor_paths(square, other, FillRuleNonZero)
```

`union_paths(subjects, fillrule)` performs a union without separate clip paths.
[`union_self`](@ref) resolves self-intersections and overlapping contours within
a `Paths64` collection.

## Geometry utilities

The remaining free functions provide direct geometry operations:

- [`area`](@ref) and [`is_positive`](@ref) inspect polygon orientation.
- [`point_in_polygon`](@ref) classifies a point as `:inside`, `:outside`, or
  `:on` the boundary.
- [`rect_clip`](@ref) clips paths independently against a rectangle.
- [`trim_collinear`](@ref) removes intermediate collinear vertices.
- [`minkowski_sum`](@ref) and [`minkowski_diff`](@ref) require an explicit
  boolean indicating whether the input path is closed.

See the [Reference](@ref) for the complete exported API.
