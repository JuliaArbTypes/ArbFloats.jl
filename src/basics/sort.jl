sort{T<:ArbFloat}(xs::Vector{T}, lt::Function=<, rev::Bool=false) = sort(xs, alg=QuickSort, lt=lt, rev=rev)
strictsort{T<:ArbFloat}(xs::Vector{T}, lt::Function=succ, rev::Bool=false) = sort(xs, alg=MergeSort, lt=lt, rev=rev)
