# one parameter predicates

"""Returns nonzero iff the midpoint and radius of x are both finite floating-point numbers, i.e. not infinities or NaN."""
function isfinite{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_is_finite), Int, (Ptr{ArbFloat{P}},), &x)
end

"""isnan or isinf"""
function notfinite{P}(x::ArbFloat{P})
    return 0 == ccall(@libarb(arb_is_finite), Int, (Ptr{ArbFloat{P}},), &x)
end

function isnan{P}(x::ArbFloat{P})
    return isnan(convert(ArfFloat{P},x))
end
function notnan{P}(x::ArbFloat{P})
    return notnan(convert(ArfFloat{P},x))
end

function isinf{P}(x::ArbFloat{P})
    return isinf(convert(ArfFloat{P},x))
end
function notinf{P}(x::ArbFloat{P})
    return notinf(convert(ArfFloat{P},x))
end

function isposinf{P}(x::ArbFloat{P})
    return isposinf(convert(ArfFloat{P},x))
end
function notposinf{P}(x::ArbFloat{P})
    return notposinf(convert(ArfFloat{P},x))
end

function isneginf{P}(x::ArbFloat{P})
    return isneginf(convert(ArfFloat{P},x))
end
function notneginf{P}(x::ArbFloat{P})
    return notneginf(convert(ArfFloat{P},x))
end


"""midpoint(x) and radius(x) are zero"""
function iszero{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_is_zero), Int, (Ptr{ArbFloat{P}},), &x)
end
"""true iff midpoint(x) or radius(x) are not zero"""
function notzero{P}(x::ArbFloat{P})
    return 0 == ccall(@libarb(arb_is_zero), Int, (Ptr{ArbFloat{P}},), &x)
end
notzero{T<:Real}(x::T) = (x != zero(T))

"""true iff zero is not within [upperbound(x), lowerbound(x)]"""
function nonzero{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_is_nonzero), Int, (Ptr{ArbFloat{P}},), &x)
end
nonzero{T<:Real}(x::T) = (x != zero(T))

"""true iff midpoint(x) is one and radius(x) is zero"""
function isone{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_is_one), Int, (Ptr{ArbFloat{P}},), &x)
end
isone{T<:Real}(x::T) = (x == one(T))

"""true iff midpoint(x) is not one or midpoint(x) is one and radius(x) is nonzero"""
function notone{P}(x::ArbFloat{P})
    return 0 == ccall(@libarb(arb_is_one), Int, (Ptr{ArbFloat{P}},), &x)
end
notone{T<:Real}(x::T) = (x != one(T))

"""true iff radius is zero"""
function isexact{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_is_exact), Int, (Ptr{ArbFloat{P}},), &x)
end
"""true iff radius is nonzero"""
function notexact{P}(x::ArbFloat{P})
    return 0 == ccall(@libarb(arb_is_exact), Int, (Ptr{ArbFloat{P}},), &x)
end

isexact{T<:Integer}(x::T) = true
notexact{T<:Integer}(x::T) = false

"""true iff midpoint(x) is an integer and radius(x) is zero"""
function isinteger{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_is_int), Int, (Ptr{ArbFloat{P}},), &x)
end
"""true iff midpoint(x) is not an integer or radius(x) is nonzero"""
function notinteger{P}(x::ArbFloat{P})
    return 0 == ccall(@libarb(arb_is_int), Int, (Ptr{ArbFloat{P}},), &x)
end

notinteger{T<:Integer}(x::T) = false

"""true iff lowerbound(x) is positive"""
function ispositive{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_is_positive), Int, (Ptr{ArbFloat{P}},), &x)
end

"""true iff upperbound(x) is negative"""
function isnegative{P}(x::ArbFloat{P})
    return  0 != ccall(@libarb(arb_is_negative), Int, (Ptr{ArbFloat{P}},), &x)
end

"""true iff upperbound(x) is zero or negative"""
function notpositive{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_is_nonpositive), Int, (Ptr{ArbFloat{P}},), &x)
end

