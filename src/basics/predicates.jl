# one parameter predicates

"""Returns nonzero iff the midpoint and radius of x are both finite floating-point numbers, i.e. not infinities or NaN."""
function isfinite{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_is_finite), Int, (Ptr{T},), &x)
end

"""isnan or isinf"""
function notfinite{T<:ArbFloat}(x::T)
    return 0 == ccall(@libarb(arb_is_finite), Int, (Ptr{ArbFloat{P}},), &x)
end

function isnan{T<:ArbFloat}(x::T)
    P = precision(T)
    y = convert(ArfFloat{P},x)
    return 0 != ccall(@libarb(arf_is_nan), Int, (Ptr{ArfFloat},), &y)
end

function notnan{T<:ArbFloat}(x::T)
    P = precision(T)
    y = ArfFloat(x)
    return 0 == ccall(@libarb(arf_is_nan), Int, (Ptr{ArfFloat},), &y)
end

function isinf{T<:ArbFloat}(x::T)
    P = precision(T)
    y = ArfFloat(x)
    return 0 != ccall(@libarb(arf_is_inf), Int, (Ptr{ArfFloat},), &y)
end

function notinf{T<:ArbFloat}(x::T)
    y = ArfFloat(x)
    return 0 == ccall(@libarb(arf_is_inf), Int, (Ptr{ArfFloat},), &y)
end

function isposinf{T<:ArbFloat}(x::T)
    y = ArfFloat(x)
    return 0 != ccall(@libarb(arf_is_posinf), Int, (Ptr{ArfFloat},), &y)
end

function notposinf{T<:ArbFloat}(x::T)
    y = ArfFloat(x)
    return 0 == ccall(@libarb(arf_is_posinf), Int, (Ptr{ArfFloat},), &y)
end

function isneginf{T<:ArbFloat}(x::T)
    y = ArfFloat(x)
    return 0 != ccall(@libarb(arf_is_neginf), Int, (Ptr{ArfFloat},), &y)
end

function notneginf{T<:ArbFloat}(x::T)
    y = ArfFloat(x)
    return 0 == ccall(@libarb(arf_is_neginf), Int, (Ptr{ArfFloat},), &y)
end


"""midpoint(x) and radius(x) are zero"""
function iszero{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_is_zero), Int, (Ptr{T},), &x)
end

"""true iff midpoint(x) or radius(x) are not zero"""
function notzero{T<:ArbFloat}(x::T)
    return 0 == ccall(@libarb(arb_is_zero), Int, (Ptr{T},), &x)
end

notzero{T<:Real}(x::T) = (x != zero(T))

"""true iff zero is not within [upperbound(x), lowerbound(x)]"""
function nonzero{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_is_nonzero), Int, (Ptr{T},), &x)
end

nonzero{T<:Real}(x::T) = (x != zero(T))

"""true iff midpoint(x) is one and radius(x) is zero"""
function isone{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_is_one), Int, (Ptr{T},), &x)
end

isone{T<:Real}(x::T) = (x == one(T))

"""true iff midpoint(x) is not one or midpoint(x) is one and radius(x) is nonzero"""
function notone{T<:ArbFloat}(x::T)
    return 0 == ccall(@libarb(arb_is_one), Int, (Ptr{T},), &x)
end

notone{T<:Real}(x::T) = (x != one(T))

"""true iff radius is zero"""
function isexact{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_is_exact), Int, (Ptr{T},), &x)
end

"""true iff radius is nonzero"""
function notexact{T<:ArbFloat}(x::T)
    return 0 == ccall(@libarb(arb_is_exact), Int, (Ptr{T},), &x)
end

isexact{T<:Integer}(x::T) = true
notexact{T<:Integer}(x::T) = false

"""true iff midpoint(x) is an integer and radius(x) is zero"""
function isinteger{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_is_int), Int, (Ptr{T},), &x)
end

"""true iff midpoint(x) is not an integer or radius(x) is nonzero"""
function notinteger{T<:ArbFloat}(x::T)
    return 0 == ccall(@libarb(arb_is_int), Int, (Ptr{T},), &x)
end

isinteger{T<:Integer}(x::T) = true
notinteger{T<:Integer}(x::T) = false

"""true iff lowerbound(x) is positive"""
function ispositive{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_is_positive), Int, (Ptr{T},), &x)
end

