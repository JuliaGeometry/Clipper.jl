module Clipper

import Base: start, next, done

using Cxx

# Export Clipper types
export Path, Paths, IntPoint

# Export Clipper Classes and Methods
export Clip, preserve_collinear!, reverse_solution!, strictly_simple!, clear!,
       add!, IntRect, PolyTree, child_count, children, is_hole, is_open, Offset,
       arc_tolerance, arc_tolerance!, miter_limit, miter_limit!, execute!, area,
       clean!, isinside, orientation, simplify!, closed_paths, open_paths,
       minkowski_diff, minkowski_sum, left, right, top, bottom, left!, right!,
       top!, bottom!

# enum exports
export ioReverseSolution, ioStrictlySimple, ioPreserveCollinear

export ctIntersection, ctUnion, ctDifference, ctXor

export ptSubject, ptClip

export etClosedPolygon, etClosedLine, etOpenSquare, etOpenRound, etOpenButt

export pftEvenOdd, pftNonZero, pftPositive, pftNegative

export jtSquare, jtRound, jtMiter

# The CPP source for clipper. It is put inside a cxx block so that we dont have
# any external dependencies. Likewise, the extra compilation time is negligable
# part of the total load time.
include("clipper_cpp.jl")

###############################################################################
## C++ type aliases. Cxx.jl automatically handles the conversion between these
## three, so we can refer to these as the same thing through the type union.
###############################################################################

typealias __ClipperIntPoint Union(pcpp"ClipperLib::IntPoint",
                                  cpcpp"ClipperLib::IntPoint",
                                  vcpp"ClipperLib::IntPoint",
                                  rcpp"ClipperLib::IntPoint")

# TODO: Remove this when https://github.com/Keno/Cxx.jl/issues/72 is closed
typealias __ClipperPath Union(
    cxxt"ClipperLib::Path",
    cxxt"ClipperLib::Path&",
    cxxt"ClipperLib::Path*"
    )

typealias __ClipperPaths Union(
    cxxt"ClipperLib::Paths",
    cxxt"ClipperLib::Paths&",
    cxxt"ClipperLib::Paths*"
    )

typealias __ClipperClipperBase Union(pcpp"ClipperLib::ClipperBase",
                                  cpcpp"ClipperLib::ClipperBase",
                                  vcpp"ClipperLib::ClipperBase",
                                  rcpp"ClipperLib::ClipperBase")

typealias __ClipperClipper Union(pcpp"ClipperLib::Clipper",
                                  cpcpp"ClipperLib::Clipper",
                                  vcpp"ClipperLib::Clipper",
                                  rcpp"ClipperLib::Clipper")

typealias __ClipperPolyTree Union(pcpp"ClipperLib::PolyTree",
                                  cpcpp"ClipperLib::PolyTree",
                                  vcpp"ClipperLib::PolyTree",
                                  rcpp"ClipperLib::PolyTree")

typealias __ClipperPolyNode Union(pcpp"ClipperLib::PolyNode",
                                  cpcpp"ClipperLib::PolyNode",
                                  vcpp"ClipperLib::PolyNode",
                                  rcpp"ClipperLib::PolyNode")

typealias __ClipperPolyNodeArray Union(
    cxxt"ClipperLib::PolyNodes",
    cxxt"ClipperLib::PolyNodes&",
    cxxt"ClipperLib::PolyNodes*"
    )


typealias __ClipperClipperOffset Union(pcpp"ClipperLib::ClipperOffset",
                                  cpcpp"ClipperLib::ClipperOffset",
                                  vcpp"ClipperLib::ClipperOffset",
                                  rcpp"ClipperLib::ClipperOffset")

typealias __ClipperIntRect Union(pcpp"ClipperLib::IntRect",
                                  cpcpp"ClipperLib::IntRect",
                                  vcpp"ClipperLib::IntRect",
                                  rcpp"ClipperLib::IntRect")

###############################################################################
## Clipper Enums
###############################################################################

const ioReverseSolution = Cxx.CppEnum{symbol("ClipperLib::InitOptions")}(1)
const ioStrictlySimple = Cxx.CppEnum{symbol("ClipperLib::InitOptions")}(2)
const ioPreserveCollinear = Cxx.CppEnum{symbol("ClipperLib::InitOptions")}(4)


