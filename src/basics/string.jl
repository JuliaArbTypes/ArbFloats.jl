@inline digitsRequired(bitsOfPrecision) = ceil(Int, bitsOfPrecision*0.3010299956639811952137)

# default values for summary view
const midpointDigits = 12;  const midpoint_digits_shown = [ midpointDigits ];
const radiusDigits   =  9;  const radius_digits_shown   = [ radiusDigits   ];
const midpointBits   = 40;  const midpoint_bits_shown   = [ midpointBits   ];
const radiusBits     = 30;  const radius_bits_shown     = [ radiusBits     ];

midpoint_digits() = midpoint_digits_shown[1]
radius_digits()   = radius_digits_shown[1]
midpoint_bits()   = midpoint_bits_shown[1]
radius_bits()     = radius_bits_shown[1]

digits_offer_bits(ndigits::Int) = convert(Int, div(abs(ndigits)*log2(10), 1))

get_midpoint_digits_shown() = midpoint_digits()
get_radius_digits_shown()   = radius_digits()

function set_midpoint_digits_shown(mdigits::Int)
    global midpoint_digits_shown, midpoint_bits_shown
    0 < mdigits <= 4096 || throw(ErrorException("Interface Exception: midpoint cannot show $mdigits digits"))
    midpoint_digits_shown[1] = mdigits
    midpoint_bits_shown[1]   = digits_offer_bits(mdigits)
    return nothing
end

function set_radius_digits_shown(rdigits::Int)
    global radius_digits_shown, radius_bits_shown
    0 < rdigits <= 22 || throw(ErrorException("Interface Exception: radius cannot show $rdigits digits"))
    radius_digits_shown[1] = rdigits
    radius_bits_shown[1]   = digits_offer_bits(rdigits)
    return nothing
end

const nonfinite_strings = ["NaN", "+Inf", "-Inf", "±Inf"];

function string_nonfinite{T<:ArbFloat}(x::T)::String
    global nonfinite_strings
    idx = isnan(x) + isinf(x)<<2 - ispositive(x)<<1 - isnegative(x)
    return nonfinite_strings[idx]
end


function string{T<:ArbFloat}(x::T)
    mdigits = midpoint_digits()
    rdigits = radius_digits()

    s = if isfinite(x)
            isexact(x) ? string_exact(x, mdigits) : string_inexact(x, mdigits, rdigits)
        else
            string_nonfinite(x)
        end
    return s
end


function string{T<:ArbFloat}(x::T, ndigits::Int)
    mdigits = max(ndigits, midpoint_digits())
    rdigits = min(ndigits, radius_digits())

    s = if isfinite(x)
            isexact(x) ? string_exact(x, mdigits) : string_inexact(x, mdigits, rdigits)
        else
            string_nonfinite(x)
        end
    return s
end

function string{T<:ArbFloat}(x::T, mdigits::Int, rdigits::Int)
    s = if isfinite(x)
            isexact(x) ? string_exact(x, mdigits) : string_inexact(x, mdigits, rdigits)
        else
            string_nonfinite(x)
        end
    return s
end



function string_exact{T<:ArbFloat}(x::T, mdigits::Int)::String
    cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, mdigits, 2%UInt)
    s = unsafe_string(cstr)
    return cleanup_numstring(s, isinteger(x))
end

function string_inexact{T<:ArbFloat}(x::T, mdigits::Int, rdigits::Int)::String
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


#=
     find the smallest N such that stringTrimmed(lowerbound(x), N) == stringTrimmed(upperbound(x), N)
=#

function smartarbstring{P}(x::ArbFloat{P})
     digts = digitsRequired(P)
     if isexact(x)
        if isinteger(x)
            return string(x, digts, UInt(2))
        else
            s = rstrip(string(x, digts, UInt(2)),'0')
            if s[end]=='.'
               s = string(s, "0")
            end
            return s
        end
     end
     if radius(x) > abs(midpoint(x))
        return "0"
     end

     lb, ub = bounds(x)
     lbs = string(lb, digts, UInt(2))
     ubs = string(ub, digts, UInt(2))
     if lbs[end]==ubs[end] && lbs==ubs
         return ubs
     end
     for i in (digts-2):-2:4
         lbs = string(lb, i, UInt(2))
         ubs = string(ub, i, UInt(2))
         if lbs[end]==ubs[end] && lbs==ubs # tests rounding to every other digit position
            us = string(ub, i+1, UInt(2))
            ls = string(lb, i+1, UInt(2))
            if us[end] == ls[end] && us==ls # tests rounding to every digit position
               ubs = lbs = us
            end
            break
         end
     end
     if lbs != ubs
        ubs = string(x, 3, UInt(2))
     end
     rstrip(ubs,'0')
end

function smartvalue{P}(x::ArbFloat{P})
    s = smartarbstring(x)
    ArbFloat{P}(s)
end

function smartstring{P}(x::ArbFloat{P})
    s = smartarbstring(x)
    a = ArbFloat{P}(s)
    if notexact(x)
       s = string(s,upperbound(x) < a ? '-' : (lowerbound(x) > a ? '+' : '~'))
    end
    return s
end

function smartstring{T<:ArbFloat}(x::T)
    absx   = abs(x)
    sa_str = smartarbstring(absx)  # smart arb string
    sa_val = (T)(absx)             # smart arb value
    if notexact(absx)
        md,rd = midpoint(absx), radius(absx)
        lo,hi = bounds(absx)
        if     sa_val <= lo
            if lo-sa_val >= ufp2(rd)
                sa_str = string(sa_str,"⁺")
            else
                sa_str = string(sa_str,"₊")
            end
        elseif sa_val > hi
            if sa_val-hi >= ufp2(rd)
                sa_str = string(sa_str,"⁻")
            else
                sa_str = string(sa_str,"₋")
            end
        else
            sa_str = string(sa_str,"~")
        end
    end
    return sa_str
end

function stringall{P}(x::ArbFloat{P})
    if isexact(x)
        return string(x)
    end
    sm = string(midpoint(x))
    sr = try
            string(Float64(radius(x)))
        catch
            string(round(radius(x),58,2))
        end

    return string(sm," ± ", sr)
end

function stringcompact{P}(x::ArbFloat{P})
    string(x,8)
end

function stringallcompact{P}(x::ArbFloat{P})
    return (isexact(x) ? string(midpoint(x)) :
              string(string(midpoint(x),8)," ± ", string(radius(x),10)))
end



#=

function stringTrimmed{P}(x::ArbFloat{P}, ndigitsremoved::Int)
   n = max(1, digitsRequired(P) - max(0, ndigitsremoved))
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, UInt(2))
   s = unsafe_string(cstr)
   # ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

=#
