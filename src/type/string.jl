function String{P}(x::ArbFloat{P}, ndigits::Int, flags::UInt)
   n = max(1,min(abs(ndigits), floor(Int, P*0.3010299956639811952137)))
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, flags)
   s = unsafe_string(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

function String{P}(x::ArbFloat{P}, flags::UInt)
   n = floor(Int, P*0.3010299956639811952137)
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, flags)
   s = unsafe_string(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

function string{P}(x::ArbFloat{P}, ndigits::Int)
   # n=trunc(abs(log(upperbound(x)-lowerbound(x))/log(2))) just the good bits
   s = String(x, ndigits, UInt(2)) # midpoint only (within 1ulp), RoundNearest
   s 
end

function string{P}(x::ArbFloat{P})
   # n=trunc(abs(log(upperbound(x)-lowerbound(x))/log(2))) just the good bits
   s = String(x,UInt(2)) # midpoint only (within 1ulp), RoundNearest
   s 
end

function stringTrimmed{P}(x::ArbFloat{P}, ndigitsremoved::Int)
   n = max(0, ndigitsremoved)
   n = max(1, floor(Int, P*0.3010299956639811952137) - n)
   cstr = ccall(@libarb(arb_get_str), Ptr{UInt8}, (Ptr{ArbFloat}, Int, UInt), &x, n, UInt(2))
   s = unsafe_string(cstr)
   ccall(@libflint(flint_free), Void, (Ptr{UInt8},), cstr)
   s
end

#=
     find the smallest N such that stringTrimmed(lowerbound(x), N) == stringTrimmed(upperbound(x), N)
=#

function smartarbstring{P}(x::ArbFloat{P})
     digits = floor(Int, precision(x)*0.3010299956639811952137)

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
    postfix = 
        if (upperbound(x) < a)   
            "-"
        elseif (lowerbound(x) > a)
            "+"
        else
            "~"
        end
    string(s,postfix)
end


function stringAll{P}(x::ArbFloat{P})
    string(midpoint(x)," ± ", string(radius(x),17))
end

function stringCompact{P}(x::ArbFloat{P})
    string(x,8)
end

function stringAllCompact{P}(x::ArbFloat{P})
    string(string(midpoint(x),8)," ± ", string(radius(x),5))
end

