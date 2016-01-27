module Clipper
    export PolyType, PolyTypeSubject, PolyTypeClip,
           ClipType, ClipTypeIntersection, ClipTypeUnion, ClipTypeDifference, ClipTypeXor,
           PolyFillType, PolyFillTypeEvenOdd, PolyFillTypeNonZero, PolyFillTypePositive, PolyFillTypeNegative,
           JoinType, JoinTypeSquare, JoinTypeRound, JoinTypeMiter,
           EndType, EndTypeClosedPolygon, EndTypeClosedLine, EndTypeOpenSquare, EndTypeOpenRound, EndTypeOpenButt,
           Clip, add_path!, add_paths!, execute, clear!, get_bounds,
           IntPoint, IntRect, orientation, area,
           ClipperOffset

    @enum PolyType PolyTypeSubject=0 PolyTypeClip=1

    @enum ClipType ClipTypeIntersection=0 ClipTypeUnion=1 ClipTypeDifference=2 ClipTypeXor=3

    @enum PolyFillType PolyFillTypeEvenOdd=0 PolyFillTypeNonZero=1 PolyFillTypePositive=2 PolyFillTypeNegative=3

    @enum JoinType JoinTypeSquare=0 JoinTypeRound=1 JoinTypeMiter=2

    @enum EndType EndTypeClosedPolygon=0 EndTypeClosedLine=1 EndTypeOpenSquare=2 EndTypeOpenRound=3 EndTypeOpenButt=4

    @windows_only begin
      const library_path = Pkg.dir("Clipper") * "\\src\\cclipper.dll"
    end

    @unix_only begin
        const library_path = Pkg.dir("Clipper") * "/src/cclipper.so"
    end

    type IntPoint
        X::Int64
        Y::Int64
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
