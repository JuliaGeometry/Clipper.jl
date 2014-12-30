using Cxx
using Polygons
using ImmutableArrays

include("clipper_cpp.jl")

typealias __ClipperIntPoint Union(CppValue{symbol("ClipperLib::IntPoint"),()},
                                  CppRef{symbol("ClipperLib::IntPoint"),()},
                                  CppPtr{symbol("ClipperLib::IntPoint"),()})

typealias __ClipperPath Union(CppValue{symbol("std::vector"),(CppValue{symbol("ClipperLib::IntPoint"),()},CppValue{symbol("std::allocator"),(CppValue{symbol("ClipperLib::IntPoint"),()},)})},
                              CppRef{symbol("std::vector"),(CppValue{symbol("ClipperLib::IntPoint"),()},CppValue{symbol("std::allocator"),(CppValue{symbol("ClipperLib::IntPoint"),()},)})},
                              CppPtr{symbol("std::vector"),(CppValue{symbol("ClipperLib::IntPoint"),()},CppValue{symbol("std::allocator"),(CppValue{symbol("ClipperLib::IntPoint"),()},)})})


function IntPoint(x::Int64, y::Int64)
    @cxx ClipperLib::IntPoint(x, y)
end

function IntPoint(v::Vector2{Int64})
    @cxx ClipperLib::IntPoint(v[1], v[2])
end

function Path(ct::Integer=0)
    @cxx ClipperLib::Path(ct)
end

function Paths(ct::Integer=0)
    @cxx ClipperLib::Paths(ct)
end

function Base.push!(a::__ClipperPath,
               b::__ClipperIntPoint)
    @cxx a->push_back(b)
end

function Base.length(p::__ClipperPath)
    @cxx p->size()
end

function Base.getindex(p::__ClipperPath, i::Integer)
    @cxx p->at(i-1)
end

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


function offset()
icxx"""
	
	//from clipper.hpp ...
	//typedef signed long long cInt;
	//struct IntPoint {cInt X; cInt Y;};
	//typedef std::vector<IntPoint> Path;
	//typedef std::vector<Path> Paths;
	
	ClipperLib::Paths subj(2), clip(1), solution;
	
	//define outer blue 'subject' polygon
	subj[0].reserve(4);
	subj[0] << 
	  ClipperLib::IntPoint(180,200) << ClipperLib::IntPoint(260,200) <<
	  ClipperLib::IntPoint(260,150) << ClipperLib::IntPoint(180,150);
	
	//define subject's inner triangular 'hole' (with reverse orientation)
	subj[1].reserve(3);
	subj[1] << 
	  ClipperLib::IntPoint(215,160) << ClipperLib::IntPoint(230,190)
	   << ClipperLib::IntPoint(200,190);
	
	//define orange 'clipping' polygon
	clip[0].reserve(4);
	clip[0] << 
	  ClipperLib::IntPoint(190,210) << ClipperLib::IntPoint(240,210) << 
	  ClipperLib::IntPoint(240,130) << ClipperLib::IntPoint(190,130);
	
	//perform intersection ...
	ClipperLib::Clipper c;
	c.AddPaths(subj, ClipperLib::ptSubject, true);
	c.AddPaths(clip, ClipperLib::ptClip, true);
	c.Execute(ClipperLib::ctIntersection, solution, ClipperLib::pftNonZero, ClipperLib::pftNonZero);
	std::cout << solution;
"""
end