const ctIntersection = Cxx.CppEnum{symbol("ClipperLib::ClipType")}(0)
const ctUnion = Cxx.CppEnum{symbol("ClipperLib::ClipType")}(1)
const ctDifference = Cxx.CppEnum{symbol("ClipperLib::ClipType")}(2)
const ctXor = Cxx.CppEnum{symbol("ClipperLib::ClipType")}(3)

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
const ptSubject = Cxx.CppEnum{symbol("ClipperLib::PolyType")}(0)
const ptClip = Cxx.CppEnum{symbol("ClipperLib::PolyType")}(1)

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
const etClosedPolygon = Cxx.CppEnum{symbol("ClipperLib::EndType")}(0)
const etClosedLine = Cxx.CppEnum{symbol("ClipperLib::EndType")}(1)
const etOpenSquare = Cxx.CppEnum{symbol("ClipperLib::EndType")}(2)
const etOpenRound = Cxx.CppEnum{symbol("ClipperLib::EndType")}(3)
const etOpenButt = Cxx.CppEnum{symbol("ClipperLib::EndType")}(4)


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
const pftEvenOdd = Cxx.CppEnum{symbol("ClipperLib::PolyFillType")}(0)
const pftNonZero = Cxx.CppEnum{symbol("ClipperLib::PolyFillType")}(1)
const pftPositive = Cxx.CppEnum{symbol("ClipperLib::PolyFillType")}(2)
const pftNegative = Cxx.CppEnum{symbol("ClipperLib::PolyFillType")}(3)


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
const jtSquare = Cxx.CppEnum{symbol("ClipperLib::JoinType")}(0)
const jtRound = Cxx.CppEnum{symbol("ClipperLib::JoinType")}(1)
const jtMiter = Cxx.CppEnum{symbol("ClipperLib::JoinType")}(2)

###############################################################################
## Clipper Types
###############################################################################

## IntPoint  ##################################################################

@doc """
The IntPoint structure is used to represent all vertices in the Clipper Library.
An integer storage type has been deliberately chosen to preserve numerical
robustness. (Early versions of the library used floating point coordinates,
but it became apparent that floating point imprecision would always cause
occasional errors.)

A sequence of IntPoints are contained within a Path structure to represent a
single contour.

Users wishing to clip or offset polygons containing floating point coordinates
need to use appropriate scaling when converting these values to and from
IntPoints.

See also the notes on [rounding](http://www.angusj.com/delphi/clipper/documentation/Docs/Overview/Rounding.htm).

## Notes

[Original Page](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/IntPoint.htm)
""" ->
function IntPoint(x::Int64, y::Int64)
    @cxx ClipperLib::IntPoint(x, y)
end

@inline function x(ip::__ClipperIntPoint)
    @cxx ip->X
end

@inline function y(ip::__ClipperIntPoint)
    @cxx ip->Y
end

## Path  ######################################################################

@doc """
This structure contains a sequence of IntPoint vertices defining a single
contour (see also terminology). Paths may be open and represent a series of line
segments bounded by 2 or more vertices, or they may be closed and represent
polygons. Whether or not a path is open depends on context. Closed paths may be
'outer' contours or 'hole' contours. Which they are depends on orientation.

Multiple paths can be grouped into a Paths structure.

## Notes

[Original Page](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/Path.htm)

""" ->
function Path(ct::Integer=0)
    @cxx ClipperLib::Path(ct)
end

@doc """
This function builds a Path structure from a Vector of Tuples.
""" ->
function Path(pts::Vector{Tuple{Int, Int}})
    p = Path()
    for point in pts
        push!(p, IntPoint(point...))
    end
    p
end

## Paths  #####################################################################

@doc """
This structure is fundamental to the Clipper Library. It's a list or array of
one or more Path structures. (The Path structure contains an ordered list of
vertices that make a single contour.)

Paths may open (a series of line segments), or they may closed (polygons).
Whether or not a path is open depends on context. Closed paths may be 'outer'
contours or 'hole' contours. Which they are depends on orientation.

## Notes

[Original Page](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/Paths.htm)
""" ->
function Paths(ct::Integer=0)
    @cxx ClipperLib::Paths(ct)
end

