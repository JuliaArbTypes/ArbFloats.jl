@inline digitsRequired(bitsOfPrecision) = ceil(Int, bitsOfPrecision*0.3010299956639812)

# rubric digit display counts
# values for stringsmall, stringcompact, string, stringlarge, stringall
#@enum EXTENT small=1 compact=2 medium=3 large=4 all=5
const small=1;
const compact=2;
const medium=3;
const large=4;
const all=5;

macro I16(x) 
    begin quote
        ($x)%Int16
    end end
end    

const midDigits = [ @I16(8), @I16(15), @I16(25), @I16(50), @I16(1200) ]
const radDigits = [ @I16(3), @I16(6),  @I16(12), @I16(25), @I16(64)   ]

const nExtents  = length(midDigits);  const maxDigits = 1200;

function set_midpoint_digits_shown(idx::Int, ndigits::Int)
    (1 <= idx     <= nExtents) || throw(ErrorException("invalid EXTENT index ($idx)"))
    (1 <= ndigits <= maxDigits)  || throw(ErrorException("midpoint does not support an $(ndigits) digit count"))
    @inbounds midDigits[ idx ] = @I16(ndigits)
    return ndigits
end
function set_radius_digits_shown(idx::Int, ndigits::Int)
    (1 <= idx     <= nExtents) || throw(ErrorException("invalid EXTENT index ($idx)"))
    (1 <= ndigits <= maxDigits)  || throw(ErrorException("radius does support an ($ndigits) digit count"))
    @inbounds midDigits[ idx ] = @I16(ndigits)
    return ndigits
end

set_midpoint_digits_shown(ndigits::Int) = midDigits[Int(medium)] = ndigits
set_radius_digits_shown(ndigits::Int) = radDigits[Int(medium)] = ndigits

function get_midpoint_digits_shown(idx::Int)
    (1 <= idx <= nExtents) || throw(ErrorException("invalid EXTENT index ($idx)"))
    @inbounds m = midDigits[ idx ]
    return m
end
function get_radius_digits_shown(idx::Int)
    (1 <= idx <= nExtents) || throw(ErrorException("invalid EXTENT index ($idx)"))
    @inbounds r = radDigits[ idx ]
    return r
end

get_midpoint_digits_shown() = midDigits[ Int(medium) ]
get_radius_digits_shown()   = radDigits[ Int(medium) ]

digits_offer_bits(ndigits::Int) = convert(Int, div(abs(ndigits)*log2(10), 1))


# prepare the scene for balanced in displaybles interfacing


const nonfinite_strings = ["NaN", "+Inf", "-Inf", "±Inf"];

function string_nonfinite(x::T) where T <: ArbFloat
    global nonfinite_strings
    idx = isnan(x) + isinf(x)<<2 - ispositive(x)<<1 - isnegative(x)
    return nonfinite_strings[idx]
end


function string(x::T) where T <: ArbFloat
    !isfinite(x) && return string_nonfinite(x)

    s = stringmedium(x) 
    return s
end


function string(x::T, ndigits::Int) where T <: ArbFloat
    !isfinite(x) && return string_nonfinite(x)
    
    rdigits = min(ndigits, get_radius_digits_shown(medium))
    s = isexact(x) ? string_exact(x, ndigits) : string_inexact(x, ndigits, rdigits)
    return s
end
@inline string(x::T, ndigits::Int16) where {T <: ArbFloat} = string(x, ndigits%Int)

function string(x::T, mdigits::Int, rdigits::Int) where T <: ArbFloat
    !isfinite(x) && return string_nonfinite(x)

    s = isexact(x) ? string_exact(x, mdigits) : string_inexact(x, mdigits, rdigits)
    return s
end
@inline string(x::T, mdigits::Int16, rdigits::Int16) where {T <: ArbFloat} = string(x, mdigits%Int, rdigits%Int)

function arb_string(x::ArbFloat{P}, digs::Int, mode::Int) where P
    !isfinite(x) && return string_nonfinite(x)

    cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, digs, mode%UInt)
    s = unsafe_string(cstr)
    return s
end    

function string_exact(x::T, mdigits::Int, rounding::Int) where T <: ArbFloat
    !isfinite(x) && return string_nonfinite(x)

    digs = Int(mdigits)
    cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, digs, rounding%UInt)
    s = unsafe_string(cstr)
    return cleanup_numstring(s, isinteger(x))
end


function sstring_exact(x::T, mdigits::Int) where T <: ArbFloat
    !isfinite(x) && return string_nonfinite(x)

    digs = Int(mdigits)
    cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, digs, 2%UInt)
    s = unsafe_string(cstr)
    return cleanup_numstring(s, isinteger(x))
