using Clipper
using Luxor

polygon = IntPoint[]
push!(polygon, IntPoint(348,257))
push!(polygon, IntPoint(364,148))
push!(polygon, IntPoint(362,148))
push!(polygon, IntPoint(326,241))
push!(polygon, IntPoint(295,219))
push!(polygon, IntPoint(258,88))
push!(polygon, IntPoint(440,129))
push!(polygon, IntPoint(370,196))
push!(polygon, IntPoint(372,275))

co = ClipperOffset()
add_path!(co, polygon, JoinTypeRound, EndTypeClosedPolygon)
round_offset_polygons = execute(co, 7.0)

co = ClipperOffset()
add_path!(co, polygon, JoinTypeSquare, EndTypeClosedPolygon)
square_offset_polygons = execute(co, 7.0)

co = ClipperOffset()
add_path!(co, polygon, JoinTypeMiter, EndTypeClosedPolygon)
miter_offset_polygons = execute(co, 7.0)

fpolygon = Point.(tofloat.(polygon, 3,3))
round_foffset_polygons = [Point.(tofloat.(round_offset_polygon, 3,3)) for round_offset_polygon in round_offset_polygons]
square_foffset_polygons = [Point.(tofloat.(square_offset_polygon, 3,3)) for square_offset_polygon in square_offset_polygons]
miter_foffset_polygons = [Point.(tofloat.(miter_offset_polygon, 3,3)) for miter_offset_polygon in miter_offset_polygons]
@png begin
    fontsize(30)
    text("JoinTypeRound", Point(-100, -300))
    translate(-300, -370)
    sethue("blue")
    poly(fpolygon, :stroke, close=true)
    sethue("green")
    setopacity(0.4)
    poly.(round_foffset_polygons, :fill, close=true)
    setopacity(1.0)
    translate(0, 200)
    sethue("blue")
    poly(fpolygon, :stroke, close=true)
    sethue("green")
    setopacity(0.4)
    poly.(square_foffset_polygons, :fill, close=true)
    setopacity(1.0)
    translate(0, 200)
    sethue("blue")
    poly(fpolygon, :stroke, close=true)
    sethue("green")
    setopacity(0.4)
    poly.(miter_foffset_polygons, :fill, close=true)
end 500 700 "offset_diff_types.png"