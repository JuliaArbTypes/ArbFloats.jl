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
    arbbench = bench(f,arbval)
    big_slowdown = bigbench/arbbench
    return big_slowdown > 1 ? trunc(Int, big_slowdown+0.335) : trunc(Int,-1/big_slowdown)
end      



