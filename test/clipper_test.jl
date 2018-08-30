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
    @test polys[1][1] == Clipper.IntPoint(0, 0)
    @test polys[1][2] == Clipper.IntPoint(2, 0)
    @test polys[1][3] == Clipper.IntPoint(2, 1)
    @test polys[1][4] == Clipper.IntPoint(0, 1)

    result, pt = execute_pt(c, ClipTypeUnion, PolyFillTypeEvenOdd, PolyFillTypeEvenOdd)
    @test result == true
    @test string(pt) == "Top-level PolyNode with 1 immediate children."
    @test length(children(pt)) === 1

    pn = children(pt)[1]

    @test length(children(pn)) == 0
    @test contour(pn)[1] == Clipper.IntPoint(0, 0)
    @test contour(pn)[2] == Clipper.IntPoint(2, 0)
    @test contour(pn)[3] == Clipper.IntPoint(2, 1)
    @test contour(pn)[4] == Clipper.IntPoint(0, 1)
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
    @test polys[1][1] == Clipper.IntPoint(10, 10)
    @test polys[1][2] == Clipper.IntPoint(6, 10)
    @test polys[1][3] == Clipper.IntPoint(6, 0)
    @test polys[1][4] == Clipper.IntPoint(10, 0)

    @test polys[2][1] == Clipper.IntPoint(0, 10)
    @test polys[2][2] == Clipper.IntPoint(0, 0)
    @test polys[2][3] == Clipper.IntPoint(4, 0)
    @test polys[2][4] == Clipper.IntPoint(4, 10)

    result, pt = execute_pt(c, ClipTypeDifference, PolyFillTypeEvenOdd, PolyFillTypeEvenOdd)
    @test result == true
    @test string(pt) == "Top-level PolyNode with 2 immediate children."
    @test length(children(pt)) === 2

    pn1,pn2 = (children(pt)...,)
    @test length(children(pn1)) == 0
    @test length(children(pn2)) == 0

    @test contour(pn1)[1] == Clipper.IntPoint(10, 10)
    @test contour(pn1)[2] == Clipper.IntPoint(6, 10)
    @test contour(pn1)[3] == Clipper.IntPoint(6, 0)
    @test contour(pn1)[4] == Clipper.IntPoint(10, 0)

    @test contour(pn2)[1] == Clipper.IntPoint(0, 10)
    @test contour(pn2)[2] == Clipper.IntPoint(0, 0)
    @test contour(pn2)[3] == Clipper.IntPoint(4, 0)
    @test contour(pn2)[4] == Clipper.IntPoint(4, 10)
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
    @test polys[1][1] == Clipper.IntPoint(0, 0)
    @test polys[1][2] == Clipper.IntPoint(2, 0)
    @test polys[1][3] == Clipper.IntPoint(2, 1)
    @test polys[1][4] == Clipper.IntPoint(0, 1)
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

test("Point in polygon") do
    path1 = Vector{IntPoint}()
    push!(path1, IntPoint(0, 0))
    push!(path1, IntPoint(4, 0))
    push!(path1, IntPoint(0, 4))

    # Returns -1 if on boundary (check all the boundary points)
    @test pointinpolygon(IntPoint(0,0), path1) == -1
    @test pointinpolygon(IntPoint(1,0), path1) == -1
    @test pointinpolygon(IntPoint(2,0), path1) == -1
    @test pointinpolygon(IntPoint(3,0), path1) == -1
    @test pointinpolygon(IntPoint(4,0), path1) == -1
    @test pointinpolygon(IntPoint(3,1), path1) == -1
    @test pointinpolygon(IntPoint(2,2), path1) == -1
    @test pointinpolygon(IntPoint(1,3), path1) == -1
    @test pointinpolygon(IntPoint(0,4), path1) == -1
    @test pointinpolygon(IntPoint(0,3), path1) == -1
    @test pointinpolygon(IntPoint(0,2), path1) == -1
    @test pointinpolygon(IntPoint(0,1), path1) == -1

    # Returns 1 if inside (check all the interior points)
    @test pointinpolygon(IntPoint(1,1), path1) == 1
    @test pointinpolygon(IntPoint(2,1), path1) == 1
    @test pointinpolygon(IntPoint(1,2), path1) == 1

    # Returns 0 if outside (check a few places outside)
    @test pointinpolygon(IntPoint(10,10), path1) == 0
    @test pointinpolygon(IntPoint(-1,-1), path1) == 0
end

struct IntPoint2
    X::Int64
    Y::Int64
