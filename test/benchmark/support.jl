using BenchmarkTools
using ArbFloats

macro setprecisions(nbits)
    quote begin
        setprecision(BigFloat, $nbits)
        setprecision(ArbFloat, $nbits)
    end   end
end

macro getvalues(val)
    quote begin
        local strval, bigfloat, bigrecip, arbfloat, arbrecip
        strval = string($val)
        bigfloat = parse(BigFloat,strval)
        bigrecip = one(BigFloat)/bigfloat
        arbfloat = ArbFloat(strval)
        arbrecip = one(ArbFloat)//arbfloat
        return (bigfloat, arbfloat, bigrecip, arbrecip)
        end
    end end  1
end

        
macro bfrun(f,val)
          quote begin
             local bfrunner, bfns
             bfrunner = @benchmarkable ($f)($val)
             tune!(bfrunner)
             bfns = run(bfrunner)
             return bfns.times[1]
          end
       end
       end
