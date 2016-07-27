
function union{T<:ArbFloat}(a::T, b::T)
    P = precision(T)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_union), Void, (Ptr{T}, Ptr{T}, Ptr{T}, Int64), &z, &a, &b, P%Int64)
    return z
end

function intersect{T<:ArbFloat}(a::T, b::T)
    P = precision(T)
    z = initializer(ArbFloat{P})
    if donotoverlap(a,b)
        ccall(@libarb(arb_indeterminant), Void, (Ptr{T},), &z)
    else
        alo,ahi = bounds(a)
        blo,bhi = bounds(b)
        if alo >= blo
           if bhi <= ahi
              bounded(z, alo, bhi)
           else
              bounded(z, alo, blo)
           end
        else
           if ahi <= bhi
              bounded(z, blo, ahi)
           else
              bounded(z, blo, alo)
           end
        end
    end
    return z
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


#=
    categorizing a floating-point value with respect to a floating-point value

    categorizing a radius value with respect to a radius value

    categorizing a floating-point value with respect to a radius value
    categorizing a radius value with respect to a floating-point value

    categorizing a floating-point value with respect to an interval value
    categorizing an interval value with respect to a floating-point value

    categorizing a radius value with respect to an interval value
    categorizing an interval value with respect to a radius value

    categorizing an interval value with respect to an interval value
=#

#=
following rounding.jl for RoundingMode declarations
=#
"""
      IntervalAboveFloat
      IntervalBelowFloat
      IntervalAroundFloat
      IntervalLoIsFloat
      IntervalHiIsFloat
"""
immutable IntravalMode{T} end

"""
     IntervalAboveFloat
"""
const IntervalAboveFloat = IntravalMode{:AboveFloat}()

"""
     IntervalBelowFloat
"""
const IntervalBelowFloat = IntravalMode{:BelowFloat}()

"""
     IntervalAroundFloat

The interval encloses the float, the float does not meet either interval bound.
"""
const IntervalAroundFloat = IntravalMode{:AroundFloat}()

"""
     IntervalLoIsFloat

The interval encloses the float, the float meets the lower interval bound.
"""
const IntervalLoIsFloat = IntravalMode{:LoIFloat}()

"""
     IntervalHiIsFloat

The interval encloses the float, the float meets the upper interval bound.
"""
const IntervalHiIsFloat = IntravalMode{:HiIsFloat}()


function about{T<:ArbFloat}(x::T)
  # signed least magnitude enclosing, signed largest magnitude enclosing
  lobound, hibound = bounds(x)
  # midpoint of span, radius of uncertainty
  midpt, radus = midpoint(x), radius(x)
  # diameter, circumference of uncertainty
  uradius         = Float64(radus)
  udiameter       = uradius+uradius
  ucircumference  = Float64(pi) * udiameter
  uvolume         = (pi*(4/3)) * uradius^3
  usurface        = (pi * 4) * uradius^2
  linearvolume    = uvolume^(1/3)
  linearsurface   = usurface^(1/2)
  return  lobound,hibound, midpt, uradius, udiameter, ucircumference, usurface, uvolume, linearsurface, linearvolume
end
