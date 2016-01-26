#! /usr/bin/env julia

pkg_dir = Pkg.dir("Clipper")

@windows_only begin
    try
      run(`where cl.exe`)
    catch
      error("ERROR: Could not find cl.exe.")
    end

    path = "$(pkg_dir)\\src\\"
    run(`cl.exe /D_USRDLL /D_WINDLL /EHsc /Fo$(path) $(path)cclipper.cpp $(path)clipper.cpp /MT /link /DLL /OUT:$(path)cclipper.dll`)
end

@unix_only begin
    cd("$(pkg_dir)/src") do
        run(`g++ -c -fPIC -std=c++11 -stdlib=libc++ clipper.cpp cclipper.cpp`)
        run(`g++ -shared -o cclipper.so clipper.o cclipper.o`)
    end
end
