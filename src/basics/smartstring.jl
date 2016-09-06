
#=
     The basic idea is to find the smallest N such that 
       string(rounded(lowerbound(x), N)) == string(rounded(upperbound(x), N))
       where rounded rounds fractional values to N fractional places
    
    Some intervals are too wide to do that.
    Some are not too wide but straddle an integer in a way that does not 
      round to match values with the desired fractional resolution.

=#
@inline digitsRequired(bitsOfPrecision) = ceil(Int, bitsOfPrecision*0.3010299956639812)

function smartarbstring{P}(x::ArbFloat{P})::String
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
     elseif radius(x) > abs(midpoint(x))
        return "0"
     end

     return smartarbstring_inexact(x)
end

function smartarbstring_inexact{P}(x::ArbFloat{P})::String
     digts = digitsRequired(P)
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
     s = rstrip(ubs,'0')
     if s[end]=='.'
         s = string(s, "0")
     end
     return s
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

#=

function stringTrimmed{P}(x::ArbFloat{P}, ndigitsremoved::Int)
   n = max(1, digitsRequired(P) - max(0, ndigitsremoved))
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, UInt(2))
   s = unsafe_string(cstr)
   # ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

=#
