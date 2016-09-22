test("Add path to clipper") do
    path = Vector{IntPoint}()

    push!(path, IntPoint(0, 0))
    push!(path, IntPoint(0, 1))

    c = Clip()

    @test add_path!(c, path, PolyTypeSubject, true) == false

    push!(path, IntPoint(1, 1))

    @test add_path!(c, path, PolyTypeSubject, true) == true
end

test("Union") do
  path1 = Vector{IntPoint}()
  push!(path1, IntPoint(0, 0))
  push!(path1, IntPoint(0, 1))
  push!(path1, IntPoint(1, 1))
  push!(path1, IntPoint(1, 0))

  path2 = Vector{IntPoint}()
  push!(path2, IntPoint(1, 0))
  push!(path2, IntPoint(1, 1))
  push!(path2, IntPoint(2, 1))
  push!(path2, IntPoint(2, 0))

  c = Clip()
  add_path!(c, path1, PolyTypeSubject, true)
  add_path!(c, path2, PolyTypeSubject, true)

  result, polys = execute(c, ClipTypeUnion, PolyFillTypeEvenOdd, PolyFillTypeEvenOdd)

  @test result == true
  @test string(polys) == "Array{Clipper.IntPoint,1}[Clipper.IntPoint[[0,0],[2,0],[2,1],[0,1]]]"
end

test("Difference") do
  path1 = Vector{IntPoint}()
  push!(path1, IntPoint(0, 0))
  push!(path1, IntPoint(0, 10))
  push!(path1, IntPoint(10, 10))
  push!(path1, IntPoint(10, 0))

  path2 = Vector{IntPoint}()
  push!(path2, IntPoint(4, 0))
  push!(path2, IntPoint(4, 10))
  push!(path2, IntPoint(6, 10))
  push!(path2, IntPoint(6, 0))

  c = Clip()
  add_path!(c, path1, PolyTypeSubject, true)
  add_path!(c, path2, PolyTypeClip, true)

  result, polys = execute(c, ClipTypeDifference, PolyFillTypeEvenOdd, PolyFillTypeEvenOdd)

  @test result == true
  @test string(polys) == "Array{Clipper.IntPoint,1}[Clipper.IntPoint[[10,10],[6,10],[6,0],[10,0]],Clipper.IntPoint[[0,10],[0,0],[4,0],[4,10]]]"
end

test("GetBounds") do
  path1 = Vector{IntPoint}()
  push!(path1, IntPoint(0, 0))
  push!(path1, IntPoint(0, 1))
  push!(path1, IntPoint(1, 1))
  push!(path1, IntPoint(1, 0))

  path2 = Vector{IntPoint}()
  push!(path2, IntPoint(1, 0))
  push!(path2, IntPoint(1, 1))
  push!(path2, IntPoint(2, 1))
  push!(path2, IntPoint(2, 0))

  c = Clip()
  add_path!(c, path1, PolyTypeSubject, true)
  add_path!(c, path2, PolyTypeSubject, true)

  rect = get_bounds(c)

  @test rect.left == 0
  @test rect.top == 0
  @test rect.right == 2
  @test rect.bottom == 1
end

test("Clear") do
  path1 = Vector{IntPoint}()
  push!(path1, IntPoint(0, 0))
  push!(path1, IntPoint(0, 10))
  push!(path1, IntPoint(10, 10))
  push!(path1, IntPoint(10, 0))

  path2 = Vector{IntPoint}()
  push!(path2, IntPoint(4, 0))
  push!(path2, IntPoint(4, 10))
  push!(path2, IntPoint(6, 10))
  push!(path2, IntPoint(6, 0))

  c = Clip()
  add_path!(c, path1, PolyTypeSubject, true)
  add_path!(c, path2, PolyTypeSubject, true)

  Clipper.clear!(c)

  rect = get_bounds(c)

  @test rect.left == 0
  @test rect.top == 0
  @test rect.right == 0
  @test rect.bottom == 0
end

test("AddPaths") do
  path1 = Vector{IntPoint}()
  push!(path1, IntPoint(0, 0))
  push!(path1, IntPoint(0, 1))
  push!(path1, IntPoint(1, 1))
  push!(path1, IntPoint(1, 0))

  path2 = Vector{IntPoint}()
  push!(path2, IntPoint(1, 0))
  push!(path2, IntPoint(1, 1))
  push!(path2, IntPoint(2, 1))
  push!(path2, IntPoint(2, 0))

  paths = Vector{IntPoint}[path1, path2]

  c = Clip()
  add_paths!(c, paths, PolyTypeSubject, true)

  result, polys = execute(c, ClipTypeUnion, PolyFillTypeEvenOdd, PolyFillTypeEvenOdd)

  @test result == true
  @test string(polys) == "Array{Clipper.IntPoint,1}[Clipper.IntPoint[[0,0],[2,0],[2,1],[0,1]]]"
end

test("Orientation") do
  path1 = Vector{IntPoint}()
  push!(path1, IntPoint(0, 0))
  push!(path1, IntPoint(0, 1))
  push!(path1, IntPoint(1, 1))
  push!(path1, IntPoint(1, 0))

  @test orientation(path1) == false

  path1 = Vector{IntPoint}()
  push!(path1, IntPoint(1, 0))
  push!(path1, IntPoint(1, 1))
  push!(path1, IntPoint(0, 1))
  push!(path1, IntPoint(0, 0))

  @test orientation(path1) == true
end

test("Area") do
  path1 = Vector{IntPoint}()
  push!(path1, IntPoint(0, 0))
  push!(path1, IntPoint(0, 1))
  push!(path1, IntPoint(1, 1))

  @test area(path1) == -0.5
end