@doc """
This function builds a Paths structure from a Vector of Path objects.
""" ->
function Paths{T<:__ClipperPath}(paths::Vector{T})
    pths = Paths()
    for path in paths
        push!(pths, path)
    end
    pths
end

@doc """
This function converts a PolyTree structure into a Paths structure.
""" ->
function Paths(pt::__ClipperPolyTree)
    paths = Paths()
    @cxx ClipperLib::PolyTreeToPaths(pt, paths)
    return paths
end

###############################################################################
## Clipper Classes
###############################################################################

## Clip  ######################################################################

function Clip(enum::Cxx.CppEnum{symbol("ClipperLib::InitOptions")} = Cxx.CppEnum{symbol("ClipperLib::InitOptions")}(0))
    @cxx ClipperLib::Clipper(enum)
end

@doc """
By default, when three or more vertices are collinear in input polygons (subject
or clip), the Clipper object removes the 'inner' vertices before clipping. When
enabled the PreserveCollinear property prevents this default behavior to allow
these inner vertices to appear in the solution.
""" ->
function preserve_collinear!(clip::__ClipperClipper, val::Bool)
    @cxx clip->PreserveCollinear(val)
end

@doc """
When this property is set to true, polygons returned in the solution parameter
of the Execute() method will have orientations opposite to their normal
orientations.
""" ->
function reverse_solution!(clip::__ClipperClipper, val::Bool)
    @cxx clip->ReverseSolution(val)
end

@doc """
Terminology:

- A simple polygon is one that does not self-intersect.
- A weakly simple polygon is a simple polygon that contains 'touching' vertices,
  or 'touching' edges.
- A strictly simple polygon is a simple polygon that does not contain 'touching'
  vertices, or 'touching' edges.

Vertices 'touch' if they share the same coordinates (and are not adjacent). An
edge touches another if one of its end vertices touches another edge excluding
its adjacent edges, or if they are co-linear and overlapping (including adjacent
edges).

Polygons returned by clipping operations (see Clipper.Execute()) should always
be simple polygons. When the StrictlySimply property is enabled, polygons
returned will be strictly simple, otherwise they may be weakly simple. It's
computationally expensive ensuring polygons are strictly simple and so this
property is disabled by default.

Note: There's currently no guarantee that polygons will be strictly simple since
'simplifying' is still a work in progress.


See also the article on Simple Polygons on Wikipedia.
""" ->
function strictly_simple!(clip::__ClipperClipper, val::Bool)
    @cxx clip->StrictlySimple(val)
end

@doc """
The Clear method removes any existing subject and clip polygons allowing the
Clipper object to be reused for clipping operations on different polygon sets.
""" ->
function clear!(clip::__ClipperClipper)
    @cxx clip->Clear()
end

@doc """
Any number of subject and clip paths can be added to a clipping task, either
individually via the AddPath() method, or as groups via the AddPaths() method,
or even using both methods.

'Subject' paths may be either open (lines) or closed (polygons) or even a
mixture of both, but 'clipping' paths must always be closed. Clipper allows
polygons to clip both lines and other polygons, but doesn't allow lines to clip
either lines or polygons.

With closed paths, orientation should conform with the filling rule that will be
passed via Clippper's Execute method.

Path Coordinate range:
Path coordinates must be between ± 0x3FFFFFFFFFFFFFFF (± 4.6e+18), otherwise a
range error will be thrown when attempting to add the path to the Clipper
object. If coordinates can be kept between ± 0x3FFFFFFF (± 1.0e+9), a modest
increase in performance (approx. 15-20%) over the larger range can be achieved
by avoiding large integer math. If the preprocessor directive use_int32 is
defined (allowing a further increase in performance of 20-30%), then the maximum
range is restricted to ± 32,767.

Return Value:
The function will return false if the path is invalid for clipping. A path is
invalid for clipping when:

- it has less than 2 vertices
- it has 2 vertices but is not an open path
0 the vertices are all co-linear and it is not an open path
""" ->
function add!(clip::__ClipperClipper, ppg::__ClipperPaths, pt::Cxx.CppEnum{symbol("ClipperLib::PolyType")}, closed::Bool)
    @cxx clip->AddPaths(ppg, pt, closed)
end

