using BenchmarkTools
using ArbFloats

macro setprecisions(nbits)
  quote begin
    setprecision(BigFloat, $nbits)
    setprecision(ArbFloat, $nbits)
  end end
end

macro vals(v)
   quote 
     convert(BigFloat,$v), convert(ArbFloat,$v)
   end     
end    


macro bench(f,val)
  quote begin
    local bfrunner, bfns
    bfrunner = @benchmarkable ($f)($val)
    tune!(bfrunner)
    bfns = run(bfrunner)
    return bfns.times[1]
  end end
end



