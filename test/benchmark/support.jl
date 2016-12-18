using BenchmarkTools
using ArbFloats

macro setprecisions(nbits)
  quote begin
    setprecision(BigFloat, $nbits)
    setprecision(ArbFloat, $nbits)
  end end
end

function big_and_arb_vals(v)
    str = string(v)
    return parse(BigFloat, str), parse(ArbFloat, str)
end    


function bench(f,val)
    benchrunner = @benchmarkable ($f)($val)
    tune!(benchrunner)
    benchcatcher = run(benchrunner)
    firstquintile = mean(benchcatcher.times[1:fld( length(benchcatcher.times), 5)])
    return(firstquintile)
end

function relbench(f,val)
    bigval, arbval = big_and_arb_vals(val)
    bigbench = bench(f,bigval)
    arbbench = benc(f,arbval)
    speedup = abs(bigbench-arbbench)/arbbench
    return speedup
end      



