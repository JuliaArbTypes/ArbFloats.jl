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

intersect{T<:ArbFloat}(a::T) = a

function intersect{T<:ArbFloat}(a::T, b::T)
    P = precision(T)
    z = initializer(ArbFloat{P})
    if donotoverlap(a,b)
        ccall(@libarb(arb_indeterminant), Void, (Ptr{T},), &z)
    else
        alo,ahi = bounds(a)
        blo,bhi = bounds(b)
        lo,hi = minmax(max(alo,blo), min(ahi,bhi))
        bounded(z, lo, hi)
    end
    return z
end

function intersect{T<:ArbFloat}(a::T, b::T, c::T)
   i1 = intersect(a,b)
   i2 = intersect(i1,c)
   return i2
end

function intersect{T<:ArbFloat}(a::T, b::T, c::T, d::T)
   i1 = intersect(a,b)
   i2 = intersect(c,d)
   return intersect(i1,i2)
end

function bounded{P}(z::ArbFloat{P}, lo::ArbFloat{P}, hi::ArbFloat{P})
    lo2 = convert(ArfFloat{P}, lo)
    hi2 = convert(ArfFloat{P}, hi)
    ccall(@libarb(arb_set_interval_arf), Void, (Ptr{ArbFloat{P}}, Ptr{ArfFloat{P}}, Ptr{ArfFloat{P}}, Int64), &z, &lo2, &hi2, P%Int64)
    return z
end
function bounded{T<:ArbFloat}(lo::T, hi::T)
    z = initializer(T)
    return bounded(z,lo,hi)
end
function boundedrange{T<:ArbFloat}(mid::T, rad::T)
    z = initializer(T)
    lo = mid-rad
    hi = mid+rad
    return bounded(z,lo,hi)
end


