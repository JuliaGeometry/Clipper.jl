#! /usr/bin/env julia

pkg_dir = dirname(dirname(@__FILE__))

@static if is_windows()
    try
      run(`where cl.exe`)
    catch
      error("ERROR: Could not find cl.exe.")
    end

    path = "$(pkg_dir)\\src\\"
    run(`cl.exe /D_USRDLL /D_WINDLL /EHsc /Fo$(path) $(path)cclipper.cpp $(path)clipper.cpp /MT /link /DLL /OUT:$(path)cclipper.dll`)
end

@static if is_unix()
    cd("$(pkg_dir)/src") do
        # Note: on Mac OS X, g++ is aliased to clang++.
        run(`g++ -c -fPIC -std=c++11 clipper.cpp cclipper.cpp`)
        run(`g++ -shared -o cclipper.so clipper.o cclipper.o`)
    end
end
