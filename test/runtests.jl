using Clipper
using Base.Test

# testing printing
a = Path()
b = IntPoint(1,0)
push!(a, b)
push!(a, b)
push!(a, b)
o = IOBuffer()
show(o, b)
@test ASCIIString(o.data) == "(1,0)"
o = IOBuffer()
show(o, a)
@test ASCIIString(o.data) == "Path([(1,0), (1,0), (1,0)])"

#test path constructor
p1 = Path()
push!(p1, IntPoint(0, 0))
push!(p1, IntPoint(0, 10))
push!(p1, IntPoint(10, 10))
p2 = Path([(0,0), (0,10), (10,10)])
@test p1 == p2

#test push shortcut
p = Path()
push!(p, (0, 0))
@test p == Path([(0,0)])

# test setindex
p = Path(2)
p[1] = IntPoint(1,1)
p[2] = IntPoint(2,2)
@test length(p) == 2
@test p[1] == IntPoint(1,1)
@test p[2] == IntPoint(2,2)

# test area
println("Testing area...")
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(1,0))
push!(p, IntPoint(1,1))
push!(p, IntPoint(0,1))
@test area(p) == 1.0

p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(0,1))
push!(p, IntPoint(1,1))
push!(p, IntPoint(1,0))
@test area(p) == -1.0

# test reverse
println("Testing reverse...")
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(1,0))
push!(p, IntPoint(1,1))
push!(p, IntPoint(0,1))
@test area(p) == 1.0
reverse!(p)
@test area(p) == -1.0

p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(0,1))
push!(p, IntPoint(1,1))
push!(p, IntPoint(1,0))
@test area(p) == -1.0
reverse!(p)
@test area(p) == 1.0

println("Testing clean...")
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(5,0))
push!(p, IntPoint(10,0))
push!(p, IntPoint(10,10))
push!(p, IntPoint(5,10))
push!(p, IntPoint(0,10))
@test length(p) == 6
clean!(p)
@test length(p) == 4

println("Testing isinside...")
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(0,2))
push!(p, IntPoint(2,2))
push!(p, IntPoint(2,0))
@test isinside(IntPoint(-1,-1), p) == 0
@test isinside(IntPoint(0,0), p) == -1
@test isinside(IntPoint(1,1), p) == 1
@test isinside(IntPoint(0,1), p) == -1
@test isinside(IntPoint(1,0), p) == -1

println("Testing orientation...")
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(0,2))
push!(p, IntPoint(2,2))
push!(p, IntPoint(2,0))
@test orientation(p) == false
reverse!(p)
@test orientation(p) == true

println("Testing simplify...")
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(0,2))
push!(p, IntPoint(2,2))
push!(p, IntPoint(2,0))
push!(p, IntPoint(1,3))
q = Paths()
push!(q,p)
simplify!(q, pftEvenOdd)
@test length(q) == 2
@test length(q[1]) == 3
@test length(q[2]) == 3

p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(0,2))
push!(p, IntPoint(2,2))
push!(p, IntPoint(2,0))


# testing offset
println("Testing Offset...")
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(100,0))
push!(p, IntPoint(100,100))
push!(p, IntPoint(0,100))
p2 = Path()
push!(p2, IntPoint(30,30))
push!(p2, IntPoint(30,70))
push!(p2, IntPoint(70,70))
push!(p2, IntPoint(70,30))
o = Offset()
paths = Paths()
push!(paths, p)
push!(paths, p2)
r1 = Paths()
r2 = PolyTree()
add!(o, paths, jtMiter, etClosedPolygon)
execute!(o, r1, 1)
execute!(o, r2, 1)
clear!(o)
# test printing
out = IOBuffer()
show(out, r2)
expected = "Path: Path([(101,101), (-1,101), (-1,-1), (101,-1)])\nis_hole: false\nchild_count: 1\nChildren[1]: \n  Path: Path([(31,31), (31,69), (69,69), (69,31)])\n  is_hole: true\n  child_count: 0\n"
@test ASCIIString(out.data) == expected
p1 = Paths(r2)
f = first(r2)
@test child_count(f) ==1
@test length(Path(f)) == 4

# paths
@test length(p1) == length(r1) == 2
p1 = p1[1]
r1 = r1[1]
# now just path
@test length(p1) == length(r1)
for i = 1:length(p1)
    @test p1[i] == r1[i]
end
@test arc_tolerance(o) == 0.25
# test changing the value
arc_tolerance!(o, 0.5)
@test arc_tolerance(o) == 0.5
@test miter_limit(o) == 2.0
miter_limit!(o, 4.0)
@test miter_limit(o) == 4.0

# test split event
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(100,0))
push!(p, IntPoint(100,100))
push!(p, IntPoint(0,100))
push!(p, IntPoint(100,50))
o = Offset()
r1 = PolyTree()
add!(o, p, jtMiter, etClosedPolygon)
execute!(o, r1, -1)
clear!(o)
@test length(r1) == 2