function add!(clip::__ClipperClipper, pg::__ClipperPath, pt::Cxx.CppEnum{symbol("ClipperLib::PolyType")}, closed::Bool)
    @cxx clip->AddPath(pg, pt, closed)
end

function execute!(c::__ClipperClipper, ty::Cxx.CppEnum{symbol("ClipperLib::ClipType")}, sol::__ClipperPaths, sft::Cxx.CppEnum{symbol("ClipperLib::PolyFillType")}=pftEvenOdd, cft::Cxx.CppEnum{symbol("ClipperLib::PolyFillType")}=pftEvenOdd)
    @cxx c->Execute(ty, sol, sft, cft)
end

function execute!(c::__ClipperClipper, ty::Cxx.CppEnum{symbol("ClipperLib::ClipType")}, sol::__ClipperPolyTree, sft::Cxx.CppEnum{symbol("ClipperLib::PolyFillType")}=pftEvenOdd, cft::Cxx.CppEnum{symbol("ClipperLib::PolyFillType")}=pftEvenOdd)
    @cxx c->Execute(ty, sol, sft, cft)
end


# TODO:
#C++ »
#bool Execute(ClipType clipType,
#  Paths &solution,
#  PolyFillType subjFillType = pftEvenOdd,
#  PolyFillType clipFillType = pftEvenOdd);

#bool Execute(ClipType clipType,
#  PolyTree &solution,
#  PolyFillType subjFillType = pftEvenOdd,
#  PolyFillType clipFillType = pftEvenOdd);

## IntRect  ###################################################################

@doc """
This method returns the axis-aligned bounding rectangle of all polygons that
have been added to the Clipper object.
""" ->
function IntRect(clip::__ClipperClipper)
    @cxx clip->GetBounds()
end

function left(r::__ClipperIntRect)
    @cxx r->left
end

function top(r::__ClipperIntRect)
    @cxx r->top
end

function right(r::__ClipperIntRect)
    @cxx r->right
end

function bottom(r::__ClipperIntRect)
    @cxx r->bottom
end

function left!(r::__ClipperIntRect, v::Integer)
    icxx"$r.left = $v;"
end

function top!(r::__ClipperIntRect, v::Integer)
    icxx"$r.top = $v;"
end

function right!(r::__ClipperIntRect, v::Integer)
    icxx"$r.right = $v;"
end

function bottom!(r::__ClipperIntRect, v::Integer)
    icxx"$r.bottom = $v;"
end

## PolyTree  ##################################################################

function PolyTree()
    @cxx ClipperLib::PolyTree()
end

@doc """
This method clears any PolyNode children contained by PolyTree the object.

Clear does not need to be called explicitly. The Clipper.Execute method that
accepts a PolyTree parameter will automatically clear the PolyTree object before
propagating it with new PolyNodes. Likewise, PolyTree's destructor will also
automatically clear any contained PolyNodes.
""" ->
function clear!(c::__ClipperPolyTree)
    @cxx c->Clear()
end

@doc """
This method returns the first outer polygon contour if any, otherwise a null
pointer.

This function is almost equivalent to calling Childs[0] except that when a
PolyTree object is empty (has no children), calling Childs[0] would raise an out
of range exception.
""" ->
function Base.first(c::__ClipperPolyTree)
    @cxx c->GetFirst()
end

@doc """
Returns the total number of PolyNodes (polygons) contained within the PolyTree.
This value is not to be confused with ChildCount which returns the number of
immediate children only (Childs) contained by PolyTree.
""" ->
function Base.length(c::__ClipperPolyTree)
    @cxx c->Total()
end

function child_count(c::__ClipperPolyTree)
    @cxx c->ChildCount()
end

## PolyNode  ##################################################################

@doc """
The returned Polynode will be the first child if any, otherwise the next
sibling, otherwise the next sibling of the Parent etc.

A PolyTree can be traversed very easily by calling GetFirst() followed by
GetNext() in a loop until the returned object is a null pointer ...
""" ->
function Base.next(c::__ClipperPolyNode)
    @cxx c->GetNext()
end

@doc """
Returns a path list which contains any number of vertices.
""" ->
function Path(c::__ClipperPolyNode)
    @cxx c->Contour
end

@doc """
Returns the number of PolyNode Childs directly owned by the PolyNode object.
""" ->
function child_count(c::__ClipperPolyNode)
    @cxx c->ChildCount()
