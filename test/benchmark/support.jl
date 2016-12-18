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
    local benchrunner, benchcatcher
    benchrunner = @benchmarkable ($f)($val)
    tune!(benchrunner)
    benchcatcher = run(benchrunner)
    return benchcatcher.times[1]
  end end
end

macro bench2relative(f,val)
  quote begin
      local val_big, val_arb, bench_big, bench_arb, relspeed
      val_big, val_arb = vals($val)
      bench_big = @bench(f, val_big)
      bench_arb = @bench(f, val_arb)
      relspeed = (abs(bench_big-bench_arb)/bench_arb)+1
      return relspeed
   end end
end



