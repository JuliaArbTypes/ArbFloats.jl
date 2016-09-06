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

function string_nonfinite{T<:ArbFloat}(x::T)::String
    global nonfinite_strings
    idx = isnan(x) + isinf(x)<<2 - ispositive(x)<<1 - isnegative(x)
    return nonfinite_strings[idx]
end


function string{T<:ArbFloat}(x::T)
    ndigits = digitsRequired(precision(T))

    s = if isfinite(x)
            string_exact(x, ndigits) 
            #isexact(x) ? string_exact(x, mdigits) : string_inexact(x, mdigits, rdigits)
        else
            string_nonfinite(x)
        end
    return s
end


function string{T<:ArbFloat,I<:Integer}(x::T, ndigits::I)
    rdigits = min(ndigits, get_radius_digits_shown())

    s = if isfinite(x)
            isexact(x) ? string_exact(x, ndigits) : string_inexact(x, ndigits, rdigits)
        else
            string_nonfinite(x)
        end
    return s
end

function string{T<:ArbFloat,I<:Integer}(x::T, mdigits::I, rdigits::I)
    s = if isfinite(x)
            isexact(x) ? string_exact(x, mdigits) : string_inexact(x, mdigits, rdigits)
        else
            string_nonfinite(x)
        end
    return s
end



function string_exact{T<:ArbFloat,I<:Integer}(x::T, mdigits::I)::String
    digs = Int(mdigits)
    cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, digs, 2%UInt)
    s = unsafe_string(cstr)
    return cleanup_numstring(s, isinteger(x))
end

function string_inexact{T<:ArbFloat,I<:Integer}(x::T, mdigits::I, rdigits::I)::String
    mid = string_exact(midpoint(x), mdigits)
    rad = string_exact(radius(x), rdigits)
    return string(mid, "±", rad)
end

function cleanup_numstring(numstr::String, isaInteger::Bool)::String
    s =
      if !isaInteger
          rstrip(numstr, '0')
      else
          string(split(numstr, '.')[1])
      end

    if s[end]=='.'
        s = string(s, "0")
    end
    return s
end

stringSmall{T<:ArbFloat}(x::T) =
    string(x, get_midpoint_digits_shown(small))
stringCompact{T<:ArbFloat}(x::T) =
    string(x, get_midpoint_digits_shown(compact))
stringMedium{T<:ArbFloat}(x::T) =
    string(x, min(digitsRequired(precision(T)),get_midpoint_digits_shown(medium)))
stringLarge{T<:ArbFloat}(x::T) =
    string(x, min(digitsRequired(precision(T)),get_midpoint_digits_shown(large)))

interval_stringSmall{T<:ArbFloat}(x::T) =
    string(x, get_midpoint_digits_shown(small), get_radius_digits_shown(small))
interval_stringCompact{T<:ArbFloat}(x::T) =
    string(x, get_midpoint_digits_shown(compact), get_radius_digits_shown(compact))
interval_string{T<:ArbFloat}(x::T) =
    string(x, min(digitsRequired(precision(T)),get_midpoint_digits_shown(medium)), get_radius_digits_shown(medium))
interval_stringLarge{T<:ArbFloat}(x::T) =
    string(x, min(digitsRequired(precision(T)),get_midpoint_digits_shown(large)), get_radius_digits_shown(large))
#stringall{T<:ArbFloat}(x::T) =
#    string(x, get_midpoint_digits_shown(all), get_radius_digits_shown(all))

stringAll{P}(x::ArbFloat{P}) = string(x, digitsRequired(P))

function interval_stringAll{P}(x::ArbFloat{P})
    if isexact(x)
        return string(x)
    end
    sm = string(midpoint(x))
    sr = try
            string(Float64(radius(x)))
         catch
            string(round(radius(x),58,2))
         end

    return string(sm,"±", sr)
end



