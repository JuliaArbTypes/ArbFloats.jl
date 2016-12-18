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
         slowerby[i] = benchbits_converted_rel(fn, val, vecnbits[i])
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

BenchmarkTools.DEFAULT_PARAMETERS.seconds = 0.5
BenchmarkTools.DEFAULT_PARAMETERS.samples = 15

#const fp_precise_bits = [128, 256, 512, 768, 1024, 1280, 1536, 2048, 2560, 3072, 3584];
# const fp_precise_bits = [128, 256, 512, 1024, 1280, 1536, 2048, 2560, 3072];
const fp_precise_bits = [128*i for i in 1:16];

println( "    bits: ",fp_precise_bits' );println()

v0 = Float64(golden); v1 = sqrt(v0); v2 = 1/sqrt(5);
mul_slowerby = nbit_bigfloat_slowerby( (*), v1, v2, fp_precise_bits); println("    mul :",mul_slowerby' )
div_slowerby = nbit_bigfloat_slowerby( (/), v1, v2, fp_precise_bits); println("    div :", div_slowerby' )
cbrt_slowerby = nbit_bigfloat_slowerby( (cbrt), v1, v2, fp_precise_bits); println("    cbrt :", cbrt_slowerby' )
exp_slowerby = nbit_bigfloat_slowerby( (exp), v0, fp_precise_bits);   println( "    exp : ", exp_slowerby' ) 
log_slowerby = nbit_bigfloat_slowerby( (log), v0, fp_precise_bits);   println( "    log : ", log_slowerby' )
cos_slowerby = nbit_bigfloat_slowerby( (cos), v0, fp_precise_bits);   println( "    cos : ", cos_slowerby' )
tan_slowerby = nbit_bigfloat_slowerby( (tan), v0, fp_precise_bits);   println( "    tan : ", tan_slowerby' )
acos_slowerby = nbit_bigfloat_slowerby( (acos), v0, fp_precise_bits); println( "    acos: ", acos_slowerby' )
atan_slowerby = nbit_bigfloat_slowerby( (atan), v0, fp_precise_bits); println( "    atan: ", atan_slowerby' )
tanh_slowerby = nbit_bigfloat_slowerby( (tan), v0, fp_precise_bits);  println( "    tanh: ", tanh_slowerby' )
atanh_slowerby = nbit_bigfloat_slowerby( (atan), v0, fp_precise_bits);println( "    atanh: ", atanh_slowerby' )
erf_slowerby = nbit_bigfloat_slowerby( (erf), v0, fp_precise_bits);println( "    erf: ", erf_slowerby' )

gamma_slowerby = nbit_bigfloat_slowerby( (gamma), v0, fp_precise_bits);println( "    gamma:  ", gamma_slowerby' )
digamma_slowerby = nbit_bigfloat_slowerby( (digamma), v0, fp_precise_bits);println( "    digamma:  ", digamma_slowerby' )
zeta_slowerby = nbit_bigfloat_slowerby( (zeta), v0, fp_precise_bits);println( "     zeta:  ", zeta_slowerby' )

println();println( "    bits: ",fp_precise_bits' )


#=
#const fp_precise_bits = [128, 256, 512, 768, 1024, 1280, 1536, 2048, 2560, 3072, 3584];
const fp_precise_bits = [128*i for i in 1:26];
const fp_precise_digs = [floor(Int, 128*i*log10(2)) for i in 1:26];

println( "    bits: ",fp_precise_bits' );println()


println();println( "    bits: ",fp_precise_bits' )

=#