end

@doc """
A read-only list of PolyNode.
Outer PolyNode childs contain hole PolyNodes, and hole PolyNode childs contain
nested outer PolyNodes.
""" ->
function children(c::__ClipperPolyNode)
    @cxx c->Childs
end

@doc """
Returns true when the PolyNode's polygon (Contour) is a hole.

Children of outer polygons are always holes, and children of holes are always
(nested) outer polygons.
The IsHole property of a PolyTree object is undefined but its children are
always top-level outer polygons.
""" ->
function is_hole(c::__ClipperPolyNode)
    @cxx c->IsHole()
end

@doc """
Returns true when the PolyNode's Contour results from a clipping operation on an
open contour (path). Only top-level PolyNodes can contain open contours.
""" ->
function is_open(c::__ClipperPolyNode)
    @cxx c->IsOpen()
end

@doc """
Returns the parent PolyNode.

The PolyTree object (which is also a PolyNode) does not have a parent and will
return a null pointer.
""" ->
function Base.parent(c::__ClipperPolyNode)
    @cxx c->Parent
end

## Offset  ####################################################################

@doc """
The ClipperOffset constructor takes 2 optional parameters: MiterLimit and
ArcTolerance. Thes two parameters corresponds to properties of the same name.
MiterLimit is only relevant when JoinType is jtMiter, and ArcTolerance is only
relevant when JoinType is jtRound or when EndType is etOpenRound.
""" ->
function Offset(miterLimit = 2.0, roundPrecision = 0.25)
    @cxx ClipperLib::ClipperOffset(miterLimit, roundPrecision)
end


@doc """
 Firstly, this field/property is only relevant when JoinType = jtRound and/or
 EndType = etRound.

Since flattened paths can never perfectly represent arcs, this field/property
specifies a maximum acceptable imprecision ('tolerance') when arcs are
approximated in an offsetting operation. Smaller values will increase
'smoothness' up to a point though at a cost of performance and in creating more
vertices to construct the arc.

The default ArcTolerance is 0.25 units. This means that the maximum distance the
flattened path will deviate from the 'true' arc will be no more than 0.25 units
(before rounding).

Reducing tolerances below 0.25 will not improve smoothness since vertex
coordinates will still be rounded to integer values. The only way to achieve
sub-integer precision is through coordinate scaling before and after offsetting
(see example below).

It's important to make ArcTolerance a sensible fraction of the offset delta
(arc radius). Large tolerances relative to the offset delta will produce poor
arc approximations but, just as importantly, very small tolerances will
substantially slow offsetting performance while providing unnecessary degrees of
precision. This is most likely to be an issue when offsetting polygons whose
coordinates have been scaled to preserve floating point precision.

Example: Imagine a set of polygons (defined in floating point coordinates) that
is to be offset by 10 units using round joins, and the solution is to retain
floating point precision up to at least 6 decimal places.

To preserve this degree of floating point precision, and given that Clipper and
ClipperOffset both operate on integer coordinates, the polygon coordinates will
be scaled up by 108 (and rounded to integers) prior to offsetting. Both offset
delta and ArcTolerance will also need to be scaled by this same factor. If
ArcTolerance was left unscaled at the default 0.25 units, every arc in the
solution would contain a fraction of 44 THOUSAND vertices while the final arc
imprecision would be 0.25 × 10-8 units (ie once scaling was reversed). However,
if 0.1 units was an acceptable imprecision in the final unscaled solution, then
ArcTolerance should be set to 0.1 × scaling_factor (0.1 × 108 ). Now if scaling
is applied equally to both ArcTolerance and to Delta Offset, then in this
example the number of vertices (steps) defining each arc would be a fraction of
23.

The formula for the number of steps in a full circular arc is ...
Pi / acos(1 - arc_tolerance / abs(delta)) 
""" ->
function arc_tolerance(o::__ClipperClipperOffset)
    @cxx o->ArcTolerance
end

function arc_tolerance!(o::__ClipperClipperOffset, v::Float64)
    icxx"$o.ArcTolerance = $v;"
end

function miter_limit(o::__ClipperClipperOffset)
    @cxx o->MiterLimit
end

function miter_limit!(o::__ClipperClipperOffset, v::Float64)
    icxx"$o.MiterLimit = $v;"
