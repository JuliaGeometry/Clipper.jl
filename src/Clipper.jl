using Cxx
using Polygons
using ImmutableArrays

include("clipper_cpp.jl")

cxx"""
    #include <iostream>
"""

function IntPoint(v::Vector2{Int64})
    @cxx ClipperLib::IntPoint(v[1], v[2])
end

function Path(ct::Integer=1)
    @cxx ClipperLib::Path(ct)
end

function Base.push!(a::CppValue{symbol("std::vector"),(CppValue{symbol("ClipperLib::IntPoint"),()},CppValue{symbol("std::allocator"),(CppValue{symbol("ClipperLib::IntPoint"),()},)})},
               b::CppValue{symbol("ClipperLib::IntPoint"),()})
    @cxx a->push_back(b)
end

function Base.show(io::IO, v::CppValue{symbol("ClipperLib::IntPoint"),()})
    x = @cxx v->X
    y = @cxx v->Y
    print(io, string("(", x,",", y,")"))
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
