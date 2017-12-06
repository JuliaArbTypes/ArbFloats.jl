# one parameter predicates

"""Returns nonzero iff the midpoint and radius of x are both finite floating-point numbers, i.e. not infinities or NaN."""
function isfinite(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_is_finite), Int, (Ref{ArbFloat{P}},), x)
end

"""isnan or isinf"""
function notfinite(x::ArbFloat{P}) where {P}
    return 0 == ccall(@libarb(arb_is_finite), Int, (Ref{ArbFloat{P}},), x)
end

function isnan(x::ArbFloat{P}) where {P}
    return isnan(convert(ArfFloat{P},x))
end
function notnan(x::ArbFloat{P}) where {P}
    return notnan(convert(ArfFloat{P},x))
end

function isinf(x::ArbFloat{P}) where {P}
    return isinf(convert(ArfFloat{P},x))
end
function notinf(x::ArbFloat{P}) where {P}
    return notinf(convert(ArfFloat{P},x))
end

function isposinf(x::ArbFloat{P}) where {P}
    return isposinf(convert(ArfFloat{P},x))
end
function notposinf(x::ArbFloat{P}) where {P}
    return notposinf(convert(ArfFloat{P},x))
end

function isneginf(x::ArbFloat{P}) where {P}
    return isneginf(convert(ArfFloat{P},x))
end
function notneginf(x::ArbFloat{P}) where {P}
    return notneginf(convert(ArfFloat{P},x))
end


"""midpoint(x) and radius(x) are zero"""
function iszero(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_is_zero), Int, (Ref{ArbFloat{P}},), x)
end
"""true iff midpoint(x) or radius(x) are not zero"""
function notzero(x::ArbFloat{P}) where {P}
    return 0 == ccall(@libarb(arb_is_zero), Int, (Ref{ArbFloat{P}},), x)
end
notzero(x::T) where {T <: Real} = (x != zero(T))

"""true iff zero is not within [upperbound(x), lowerbound(x)]"""
function nonzero(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_is_nonzero), Int, (Ref{ArbFloat{P}},), x)
end
nonzero(x::T) where {T <: Real} = (x != zero(T))

"""true iff midpoint(x) is one and radius(x) is zero"""
function isone(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_is_one), Int, (Ref{ArbFloat{P}},), x)
end
isone(x::T) where {T <: Real} = (x == one(T))

"""true iff midpoint(x) is not one or midpoint(x) is one and radius(x) is nonzero"""
function notone(x::ArbFloat{P}) where {P}
    return 0 == ccall(@libarb(arb_is_one), Int, (Ref{ArbFloat{P}},), x)
end
notone(x::T) where {T <: Real} = (x != one(T))

"""true iff radius is zero"""
function isexact(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_is_exact), Int, (Ref{ArbFloat{P}},), x)
end
"""true iff radius is nonzero"""
function notexact(x::ArbFloat{P}) where {P}
    return 0 == ccall(@libarb(arb_is_exact), Int, (Ref{ArbFloat{P}},), x)
end

isexact(x::T) where {T <: Integer} = true
notexact(x::T) where {T <: Integer} = false

"""true iff midpoint(x) is an integer and radius(x) is zero"""
function isinteger(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_is_int), Int, (Ref{ArbFloat{P}},), x)
end
"""true iff midpoint(x) is not an integer or radius(x) is nonzero"""
function notinteger(x::ArbFloat{P}) where {P}
    return 0 == ccall(@libarb(arb_is_int), Int, (Ref{ArbFloat{P}},), x)
end

notinteger(x::T) where {T <: Integer} = false

"""true iff lowerbound(x) is positive"""
function ispositive(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_is_positive), Int, (Ref{ArbFloat{P}},), x)
end

"""true iff upperbound(x) is negative"""
function isnegative(x::ArbFloat{P}) where {P}
    return  0 != ccall(@libarb(arb_is_negative), Int, (Ref{ArbFloat{P}},), x)
end

"""true iff upperbound(x) is zero or negative"""
function notpositive(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_is_nonpositive), Int, (Ref{ArbFloat{P}},), x)
end

"""true iff lowerbound(x) is zero or positive"""
function notnegative(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_is_nonnegative), Int, (Ref{ArbFloat{P}},), x)
end

# two parameter predicates

"""true iff midpoint(x)==midpoint(y) and radius(x)==radius(y)"""
function areequal(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_equal), Int, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), x, y)
end


"""true iff midpoint(x)!=midpoint(y) or radius(x)!=radius(y)"""
function notequal(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
    return 0 == ccall(@libarb(arb_equal), Int, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), x, y)
end

"""true iff x and y have a common point"""
function overlap(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_overlaps), Int, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), x, y)
end

"""true iff x and y have no common point"""
function donotoverlap(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
    return 0 == ccall(@libarb(arb_overlaps), Int, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), x, y)
end

"""true iff x spans (covers) all of y"""
function contains(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_contains), Int, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), x, y)
end

"""true iff y spans (covers) all of x"""
function iscontainedby(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_contains), Int, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), y, x)
end

"""true iff x does not span (cover) all of y"""
function doesnotcontain(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_contains), Int, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), x, y)
end

"""true iff y does not span (cover) all of x"""
function isnotcontainedby(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
    return 0 == ccall(@libarb(arb_contains), Int, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), y, x)
end

"""true if it is quite likely that the arguments indicate the same value"""
function approxeq(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
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

(≊)(x::ArbFloat{P}, y::ArbFloat{P}) where {P} = approxeq(x,y)
for F in (:overlap, :donotoverlap, :contains, :doesnotcontain, :iscontainedby, :isnotcontainedby, :approxeq)
  @eval ($F)(x::ArbFloat{P}, y::ArbFloat{Q}) where {P,Q} = ($F)(promote(x,y)...)
end

"""true iff x contains an integer"""
function includes_integer(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_contains_int), Int, (Ref{ArbFloat{P}},), x)
end

"""true iff x does not contain an integer"""
function excludes_integer(x::ArbFloat{P}) where {P}
    return 0 == ccall(@libarb(arb_contains_int), Int, (Ref{ArbFloat{P}},), x)
end

"""true iff x contains zero"""
function includes_zero(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_contains_int), Int, (Ref{ArbFloat{P}},), x)
end

"""true iff x does not contain zero"""
function excludes_zero(x::ArbFloat{P}) where {P}
    return 0 == ccall(@libarb(arb_contains_int), Int, (Ref{ArbFloat{P}},), x)
end

"""true iff x contains a positive value"""
function includes_positive(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_contains_positive), Int, (Ref{ArbFloat{P}},), x)
end

"""true iff x contains a negative value"""
function includes_negative(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_contains_negative), Int, (Ref{ArbFloat{P}},), x)
end

"""true iff x contains a nonpositive value"""
function includes_nonpositive(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_contains_nonpositive), Int, (Ref{ArbFloat{P}},), x)
end

"""true iff x contains a nonnegative value"""
function includes_nonnegative(x::ArbFloat{P}) where {P}
    return 0 != ccall(@libarb(arb_contains_nonnegative), Int, (Ptr{ArbFloat{ArbFloat{P}}},), x)
end
