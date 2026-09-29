# Clipper.jl (Clipper2 wrapper)

A Julia wrapper for [Clipper2](https://github.com/AngusJohnson/Clipper2)'s
integer-coordinate polygon clipping and offsetting API.

## API

- A single `FillRule` is used for each boolean operation.
- Geometry is added with `add_subject!`, `add_clip!`, and `add_open_subject!`.
- Native enum values: `ClipTypeNone`, `ClipTypeIntersection`, `ClipTypeUnion`,
  `ClipTypeDifference`, `ClipTypeXor`; `FillRuleEvenOdd`, `FillRuleNonZero`,
  `FillRulePositive`, `FillRuleNegative`; `JoinTypeSquare`, `JoinTypeBevel`,
  `JoinTypeRound`, `JoinTypeMiter`; and `EndTypePolygon`, `EndTypeJoined`,
  `EndTypeButt`, `EndTypeSquare`, `EndTypeRound`.
- `union_self(paths, fillrule)` resolves self-intersections and overlapping
  contours within a path collection.
- Open paths are first-class: both `execute` and `execute_polytree` return
  `(closed, open)`.
- Z-aware paths use `Point64Z` with the same add functions and
  `execute_polytree_z`; invented intersections carry `Z_INTERSECTION`.
- Boolean convenience functions require an explicit `FillRule`; offset
  convenience functions require explicit `JoinType` and `EndType` values.
- The C ABI is likewise Clipper2-native: `clipper64_*` / `clipperoffset_*`
  handles, per-mode add entry points, and `Rect64` with `top` = min-y /
  `bottom` = max-y.

## Layers

| Layer | Symbols |
|-------|---------|
| Engine | `Clipper64`, `add_subject!`, `add_clip!`, `add_open_subject!`, `execute`, `execute_polytree`, `execute_polytree_z`, `clear!` |
| Offset | `ClipperOffset(; miter_limit, arc_tolerance, preserve_collinear, reverse_solution)`, `add_path!`, `execute`, `clear!` |
| Free functions | `union_paths`, `intersect_paths`, `difference_paths`, `xor_paths`, `inflate_paths`, `minkowski_sum`, `minkowski_diff`, `union_self`, `trim_collinear`, `rect_clip`, `area`, `is_positive`, `point_in_polygon` |

## Upgrading from Clipper.jl 0.6 or earlier (Clipper1)

Clipper.jl 0.7 is a deliberate API break: it wraps Clipper2 rather than emulating
the Clipper1 API. There are no deprecated aliases for the old names.

A typical boolean operation changes as follows:

```julia
# Clipper.jl <= 0.6
subject = IntPoint[
    IntPoint(0, 0), IntPoint(10, 0),
    IntPoint(10, 10), IntPoint(0, 10),
]
clipper = Clip()
add_path!(clipper, subject, PolyTypeSubject, true)
ok, solution = execute(
    clipper,
    ClipTypeUnion,
    PolyFillTypeNonZero,
    PolyFillTypeNonZero,
)

# Clipper.jl >= 0.7
subject = Point64[
    Point64(0, 0), Point64(10, 0),
    Point64(10, 10), Point64(0, 10),
]
clipper = Clipper64(; preserve_collinear=false)
add_subject!(clipper, subject)
solution, open_solution = execute(clipper, ClipTypeUnion, FillRuleNonZero)
```

The `preserve_collinear=false` option in the new example most closely matches
Clipper1's minimal-vertex output. Omit it to use Clipper2's default and retain
intermediate collinear vertices.

### API replacements

| Clipper.jl <= 0.6 | Clipper.jl >= 0.7 | Migration note |
|-------------------|-------------------|----------------|
| `IntPoint`, `Vector{IntPoint}`, `Vector{Vector{IntPoint}}` | `Point64`, `Path64`, `Paths64` | Point fields changed from `.X`/`.Y` to `.x`/`.y`. |
| `Clip()` | `Clipper64()` | `Clip` was removed. |
| `add_path!(c, path, PolyTypeSubject, closed)` | `add_subject!(c, path; closed=true)` | Prefer `add_open_subject!` when `closed=false`. The new method returns `c`, not a `Bool`. |
| `add_path!(c, path, PolyTypeClip, true)` | `add_clip!(c, path)` | Clipper2 clip paths are always closed. |
| `add_paths!(c, paths, ...)` | `add_subject!(c, paths)`, `add_clip!(c, paths)`, or `add_open_subject!(c, paths)` | The new add methods accept either one path or a path collection. |
| `PolyFillTypeNonZero` and the other `PolyFillType*` values | `FillRuleNonZero` and the corresponding `FillRule*` values | The type was renamed from `PolyFillType` to `FillRule`. |
| `execute(c, operation, subject_fill, clip_fill)` | `execute(c, operation, fill_rule)` | Clipper2 applies one fill rule to the whole operation. |
| `(success, paths) = execute(...)` | `(closed, open) = execute(...)` | Failures now throw `ClipperError`; open results are returned separately. |
| `(success, tree) = execute_pt(...)` | `(tree, open) = execute_polytree(...)` | The tree root is `PolyTree64`; its nodes are `PolyPath64`. |
| `PolyNode`, `parent(node)`, `isopen(node)` | `PolyPath64`, no parent/open fields | Use `children`, `contour`, and `ishole`; open paths are outside the tree. |
| `orientation(path)` | `is_positive(path)` | Both report positive polygon orientation. |
| `pointinpolygon(point, path)` | `point_in_polygon(point, path)` | Results changed from `1`, `0`, `-1` to `:inside`, `:outside`, `:on`. |
| `simplify_polygons(paths, fill)` | `union_self(paths, fill)` | The fill rule is now required explicitly. |
| `minkowski_sum(pattern, path[, closed])` | `minkowski_sum(pattern, path, closed)` | The `closed` argument is now required. |
| `minkowski_difference(pattern, path)` | `minkowski_diff(pattern, path, closed)` | The function was renamed and gained a required `closed` argument. |
| `IntRect`, `get_bounds(c)` | `Rect64`; no engine-bounds function | Track the input paths and calculate their bounds before adding them. |
| `IntPoint(x, y, magnitude, sigdigits)`, `tofloat(...)` | no direct replacement | Scale to and from `Int64` explicitly in application code. |

The new geometry-add methods return the engine for chaining rather than a
success `Bool`; failures throw `ClipperError`. Replace code that branches on an
`add_path!` or `add_paths!` result with normal calls and, when recovery is
needed, exception handling.

`ClipTypeIntersection`, `ClipTypeUnion`, `ClipTypeDifference`, and `ClipTypeXor`
keep their names, but their integer values changed and `ClipTypeNone` was added.
`JoinTypeRound`, `JoinTypeMiter`, and several mapped `EndType` values also have
new integer values, and `JoinTypeBevel` is new. Always pass enum values by name
rather than storing or passing their underlying integers.

Clipper2 has one fill rule per operation. When old code passed the same subject
and clip fill types, replace them with the corresponding single `FillRule`. An
old operation that intentionally used different fill types has no direct
one-call translation; normalize the inputs or split it into multiple boolean
operations.

### Offsetting

Offset enum names map as follows:

| Clipper.jl <= 0.6 | Clipper.jl >= 0.7 |
|-------------------|-------------------|
| `EndTypeClosedPolygon` | `EndTypePolygon` |
| `EndTypeClosedLine` | `EndTypeJoined` |
| `EndTypeOpenButt` | `EndTypeButt` |
| `EndTypeOpenSquare` | `EndTypeSquare` |
| `EndTypeOpenRound` | `EndTypeRound` |

The constructor now uses keywords. For example,
`ClipperOffset(2.0, 0.25)` becomes
`ClipperOffset(; miter_limit=2.0, arc_tolerance=0.25)`. The new default
`arc_tolerance=0.0` asks Clipper2 to choose it automatically.

`add_paths!` was removed here too; pass either a `Path64` or `Paths64` to
`add_path!`:

```julia
square = Point64[
    Point64(0, 0), Point64(10, 0),
    Point64(10, 10), Point64(0, 10),
]
paths = Paths64([square])
offset = ClipperOffset(; miter_limit=2.0, arc_tolerance=0.25)
add_path!(offset, paths, JoinTypeRound, EndTypePolygon)
result = execute(offset, 7.0)
```

Add an outer polygon and its holes together in one `Paths64` call. Clipper2's
offset engine requires them to be submitted as a batch to associate the holes
with the outer polygon correctly.

### Result differences

Clipper2 may choose a different first vertex or traversal order for an otherwise
identical contour. It preserves intermediate collinear vertices by default in
`Clipper64`, and Minkowski output can likewise contain additional collinear
vertices. Tests should therefore compare geometry (for example, area and
containment) rather than exact path-vector order. Use
`Clipper64(; preserve_collinear=false)` or `trim_collinear` when minimal-vertex
contours are required.

## Testing this draft

The `libcclipper2` product is being added to `Clipper2_jll` by
[JuliaPackaging/Yggdrasil#14270](https://github.com/JuliaPackaging/Yggdrasil/pull/14270).
Until that JLL is published, place a matching local library at
`deps/libcclipper2.so`, `deps/libcclipper2.dylib`, or `deps/libcclipper2.dll`.
It must be built from `deps/cwrapper/cclipper2.cpp` with `-DUSINGZ` against the
patched Clipper2 2.0.1 used by that Yggdrasil recipe. Then run:

```sh
julia --project -e 'using Pkg; Pkg.test()'
```

The package loader and `Project.toml` will use the `Clipper2_jll.libcclipper2`
product once it is available.

## Status / roadmap

- The engine, offset, free-function, and Z-aware APIs are covered by the
  standalone test suite in `test/runtests.jl`.
- Only integer coordinates (`Path64` and `Path64Z`) are supported. Double-precision
  `PathD` support could be added in the future.
- The canonical C wrapper source is in `deps/cwrapper/`; the Yggdrasil recipe
  pulls that directory when building `libcclipper2`.

## License

Clipper.jl and Clipper2 are available under the
[Boost Software License 1.0](LICENSE.md).