end
@inline string_exact(x::T, mdigits::Int16) where {T <: ArbFloat} = string_exact(x, mdigits%Int)

function string_inexact(x::T, mdigits::Int, rdigits::Int) where T <: ArbFloat
    !isfinite(x) && return string_nonfinite(x)

    mid = string_exact(midpoint(x), mdigits)
    rad = string_exact(radius(x), rdigits)
    return string(mid, "±", rad)
end
@inline string_inexact(x::T, mdigits::Int16, rdigits::Int16) where {T <: ArbFloat} = string_inexact(x, mdigits%Int, rdigits%Int)
@inline string_inexact(x::T, mdigits::Int, rdigits::Int16) where {T <: ArbFloat} = string_inexact(x, mdigits, rdigits%Int)
@inline string_inexact(x::T, mdigits::Int16, rdigits::Int) where {T <: ArbFloat} = string_inexact(x, mdigits%Int, rdigits)

function cleanup_numstring(numstr::String, isaInteger::Bool)::String
    # is there an exponent
    body,expn = ('e' in numstr) ? split(numstr, 'e') : (numstr, "")
    if !isaInteger
        body = rstrip(body, '0')
    elseif '.' in body
        body = string(split(numstr, '.')[1])
    end
    if expn != ""
        body = string(body,"e",expn)
    end
    if body[end]=='.'
        body = string(body,"0")
    end
    return body
end

#=
function string_pm{T<:ArbFloat}(x::T)
    P = precision(T)
    mdigs = min(digitsRequired(P),get_midpoint_digits_shown(medium))
    rdigs = get_radius_digits_shown(medium)
    s = isexact(x) ? string_exact(x, mdigs) : string_inexact(x, mdigs, rdigs)
    return s
end
=#


function stringsmall_pm(x::ArbFloat{P}) where P
    !isfinite(x) && return string_nonfinite(x)

    if isexact(x)
        return stringsmall(x)
    end
    digs = min(digitsRequired(P), get_midpoint_digits_shown(small))
    sm = string_exact(midpoint(x), digs)
    
    sr = try
            string(Float32(radius(x)))
         catch
            string(round(radius(x),23,2))
         end

    return string(sm,"±", sr)
end
stringsmall(x::ArbFloat{P}) where P =
    string_exact(x, min(get_midpoint_digits_shown(small),digitsRequired(P)))

function stringcompact_pm(x::ArbFloat{P}) where P
    !isfinite(x) && return string_nonfinite(x)

    if isexact(x)
        return stringcompact(x)
    end
    digs = min(digitsRequired(P), get_midpoint_digits_shown(compact))
    sm = string_exact(midpoint(x), digs)

    sr = try
            string(Float32(radius(x)))
         catch
            string(round(radius(x),23,2))
         end

    return string(sm,"±", sr)
end
stringcompact(x::ArbFloat{P}) where P = 
    string_exact(x, min(get_midpoint_digits_shown(compact),digitsRequired(P)))

function stringmedium_pm(x::ArbFloat{P}) where P
    !isfinite(x) && return string_nonfinite(x)

    if isexact(x)
        return stringmedium(x)
    end
    digs = min(digitsRequired(P), get_midpoint_digits_shown(medium))
    sm = string_exact(midpoint(x), digs)
    sr = try
            string(Float64(radius(x)))
         catch
            string(round(radius(x),58,2))
         end

    return string(sm,"±", sr)
end
stringmedium(x::ArbFloat{P}) where P =
    string_exact(x, min(get_midpoint_digits_shown(medium),digitsRequired(P)))

@inline string_pm(x::ArbFloat{P}) where {P} = stringmedium_pm(x)

function stringlarge_pm(x::ArbFloat{P}) where P
    !isfinite(x) && return string_nonfinite(x)

    if isexact(x)
        return stringlarge(x)
    end
    digs = min(digitsRequired(P), get_midpoint_digits_shown(large))
    sm = string_exact(midpoint(x), digs)
    sr = try
            string(Float64(radius(x)))
         catch
            string(round(radius(x),58,2))
         end

    return string(sm,"±", sr)
end
stringlarge(x::ArbFloat{P}) where P =
    string_exact(x, min(get_midpoint_digits_shown(large),digitsRequired(P)))

function stringall_pm(x::ArbFloat{P}) where P
    !isfinite(x) && return string_nonfinite(x)

    if isexact(x)
        return stringall(x)
    end
    sm = string_exact(midpoint(x), digitsRequired(P))
    sr = try
            string(Float64(radius(x)))
         catch
            string(round(radius(x),58,2))
         end

    return string(sm,"±", sr)
end
stringall(x::ArbFloat{P}) where P = 
    string_exact(x, digitsRequired(P))