end
Base.convert(::Type{IntPoint2}, x::IntPoint) = IntPoint2(x.X, x.Y)
Base.convert(::Type{IntPoint}, x::IntPoint2) = IntPoint(x.X, x.Y)

test("PolyTrees / PolyNodes") do
    path1 = Vector{IntPoint}()
    push!(path1, IntPoint(8, 8))
    push!(path1, IntPoint(0, 8))
    push!(path1, IntPoint(0, 0))
    push!(path1, IntPoint(8, 0))

    path2 = Vector{IntPoint}()
    push!(path2, IntPoint(1, 1))
    push!(path2, IntPoint(1, 7))
    push!(path2, IntPoint(7, 7))
    push!(path2, IntPoint(7, 1))

    path3 = Vector{IntPoint}()
    push!(path3, IntPoint(6, 6))
    push!(path3, IntPoint(2, 6))
    push!(path3, IntPoint(2, 2))
    push!(path3, IntPoint(6, 2))

    paths = Vector{IntPoint}[path1, path2, path3]

    c = Clip()
    add_paths!(c, paths, PolyTypeSubject, true)

    result, pt = execute_pt(c, ClipTypeUnion, PolyFillTypeEvenOdd, PolyFillTypeEvenOdd)

    # test expected PolyTree structure
    @test result == true
    @test isa(pt, PolyNode{IntPoint})
    @test parent(pt) === pt     # in the wrapper we set the parent of top level to itself
    @test length(children(pt)) === 1
    @test contour(pt) == IntPoint[]     # top level has no contour
    @test length(children(pt)) == 1

    pn1 = children(pt)[1]
    @test !ishole(pn1)
    @test !isopen(pn1)
    @test contour(pn1) == path1
    @test length(children(pn1)) === 1
    @test parent(pn1) === pt
    @test length(children(pn1)) == 1
    @test contour(pn1)[1] == Clipper.IntPoint(8, 8)
    @test contour(pn1)[2] == Clipper.IntPoint(0, 8)
    @test contour(pn1)[3] == Clipper.IntPoint(0, 0)
    @test contour(pn1)[4] == Clipper.IntPoint(8, 0)

    pn2 = children(pn1)[1]
    @test ishole(pn2)
    @test !isopen(pn2)
    @test contour(pn2) == path2
    @test length(children(pn2)) === 1
    @test parent(pn2) === pn1
    @test length(children(pn2)) == 1
    @test contour(pn2)[1] == Clipper.IntPoint(1, 1)
    @test contour(pn2)[2] == Clipper.IntPoint(1, 7)
    @test contour(pn2)[3] == Clipper.IntPoint(7, 7)
    @test contour(pn2)[4] == Clipper.IntPoint(7, 1)

    pn3 = children(pn2)[1]
    @test !ishole(pn3)
    @test !isopen(pn3)
    @test contour(pn3) == path3
    @test isempty(children(pn3))
    @test parent(pn3) === pn2
    @test length(children(pn3)) == 0
    @test contour(pn3)[1] == Clipper.IntPoint(6, 6)
    @test contour(pn3)[2] == Clipper.IntPoint(2, 6)
    @test contour(pn3)[3] == Clipper.IntPoint(2, 2)
    @test contour(pn3)[4] == Clipper.IntPoint(6, 2)

    # Test that we can preserve the tree structure when converting between types.
    pt2 = convert(PolyNode{IntPoint2}, pt)
    pt3 = convert(PolyNode{IntPoint}, pt2)

    @test result == true
    @test isa(pt3, PolyNode{IntPoint})
    @test parent(pt3) === pt3     # in the wrapper we set the parent of top level to itself
    @test length(children(pt3)) === 1
    @test contour(pt3) == IntPoint[]     # top level has no contour

    pn1 = children(pt3)[1]
    @test !ishole(pn1)
    @test !isopen(pn1)
    @test contour(pn1) == path1
    @test length(children(pn1)) === 1
    @test parent(pn1) === pt3

    pn2 = children(pn1)[1]
    @test ishole(pn2)
    @test !isopen(pn2)
    @test contour(pn2) == path2
    @test length(children(pn2)) === 1
    @test parent(pn2) === pn1

    pn3 = children(pn2)[1]
    @test !ishole(pn3)
    @test !isopen(pn3)
    @test contour(pn3) == path3
    @test isempty(children(pn3))
    @test parent(pn3) === pn2

    # Only convert top-level PolyNodes (i.e. PolyTrees)
    @test_throws ErrorException convert(PolyNode{IntPoint2}, pn3)
end
