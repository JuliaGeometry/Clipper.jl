using Cxx

#
# The CPP source for clipper. It is put inside a cxx block so that we dont have
# and external dependencies. Likewise, the extra compilation time is negligable
# part of the total load time.
#

include("clipper_cpp.jl")
include("clipper_enums.jl")

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
