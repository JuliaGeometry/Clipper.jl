#
# Clipper Enums
#

const ioReverseSolution = CppEnum{symbol("ClipperLib::InitOptions")}(1)
const ioStrictlySimple = CppEnum{symbol("ClipperLib::InitOptions")}(2)
const ioPreserveCollinear = CppEnum{symbol("ClipperLib::InitOptions")}(4)


const ctIntersection = CppEnum{symbol("ClipperLib::ClipType")}(0)
const ctUnion = CppEnum{symbol("ClipperLib::ClipType")}(1)
const ctDifference = CppEnum{symbol("ClipperLib::ClipType")}(2)
const ctXor = CppEnum{symbol("ClipperLib::ClipType")}(3)

"""
Boolean (clipping) operations are mostly applied to two sets of Polygons,
represented in this library as subject and clip polygons. Whenever Polygons are
added to the Clipper object, they must be assigned to either subject or clip
polygons.

UNION operations can be performed on one set or both sets of polygons, but all
other boolean operations require both sets of polygons to derive meaningful
solutions.

## Notes

[Original Page](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/PolyType.htm)
"""
const ptSubject = CppEnum{symbol("ClipperLib::PolyType")}(0)
const ptClip = CppEnum{symbol("ClipperLib::PolyType")}(1)

"""
 The AbstractEndType has 5 decendent options:

- ClosedPolygon: Ends are joined using the JoinType value and the path filled as
  a polygon
- ClosedLine: Ends are joined using the JoinType value and the path filled as a
  polyline
- OpenSquare: Ends are squared off and extended delta units
- OpenRound: Ends are rounded off and extended delta units
- OpenButt: Ends are squared off with no extension.
- OpenSingle: Offsets an open path in a single direction. Planned for a future 
  update.

Note: With etClosedPolygon and etClosedLine types, the path closure will be the
same regardless of whether or not the first and last vertices in the path match.

![](https://raw.githubusercontent.com/Voxel8/Clipper.jl/master/doc/img/endtypes.png?token=AB_WDL566awwi_dkT6kRkJFCbZvKb4Rrks5UrEQiwA%3D%3D)

## Notes

[Original Page](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/EndType.htm)
"""
const etClosedPolygon = CppEnum{symbol("ClipperLib::EndType")}(0)
const etClosedLine = CppEnum{symbol("ClipperLib::EndType")}(1)
const etOpenSquare = CppEnum{symbol("ClipperLib::EndType")}(2)
const etOpenRound = CppEnum{symbol("ClipperLib::EndType")}(3)
const etOpenButt = CppEnum{symbol("ClipperLib::EndType")}(4)