"""true iff upperbound(x) is negative"""
function isnegative{T<:ArbFloat}(x::T)
    return  0 != ccall(@libarb(arb_is_negative), Int, (Ptr{T},), &x)
end

"""true iff upperbound(x) is zero or negative"""
function notpositive{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_is_nonpositive), Int, (Ptr{T},), &x)
end
excludesPositive{P}(x::ArbFloat{P}) = notpositive(x)

"""true iff lowerbound(x) is zero or positive"""
function notnegative{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_is_nonnegative), Int, (Ptr{T},), &x)
end
excludesNegative{P}(x::ArbFloat{P}) = notnegative(x)

# two parameter predicates

"""true iff midpoint(x)==midpoint(y) and radius(x)==radius(y)"""
function areequal{T<:ArbFloat}(x::T, y::T)
    return 0 != ccall(@libarb(arb_equal), Int, (Ptr{T}, Ptr{T}), &x, &y)
end


"""true iff midpoint(x)!=midpoint(y) or radius(x)!=radius(y)"""
function notequal{T<:ArbFloat}(x::T, y::T)
    return 0 == ccall(@libarb(arb_equal), Int, (Ptr{T}, Ptr{T}), &x, &y)
end

"""true iff x and y have a common point"""
function overlap{T<:ArbFloat}(x::T, y::T)
    return 0 != ccall(@libarb(arb_overlaps), Int, (Ptr{T}, Ptr{T}), &x, &y)
end

"""true iff x and y have no common point"""
function donotoverlap{T<:ArbFloat}(x::T, y::T)
    return 0 == ccall(@libarb(arb_overlaps), Int, (Ptr{T}, Ptr{T}), &x, &y)
end

"""true iff x spans (covers) all of y"""
function contains{T<:ArbFloat}(x::T, y::T)
    return 0 != ccall(@libarb(arb_contains), Int, (Ptr{T}, Ptr{T}), &x, &y)
end

"""true iff y spans (covers) all of x"""
function iscontainedby{T<:ArbFloat}(x::T, y::T)
    return 0 != ccall(@libarb(arb_contains), Int, (Ptr{T}, Ptr{T}), &y, &x)
end

"""true iff x does not span (cover) all of y"""
function doesnotcontain{T<:ArbFloat}(x::T, y::T)
    return 0 != ccall(@libarb(arb_contains), Int, (Ptr{T}, Ptr{T}), &x, &y)
end

"""true iff y does not span (cover) all of x"""
function isnotcontainedby{T<:ArbFloat}(x::T, y::T)
    return 0 == ccall(@libarb(arb_contains), Int, (Ptr{T}, Ptr{T}), &y, &x)
end

"""true if it is quite likely that the arguments indicate the same value"""
function approxeq{T<:ArbFloat}(x::T, y::T)
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

(≊){T<:ArbFloat}(x::T, y::T) = approxeq(x,y)
for F in (:overlap, :donotoverlap, :contains, :doesnotcontain, :iscontainedby, :isnotcontainedby, :approxeq)
  @eval ($F){P,Q}(x::ArbFloat{P}, y::ArbFloat{Q}) = ($F)(promote(x,y)...)
end

"""true iff x contains an integer"""
function includesAnInteger{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_contains_int), Int, (Ptr{T},), &x)
end

"""true iff x does not contain an integer"""
function excludesIntegers{T<:ArbFloat}(x::T)
    return 0 == ccall(@libarb(arb_contains_int), Int, (Ptr{T},), &x)
end

"""true iff x contains zero"""
function includesZero{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_contains_int), Int, (Ptr{T},), &x)
end

"""true iff x does not contain zero"""
function excludesZero{T<:ArbFloat}(x::T)
    return 0 == ccall(@libarb(arb_contains_int), Int, (Ptr{T},), &x)
end

"""true iff x contains a positive value"""
function includesPositive{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_contains_positive), Int, (Ptr{T},), &x)
end

"""true iff x contains a negative value"""
function includesNegative{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_contains_negative), Int, (Ptr{T},), &x)
end

"""true iff x contains a nonpositive value"""
function includesNonpositive{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_contains_nonpositive), Int, (Ptr{T},), &x)
end

"""true iff x contains a nonnegative value"""
function includesNonnegative{T<:ArbFloat}(x::T)
    return 0 != ccall(@libarb(arb_contains_nonnegative), Int, (Ptr{ArbFloat{T}},), &x)
end