"""true iff lowerbound(x) is zero or positive"""
function notnegative{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_is_nonnegative), Int, (Ptr{ArbFloat{P}},), &x)
end

# two parameter predicates

"""true iff midpoint(x)==midpoint(y) and radius(x)==radius(y)"""
function areequal{P}(x::ArbFloat{P}, y::ArbFloat{P})
    return 0 != ccall(@libarb(arb_equal), Int, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y)
end


"""true iff midpoint(x)!=midpoint(y) or radius(x)!=radius(y)"""
function notequal{P}(x::ArbFloat{P}, y::ArbFloat{P})
    return 0 == ccall(@libarb(arb_equal), Int, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y)
end

"""true iff x and y have a common point"""
function overlap{P}(x::ArbFloat{P}, y::ArbFloat{P})
    return 0 != ccall(@libarb(arb_overlaps), Int, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y)
end

"""true iff x and y have no common point"""
function donotoverlap{P}(x::ArbFloat{P}, y::ArbFloat{P})
    return 0 == ccall(@libarb(arb_overlaps), Int, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y)
end

"""true iff x spans (covers) all of y"""
function contains{P}(x::ArbFloat{P}, y::ArbFloat{P})
    return 0 != ccall(@libarb(arb_contains), Int, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y)
end

"""true iff y spans (covers) all of x"""
function iscontainedby{P}(x::ArbFloat{P}, y::ArbFloat{P})
    return 0 != ccall(@libarb(arb_contains), Int, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &y, &x)
end

"""true iff x does not span (cover) all of y"""
function doesnotcontain{P}(x::ArbFloat{P}, y::ArbFloat{P})
    return 0 != ccall(@libarb(arb_contains), Int, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y)
end

"""true iff y does not span (cover) all of x"""
function isnotcontainedby{P}(x::ArbFloat{P}, y::ArbFloat{P})
    return 0 == ccall(@libarb(arb_contains), Int, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &y, &x)
end

"""true if it is quite likely that the arguments indicate the same value"""
function approxeq{P}(x::ArbFloat{P}, y::ArbFloat{P})
    z =
        if contains(x,y)
           true
        elseif contains(y,x)
           true
        else
           x = tidy(x)
           y = tidy(y)
           contains(x,y) || contains(y,x)
        end
    return z
end

(≊){P}(x::ArbFloat{P}, y::ArbFloat{P}) = approxeq(x,y)
for F in (:overlap, :donotoverlap, :contains, :doesnotcontain, :iscontainedby, :isnotcontainedby, :approxeq)
  @eval ($F){P,Q}(x::ArbFloat{P}, y::ArbFloat{Q}) = ($F)(promote(x,y)...)
end

"""true iff x contains an integer"""
function includes_integer{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_contains_int), Int, (Ptr{ArbFloat{P}},), &x)
end

"""true iff x does not contain an integer"""
function excludes_integer{P}(x::ArbFloat{P})
    return 0 == ccall(@libarb(arb_contains_int), Int, (Ptr{ArbFloat{P}},), &x)
end

"""true iff x contains zero"""
function includes_zero{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_contains_int), Int, (Ptr{ArbFloat{P}},), &x)
end

"""true iff x does not contain zero"""
function excludes_zero{P}(x::ArbFloat{P})
    return 0 == ccall(@libarb(arb_contains_int), Int, (Ptr{ArbFloat{P}},), &x)
end

"""true iff x contains a positive value"""
function includes_positive{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_contains_positive), Int, (Ptr{ArbFloat{P}},), &x)
end

"""true iff x contains a negative value"""
function includes_negative{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_contains_negative), Int, (Ptr{ArbFloat{P}},), &x)
end

"""true iff x contains a nonpositive value"""
function includes_nonpositive{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_contains_nonpositive), Int, (Ptr{ArbFloat{P}},), &x)
end

"""true iff x contains a nonnegative value"""
function includes_nonnegative{P}(x::ArbFloat{P})
    return 0 != ccall(@libarb(arb_contains_nonnegative), Int, (Ptr{ArbFloat{ArbFloat{P}}},), &x)
end
