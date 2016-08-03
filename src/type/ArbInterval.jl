#=
void arb_union(arb_t z, const arb_t x, const arb_t y, slong prec)¶
Sets z to a ball containing both x and y.
=#
union{T<:ArbFloat}(a::T) = a

function union{T<:ArbFloat}(a::T, b::T)
    P = precision(T)
    z = initializer(T)
    ccall(@libarb(arb_union), Void, (Ptr{T}, Ptr{T}, Ptr{T}, Clong), &z, &a, &b, P)
    return z
end
function union{T<:ArbFloat}(a::T, b::T, c::T)
    z1 = union(a,b)
    z2 = union(z1,c)
    return z2
end
function union{T<:ArbFloat}(a::T, b::T, c::T, d::T)
    z1 = union(a,b)
    z2 = union(z1,c)
    z3 = union(z2,d)
    return z3
end

narrow{T<:ArbFloat}(a::T) = a

function narrow{T<:ArbFloat}(a::T, b::T)
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    lo = max(alo,blo)
    hi = min(ahi,bhi)
    return union(lo,hi)
end

function narrow{T<:ArbFloat}(a::T, b::T, c::T)
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    clo, chi = bounds(c)
    lo = max(max(alo,blo),clo)
    hi = min(min(ahi,bhi),chi)
    return union(lo,hi)
end

function narrow{T<:ArbFloat}(a::T, b::T, c::T, d::T)
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    clo, chi = bounds(c)
    dlo, dhi = bounds(d)
    lo = max(max(alo,blo),max(clo,dlo))
    hi = min(min(ahi,bhi),min(chi,clo))
    return union(lo,hi)
end



