# PairTools

[![Build Status](https://github.com/jlapeyre/PairTools.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jlapeyre/PairTools.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jlapeyre/PairTools.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jlapeyre/PairTools.jl)

Julia function and macro to create an iterator over pairs whose members are
indices and elements of a slice. The keys
of the pairs are the same as the indices used to create the slice, rather than the new indices of the slice.
For example `@pairs a[4:5]` will have keys `4:5` rather than `1:2` as does `pairs(a[4:5])`.

### Examples
```julia
julia> using PairTools: @pairs

julia> a = collect(1:5);

julia> pairs(a[4:5])
pairs(::Vector{Int64})(...):
  1 => 4
  2 => 5

julia> @pairs a[4:5]
pairs(::Vector{Int64})(...):
  4 => 4
  5 => 5

julia> m = reshape(1:100, (10,10));

julia> @pairs m[9:10, 5:7]
pairs(::Base.ReshapedArray{Int64, 2, UnitRange{Int64}, Tuple{}})(...):
  CartesianIndex(9, 5)  => 49
  CartesianIndex(10, 5) => 50
  CartesianIndex(9, 6)  => 59
  CartesianIndex(10, 6) => 60
  CartesianIndex(9, 7)  => 69
  CartesianIndex(10, 7) => 70

julia> pairs(m[9:10, 5:7])
pairs(::Matrix{Int64})(...):
  CartesianIndex(1, 1) => 49
  CartesianIndex(2, 1) => 50
  CartesianIndex(1, 2) => 59
  CartesianIndex(2, 2) => 60
  CartesianIndex(1, 3) => 69
  CartesianIndex(2, 3) => 70
```

### Docstring

    @pairs(A[inds])
    @pairs(IndexLinear(), A[inds])
    @pairs(IndexCartesian(), A[inds])

Return an instance of `Base.Pairs`, as does `Base.pairs`, but the
keys are `inds` rather than the new indices of the slice `A[inds]`.
For example `@pairs a[4:6]` has keys `4:6` rather than keys `1:3`.
See further examples below.

Notes:

Some of the semantics is not documented here, but appears in the test suite.
Some is neither documented nor tested.

In contrast to `pairs`, the entire iterable `A` is retained in the instance of `Pairs`
rather than just the slice. In this sense, `@pairs` returns a kind of "view".
For `a::Vector`, for example, `keys(@pairs a[slice])` will be of length `length(slice)`.
But `values(@pairs a[slice])` will return the `length(a)` values
of `a`. There is a TODO in Base saying `values` should return a view.

`pairs(d[[a,b,c]])` throws an error for `d::Dict`. `@pairs(d[[a,b,c]])` returns a result, but attempting
to iterate over it will throw an error. This could be fixed, but would require type piracy.

For `d::Dictionary` from Dictionaries.jl, `pairs(d[[a,b,c]])` throws an error. But
`@pairs(d[[a,b,c]])` returns a result that can be iterated over with expected results.

#### Examples

```julia
julia> a = collect(1:5);

julia> pairs(a[4:end])
pairs(::Vector{Int64})(...):
  1 => 4
  2 => 5

julia> @pairs a[4:end]
pairs(::Vector{Int64})(...):
  4 => 4
  5 => 5
```