end

@doc """
This method clears all paths from the ClipperOffset object, allowing new paths
to be assigned.
""" ->
function clear!(c::__ClipperClipperOffset)
    @cxx c->Clear()
end


@doc """
Adds a Path to a ClipperOffset object in preparation for offsetting.

Any number of paths can be added, and each has its own JoinType and EndType. All 'outer' Paths must have the same orientation, and any 'hole' paths must have reverse orientation. Closed paths must have at least 3 vertices. Open paths may have as few as one vertex. Open paths can only be offset with positive deltas.
""" ->
function add!(c::__ClipperClipperOffset, path::__ClipperPath, jt::Cxx.CppEnum{symbol("ClipperLib::JoinType")}, et::Cxx.CppEnum{symbol("ClipperLib::EndType")})
    @cxx c->AddPath(path, jt, et)
end

function add!(c::__ClipperClipperOffset, paths::__ClipperPaths, jt::Cxx.CppEnum{symbol("ClipperLib::JoinType")}, et::Cxx.CppEnum{symbol("ClipperLib::EndType")})
    @cxx c->AddPaths(paths, jt, et)
end


@doc """
This method takes two parameters. The first is the structure (either PolyTree or
Paths) that will receive the result of the offset operation. The second
parameter is the amount to which the supplied paths will be offset - negative
delta values to shrink polygons and positive delta to expand them.

This method can be called multiple times, offsetting the same paths by different
amounts (ie using different deltas).
""" ->
function execute!(c::__ClipperClipperOffset, sol::__ClipperPaths, delta)
    @cxx c->Execute(sol, delta)
end

function execute!(c::__ClipperClipperOffset, sol::__ClipperPolyTree, delta)
    @cxx c->Execute(sol, delta)
end


###############################################################################
## Clipper Functions
###############################################################################

@doc """
This function returns the area of the supplied polygon. (It's assumed that the
path will be closed.) Depending on orientation, this value may be positive or
negative. If Orientation is true, then the area will be positive and
conversely, if Orientation is false, then the area will be negative.

## Notes

[Original Page](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/Area.htm)
""" ->
function area(p::__ClipperPath)
    @cxx ClipperLib::Area(p)
end


@doc """
Reverses the vertex order (and hence orientation) in the specified path.

# Parameters
p
    The path to reverse

## Notes

[Original Page](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/ReversePath.htm)
""" ->
function Base.reverse!(p::__ClipperPath)
    @cxx ClipperLib::ReversePath(p)
end


@doc """
Reverses the vertex order (and hence orientation) in the specified paths.
""" ->
function Base.reverse!(p::__ClipperPaths)
    @cxx ClipperLib::ReversePaths(p)
end


@doc """
Removes vertices:

- that join co-linear edges, or join edges that are almost co-linear
  (such that if the vertex was moved no more than the specified distance
  the edges would be co-linear)
- that are within the specified distance of an adjacent vertex
- that are within the specified distance of a semi-adjacent vertex together
  with their out-lying vertices

Vertices are semi-adjacent when they are separated by a single (out-lying)
vertex.

The distance parameter's default value is approximately √2 so that a vertex will
be removed when adjacent or semi-adjacent vertices having their corresponding X
and Y coordinates differing by no more than 1 unit. (If the egdes are
semi-adjacent the out-lying vertex will be removed too.)

## Notes

[Original Page](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/CleanPolygon.htm)
""" ->
function clean!(p::__ClipperPath, distance = 1.415)
    @cxx ClipperLib::CleanPolygon(p, distance)
end

function clean!(p::__ClipperPaths, distance = 1.415)
    @cxx ClipperLib::CleanPolygons(p, distance)
end


@doc """
Returns 0 if false, -1 if pt is on poly and +1 if pt is in poly.

## Notes

[Original Page](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/PointInPolygon.htm)
""" ->
function isinside(pt::__ClipperIntPoint, poly::__ClipperPath)
    @cxx ClipperLib::PointInPolygon(pt, poly)
end


