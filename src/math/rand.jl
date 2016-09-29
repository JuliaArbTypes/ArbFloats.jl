#=
    Results should be as sampling from a uniform distribution in [0,1).
    Written to do that rather well, rather than to do that very fast.
=#    

function rand1{P}(::Type{ArbFloat{P}})
    i = rand(Int128)
    while i ==  typemin(Int128) || abs(i) >= (typemax(Int128)-1)
       i = rand(Int128)
    end
    bf = BigFloat(abs(i)) / BigFloat(typemax(Int128))
    return ArbFloat{P}(bf)
end


function rand{P}(::Type{ArbFloat{P}})
    n = cld(P,128)
    rs = zeros(ArbFloat{P}, n)
    for i in 1:n
        rs[i] = rand1(ArbFloat{P})
    end
    r = reduce(*, one(ArbFloat{P}), rs)
    if n > 1
       if n == 2
          r = sqrt(r)
       else
          r = r^(1/n)
       end
    end
    return midpoint(r)
end

function rand{P}(::Type{ArbFloat{P}}, N::Int)
    n = max(1, N)
    rs = zeros(ArbFloat{P}, n)
    for i in 1:n
        rs[i] = rand(ArbFloat{P})
    end
    return rs
end



function randn{P}(::Type{ArbFloat{P}})
    n = cld(P,64)
    rs = zeros(ArbFloat{P}, n)
    for i in 1:n
        rs[i] = randn(Float64)
    end
    r = reduce(*, one(ArbFloat{P}), rs)
    return n==1 ? r : (n==2 ? sqrt(r) : r^(1/n))
end

function randn{P}(::Type{ArbFloat{P}}, N::Int)
    n = max(1,N)
    rs = zeros(ArbFloat{P}, n)
    for i in 1:n
        rs[i] = randn(ArbFloat{P})
     end
     return rs
end



