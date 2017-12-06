function midpoint_radius(x::ArbFloat{P}) where {P}
    return midpoint(x), radius(x)
end

function midpoint_radius(midpt::ArbFloat{P}, radius::ArbFloat{P}) where {P}
    mid = midpoint(midpt)
    rad = midpoint(radius)
    ccall(@libarb(arb_add_error), Void, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), mid, rad)
    return mid
end

function midpoint_radius(mid::Float64, rad::Float64)
    m = convert(ArbFloat, mid)
    r = convert(ArbFloat, rad)
    return midpoint_radius(m, r)
end
function midpoint_radius(mid::ArbFloat{P}, rad::Float64) where {P}
    r = convert(ArbFloat{P}, rad)
    return midpoint_radius(mid, r)
end
function midpoint_radius(mid::ArfFloat{P}, rad::Float64) where {P}
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

function bounding_midpoint(a::T) where {T <: ArbFloat}
    halflo = lowerbound(a) * 0.5
    halfhi = upperbound(a) * 0.5
    return midpoint(halflo + halfhi)
end

function bounding_radius(a::T) where {T <: ArbFloat}
    halflo = lowerbound(a) * 0.5
    halfhi = upperbound(a) * 0.5
    return midpoint(halfhi - halflo)
end

function bounding_midpoint_radius(a::T) where {T <: ArbFloat}
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
union(a::T) where {T <: ArbFloat} = a

function union(a::T, b::T) where {T <: ArbFloat}
    P = precision(T)
    z = ArbFloat{P}{}
    ccall(@libarb(arb_union), Void, (Ptr{T}, Ptr{T}, Ptr{T}, Clong), z, &a, &b, P)
    return z
end
function union(a::T, b::T, c::T) where {T <: ArbFloat}
    z1 = union(a,b)
    z2 = union(z1,c)
    return z2
end
function union(a::T, b::T, c::T, d::T) where {T <: ArbFloat}
    z1 = union(a,b)
    z2 = union(z1,c)
    z3 = union(z2,d)
    return z3
end

narrow(a::T) where {T <: ArbFloat} = a

function narrow(a::T, b::T) where {T <: ArbFloat}
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    lo = max(alo,blo)
    hi = min(ahi,bhi)
    return union(lo,hi)
end

function narrow(a::T, b::T, c::T) where {T <: ArbFloat}
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    clo, chi = bounds(c)
    lo = max(max(alo,blo),clo)
    hi = min(min(ahi,bhi),chi)
    return union(lo,hi)
end

function narrow(a::T, b::T, c::T, d::T) where {T <: ArbFloat}
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    clo, chi = bounds(c)
    dlo, dhi = bounds(d)
    lo = max(max(alo,blo),max(clo,dlo))
    hi = min(min(ahi,bhi),min(chi,clo))
    return union(lo,hi)
end

intersect(a::T) where {T <: ArbFloat} = a

function intersect(a::T, b::T) where {T <: ArbFloat}
    P = precision(T)
    z = initializer(ArbFloat{P})
    if donotoverlap(a,b)
        ccall(@libarb(arb_indeterminate), Void, (Ptr{T},), z)
    else
        alo,ahi = bounds(a)
        blo,bhi = bounds(b)
        lo,hi = minmax(max(alo,blo), min(ahi,bhi))
        bounded(z, lo, hi)
    end
    return z
end

function intersect(a::T, b::T, c::T) where {T <: ArbFloat}
   i1 = intersect(a,b)
   i2 = intersect(i1,c)
   return i2
end

function intersect(a::T, b::T, c::T, d::T) where {T <: ArbFloat}
   i1 = intersect(a,b)
   i2 = intersect(c,d)
   return intersect(i1,i2)
end

function bounded(z::ArbFloat{P}, lo::ArbFloat{P}, hi::ArbFloat{P}) where {P}
    lo2 = convert(ArfFloat{P}, lo)
    hi2 = convert(ArfFloat{P}, hi)
    ccall(@libarb(arb_set_interval_arf), Void, (Ref{ArbFloat{P}}, Ptr{ArfFloat{P}}, Ptr{ArfFloat{P}}, Int64), z, &lo2, &hi2, P%Int64)
    return z
end
function bounded(lo::T, hi::T) where {T <: ArbFloat}
    P = precision(T)
    z = initializer(ArbFloat{P})
    return bounded(z,lo,hi)
end
function boundedrange(mid::T, rad::T) where {T <: ArbFloat}
    P = precision(T)
    z = initializer(ArbFloat{P})
    lo = mid-rad
    hi = mid+rad
    return bounded(z,lo,hi)
end


