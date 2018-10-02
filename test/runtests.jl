using Clipper
using Test

function test(run::Function, name::AbstractString; verbose=true)
    test_name = "Test $(name)"
    if verbose
        println(stderr, test_name)
    end
    try
        run()
    catch e
        println("Error running: ", test_name)
        rethrow(e)
    end
end

include("clipper_test.jl")
include("clipper_offset_test.jl")
