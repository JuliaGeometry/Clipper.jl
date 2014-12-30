using Cxx
using Polygons
using ImmutableArrays

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

#
# Clipper Flags. In C++ these are enums, but here we use abstract types so we
# always get specialized code.
#

@doc """
Boolean (clipping) operations are mostly applied to two sets of Polygons,
represented in this library as subject and clip polygons. Whenever Polygons are
added to the Clipper object, they must be assigned to either subject or clip
polygons.

UNION operations can be performed on one set or both sets of polygons, but all
other boolean operations require both sets of polygons to derive meaningful
solutions.

## Notes
- [C++](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/PolyType.htm)
""" ->
abstract AbstractPolyType
type SubjectPoly <: AbstractPolyType end
type ClipPoly <: AbstractPolyType end

@doc """
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
- [C++](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/EndType.htm)
""" ->
abstract AbstractEndType
type ClosedPolygon <: AbstractEndType end
type ClosedLine <: AbstractEndType end
type OpenSquare <: AbstractEndType end
type OpenRound <: AbstractEndType end
type OpenButt <: AbstractEndType end


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
- [C++](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/IntPoint.htm)
""" ->
function IntPoint(x::Int64, y::Int64)
    @cxx ClipperLib::IntPoint(x, y)
end

function IntPoint(v::Vector2{Int64})
    @cxx ClipperLib::IntPoint(v[1], v[2])
end

@doc """
This structure contains a sequence of IntPoint vertices defining a single
contour (see also terminology). Paths may be open and represent a series of line
segments bounded by 2 or more vertices, or they may be closed and represent
polygons. Whether or not a path is open depends on context. Closed paths may be
'outer' contours or 'hole' contours. Which they are depends on orientation.

Multiple paths can be grouped into a Paths structure.
## Notes
- [C++](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/Path.htm)

""" ->
function Path(ct::Integer=0)
    @cxx ClipperLib::Path(ct)
end

function Path(poly::Polygon{Vertex{Vector2{Int64}}})
    n = length(poly.vertices)
    p = Path()
    @cxx p->reserve(n)
    for vert in poly.vertices
        push!(p, IntPoint(vert.location))
    end
    return p
end

@doc """
This structure is fundamental to the Clipper Library. It's a list or array of
one or more Path structures. (The Path structure contains an ordered list of
vertices that make a single contour.)

Paths may open (a series of line segments), or they may closed (polygons).
Whether or not a path is open depends on context. Closed paths may be 'outer'
contours or 'hole' contours. Which they are depends on orientation.

## Notes
- [C++](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Types/Paths.htm)
""" ->
function Paths(ct::Integer=0)
    @cxx ClipperLib::Paths(ct)
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
- [C++](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/Area.htm)
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
- [C++](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/ReversePath.htm)
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
- [C++](http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/CleanPolygon.htm)
""" ->
function clean!(p::__ClipperPath, distance = 1.415)
    @cxx ClipperLib::CleanPolygon(p, distance)
end
function clean!(p::__ClipperPaths, distance = 1.415)
    @cxx ClipperLib::CleanPolygons(p, distance)
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
