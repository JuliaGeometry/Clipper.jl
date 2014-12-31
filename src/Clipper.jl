using Cxx

#
# The CPP source for clipper. It is put inside a cxx block so that we dont have
# and external dependencies. Likewise, the extra compilation time is negligable
# part of the total load time.
#

include("clipper_cpp.jl")

#
# C++ type aliases. Cxx.jl automatically handles the conversion between these
# three, so we can refer to these as the same thing through the type union.
#

typealias __ClipperIntPoint Union(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},
                                  CppRef{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},
                                  CppPtr{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)})

typealias __ClipperPath Union(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},
                              CppRef{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},
                              CppPtr{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)})


typealias __ClipperPaths Union(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},)},(false,false,false)})},(false,false,false)},
    CppRef{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},)},(false,false,false)})},(false,false,false)},
    CppPtr{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},)},(false,false,false)})},(false,false,false)})

typealias __ClipperClip Union(CppValue{CppBaseType{symbol("ClipperLib::Clipper")},(false,false,false)},
                                CppRef{CppBaseType{symbol("ClipperLib::Clipper")},(false,false,false)},
                                CppPtr{CppBaseType{symbol("ClipperLib::Clipper")},(false,false,false)})

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

#
# Clipper Types
#

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

#
# Clipper Classes
#

function Clip(enum::CppEnum{symbol("ClipperLib::InitOptions")} = CppEnum{symbol("ClipperLib::InitOptions")}(0))
    @cxx ClipperLib::Clipper(enum)
end

@doc """
By default, when three or more vertices are collinear in input polygons (subject
or clip), the Clipper object removes the 'inner' vertices before clipping. When
enabled the PreserveCollinear property prevents this default behavior to allow
these inner vertices to appear in the solution.
""" ->
function preserve_collinear(clip::__ClipperClip, val::Bool)
    @cxx clip->PreserveCollinear(val)
end

@doc """
When this property is set to true, polygons returned in the solution parameter
of the Execute() method will have orientations opposite to their normal
orientations.
""" ->
function reverse_solution(clip::__ClipperClip, val::Bool)
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
function strictly_simple(clip::__ClipperClip, val::Bool)
    @cxx clip->StrictlySimple(val)
end

@doc """
The Clear method removes any existing subject and clip polygons allowing the
Clipper object to be reused for clipping operations on different polygon sets.
""" ->
function clear(clip::__ClipperClip)
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
function add(clip::__ClipperClip, ppg::__ClipperPaths, pt::CppEnum{symbol("ClipperLib::PolyType")}, closed::Bool)
    @cxx clip->AddPaths(ppg, pt, closed)
end

function add(clip::__ClipperClip, pg::__ClipperPath, pt::CppEnum{symbol("ClipperLib::PolyType")}, closed::Bool)
    @cxx clip->AddPath(pg, pt, closed)
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

@doc """
This method returns the axis-aligned bounding rectangle of all polygons that
have been added to the Clipper object.
""" ->
function IntRect(clip::__ClipperClip)
    @cxx clip->GetBounds()
end

#
# Clipper Functions
#

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
function simplify!(p::__ClipperPaths, t::CppEnum{symbol("ClipperLib::PolyFillType")})
    @cxx ClipperLib::SimplifyPolygons(p, t)
end


function offset(p::__ClipperPath, dist::Real)
    new_p = Paths()
    co = @cxx ClipperLib::ClipperOffset()
    jt = @cxx ClipperLib::jtRound
    et = @cxx ClipperLib::etClosedPolygon
    @cxx co->AddPath(p, jt, et);
    @cxx co->Execute(new_p, dist);
    return new_p
end

#
# Some "julian" encapsulation of Clipper types.
#

function Base.push!(a::__ClipperPath,
               b::__ClipperIntPoint)
    @cxx a->push_back(b)
end

function Base.push!(a::__ClipperPaths,
               b::__ClipperPath)
    @cxx a->push_back(b)
end

function Base.length(p::__ClipperPath)
    @cxx p->size()
end

function Base.length(p::__ClipperPaths)
    @cxx p->size()
end

function Base.getindex(p::__ClipperPath, i::Integer)
    @cxx p->at(i-1)
end

function Base.getindex(p::__ClipperPaths, i::Integer)
    @cxx p->at(i-1)
end

function Base.show(io::IO, v::__ClipperIntPoint)
    x = @cxx v->X
    y = @cxx v->Y
    print(io, string("(", x,",", y,")"))
end

function Base.show(io::IO, p::__ClipperPath)
    n = length(p)
    print(io, "Path => [")
    for i = 1:n
        show(io, p[i])
        n > 1 && i < n && print(io, ",")
    end
    print(io, "]")
end

function Base.show(io::IO, p::__ClipperPath)
    n = length(p)
    print(io, "Path => [")
    for i = 1:n
        show(io, p[i])
        n > 1 && i < n && print(io, ",")
    end
    print(io, "]")
end

function Base.show(io::IO, p::__ClipperPaths)
    n = length(p)
    print(io, "Paths => [")
    for i = 1:n
        show(io, p[i])
        n > 1 && i < n && println(io, ",")
    end
    print(io, "]")
end
