"""
A higher level wrapping of clipper functionality, leading to a simpler API.

"""
module Basic

using Clipper


function offset(paths::Clipper.__ClipperPaths, dist::Int)
    o = Offset()
    pt = PolyTree()

    for i = 1:length(paths)
        path = paths[i]
        add!(o, path, jtMiter, etClosedPolygon)
    end
    execute!(o, pt, dist)
    clear!(o)

    return pt
end

end # module
