using Clipper
using Base.Test

# testing printing
a = Path()
b = IntPoint(1,0)
push!(a, b)
println(a)
push!(a, b)
push!(a, b)
println(a)

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

println("Testing clip...")
c = Clip()
strictly_simple(c,true)
preserve_collinear(c,true)
reverse_solution(c,true)
clear(c)


p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(0,2))
push!(p, IntPoint(2,2))
push!(p, IntPoint(2,0))

println("Testing PolyTree...")
pt = PolyTree()
clear(pt)
@test length(pt) == 0
@test first(pt).ptr == C_NULL # Null ptr

# testing offset
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(10,0))
push!(p, IntPoint(10,10))
push!(p, IntPoint(0,10))
o = Offset()
r1 = Paths()
r2 = PolyTree()
add(o, p, jtMiter, etClosedPolygon)
execute!(o, r1, 1)
execute!(o, r2, 1)
clear(o)
p1 = Paths(r2)
# paths
@test length(p1) == length(r1) == 1
p1 = p1[1]
r1 = r1[1]
# now just path
@test length(p1) == length(r1)
for i = 1:length(p1)
    @test p1[i] == r1[i]
end
@test arc_tolerance(o) == 0.25
# test changing the value
arc_tolerance(o, 0.5)
@test arc_tolerance(o) == 0.5

# test IntRect
println("Testing IntRect...")
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(10,0))
push!(p, IntPoint(10,10))
push!(p, IntPoint(0,10))
c = Clip()
add(c, p, ptSubject, true)
ir = IntRect(c)
@test left(ir) == 0
@test right(ir) == 10
@test top(ir) == 0
@test bottom(ir) == 10
left(ir,1)
right(ir,2)
top(ir,3)
bottom(ir,4)
@test left(ir) == 1
@test right(ir) == 2
@test top(ir) == 3
@test bottom(ir) == 4
println(ir)
