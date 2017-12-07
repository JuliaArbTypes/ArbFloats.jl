
#=
     The basic idea is to find the smallest N such that 
       string(rounded(lowerbound(x), N)) == string(rounded(upperbound(x), N))
       where rounded rounds fractional values to N fractional places
    
    Some intervals are too wide to do that.
    Some are not too wide but straddle an integer in a way that does not 
      round to match values with the desired fractional resolution.

=#
# digitsRequired(bitsOfPrecision) = ceil(Int, bitsOfPrecision*0.3010299956639812)

function smartarbstring(x::ArbFloat{P}) where P
     digts = digitsRequired(P)
     if isexact(x)
        if isinteger(x)
            return string(x, digts)
        else
            s = rstrip(string(x, digts),'0')
            if s[end]=='.'
               s = string(s, "0")
            end
            return s
        end
     elseif radius(x) > abs(midpoint(x))
        return "0"
     end

     return smartarbstring_inexact(x)
end

function smartarbstring_inexact(x::ArbFloat{P}) where P
     digts = digitsRequired(P)
     lb, ub = bounds(x)
     lbs = string_exact(lb, digts)
     ubs = string_exact(ub, digts)
     if lbs[end]==ubs[end] && lbs==ubs
         return ubs
     end
     for i in (digts-2):-2:4
         lbs = string_exact(lb, i)
         ubs = string_exact(ub, i)
         if lbs[end]==ubs[end] && lbs==ubs # tests rounding to every other digit position
            us = string_exact(ub, i+1)
            ls = string_exact(lb, i+1)
            if us[end] == ls[end] && us==ls # tests rounding to every digit position
               ubs = lbs = us
            end
            break
         end
     end
     if lbs != ubs
        ubs = stringcompact(x)
     end
     s = rstrip(ubs,'0')
     if s[end]=='.'
         s = string(s, "0")
     end
     return s
end

function smartvalue(x::ArbFloat{P}) where {P}
    s = smartarbstring(x)
    ArbFloat{P}(s)
end

function smartstring(x::ArbFloat{P}) where {P}
    s = smartarbstring(x)
    a = ArbFloat{P}(s)
    if notexact(x)
       s = string(s,upperbound(x) < a ? '₋' : (lowerbound(x) > a ? '₊' : 'ₒ'))
    end
    return s
end

function smarterstring(x::T) where {T <: ArbFloat}
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
            if sa_val-hi >= ufp2(rd)
                sa_str = string(sa_str,"ᵒ")
            else
                sa_str = string(sa_str,"ₒ")
            end
        end
    end
    return sa_str
end

#=

function stringTrimmed{P}(x::ArbFloat{P}, ndigitsremoved::Int)
   n = max(1, digitsRequired(P) - max(0, ndigitsremoved))
   cstr = ccall(@libarb(arb_get_str), Ref{UInt8}, (Ref{ArbFloat{P}}, Int, UInt), x, n, UInt(2))
   s = unsafe_string(cstr)
   # ccall(@libflint(flint_free), Void, (Ref{UInt8},), cstr)
   s
end

=#
