function midpoint_radius{P}(x::ArbFloat{P})
    return midpoint(x), radius(x)
end

function midpoint_radius{P}(midpt::ArbFloat{P}, radius::ArbFloat{P})
    mid = midpoint(midpt)
    rad = midpoint(radius)
    ccall(@libarb(arb_add_error), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &mid, &rad)
    return mid
end

function midpoint_radius(mid::Float64, rad::Float64)
    m = convert(ArbFloat, mid)
    r = convert(ArbFloat, rad)
    return midpoint_radius(m, r)
end
function midpoint_radius{P}(mid::ArbFloat{P}, rad::Float64)
    r = convert(ArbFloat{P}, rad)
    return midpoint_radius(mid, r)
end
function midpoint_radius{P}(mid::ArfFloat{P}, rad::Float64)
    m = convert(ArbFloat{P}, mid)
    r = convert(ArbFloat{P}, rad)
    return midpoint_radius(m, r)
end
function midpoint_radius(mid::String, rad::String)
    P = precision(ArbFloat)
    m = ArbFloat(mid)
    r = ArbFloat(rad)
    return midpoint_radius(m, r)
end
function midpoint_radius(mid, rad)
    P = precision(ArbFloat)
    m = convert(ArbFloat{P}, mid)
    r = convert(ArbFloat{P}, rad)
    return midpoint_radius(m, r)
end

function bounding_midpoint{T<:ArbFloat}(a::T)
    halflo = lowerbound(a) * 0.5
    halfhi = upperbound(a) * 0.5
    return midpoint(halflo + halfhi)
end

function bounding_radius{T<:ArbFloat}(a::T)
    halflo = lowerbound(a) * 0.5
    halfhi = upperbound(a) * 0.5
    return midpoint(halfhi - halflo)
end

function bounding_midpoint_radius{T<:ArbFloat}(a::T)
    halflo = lowerbound(a) * 0.5
    halfhi = upperbound(a) * 0.5
    mid = midpoint(halflo + halfhi)
    rad = midpoint(halfhi - halflo)
    return midpoint_radius(mid, rad)
end


#=
void arb_union(arb_t z, const arb_t x, const arb_t y, slong prec)¶
Sets z to a ball containing both x and y.
=#
union{T<:ArbFloat}(a::T) = a

function union{T<:ArbFloat}(a::T, b::T)
    P = precision(T)
    z = ArbFloat{P}{}
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
        ccall(@libarb(arb_indeterminate), Void, (Ptr{T},), &z)
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
    P = precision(T)
    z = initializer(ArbFloat{P})
    return bounded(z,lo,hi)
end
function boundedrange{T<:ArbFloat}(mid::T, rad::T)
    P = precision(T)
    z = initializer(ArbFloat{P})
    lo = mid-rad
    hi = mid+rad
    return bounded(z,lo,hi)
end


