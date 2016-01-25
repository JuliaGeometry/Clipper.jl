#! /usr/bin/env julia

pkg_dir = Pkg.dir("Clipper.jl")

@windows_only begin
    try
      run(`where cl.exe`)
    catch
      error("ERROR: Could not find cl.exe.")
    end

    path = "$(pkg_dir)\\src\\"
    run(`cl.exe /D_USRDLL /D_WINDLL /EHsc /Fo$(path) $(path)cclipper.cpp $(path)clipper.cpp /MT /link /DLL /OUT:$(path)cclipper.dll`)
end
