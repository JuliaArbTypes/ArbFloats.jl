sort{T<:ArbFloat}(xs::Vector{T}, lt::Function=<, rev::Bool=false) = sort(xs, alg=QuickSort, lt=lt, rev=rev)
function sort_intervals{T<:ArbFloat}(xs::Vector{T}, rev::Bool=false)
   lessthan = rev ? pred : succ  
   return sort(xs, alg=MergeSort, lt=lessthan)
end
