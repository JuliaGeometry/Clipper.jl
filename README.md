# Clipper.jl

[![CI][ci-img]][ci-url]
[![Dev][docs-dev-img]][docs-dev-url]
[![Stable][docs-stable-img]][docs-stable-url]

Clipper.jl is a Julia wrapper for Angus Johnson's library for polygon clipping and offsetting, [Clipper2 (v1.2.2)](https://github.com/AngusJohnson/Clipper2/tree/Clipper2_1.2.2). 

> # Clipper2
> ### A Polygon [Clipping](https://en.wikipedia.org/wiki/Clipping_(computer_graphics)) and [Offsetting](https://en.wikipedia.org/wiki/Parallel_curve) library (in C++, C# & Delphi)
> 
> The **Clipper2** library performs **intersection**, **union**, **difference** and **XOR** boolean operations on both simple and complex polygons. It also performs polygon offsetting. This is a major update of my original [**Clipper**](https://sourceforge.net/projects/polyclipping/) library that was written over 10 years ago. That library I'm now calling **Clipper1** and while it still works very well, Clipper2 is [better](http://www.angusj.com/clipper2/Docs/Changes.htm) in just about every way.

## License
Available under the [Boost Software License - Version 1.0](http://www.boost.org/LICENSE_1_0.txt).
See: [LICENSE.md](./LICENSE.md).

[ci-img]: https://github.com/JuliaGeometry/Clipper.jl/actions/workflows/CI.yml/badge.svg?branch=master
[ci-url]: https://github.com/JuliaGeometry/Clipper.jl/actions/workflows/CI.yml

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://juliageometry.github.io/Clipper.jl/dev

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://juliageometry.github.io/Clipper.jl/stable
