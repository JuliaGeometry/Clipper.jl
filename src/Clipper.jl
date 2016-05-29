__precompile__()
module Clipper
    export PolyType, PolyTypeSubject, PolyTypeClip,
           ClipType, ClipTypeIntersection, ClipTypeUnion, ClipTypeDifference, ClipTypeXor,
           PolyFillType, PolyFillTypeEvenOdd, PolyFillTypeNonZero, PolyFillTypePositive, PolyFillTypeNegative,
           JoinType, JoinTypeSquare, JoinTypeRound, JoinTypeMiter,
           EndType, EndTypeClosedPolygon, EndTypeClosedLine, EndTypeOpenSquare, EndTypeOpenRound, EndTypeOpenButt,
           Clip, add_path!, add_paths!, execute, clear!, get_bounds,
           IntPoint, IntRect, orientation, area, pointinpolygon, ClipperOffset,
           PolyNode, execute_pt, contour, ishole, contour, children

    @enum PolyType PolyTypeSubject=0 PolyTypeClip=1

    @enum ClipType ClipTypeIntersection=0 ClipTypeUnion=1 ClipTypeDifference=2 ClipTypeXor=3

    @enum PolyFillType PolyFillTypeEvenOdd=0 PolyFillTypeNonZero=1 PolyFillTypePositive=2 PolyFillTypeNegative=3

    @enum JoinType JoinTypeSquare=0 JoinTypeRound=1 JoinTypeMiter=2

    @enum EndType EndTypeClosedPolygon=0 EndTypeClosedLine=1 EndTypeOpenSquare=2 EndTypeOpenRound=3 EndTypeOpenButt=4

    @static if is_windows()
        const library_path = joinpath(dirname(@__FILE__), "cclipper.dll")
    end

    @static if is_unix()
        const library_path = joinpath(dirname(@__FILE__), "cclipper.so")
    end

    immutable IntPoint
        X::Int64
        Y::Int64
    end

    type PolyNode{T}
        contour::Vector{T}
        hole::Bool
        open::Bool
        children::Vector{PolyNode{T}}
        parent::PolyNode{T}
        PolyNode(a,b,c) = new(a,b,c)
        function PolyNode(a,b,c,d)
            p = new(a,b,c,d)
            p.parent = p
            return p
        end
        PolyNode(a,b,c,d,e) = new(a,b,c,d,e)
    end

    Base.convert{T}(::Type{PolyNode{T}}, x::PolyNode{T}) = x
    function Base.convert{S,T}(::Type{PolyNode{S}}, x::PolyNode{T})
        parent(x) !== x && error("must convert a top-level PolyNode (i.e. a PolyTree).")

        pn = PolyNode{S}(convert(Vector{S}, contour(x)), ishole(x), isopen(x))
        pn.children = [PolyNode(y,pn) for y in children(x)]
        pn.parent = pn
    end
    function PolyNode{S}(x::PolyNode, parent::PolyNode{S})
        pn = PolyNode{S}(contour(x), ishole(x), isopen(x))
        pn.children = [PolyNode(y,pn) for y in children(x)]
        pn.parent = parent
        pn
    end

    @inline ishole(x::PolyNode) = x.hole
    @inline Base.isopen(x::PolyNode) = x.open
    @inline contour(x::PolyNode) = x.contour
    @inline children(x::PolyNode) = x.children
    @inline Base.parent(x::PolyNode) = x.parent

    function Base.show(io::IO, node::PolyNode)
        if parent(node) === node
            print(io, "Top-level PolyNode with $(length(children(node))) immediate children.")
        else
            if isopen(node)
                print(io, "Open ")
            else
                print(io, "Closed ")
            end
            print(io, "PolyNode ")
            ishole(node) && print(io, "(hole) ")
            println(io, "with contour:")
            show(io, contour(node))
            println(io, "")
            print(io, "...and $(length(children(node))) immediate children.")
        end
    end

    function Base.show(io::IO, point::IntPoint)
      print(io, "[$(point.X),$(point.Y)]")
    end

    function append!(outputArray::Ptr{Void}, polyIndex::Csize_t, point::IntPoint)
        ourArray = unsafe_pointer_to_objref(outputArray)::Vector{Vector{IntPoint}}

        while (polyIndex + 1) > length(ourArray)
          push!(ourArray, Vector{IntPoint}())
        end

        push!(ourArray[polyIndex + 1], point)
    end

    # private
    function appendpn!(jl_node::Ptr{Void}, point::IntPoint)
        node = unsafe_pointer_to_objref(jl_node)::PolyNode{IntPoint}
        push!(contour(node), point)
    end

    # private
    function newnode(outputTree::Ptr{Void}, ishole::Bool, isopen::Bool)
        tree = unsafe_pointer_to_objref(outputTree)::PolyNode{IntPoint}
        node = PolyNode{IntPoint}(IntPoint[], ishole, isopen, PolyNode{IntPoint}[], tree)
        push!(children(tree), node)
        pointer_from_objref(node)
    end

    #==============================================================#
  	# Static functions
  	#==============================================================#
    function orientation(path::Vector{IntPoint})
        ccall((:orientation, library_path), Cuchar, (Ptr{IntPoint}, Csize_t),
            path,
            length(path)) == 1 ? true : false
    end

    function area(path::Vector{IntPoint})
        ccall((:area, library_path), Float64, (Ptr{IntPoint}, Csize_t),
            path,
            length(path))
    end

    function pointinpolygon(pt::IntPoint, path::Vector{IntPoint})
        ccall((:pointinpolygon, library_path), Cint, (IntPoint, Ptr{IntPoint}, Csize_t),
            pt,
            path,
            length(path))
    end

    #==============================================================#
  	# Clipper object
  	#==============================================================#
    type Clip
        clipper_ptr::Ptr{Void}

        function Clip()
            clipper = new(ccall((:get_clipper, library_path), Ptr{Void}, ()))
            finalizer(clipper, c -> ccall((:delete_clipper, library_path), Void, (Ptr{Void},), c.clipper_ptr))

            clipper
        end
    end

    function add_path!(c::Clip, path::Vector{IntPoint}, polyType::PolyType, closed::Bool)
        ccall((:add_path, library_path), Cuchar, (Ptr{Void}, Ptr{IntPoint}, Csize_t, Cint, Cuchar),
              c.clipper_ptr,
              path,
              length(path),
              Int(polyType),
              closed) == 1 ? true : false
    end

    function add_paths!(c::Clip, paths::Vector{Vector{IntPoint}}, polyType::PolyType, closed::Bool)
        lengths = Vector{UInt64}()
        for path in paths
            push!(lengths, length(path))
        end

        ccall((:add_paths, library_path), Cuchar, (Ptr{Void}, Ptr{Ptr{IntPoint}}, Ptr{Csize_t}, Csize_t, Cint, Cuchar),
              c.clipper_ptr,
              paths,
              lengths,
              length(paths),
              Int(polyType),
              closed) == 1 ? true : false
    end

    function execute(c::Clip, clipType::ClipType, subjFillType::PolyFillType, clipFillType::PolyFillType)
        polys = Vector{Vector{IntPoint}}()

        result = ccall((:execute, library_path), Cuchar, (Ptr{Void}, Cint, Cint, Cint, Any, Ptr{Void}),
                        c.clipper_ptr,
                        Int(clipType),
                        Int(subjFillType),
                        Int(clipFillType),
                        polys,
                        cfunction(append!, Any, (Ptr{Void}, Csize_t, IntPoint)))

        return result == 1 ? true : false, polys
    end

    function execute_pt(c::Clip, clipType::ClipType, subjFillType::PolyFillType, clipFillType::PolyFillType)
        pt = PolyNode{IntPoint}(IntPoint[], false, false, PolyNode{IntPoint}[])

        result = ccall((:execute_pt, library_path), Cuchar,
            (Ptr{Void}, Cint, Cint, Cint, Any, Ptr{Void}, Ptr{Void}),
            c.clipper_ptr,
            Int(clipType),
            Int(subjFillType),
            Int(clipFillType),
            pt,
            cfunction(newnode, Ptr{Void}, (Ptr{Void}, Bool, Bool)),
            cfunction(appendpn!, Any, (Ptr{Void}, IntPoint)))

        return result == 1 ? true : false, pt
    end

    function clear!(c::Clip)
        ccall((:clear, library_path), Void, (Ptr{Void},), c.clipper_ptr)
    end

    type IntRect
        left::Int64
        top::Int64
        right::Int64
        bottom::Int64
    end

    function get_bounds(c::Clip)
        ccall((:get_bounds, library_path), IntRect, (Ptr{Void}, ), c.clipper_ptr)
    end

    #==============================================================#
  	# ClipperOffset object
  	#==============================================================#
    type ClipperOffset
        clipper_ptr::Ptr{Void}

        function ClipperOffset(miterLimit::Float64 = 2.0, roundPrecision::Float64 = 0.25)
            clipper = new(ccall((:get_clipper_offset, library_path), Ptr{Void}, (Cdouble, Cdouble), miterLimit, roundPrecision))
            finalizer(clipper, c -> ccall((:delete_clipper_offset, library_path), Void, (Ptr{Void},), c.clipper_ptr))

            clipper
        end
    end

    function add_path!(c::ClipperOffset, path::Vector{IntPoint}, joinType::JoinType, endType::EndType)
        ccall((:add_offset_path, library_path), Void, (Ptr{Void}, Ptr{IntPoint}, Csize_t, Cint, Cint),
              c.clipper_ptr,
              path,
              length(path),
              Int(joinType),
              Int(endType))
    end

    function add_paths!(c::ClipperOffset, paths::Vector{Vector{IntPoint}}, joinType::JoinType, endType::EndType)
        lengths = Vector{UInt64}()
        for path in paths
            push!(lengths, length(path))
        end

        ccall((:add_offset_paths, library_path), Void, (Ptr{Void}, Ptr{Ptr{IntPoint}}, Ptr{Csize_t}, Csize_t, Cint, Cint),
              c.clipper_ptr,
              paths,
              lengths,
              length(paths),
              Int(joinType),
              Int(endType))
    end

    function clear!(c::ClipperOffset)
        ccall((:clear_offset, library_path), Void, (Ptr{Void},), c.clipper_ptr)
    end

    function execute(c::ClipperOffset, delta::Float64)
        polys = Vector{Vector{IntPoint}}()

        result = ccall((:execute_offset, library_path), Void, (Ptr{Void}, Cdouble, Any, Ptr{Void}),
                        c.clipper_ptr,
                        delta,
                        polys,
                        cfunction(append!, Any, (Ptr{Void}, Csize_t, IntPoint)))

        return polys
    end
end
