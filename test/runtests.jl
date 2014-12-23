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