@doc """
Orientation is only important to closed paths. Given that vertices are declared
in a specific order, orientation refers to the direction (clockwise or
counter-clockwise) that these vertices progress around a closed path.

Orientation is also dependent on axis direction:
- On Y-axis positive upward displays, Orientation will return true if the
  polygon's orientation is counter-clockwise.
- On Y-axis positive downward displays, Orientation will return true if the
  polygon's orientation is clockwise.

![](https://raw.githubusercontent.com/Voxel8/Clipper.jl/master/doc/img/orientation.png?token=AB_WDHGa2pqOPQ7nTLGAGcMGMwGA3nzPks5UrFgMwA%3D%3D)

Notes:

- Self-intersecting polygons have indeterminate orientations in which case this
  function won't return a meaningful value.
- The majority of 2D graphic display libraries (eg GDI, GDI+, XLib, Cairo, AGG,
  Graphics32) and even the SVG file format have their coordinate origins at the
  top-left corner of their respective viewports with their Y axes increasing
  downward. However, some display libraries (eg Quartz, OpenGL) have their
  coordinate origins undefined or in the classic bottom-left position with
  their Y axes increasing upward.
- For Non-Zero filled polygons, the orientation of holes must be opposite that
  of outer polygons.
- For closed paths (polygons) in the solution returned by Clipper's Execute
  method, their orientations will always be true for outer polygons and false
  for hole polygons (unless the ReverseSolution property has been enabled).

## Notes

[Original Page](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/Orientation.htm)
""" ->
function orientation(p::__ClipperPath)
    @cxx ClipperLib::Orientation(p)
end


@doc """
Removes self-intersections from the supplied polygon (by performing a boolean
union operation using the nominated PolyFillType).
Polygons with non-contiguous duplicate vertices (ie 'touching') will be split
into two polygons.

Note: There's currently no guarantee that polygons will be strictly simple since
'simplifying' is still a work in progress.

![](https://raw.githubusercontent.com/Voxel8/Clipper.jl/master/doc/img/simplifypolygons.png?token=AB_WDGPhKj2xE6uaeVrSDKv3eNQx0hPSks5UrLNSwA%3D%3D)
"""->
function simplify!(p::__ClipperPaths, t::Cxx.CppEnum{symbol("ClipperLib::PolyFillType")})
    @cxx ClipperLib::SimplifyPolygons(p, t)
end


@doc """
This function filters out open paths from the PolyTree structure and returns
only closed paths in a Paths structure.
""" ->
function closed_paths(pt::__ClipperPolyTree)
    paths = Paths()
    @cxx ClipperLib::ClosedPathsFromPolyTree(pt, paths)
    return paths
end

@doc """
This function filters out closed paths from the PolyTree structure and returns
only open paths in a Paths structure.
""" ->
function open_paths(pt::__ClipperPolyTree)
    paths = Paths()
    @cxx ClipperLib::OpenPathsFromPolyTree(pt, paths)
    return paths
end

@doc """
Minkowski Difference is performed by subtracting each point in a polygon from
the set of points in an open or closed path. A key feature of Minkowski
Difference is that when it's applied to two polygons, the resulting polygon will
contain the coordinate space origin whenever the two polygons touch or overlap.
(This function is often used to determine when polygons collide.)
""" ->
function minkowski_diff(p1::__ClipperPath, p2::__ClipperPath)
    paths = Paths()
    @cxx MinkowskiDiff(p1, p2, paths)
    return paths
end

@doc """
Minkowski Addition is performed by adding each point in a polygon 'pattern' to
the set of points in an open or closed path. The resulting polygon (or polygons)
defines the region that the 'pattern' would pass over in moving from the
beginning to the end of the 'path'.
""" ->
function minkowski_sum(p1::__ClipperPath, p2::__ClipperPath, closed::Bool)
    paths = Paths()
    @cxx ClipperLib::MinkowskiSum(p1, p2, paths, closed)
    return paths
end

function minkowski_sum(p1::__ClipperPath, p2::__ClipperPaths, pft::Cxx.CppEnum{symbol("ClipperLib::PolyFillType")}, closed::Bool)
    paths = Paths()
    @cxx ClipperLib::MinkowskiSum(p1, p2, paths, pft, closed)
    return paths
end

###############################################################################
## Some "julian" encapsulation of Clipper types.
###############################################################################

## Comparison  ################################################################

@inline function ==(a::__ClipperPath, b::__ClipperPath)
    length(a) != length(b) && return false
    for i = 1:length(a)
        a[i] != b[i] && return false
    end
    return true
