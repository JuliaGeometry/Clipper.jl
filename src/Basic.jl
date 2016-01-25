"""
A higher level wrapping of clipper functionality, leading to a simpler API.

"""
module Basic

using Clipper


function offset(paths::Clipper.Paths, dist::Int)
    o = Offset()
    pt = PolyTree()
    add!(o, paths, jtMiter, etClosedPolygon)
    execute!(o, pt, dist)
    clear!(o)

    return pt
end

end # module
