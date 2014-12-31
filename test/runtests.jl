using Clipper
using Base.Test

# testing printing
a = Path()
b = IntPoint(Vector2(1,0))
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

# testing offset
p = Path()
push!(p, IntPoint(0,0))
push!(p, IntPoint(100,0))
push!(p, IntPoint(100,100))
push!(p, IntPoint(0,100))
p_n = offset(p, 10.0)
@show p_n

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
