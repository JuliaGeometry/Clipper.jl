#! /usr/bin/env julia

path = joinpath(dirname(@__FILE__), "..", "src")

if is_windows()
    if success(`where cl.exe`)
        info("Compiling with cl.exe")
        run(`cl.exe /D_USRDLL /D_WINDLL /EHsc /Fo$(path) $(path)cclipper.cpp $(path)clipper.cpp /MT /link /DLL /OUT:$(path)cclipper.dll`)
    else
        import WinRPM
        info("Compiling with WinRPM gcc-c++")
        WinRPM.install("gcc-c++"; yes = true)
        WinRPM.install("gcc"; yes = true)
        WinRPM.install("headers"; yes = true)
        WinRPM.install("winpthreads-devel"; yes = true)

        gpp = Pkg.dir("WinRPM","deps","usr","x86_64-w64-mingw32","sys-root","mingw","bin","g++")
        RPMbindir = Pkg.dir("WinRPM","deps","usr","x86_64-w64-mingw32","sys-root","mingw","bin")
        incdir = Pkg.dir("WinRPM","deps","usr","x86_64-w64-mingw32","sys-root","mingw","include")

        push!(Base.Libdl.DL_LOAD_PATH, RPMbindir)
        ENV["PATH"] = ENV["PATH"] * ";" * RPMbindir
        if success(`$gpp --version`)
            cd(path) do
                run(`$gpp -c -fPIC -std=c++11 clipper.cpp cclipper.cpp -I $incdir`)
                run(`$gpp -shared -o cclipper.dll clipper.o cclipper.o`)
            end
        else
            error("no windows c++ compiler (cl.exe) found, and WinRPM with g++ is failing as well.")
        end
    end
end

if is_unix()
    cd(path) do
        # Note: on Mac OS X, g++ is aliased to clang++.
        run(`g++ -c -fPIC -std=c++11 clipper.cpp cclipper.cpp`)
        run(`g++ -shared -o cclipper.so clipper.o cclipper.o`)
    end
end
