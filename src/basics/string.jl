@inline digitsRequired(bitsOfPrecision) = ceil(Int, bitsOfPrecision*0.3010299956639811952137)

function String{P}(x::ArbFloat{P}, ndigits::Int, flags::UInt)
    n = max(1,min(abs(ndigits), digitsRequired(P)))
    cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, flags)
    s = unsafe_string(cstr)
    ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
    s
end

function String{P}(x::ArbFloat{P}, flags::UInt)
    cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt),
                 &x, digitsRequired(P), flags)
    s = unsafe_string(cstr)
    ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
    s
end

# n=trunc(abs(log(upperbound(x)-lowerbound(x))/log(2))) just the good bits
string{P}(x::ArbFloat{P}, ndigits::Int) =
    String(x, ndigits, UInt(2)) # midpoint only (within 1ulp), RoundNearest

# n=trunc(abs(log(upperbound(x)-lowerbound(x))/log(2))) just the good bits
string{P}(x::ArbFloat{P}) =
    String(x,UInt(2)) # midpoint only (within 1ulp), RoundNearest

function stringTrimmed{P}(x::ArbFloat{P}, ndigitsremoved::Int)
   n = max(1, digitsRequired(P) - max(0, ndigitsremoved))
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, UInt(2))
   s = unsafe_string(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

#=
     find the smallest N such that stringTrimmed(lowerbound(x), N) == stringTrimmed(upperbound(x), N)
=#

function smartarbstring{P}(x::ArbFloat{P})
     digits = digitsRequired(P)
     if isexact(x)
        return String(x, digits, UInt(2))
     end

     lb, ub = bounds(x)
     lbs = String(lb, digits, UInt(2))
     ubs = String(ub, digits, UInt(2))
     if lbs[end]==ubs[end] && lbs==ubs
         return ubs
     end
     for i in (digits-2):-2:4
         lbs = String(lb, i, UInt(2))
         ubs = String(ub, i, UInt(2))
         if lbs[end]==ubs[end] && lbs==ubs # tests rounding to every other digit position
            us = String(ub, i+1, UInt(2))
            ls = String(lb, i+1, UInt(2))
            if us[end] == ls[end] && us==ls # tests rounding to every digit position
               ubs = lbs = us
            end
            break
         end
     end
     if lbs != ubs
        ubs = String(x, 3, UInt(2))
     end
     ubs
end

function smartvalue{P}(x::ArbFloat{P})
    s = smartarbstring(x)
    ArbFloat{P}(s)
end

function smartstring{P}(x::ArbFloat{P})
    s = smartarbstring(x)
    a = ArbFloat{P}(s)
    string(s,upperbound(x) < a ? '-' : (lowerbound(x) > a ? '+' : '~'))
end

function smarterarbstring{P}(af::ArbFloat{P})
    negative, af  = signbit(af) ? (true, -af) : (false, af)
    af_rad        = radius(af)
    af_mid        = midpoint(af)
    ulp_af_mid    = ulp2(af_mid)
    ufp_af_rad    = ufp2(af_rad)

    digitsToKeep  = digitsRequired(P)
    if ufp_af_rad >= ulp_af_mid
        digitsToKeep += ceil(Int,
            (log10(ulp10(upperbound(af))) - log10(ufp10(af_rad))) - 0.001)
    end
    af_mid = ifelse( negative, -af_mid, af_mid)
    return String(af_mid, digitsToKeep, UInt(2))
end

function smartervalue{P}(x::ArbFloat{P})
    s = smarterarbstring(x)
    ArbFloat{P}(s)
end

function smarterstring{P}(af::ArbFloat{P})
    s = smartarbstring(af)
    sf = ArbFloat{P}(s)
    lb,ub = bounds(af)
    rad = radius(af)
    dia = rad+rad
    chr = "~"
    if rad > ulp10(sf)
      begin
        if ub <= sf
            chr = "-"
        elseif lb >= sf
            chr = "+"
        else
            if sf > af
                chr = "⨪"
            elseif sf < af
                chr = "⨥"
            end
        end
      end
    end

    string(s, chr)
end

function stringall{P}(x::ArbFloat{P})
    return (isexact(x) ? string(midpoint(x)) :
              string(midpoint(x)," ± ", string(radius(x),10)))
end

function stringcompact{P}(x::ArbFloat{P})
    string(x,8)
end

function stringallcompact{P}(x::ArbFloat{P})
    return (isexact(x) ? string(midpoint(x)) :
              string(string(midpoint(x),8)," ± ", string(radius(x),10)))
end
