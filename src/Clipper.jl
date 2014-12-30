using Cxx
using Polygons
using ImmutableArrays


# The CPP source for clipper. It is put inside a cxx block so that we dont have
# and external dependencies. Likewise, the extra compilation time is negligable
# part of the total load time.
include("clipper_cpp.jl")

# C++ type aliases. Cxx.jl automatically handles the conversion between these
# three, so we can refer to these as the same thing through the type union.
typealias __ClipperIntPoint Union(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},
                                  CppRef{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},
                                  CppPtr{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)})

typealias __ClipperPath Union(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},
                              CppRef{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},
                              CppPtr{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)})


typealias __ClipperPaths Union(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},)},(false,false,false)})},(false,false,false)},
    CppRef{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},)},(false,false,false)})},(false,false,false)},
    CppPtr{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppTemplate{CppBaseType{symbol("std::vector")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},CppValue{CppTemplate{CppBaseType{symbol("std::allocator")},(CppValue{CppBaseType{symbol("ClipperLib::IntPoint")},(false,false,false)},)},(false,false,false)})},(false,false,false)},)},(false,false,false)})},(false,false,false)})

function IntPoint(x::Int64, y::Int64)
    @cxx ClipperLib::IntPoint(x, y)
end

function IntPoint(v::Vector2{Int64})
    @cxx ClipperLib::IntPoint(v[1], v[2])
end

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

function Paths(ct::Integer=0)
    @cxx ClipperLib::Paths(ct)
end

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

@doc """
This function returns the area of the supplied polygon. (It's assumed that the
path will be closed.) Depending on orientation, this value may be positive or
negative. If Orientation is true, then the area will be positive and
conversely, if Orientation is false, then the area will be negative.

# Notes
C++: http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/Area.htm
""" ->
function area(p::__ClipperPath)
    @cxx ClipperLib::Area(p)
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

function offset(p::__ClipperPath, dist::Real)
    new_p = Paths()
    co = @cxx ClipperLib::ClipperOffset()
    jt = @cxx ClipperLib::jtRound
    et = @cxx ClipperLib::etClosedPolygon
    @cxx co->AddPath(p, jt, et);
    @cxx co->Execute(new_p, dist);
    return new_p
end

@doc """
Reverses the vertex order (and hence orientation) in the specified path or paths.

# Parameters
p
    The path or paths to reverse

# Notes
C++: http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/ReversePath.htm
""" ->
function Base.reverse!(p::__ClipperPath)
    @cxx ClipperLib::ReversePath(p)
end
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

# Notes
C++: http://www.angusj.com/delphi/clipper/documentation/Docs/Units/ClipperLib/Functions/CleanPolygon.htm
""" ->
function clean!(p::__ClipperPath, distance = 1.415)
    @cxx ClipperLib::CleanPolygon(p, distance)
end
function clean!(p::__ClipperPaths, distance = 1.415)
    @cxx ClipperLib::CleanPolygons(p, distance)
end

