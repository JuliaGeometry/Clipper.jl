using Clipper
using Test

# Helper: compare a result Paths64 against an expected set of vertices, order- and
# collinear-tolerant where noted. For exact-vertex tests we compare Sets of points.
pointset(paths) = Set(Iterators.flatten(paths))

const RECT = Point64[Point64(0, 0), Point64(10, 0), Point64(10, 10), Point64(0, 10)]

@testset "Clipper.jl (faithful Clipper2 wrapper)" begin

    @testset "Enums and types" begin
        @test Int(ClipTypeNone) == 0
        @test Int(ClipTypeIntersection) == 1
        @test Int(ClipTypeUnion) == 2
        @test Int(ClipTypeDifference) == 3
        @test Int(ClipTypeXor) == 4
        @test Int(FillRuleEvenOdd) == 0
        @test Int(FillRuleNonZero) == 1
        @test Int(FillRulePositive) == 2
        @test Int(FillRuleNegative) == 3
        @test Int(JoinTypeSquare) == 0
        @test Int(JoinTypeBevel) == 1
        @test Int(JoinTypeRound) == 2
        @test Int(JoinTypeMiter) == 3
        @test Int(EndTypePolygon) == 0
        @test Int(EndTypeJoined) == 1
        @test Int(EndTypeButt) == 2
        @test Int(EndTypeSquare) == 3
        @test Int(EndTypeRound) == 4
        @test sizeof(ClipTypeNone) == sizeof(Cint)
        @test Cint(FillRulePositive) isa Cint

        # Types
        p = Point64(3, 4)
        @test p.x == 3 && p.y == 4
        @test Point64(3, 4) == Point64(Int64(3), Int64(4))
        @test Point64(Int32(3), Int32(4)) == Point64(3, 4)
        r = Rect64(0, 10, 10, 0)
        @test r.left == 0 && r.right == 10
        @test Path64 == Vector{Point64}
        @test Paths64 == Vector{Vector{Point64}}

        pz = Point64Z(3, 4, 5)
        @test (pz.x, pz.y, pz.z) == (3, 4, 5)
        @test sizeof(Point64Z) == 3 * sizeof(Int64)
        @test Path64Z == Vector{Point64Z}
        @test Paths64Z == Vector{Vector{Point64Z}}
        @test Z_INTERSECTION == typemin(Int64)

        n = PolyPath64()
        @test isempty(contour(n)) && !ishole(n) && isempty(children(n))
        nz = PolyPath64Z()
        @test isempty(contour(nz)) && !ishole(nz) && isempty(children(nz))
    end

    @testset "NULL handles throw" begin
        @test_throws ClipperError Clipper._checked_handle(C_NULL, :test_create)
        ptr = Ptr{Cvoid}(1)
        @test Clipper._checked_handle(ptr, :test_create) == ptr
    end

    @testset "Engine boolean operations" begin
        # area / orientation sanity at the free-fn layer (used as oracle below)
        @test area(RECT) == 100.0
        @test is_positive(RECT)

        # Union of two overlapping rectangles → one contour.
        a = RECT
        b = Point64[Point64(5, 5), Point64(15, 5), Point64(15, 15), Point64(5, 15)]
        c = Clipper64()
        add_subject!(c, a)
        add_clip!(c, b)
        u, u_open = execute(c, ClipTypeUnion, FillRuleNonZero)
        @test length(u) == 1
        @test isempty(u_open)
        # L-shaped union area = 100 + 100 - 25 (overlap) = 175.
        @test abs(area(u[1])) == 175.0

        # Intersection → the 5×5 overlap square, area 25.
        clear!(c)
        add_subject!(c, a)
        add_clip!(c, b)
        i, _ = execute(c, ClipTypeIntersection, FillRuleNonZero)
        @test length(i) == 1
        @test abs(area(i[1])) == 25.0

        # Difference a − b → area 75.
        clear!(c)
        add_subject!(c, a)
        add_clip!(c, b)
        d, _ = execute(c, ClipTypeDifference, FillRuleNonZero)
        @test sum(abs(area(p)) for p in d) == 75.0

        # Exclusive-or → symmetric difference, area 150 (175 union − 25 intersection).
        clear!(c)
        add_subject!(c, a)
        add_clip!(c, b)
        x, _ = execute(c, ClipTypeXor, FillRuleNonZero)
        @test sum(abs(area(p)) for p in x) == 150.0
    end

    @testset "Degenerate single-path adds throw" begin
        # Single-path adds validate vertex counts (closed ≥ 3, open ≥ 2) and the
        # Julia wrappers convert the C `false` into a ClipperError.
        c = Clipper64()
        @test_throws ClipperError add_subject!(c, Point64[Point64(0, 0), Point64(1, 1)])
        @test_throws ClipperError add_clip!(c, Point64[Point64(0, 0), Point64(1, 1)])
        @test_throws ClipperError add_open_subject!(c, Point64[Point64(0, 0)])
        @test_throws ClipperError add_subject!(
            c, Point64Z[Point64Z(0, 0, 1), Point64Z(1, 1, 2)]
        )
        @test_throws ClipperError add_open_subject!(c, Point64Z[Point64Z(0, 0, 1)])
        # Batch adds defer degenerate paths to the engine, which ignores them.
        @test add_subject!(c, Paths64([RECT])) === c
    end

    @testset "Open paths returned from execute" begin
        # Same open-polyline intersection as the polytree test below, through the
        # flat execute: open results arrive as the second tuple element.
        line = Point64[Point64(-5, 5), Point64(25, 5)]
        c = Clipper64()
        add_open_subject!(c, line)
        add_clip!(c, RECT)
        closed_result, open_result = execute(c, ClipTypeIntersection, FillRuleNonZero)
        @test isempty(closed_result)
        @test length(open_result) == 1
        @test pointset(open_result) == Set([Point64(0, 5), Point64(10, 5)])
    end

    @testset "Preserve collinear vertices" begin
        # Two abutting rectangles whose union has collinear vertices at the seam.
        left = Point64[Point64(0, 0), Point64(5, 0), Point64(5, 10), Point64(0, 10)]
        right = Point64[Point64(5, 0), Point64(10, 0), Point64(10, 10), Point64(5, 10)]

        # Clipper2 default (preserve_collinear=true): seam vertices retained.
        c = Clipper64()
        add_subject!(c, Paths64([left, right]))
        u, _ = execute(c, ClipTypeUnion, FillRuleNonZero)
        @test length(u) == 1
        @test length(u[1]) == 6

        # preserve_collinear=false: minimal-vertex output.
        c2 = Clipper64(; preserve_collinear = false)
        add_subject!(c2, Paths64([left, right]))
        u2, _ = execute(c2, ClipTypeUnion, FillRuleNonZero)
        @test length(u2) == 1
        @test length(u2[1]) == 4
        @test abs(area(u2[1])) == 100.0
    end

    @testset "PolyTree with a hole" begin
        # Outer 0..20 square minus inner 5..15 square → an annulus: one outer
        # contour with one hole child.
        outer = Point64[Point64(0, 0), Point64(20, 0), Point64(20, 20), Point64(0, 20)]
        inner = Point64[Point64(5, 5), Point64(15, 5), Point64(15, 15), Point64(5, 15)]
        c = Clipper64()
        add_subject!(c, outer)
        add_clip!(c, inner)
        tree, open_result = execute_polytree(c, ClipTypeDifference, FillRuleNonZero)
        @test isempty(open_result)
        @test length(children(tree)) == 1
        root = children(tree)[1]
        @test !ishole(root)
        @test length(children(root)) == 1
        @test ishole(children(root)[1])
        # Net area = 400 − 100 = 300.
        net = abs(area(contour(root))) - abs(area(contour(children(root)[1])))
        @test net == 300.0
    end

    @testset "Open paths returned from execute_polytree" begin
        # A horizontal open polyline through RECT, intersected with it: Clipper2
        # returns the surviving open segment separately from the closed tree.
        line = Point64[Point64(-5, 5), Point64(25, 5)]
        c = Clipper64()
        add_open_subject!(c, line)
        add_clip!(c, RECT)
        tree, open_result = execute_polytree(c, ClipTypeIntersection, FillRuleNonZero)
        @test isempty(children(tree))
        @test length(open_result) == 1
        @test pointset(open_result) == Set([Point64(0, 5), Point64(10, 5)])
    end

    @testset "Offsetting" begin
        # Inflate a 10×10 square by 5 with miter joins → 20×20 bbox, area 400.
        o = ClipperOffset()
        add_path!(o, RECT, JoinTypeMiter, EndTypePolygon)
        infl = execute(o, 5.0)
        @test length(infl) == 1
        @test abs(area(infl[1])) == 400.0

        # Deflate by 2 → 6×6, area 36.
        o2 = ClipperOffset()
        add_path!(o2, RECT, JoinTypeMiter, EndTypePolygon)
        defl = execute(o2, -2.0)
        @test length(defl) == 1
        @test abs(area(defl[1])) == 36.0

        # Round join inflate produces more vertices than miter (arc approximation).
        o3 = ClipperOffset(; arc_tolerance = 0.25)
        add_path!(o3, RECT, JoinTypeRound, EndTypePolygon)
        rnd = execute(o3, 5.0)
        @test length(rnd) == 1
        @test length(rnd[1]) > 4

        # Bevel join cuts each corner with a single edge: 8 vertices, area between
        # the beveled minimum and the miter square (400 − 4·½·5² corner triangles).
        o4 = ClipperOffset()
        add_path!(o4, RECT, JoinTypeBevel, EndTypePolygon)
        bev = execute(o4, 5.0)
        @test length(bev) == 1
        @test length(bev[1]) == 8
        @test abs(area(bev[1])) == 350.0
    end

    @testset "Free functions" begin
        b = Point64[Point64(5, 5), Point64(15, 5), Point64(15, 15), Point64(5, 15)]

        @test sum(
            abs(area(p)) for p in
                union_paths(RECT, b, FillRuleNonZero)
        ) == 175.0
        @test sum(
            abs(area(p)) for p in
                intersect_paths(RECT, b, FillRuleNonZero)
        ) == 25.0
        @test sum(
            abs(area(p)) for p in
                difference_paths(RECT, b, FillRuleNonZero)
        ) == 75.0
        @test sum(
            abs(area(p)) for p in
                xor_paths(RECT, b, FillRuleNonZero)
        ) == 150.0

        infl = inflate_paths(RECT, 5.0, JoinTypeMiter, EndTypePolygon)
        @test abs(area(infl[1])) == 400.0

        @test point_in_polygon(Point64(5, 5), RECT) == :inside
        @test point_in_polygon(Point64(50, 50), RECT) == :outside
        @test point_in_polygon(Point64(0, 5), RECT) == :on

        # Self-union of a single rect is itself (area unchanged).
        us = union_self(Paths64([RECT]), FillRuleNonZero)
        @test sum(abs(area(p)) for p in us) == 100.0

        # Minkowski sum of a small square pattern over a path enlarges it.
        pattern = Point64[Point64(-1, -1), Point64(1, -1), Point64(1, 1), Point64(-1, 1)]
        ms = minkowski_sum(pattern, RECT, true)
        @test !isempty(ms)

        # Minkowski difference accepts the same closed kwarg.
        md = minkowski_diff(pattern, RECT, true)
        @test !isempty(md)
        @test !isempty(minkowski_diff(pattern, RECT, false))

        # trim_collinear drops a vertex that sits on the straight edge between its
        # neighbours; the 4 true corners survive.
        withmid = Point64[
            Point64(0, 0), Point64(5, 0), Point64(10, 0),
            Point64(10, 10), Point64(0, 10),
        ]
        tc = trim_collinear(Paths64([withmid]))
        @test length(tc) == 1
        @test length(tc[1]) == 4
        @test abs(area(tc[1])) == 100.0
    end

    @testset "Rectangle clipping" begin
        # Clip RECT (0..10) to the rectangle x,y ∈ 5..20: the surviving quarter.
        tile = Rect64(5, 5, 20, 20)
        rc = rect_clip(tile, RECT)
        @test length(rc) == 1
        @test abs(area(rc[1])) == 25.0
        @test pointset(rc) == Set(
            [
                Point64(5, 5), Point64(10, 5),
                Point64(10, 10), Point64(5, 10),
            ]
        )

        # Path entirely inside survives unchanged; entirely outside vanishes.
        @test length(rect_clip(Rect64(-5, -5, 15, 15), RECT)) == 1
        @test abs(area(rect_clip(Rect64(-5, -5, 15, 15), RECT)[1])) == 100.0
        @test isempty(rect_clip(Rect64(100, 100, 200, 200), RECT))

        # Tiling invariant: cutting into quadrant tiles partitions the area
        # exactly (integer seams), so the tile areas sum to the original.
        tiles = [
            Rect64(0, 0, 5, 5), Rect64(5, 0, 10, 5),
            Rect64(0, 5, 5, 10), Rect64(5, 5, 10, 10),
        ]
        tiled_area = sum(abs(area(p)) for t in tiles for p in rect_clip(t, RECT))
        @test tiled_area == 100.0
    end

    @testset "Edge-touching integer union merges at every edge length" begin
        # Edge-touching polygons must merge even when their shared edge is only
        # one integer unit long.
        touch(sz) = union_paths(
            Paths64(
                [
                    Point64[Point64(0, 0), Point64(sz, 0), Point64(sz, sz), Point64(0, sz)],
                    Point64[Point64(sz, 0), Point64(2sz, 0), Point64(2sz, sz), Point64(sz, sz)],
                ]
            ), FillRuleNonZero
        )
        @test length(touch(1)) == 1
        @test length(touch(2)) == 1
        @test length(touch(1000)) == 1
    end

    @testset "Z provenance through the Julia API" begin
        # Three classes must be distinguishable: original tagged vertices,
        # invented intersections, and intersections coinciding with an endpoint.
        subject = Point64Z[
            Point64Z(0, 0, 1), Point64Z(10, 0, 2),
            Point64Z(10, 10, 3), Point64Z(0, 10, 4),
        ]
        clip = Point64Z[
            Point64Z(5, 5, 101), Point64Z(15, 5, 102), Point64Z(15, 15, 103),
            Point64Z(5, 15, 104), Point64Z(5, 10, 105),
        ]

        c = Clipper64()
        @test add_subject!(c, subject) === c
        @test add_clip!(c, clip) === c
        root, open_result = execute_polytree_z(
            c, ClipTypeIntersection, FillRuleNonZero
        )
        @test root isa PolyTree64Z
        @test open_result isa Paths64Z
        @test isempty(open_result)
        @test length(children(root)) == 1
        result = contour(children(root)[1])
        zof = Dict((p.x, p.y) => p.z for p in result)
        @test Set(keys(zof)) == Set([(5, 5), (10, 5), (10, 10), (5, 10)])
        @test zof[(5, 5)] == 101              # original clip vertex
        @test zof[(10, 10)] == 3              # original subject vertex
        @test zof[(10, 5)] == Z_INTERSECTION  # invented at edge crossing
        @test zof[(5, 10)] == 105             # endpoint-coincident: z preserved
    end

    @testset "Z PolyTree hierarchy" begin
        outer = Point64Z[
            Point64Z(0, 0, 1), Point64Z(20, 0, 2),
            Point64Z(20, 20, 3), Point64Z(0, 20, 4),
        ]
        inner = Point64Z[
            Point64Z(5, 5, 11), Point64Z(15, 5, 12),
            Point64Z(15, 15, 13), Point64Z(5, 15, 14),
        ]
        c = Clipper64()
        add_subject!(c, outer)
        add_clip!(c, inner)
        root, _ = execute_polytree_z(c, ClipTypeDifference, FillRuleNonZero)
        @test length(children(root)) == 1
        outer_node = children(root)[1]
        @test !ishole(outer_node)
        @test length(children(outer_node)) == 1
        @test ishole(children(outer_node)[1])
        @test Set(p.z for p in contour(children(outer_node)[1])) == Set(11:14)
    end

    @testset "Mixed narrow and Z-aware inputs" begin
        subject = Point64Z[
            Point64Z(0, 0, 1), Point64Z(10, 0, 2),
            Point64Z(10, 10, 3), Point64Z(0, 10, 4),
        ]
        clip = Point64[
            Point64(5, 5), Point64(15, 5), Point64(15, 15), Point64(5, 15),
        ]
        c = Clipper64()
        add_subject!(c, subject)
        add_clip!(c, clip)
        root, _ = execute_polytree_z(c, ClipTypeIntersection, FillRuleNonZero)
        zof = Dict((p.x, p.y) => p.z for p in contour(children(root)[1]))
        @test zof[(5, 5)] == 0
        @test zof[(10, 10)] == 3
        @test zof[(10, 5)] == Z_INTERSECTION
    end

    @testset "Z open-path single and batch adds" begin
        line = Point64Z[Point64Z(-5, 5, 11), Point64Z(25, 5, 12)]
        clip = Point64Z[
            Point64Z(0, 0, 101), Point64Z(10, 0, 102),
            Point64Z(10, 10, 103), Point64Z(0, 10, 104),
        ]

        for batch in (false, true)
            c = Clipper64()
            added_open = batch ?
                add_open_subject!(c, Paths64Z([line])) : add_open_subject!(c, line)
            added_clip = batch ? add_clip!(c, clip) : add_clip!(c, Paths64Z([clip]))
            @test added_open === c
            @test added_clip === c

            root, open_result = execute_polytree_z(
                c, ClipTypeIntersection, FillRuleNonZero
            )
            @test isempty(children(root))
            @test length(open_result) == 1
            @test Set((p.x, p.y) for p in open_result[1]) == Set([(0, 5), (10, 5)])
            @test all(p -> p.z == Z_INTERSECTION, open_result[1])
        end
    end

    @testset "Z provenance through join/split paths" begin
        # A z of zero here would mean an engine path applied no z policy. This
        # geometry reaches one of the patched join/split paths.
        subject = Point64Z[
            Point64Z(15, 10, 1001), Point64Z(26, 38, 1002),
            Point64Z(17, 10, 1003), Point64Z(10, 2, 1004),
        ]
        clip = Point64Z[
            Point64Z(-8, 8, 5001), Point64Z(37, -1, 5002),
            Point64Z(39, 33, 5003), Point64Z(-9, 35, 5004),
        ]

        c = Clipper64()
        @test add_subject!(c, Paths64Z([subject])) === c
        @test add_clip!(c, Paths64Z([clip])) === c
        root, _ = execute_polytree_z(c, ClipTypeUnion, FillRuleNegative)
        @test length(children(root)) == 1
        result = contour(children(root)[1])
        zof = Dict((p.x, p.y) => p.z for p in result)
        @test Set(keys(zof)) == Set([(15, 10), (26, 38), (17, 10), (11, 4)])
        @test zof[(15, 10)] == 1001
        @test zof[(26, 38)] == 1002
        @test zof[(17, 10)] == 1003
        @test zof[(11, 4)] == Z_INTERSECTION  # 0 without the Clipper2 patch
        @test !any(p -> p.z == 0, result)
    end

    @testset "ABI boundary — invalid enum values rejected" begin
        # The Julia @enum types can't construct invalid values, so exercise the
        # C validation directly: an out-of-range clip_type must fail the call
        # (return false) rather than run a default operation.
        c = Clipper64()
        add_subject!(c, RECT)
        nocb = @cfunction(Clipper._paths_append, Cvoid, (Ptr{Cvoid}, Csize_t, Point64))
        sink = Clipper._PathsSink(Point64)
        ok = ccall(
            (:clipper64_execute, Clipper.libcclipper2), Bool,
            (Ptr{Cvoid}, Cint, Cint, Any, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
            c, Cint(99), Cint(FillRuleNonZero), sink, nocb, C_NULL, C_NULL
        )
        @test !ok
        @test isempty(sink.paths)
    end
end