end

@inline function ==(i1::__ClipperIntPoint, i2::__ClipperIntPoint)
    x(i1) == x(i2) && y(i1) == y(i2)
end
@inline function Base.isequal(i1::__ClipperIntPoint, i2::__ClipperIntPoint)
    isequal(x(i1),x(i2)) && isequal(y(i1),y(i2))
end

## Array-like Interface  ######################################################

@inline function Base.push!(a::__ClipperPath,
               b::__ClipperIntPoint)
    @cxx a->push_back(b)
end

@inline function Base.push!(a::__ClipperPath, b::Tuple{Int, Int})
    push!(a, IntPoint(b...))
end

@inline function Base.push!(a::__ClipperPaths,
               b::__ClipperPath)
    @cxx a->push_back(b)
end

@inline function Base.length(p::__ClipperPath)
    @cxx p->size()
end

@inline function Base.length(p::__ClipperPaths)
    @cxx p->size()
end

@inline function Base.length(p::__ClipperPolyNodeArray)
    @cxx p->size()
end

@inline function Base.getindex(p::__ClipperPath, i::Integer)
    icxx"$p[$i-1];"
end

@inline function Base.getindex(p::__ClipperPaths, i::Integer)
    icxx"$p[$i-1];"
end

@inline function Base.getindex(p::__ClipperPolyNodeArray, i::Integer)
    # we dereference here because:
    # typedef std::vector< PolyNode* > PolyNodes;
    # gives us pointers to Polynodes
    icxx"*$p[$i-1];"
end

@inline function Base.setindex!(path::__ClipperPath, pt::__ClipperIntPoint, i::Integer)
    icxx"$path[$i-1] = $pt;"
end

@inline function Base.setindex!(paths::__ClipperPaths, path::__ClipperPath, i::Integer)
    icxx"$paths[$i-1] = $path;"
end

@inline function Base.isempty(p::__ClipperPath)
    length(p) == 0
end

@inline function Base.isempty(p::__ClipperPaths)
    length(p) == 0
end

@inline function Base.endof(p::__ClipperPath)
    length(p)
end

@inline function Base.endof(p::__ClipperPaths)
    length(p)
end

## Iteration Support  #########################################################

@inline Base.start(path::__ClipperPath) = 1
@inline Base.next(path::__ClipperPath, state) = path[state], state+1
@inline Base.done(path::__ClipperPath, state) = length(path) < state

## Show Function  #############################################################

function Base.show(io::IO, v::__ClipperIntPoint)
    print(io, string("(", x(v),",", y(v),")"))
end

function Base.show(io::IO, r::__ClipperIntRect)
    print(io, "left: $(left(r)) right: $(right(r)) top: $(top(r)) bottom: $(bottom(r))")
end

function Base.show(io::IO, p::__ClipperPath)
    if isempty(p)
        return
    end
    print(io, "Path([")
    for i = 1:length(p)-1
        print(io, string("(", x(p[i]), ",", y(p[i]), "), "))
    end
    print(io, string("(", x(p[end]), ",", y(p[end]), ")"))
    print(io, "])")
end

function Base.show(io::IO, p::__ClipperPaths)
    len = length(p)
    if len == 0
        print(io, "Paths()")
        return
    end
    print(io, "Paths([\n    ")
    for i = 1:len
        print(io, p[i])
        if i < len
            print(io, ",\n    ")
        end
    end
    print(io, "\n)")
end

function Base.show(io::IO, p::__ClipperPolyTree)
    node = first(p) # grab first PolyNode
    while node != C_NULL
        # only show top-level polys
        length(Path(parent(node))) == 0 && show(io, node)
        node = next(node)
    end
end

function Base.show(io::IO, p::__ClipperPolyNode, depth=0)
    indent = " "^(depth*2)
    ct = child_count(p)
    println(io, "$(indent)Path: $(Path(p))")
    println(io, "$(indent)is_hole: $(is_hole(p))")
    println(io, "$(indent)child_count: $(ct)")
    for i = 1:ct
        println(io, "$(indent)Children[$i]: ")
        child = children(p)[i]
        show(io, child, depth+1)
    end
end

# Clipper basic interface
include("Basic.jl")

end # module
