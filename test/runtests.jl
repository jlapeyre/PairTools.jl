using PairTools: @pairs, pairs_inds
using Test

if VERSION >= v"1.7"
    const Pairs = Base.Pairs
else
    const Pairs = Iterators.Pairs
end


@testset "PairTools.jl" begin
    a = collect(1:5)
    for psa in (@pairs a[4:5], pairs_inds(a, 4:5), @pairs a[4:end], @pairs(IndexLinear(), a[4:end]),
                pairs_inds(IndexLinear(), a, 4:5))
        psa = @pairs a[4:5]
        cpsa = collect(psa)
        @test cpsa == [4 => 4, 5 => 5]
        @test typeof(psa) == Pairs{Int64, Int64, UnitRange{Int64}, Vector{Int64}}
    end

    m = reshape(1:16, (4,4))
    pm = @pairs(m[3:4, 3:4])
    @test values(pm) == m  # this is the way Base works at the moment.
    @test isa(keys(pm), CartesianIndices{2, Tuple{UnitRange{Int64}, UnitRange{Int64}}})
    for tm in (m, collect(m))
        pm = @pairs tm[9:16]
        @test Pairs(tm, reshape([CartesianIndex(i, j) for i in 1:4, j in 3:4], (8,))) == pm
    end

    tup = (1:5...,)
    pt = @pairs tup[4:end]
    @test typeof(pt) == Pairs{Int64, Int64, UnitRange{Int64}, NTuple{5, Int64}}
    @test values(pt) == tup
    @test keys(pt) == 4:5
    @test collect(pt) == [4 => 4, 5 => 5]
end