"""
Filling indicates those regions that are inside a closed path (ie 'filled' with
a brush color or pattern in a graphical display) and those regions that are
outside. The Clipper Library supports 4 filling rules:

 - Even-Odd (pftEvenOdd)
 - Non-Zero (pftNonZero)
 - Positive (pftPositive)
 - Negative (pftNegative)

The simplest filling rule is Even-Odd filling (sometimes called alternate
filling). Given a group of closed paths start from a point outside the paths and
progress along an imaginary line through the paths. When the first path is
crossed the encountered region is filled. When the next path is crossed the
encountered region is not filled. Likewise, each time a path is crossed,
filling starts if it had stopped and stops if it had started.

With the exception of Even-Odd filling, all other filling rules rely on edge
direction and winding numbers to determine filling. Edge direction is determined
by the order in which vertices are declared when constructing a path. Edge
direction is used to determine the winding number of each polygon subregion.

The winding number for each polygon sub-region can be derived by:

- 1. starting with a winding number of zero and
- 2. from a point (P1) that's outside all polygons, draw an imaginary line to a
     point that's inside a given sub-region (P2)
- 3. while traversing the line from P1 to P2, for each path that crosses the
     imaginary line from right to left increment the winding number, and for
     each path that crosses the line from left to right decrement the
     winding number.
- 4. Once you arrive at the given sub-region you have its winding number.

![](https://raw.githubusercontent.com/Voxel8/Clipper.jl/master/doc/img/filltype1.png?token=AB_WDBclxAG9YspoY7jrVWwbi8hWbQsFks5UrF1RwA%3D%3D)

**Even-Odd (Alternate):** Odd numbered sub-regions are filled, while even
numbered sub-regions are not.

**Non-Zero (Winding):** All non-zero sub-regions are filled.

**Positive:** All sub-regions with winding counts > 0 are filled.

**Negative:** All sub-regions with winding counts < 0 are filled.

Polygon regions are defined by one or more closed paths which may or may not
intersect. A single polygon region can be defined by a single non-intersecting
path or by multiple non-intersecting paths where there's typically an 'outer'
path and one or more inner 'hole' paths. Looking at the three shapes in the
image above, the middle shape consists of two concentric rectangles sharing the
same clockwise orientation. With even-odd filling, where orientation can be
disregarded, the inner rectangle would create a hole in the outer rectangular
polygon. There would be no hole with non-zero filling. In the concentric
rectangles on the right, where the inner rectangle is orientated opposite to the
outer, a hole will be rendered with either even-odd or non-zero filling. A
single path can also define multiple subregions if it self-intersects as in the
example of the 5 pointed star shape below.

![](https://raw.githubusercontent.com/Voxel8/Clipper.jl/master/doc/img/filltype2.png?token=AB_WDNxBT_EEomS1Nwuia1ZQgf3cNMw5ks5UrF2xwA%3D%3D)

By far the most widely used fill rules are Even-Odd (aka Alternate) and Non-Zero
(aka Winding). Most graphics rendering libraries (AGG, Android Graphics, Cairo,
GDI+, OpenGL, Quartz 2D etc) and vector graphics storage formats (SVG,
Postscript, Photoshop etc) support both these rules. However some libraries
(eg Java's Graphics2D) only support one fill rule. Android Graphics and OpenGL
are the only libraries (that I'm aware of) that support multiple filling rules.

It's useful to note that edge direction has no affect on a winding number's
odd-ness or even-ness. (This is why orientation is ignored when the Even-Odd
rule is employed.)

The direction of the Y-axis does affect polygon orientation and edge direction.
However, changing Y-axis orientation will only change the sign of winding
numbers, not their magnitudes, and has no effect on either Even-Odd or Non-Zero
filling.

## Notes

[Original Page](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/PolyFillType.htm)
"""
const pftEvenOdd = CppEnum{symbol("ClipperLib::PolyFillType")}(0)
const pftNonZero = CppEnum{symbol("ClipperLib::PolyFillType")}(1)
const pftPositive = CppEnum{symbol("ClipperLib::PolyFillType")}(2)
const pftNegative = CppEnum{symbol("ClipperLib::PolyFillType")}(3)


"""

![](https://raw.githubusercontent.com/Voxel8/Clipper.jl/master/doc/img/jointype.png?token=AB_WDFb-zfb5TvOlOHBOxoBYnfkZ4pRTks5UrGOgwA%3D%3D)

- **MiterJoin:** There's a necessary limit to mitered joins since offsetting
  edges that join at very acute angles will produce excessively long and narrow
  'spikes'. Offset's MiterLimit property specifies a maximum distance that
  vertices will be offset (in multiples of delta). For any given edge join, when
  miter offsetting would exceed that maximum distance, 'square' joining is
  applied.
- **RoundJoin:** While flattened paths can never perfectly trace an arc, they
  are approximated by a series of arc chords (see ClipperObject's ArcTolerance
  property).
- **SquareJoin:** Squaring is applied uniformally at all convex edge joins at
  1 × delta.
"""
const jtSquare = CppEnum{symbol("ClipperLib::JoinType")}(0)
const jtRound = CppEnum{symbol("ClipperLib::JoinType")}(1)
const jtMiter = CppEnum{symbol("ClipperLib::JoinType")}(2)
