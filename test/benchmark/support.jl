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


function bench_twoargs(f,val1,val2)
    benchrunner = @benchmarkable ($f)($val1,$val2)
    tune!(benchrunner)
    benchcatcher = run(benchrunner)
    firstquintile = mean(benchcatcher.times[1:fld( length(benchcatcher.times), 5)])
    return(firstquintile)
end


function bench_rel(f,val)
    bigval, arbval = big_and_arb_vals(val)
    bigbench = bench(f,bigval)
    arbbench = bench(f,arbval)
    big_slowdown = bigbench/arbbench
    return Float16(big_slowdown)
end      


function benchbits_parsed_rel(f,val,nbits)
    setprecision(BigFloat, nbits) 
    setprecision(ArbFloat, nbits)
    str = string(val)
    bigval = parse(BigFloat,str)
    arbval = parse(ArbFloat,str)
    bigbench = bench(f,bigval)
    arbbench = bench(f,arbval)
    big_slowdown = bigbench/arbbench
    return floor(Int, 0.25 + Float16(big_slowdown))
end

function benchbits_converted_rel(f,val,nbits)
    setprecision(BigFloat, nbits) 
    setprecision(ArbFloat, nbits)
    bigval = convert(BigFloat,val)
    arbval = convert(ArbFloat,val)
    bigbench = bench(f,bigval)
    arbbench = bench(f,arbval)
    big_slowdown = bigbench/arbbench
    return floor(Int, 0.25 + Float16(big_slowdown))
end

function nbit_bigfloat_slowerby(fn, val, vecnbits)
    nprecisions = length(vecnbits)
    slowerby = zeros(Int, nprecisions)
    for i in 1:nprecisions
         slowerby[i] = benchbits_coverted_rel(fn, val, vecnbits[i])
    end
    return slowerby
end

  
