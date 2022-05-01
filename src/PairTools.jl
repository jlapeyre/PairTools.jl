module PairTools

export @pairs, pairs_inds

if VERSION >= v"1.7"
    const Pairs = Base.Pairs
else
    const Pairs = Iterators.Pairs
end


"""
    pairs_inds(A, inds)
    pairs_inds(IndexLinear(), A, inds)
    pairs_inds(IndexCartesian(), A, inds)

Return an iterator of type `Pairs`, as does `Base.pairs`, but representing
the slice `A[inds]`. The result differs from `pairs(A[inds])` in that the
the keys of the pairs are `inds` rather than the new indices of the slice `A[inds]`.

A convenient way to call `pairs_inds` is via the macro `@pairs`.
"""
pairs_inds(itr, inds...) = Pairs(itr, inds)
pairs_inds(itr, inds) = Pairs(itr, inds)
pairs_inds(itr::AbstractArray, inds...) = pairs_inds(IndexCartesian(), itr, inds...)
pairs_inds(itr::AbstractVector, inds...) = pairs_inds(IndexLinear(), itr, inds...)

# Note the asymmetry below: This reflects the asymmetry in Base.
# CartesianIndices((2:4, 2:4)) and LinearIndices((2:4,)) have very
# different semantics.
#pairs_inds(::IndexCartesian, itr, inds...) = Pairs(itr, CartesianIndices(itr)[inds...])
pairs_inds(::IndexCartesian, itr, inds...) = Pairs(itr, CartesianIndices(inds))
pairs_inds(::IndexLinear, itr, inds...) = Pairs(itr, LinearIndices(itr)[inds...])

# This method is missing from Base. The equivalent with one key is defined.
# This would allow `pairs(zeros(2,2))[2, 2]`
# Base.getindex(v::Pairs, keys...) = getfield(v, :data)[keys...]

function _pairs_expr(ex, inds=nothing)
    if Meta.isexpr(ex, :ref)
        ex = Base.replace_ref_begin_end!(ex)
        ptup = isnothing(inds) ? (:pairs_inds,) : (:pairs_inds, inds)
        if Meta.isexpr(ex, :ref)
            ex = Expr(:call, ptup..., ex.args...)
        else # ex replaced by let ...; foo[...]; end
            @assert Meta.isexpr(ex, :let) && Meta.isexpr(ex.args[2], :ref)
            ex.args[2] = Expr(:call, ptup..., ex.args[2].args...)
        end
        return Expr(:&&, true, esc(ex))
    else
        return Expr(:call, :pairs, esc(ex))
    end
end

"""
    @pairs(A[inds])
    @pairs(IndexLinear(), A[inds])
    @pairs(IndexCartesian(), A[inds])

Return an instance of `Pairs`, as does `Base.pairs`, but the
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

# Examples
```julia-repl
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
"""
macro pairs(ex)
   return _pairs_expr(ex)
end

macro pairs(inds, ex)
   return _pairs_expr(ex, inds)
end

end # module PairTools
