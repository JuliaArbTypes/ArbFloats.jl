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


function bench(f,val1,val2)
    benchrunner = @benchmarkable ($f)($val1,$val2)
    tune!(benchrunner)
    benchcatcher = run(benchrunner)
    firstquintile = mean(benchcatcher.times[1:fld( length(benchcatcher.times), 5)])
    return(firstquintile)
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

function benchbits_converted_rel(f,val1,val2,nbits)
    setprecision(BigFloat, nbits) 
    setprecision(ArbFloat, nbits)
  
    bigval1 = convert(BigFloat,val1)
    bigval2 = convert(BigFloat,val2)
    arbval1 = convert(ArbFloat,val1)
    arbval2 = convert(ArbFloat,val2)
  
    bigbench = bench(f,bigval1,bigval2)
    arbbench = bench(f,arbval1,arbval2)
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


function nbit_bigfloat_slowerby(fn, val1, val2, vecnbits)
    nprecisions = length(vecnbits)
    slowerby = zeros(Int, nprecisions)
    for i in 1:nprecisions
         slowerby[i] = benchbits_converted_rel(fn, val1, val2, vecnbits[i])
    end
    return slowerby
end

BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1
BenchmarkTools.DEFAULT_PARAMETERS.samples = 25

const fp_precise_bits = [128, 256, 512, 1024, 2048, 3072, 4096, 8192];

mul_slowerby = nbit_bigfloat_slowerby( (*), pi, golden, fp_precise_bits)
div_slowerby = nbit_bigfloat_slowerby( (/), pi, golden, fp_precise_bits)
exp_slowerby = nbit_bigfloat_slowerby( (exp), golden, fp_precise_bits)
log_slowerby = nbit_bigfloat_slowerby( (log), golden, fp_precise_bits)
tan_slowerby = nbit_bigfloat_slowerby( (tan), golden, fp_precise_bits)
atan_slowerby = nbit_bigfloat_slowerby( (atan), golden, fp_precise_bits)
tanh_slowerby = nbit_bigfloat_slowerby( (tan), golden, fp_precise_bits)
atanh_slowerby = nbit_bigfloat_slowerby( (atan), golden, fp_precise_bits)






