using Cxx
using Polygons
using ImmutableArrays

include("clipper_cpp.jl")

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
