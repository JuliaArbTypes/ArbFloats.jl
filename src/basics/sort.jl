sort{T<:ArbFloat}(xs::Vector{T}) = sort(xs, lt=<)
sort{T<:ArbFloat}(xs::Vector{T}, lt::Function=<) = sort(xs, lt=lt)
sort{T<:ArbFloat}(xs::Vector{T}, rev::Bool=false) = sort(xs, lt=<, rev=rev)
