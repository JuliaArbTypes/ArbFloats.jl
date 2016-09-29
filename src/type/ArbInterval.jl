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
    mid = halflo + halfhi
    return mid
end

function bounding_radius{T<:ArbFloat}(a::T)
    halflo = lowerbound(a) * 0.5
    halfhi = upperbound(a) * 0.5
    rad = halfhi - halflo
    return rad
end

function bounding_midpoint_radius{T<:ArbFloat}(a::T)
    halflo = lowerbound(a) * 0.5
    halfhi = upperbound(a) * 0.5
    mid = halflo + halfhi
    rad = halfhi - halflo
    return midpoint_radius(mid, rad)
end


#=
void arb_union(arb_t z, const arb_t x, const arb_t y, slong prec)¶
Sets z to a ball containing both x and y.
=#
union{T<:ArbFloat}(a::T) = a

function union{T<:ArbFloat}(a::T, b::T)
    P = precision(T)
    z = T()
    ccall(@libarb(arb_union), Void, (Ptr{T}, Ptr{T}, Ptr{T}, Int), &z, &a, &b, P)
    return z
end
function union{T<:ArbFloat}(a::Vector{T})
    return reduce(union, zero(T), a)
end
function union{T<:ArbFloat}(xs...)
    return reduce(union, zero(T), [xs...])
end


intersect{T<:ArbFloat}(a::T) = a

function intersect{T<:ArbFloat}(a::T, b::T)
    P = precision(T)
    z = T()
    if donotoverlap(a,b)
      ccall(@libarb(arb_indeterminate), Void, (Ptr{T},), &z)
    else
        alo,ahi = bounds(a)
        blo,bhi = bounds(b)
        lo,hi = minmax(max(alo,blo), min(ahi,bhi))
        z = union(lo, hi)
    end
    return z
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


function bounded{P}(z::ArbFloat{P}, lo::ArbFloat{P}, hi::ArbFloat{P})
    lo2 = convert(ArfFloat{P}, lo)
    hi2 = convert(ArfFloat{P}, hi)
    ccall(@libarb(arb_set_interval_arf), Void, (Ptr{ArbFloat{P}}, Ptr{ArfFloat{P}}, Ptr{ArfFloat{P}}, Int64), &z, &lo2, &hi2, P%Int64)
    return z
end
function bounded{T<:ArbFloat}(lo::T, hi::T)
    P = precision(T)
    z = ArbFloat{P}()
    return bounded(z,lo,hi)
end
function boundedrange{T<:ArbFloat}(mid::T, rad::T)
    P = precision(T)
    z = ArbFloat{P}()
    lo = mid-rad
    hi = mid+rad
    return bounded(z,lo,hi)
end


