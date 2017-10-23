sort(xs::Vector{T}, lt::Function=<, rev::Bool=false) where {T <: ArbFloat} = sort(xs, alg=QuickSort, lt=lt, rev=rev)
function sort_intervals(xs::Vector{T}, rev::Bool=false) where {T <: ArbFloat}
   lessthan = rev ? pred : succ  
   return sort(xs, alg=MergeSort, lt=lessthan)
end