# Split event in hole case
p1 = Path()
push!(p1, IntPoint(0,0))
push!(p1, IntPoint(100,0))
push!(p1, IntPoint(100,100))
push!(p1, IntPoint(0,100))
p2 = Path()
push!(p2, IntPoint(30,30))
push!(p2, IntPoint(30,70))
push!(p2, IntPoint(70,70))
push!(p2, IntPoint(70,30))
push!(p2, IntPoint(50,30))
push!(p2, IntPoint(60,40))
push!(p2, IntPoint(40,40))
push!(p2, IntPoint(50,30))
o = Offset()
paths = Paths()
push!(paths, p1)
push!(paths, p2)
add!(o, paths, jtMiter, etClosedPolygon)
r1 = PolyTree()
execute!(o, r1, -1)
clear!(o)
@show r1

# test IntRect
println("Testing IntRect...")
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(10,0))
push!(p, IntPoint(10,10))
push!(p, IntPoint(0,10))
c = Clip()
add!(c, p, ptSubject, true)
ir = IntRect(c)
@test left(ir) == 0
@test right(ir) == 10
@test top(ir) == 0
@test bottom(ir) == 10
left!(ir,1)
right!(ir,2)
top!(ir,3)
bottom!(ir,4)
@test left(ir) == 1
@test right(ir) == 2
@test top(ir) == 3
@test bottom(ir) == 4

# test Clip
println("Testing Clip...")

function setup_clip()
    c = Clip()
    subj = Path()
    push!(subj, IntPoint(0,0))
    push!(subj, IntPoint(10,0))
    push!(subj, IntPoint(10,10))
    push!(subj, IntPoint(0,10))
    clip = Path()
    push!(clip, IntPoint(0,0))
    push!(clip, IntPoint(10,0))
    push!(clip, IntPoint(10,10))
    push!(clip, IntPoint(0,10))
    add!(c, subj, ptSubject, true)
    add!(c, clip, ptClip, true)
    c
end

# ctDifference
c = setup_clip()
sol = Paths()
execute!(c, ctDifference, sol)
@test length(sol) == 0

# ctIntersection
c = setup_clip()
sol = Paths()
execute!(c, ctIntersection, sol)
@test length(sol) == 1
@test length(sol[1]) == 4

# ctUnion
c = setup_clip()
sol = Paths()
execute!(c, ctUnion, sol)
@test length(sol) == 1
@test length(sol[1]) == 4

# ctXor
c = setup_clip()
sol = Paths()
execute!(c, ctXor, sol)
@test length(sol) == 0

strictly_simple!(c,true)
preserve_collinear!(c,true)
reverse_solution!(c,true)
clear!(c)

# polytree and poly node tests, use set ops
println("Testing PolyTree...")
pt = PolyTree()
clear!(pt)
@test length(pt) == 0
@test first(pt).ptr == C_NULL # Null ptr
c = setup_clip()
sol = PolyTree()
execute!(c, ctIntersection, sol)
@test length(sol) == 1
f = first(sol)
@test length(Path(f)) == 4
@test !is_hole(f)
@test !is_open(f)
@test child_count(f) == 0
@test child_count(sol) == 1

# path equality
println("Testing path equality")
p1 = Path()
push!(p1, IntPoint(0,0))
push!(p1, IntPoint(10,0))
push!(p1, IntPoint(10,10))
p2 = Path()
push!(p2, IntPoint(0,0))
push!(p2, IntPoint(10,0))
push!(p2, IntPoint(10,10))
@test p1 == p2

# offsetting a polygon with holes.
println("Testing offset of a polygon with holes...")
perimeter = Path()
push!(perimeter, IntPoint(-10,-10))
push!(perimeter, IntPoint(60,-10))
push!(perimeter, IntPoint(60,60))
push!(perimeter, IntPoint(-10,60))

hole = Path()
push!(hole, IntPoint(4,4))
push!(hole, IntPoint(4,8))
push!(hole, IntPoint(8,8))
push!(hole, IntPoint(8,4))

hole2 = Path()
push!(hole2, IntPoint(12,4))
push!(hole2, IntPoint(12,8))
push!(hole2, IntPoint(16,8))
push!(hole2, IntPoint(16,4))

o = Offset()
paths = Paths()
push!(paths, perimeter)
push!(paths, hole)
push!(paths, hole2)
add!(o, paths, jtMiter, etClosedPolygon)

outpaths = Paths()
execute!(o, outpaths, -2)
@test length(outpaths) == 2
@test outpaths[1] == Path([(58,58), (-8,58), (-8,-8), (58,-8)])
@test outpaths[2] == Path([(18,2), (2,2), (2,10), (18,10)])

# test Paths() construction from a Vector of Path objects
paths = Paths([
    Path([(0,0)]),
    Path([(10,10)]),
])
@test length(paths) == 2
@test paths[1] == Path([(0,0)])
@test paths[2] == Path([(10,10)])

# test Paths() printing
o = IOBuffer()
show(o, outpaths)
expected = """Paths([
    Path([(58,58), (-8,58), (-8,-8), (58,-8)]),
    Path([(18,2), (2,2), (2,10), (18,10)])
)"""
@test ASCIIString(o.data) == expected

p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(10,0))
push!(p, IntPoint(10,10))
push!(p, IntPoint(0,10))
ps = Paths()
push!(ps, p)
pt = Clipper.Basic.offset(ps, 2)

path = Path([(0,0),(0,0),(0,0)])
i = 1
for point in path
    @test point === path[i]
    i += 1
end
@test i == 4
