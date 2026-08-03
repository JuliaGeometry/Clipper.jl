```@meta
CurrentModule = Clipper
```

# Reference

```@docs
Clipper
```

## Enums

The enum values are backed by `Cint` and use the values defined by the C wrapper.

| Enum | Values in declaration order |
|------|-----------------------------|
| [`ClipType`](@ref) | `ClipTypeNone`, `ClipTypeIntersection`, `ClipTypeUnion`, `ClipTypeDifference`, `ClipTypeXor` |
| [`FillRule`](@ref) | `FillRuleEvenOdd`, `FillRuleNonZero`, `FillRulePositive`, `FillRuleNegative` |
| [`JoinType`](@ref) | `JoinTypeSquare`, `JoinTypeBevel`, `JoinTypeRound`, `JoinTypeMiter` |
| [`EndType`](@ref) | `EndTypePolygon`, `EndTypeJoined`, `EndTypeButt`, `EndTypeSquare`, `EndTypeRound` |

```@docs
ClipType
FillRule
JoinType
EndType
```

## Geometry and result types

```@docs
Point64
Path64
Paths64
Rect64
PolyPath64
PolyTree64
ClipperError
children
contour
ishole
```

## Clipping engine

```@docs
Clipper64
add_subject!
add_open_subject!
add_clip!
execute(::Clipper64, ::ClipType, ::FillRule)
execute_polytree
clear!(::Clipper64)
```

## Offsetting

```@docs
ClipperOffset
add_path!
execute(::ClipperOffset, ::Real)
clear!(::ClipperOffset)
inflate_paths
```

## Free functions

```@docs
area
intersect_paths
union_paths
difference_paths
xor_paths
union_self
is_positive
minkowski_diff
minkowski_sum
point_in_polygon
rect_clip
trim_collinear
```
