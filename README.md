# Clipper.jl (faithful Clipper2 wrapper)

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
- Boolean convenience functions require an explicit `FillRule`; offset
  convenience functions require explicit `JoinType` and `EndType` values.
- The C ABI is likewise Clipper2-native: `clipper64_*` / `clipperoffset_*`
  handles, per-mode add entry points, and `Rect64` with `top` = min-y /
  `bottom` = max-y.

## Layers

| Layer | Symbols |
|-------|---------|
| Engine | `Clipper64`, `add_subject!`, `add_clip!`, `add_open_subject!`, `execute`, `execute_polytree`, `clear!` |
| Offset | `ClipperOffset(; miter_limit, arc_tolerance, preserve_collinear, reverse_solution)`, `add_path!`, `execute`, `clear!` |
| Free functions | `union_paths`, `intersect_paths`, `difference_paths`, `xor_paths`, `inflate_paths`, `minkowski_sum`, `minkowski_diff`, `union_self`, `trim_collinear`, `rect_clip`, `area`, `is_positive`, `point_in_polygon` |

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
- Only integer coordinates (`Path64`) are supported. Double-precision `PathD`
  support could be added in the future.
- The canonical C wrapper source is in `deps/cwrapper/`; the Yggdrasil recipe
  pulls that directory when building `libcclipper2`.

## License

Clipper.jl and Clipper2 are available under the
[Boost Software License 1.0](LICENSE.md).
