test("Add path to offset") do
    path = Vector{IntPoint}()

    push!(path, IntPoint(0, 0))
    push!(path, IntPoint(0, 1))

    c = ClipperOffset()

    add_path!(c, path, JoinTypeRound, EndTypeClosedPolygon)
end

test("Add paths to offset") do
    path1 = Vector{IntPoint}()

    push!(path1, IntPoint(0, 0))
    push!(path1, IntPoint(0, 1))

    path2 = Vector{IntPoint}()

    push!(path2, IntPoint(5, 0))
    push!(path2, IntPoint(2, 1))

    paths = Vector{IntPoint}[path1, path2]

    c = ClipperOffset()

    add_paths!(c, paths, JoinTypeRound, EndTypeClosedPolygon)
end


test("Clear") do
    path = Vector{IntPoint}()

    push!(path, IntPoint(0, 0))
    push!(path, IntPoint(0, 1))

    c = ClipperOffset()

    add_path!(c, path, JoinTypeRound, EndTypeClosedPolygon)

    Clipper.clear!(c)
end

test("Offset") do
    path = Vector{IntPoint}()

    push!(path, IntPoint(0, 0))
    push!(path, IntPoint(0, 1))

    c = ClipperOffset()

    add_path!(c, path, JoinTypeRound, EndTypeOpenRound)

    poly = execute(c, 1.0)

    @test poly == [[IntPoint(1,2), IntPoint(-1,2), IntPoint(-1,-1), IntPoint(1,-1)]]
end
