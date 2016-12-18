using BenchmarkTools
using ArbFloats

round2(x) = round(x*100.0)/100.0


macro setprecisions(nbits)
  quote begin
    setprecision(BigFloat, $nbits)
    setprecision(ArbFloat, $nbits)
  end end
end



function bench(f,val)
    benchrunner = @benchmarkable ($f)($val)
    tune!(benchrunner)
    benchcatcher =  run(benchrunner).times
    return benchcatcher
end


function bench(f,val1,val2)
    benchrunner = @benchmarkable ($f)($val1,$val2)
    tune!(benchrunner)
    benchcatcher = run(benchrunner).times
    return benchcatcher
end


function benchbits_parsed_rel(f,val,nbits)
    setprecision(BigFloat, nbits) 
    setprecision(ArbFloat, nbits)
    str = string(val)
    bigval = parse(BigFloat,str)
    arbval = parse(ArbFloat,str)
    bigbench = bench(f,bigval)
    arbbench = bench(f,arbval)
    big_slowdown = ratio( median(bigbench), median(arbbench) )
    return round2(big_slowdown)
  end

function benchbits_converted_rel(f,val,nbits)
    setprecision(BigFloat, nbits) 
    setprecision(ArbFloat, nbits)
    bigval = convert(BigFloat,val)
    arbval = convert(ArbFloat,val)
    bigbench = bench(f,bigval)
    arbbench = bench(f,arbval)
    big_slowdown =  ratio( median(bigbench), median(arbbench) )
    return round2(big_slowdown)
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
    big_slowdown =  ratio( median(bigbench), median(arbbench) )
    return round2(big_slowdown)
end



function nbit_bigfloat_slowerby(fn, val, vecnbits)
    nprecisions = length(vecnbits)
    slowerby = zeros(Float64, nprecisions)
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

BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1
BenchmarkTools.DEFAULT_PARAMETERS.samples = 8
BenchmarkTools.DEFAULT_PARAMETERS.evals   = 1


#const fp_precise_bits = [128, 256, 512, 768, 1024, 1280, 1536, 2048, 2560, 3072, 3584];
# const fp_precise_bits = [128, 256, 512, 1024, 1280, 1536, 2048, 2560, 3072];
const fp_precise_bits = [128*i for i in 1:16];

println( "    bits: ",fp_precise_bits' );println()

g = Float64(golden); recipg = 1/g; ten=10.0; tenth = (1/ten);
#mul_slowerby = nbit_bigfloat_slowerby( (*), g, recipg, fp_precise_bits); println("    mul :",mul_slowerby' )
#div_slowerby = nbit_bigfloat_slowerby( (/), g, recipg, fp_precise_bits); println("    div :", div_slowerby' )
# sqrt_slowerby = nbit_bigfloat_slowerby( (sqrt), v1, v2, fp_precise_bits); println("    sqrt :", sqrt_slowerby' )
exp_slowerby = nbit_bigfloat_slowerby( (exp), g, fp_precise_bits);   println( "    exp : ", exp_slowerby' ) 
log_slowerby = nbit_bigfloat_slowerby( (log), g, fp_precise_bits);   println( "    log : ", log_slowerby' )
cos_slowerby = nbit_bigfloat_slowerby( (cos), g, fp_precise_bits);   println( "    cos : ", cos_slowerby' )
tan_slowerby = nbit_bigfloat_slowerby( (tan), g, fp_precise_bits);   println( "    tan : ", tan_slowerby' )
acos_slowerby = nbit_bigfloat_slowerby( (acos), recipg, fp_precise_bits); println( "    acos: ", acos_slowerby' )
atan_slowerby = nbit_bigfloat_slowerby( (atan), recipg, fp_precise_bits); println( "    atan: ", atan_slowerby' )
cosh_slowerby = nbit_bigfloat_slowerby( (cosh), g, fp_precise_bits);  println( "    cosh: ", cosh_slowerby' )
tanh_slowerby = nbit_bigfloat_slowerby( (tanh), g, fp_precise_bits);  println( "    tanh: ", tanh_slowerby' )
acosh_slowerby = nbit_bigfloat_slowerby( (acosh), g, fp_precise_bits);println( "    acosh: ", acosh_slowerby' )
atanh_slowerby = nbit_bigfloat_slowerby( (atanh), recipg, fp_precise_bits);println( "    atanh: ", atanh_slowerby' )

gamma_slowerby = nbit_bigfloat_slowerby( (gamma), g, fp_precise_bits);println( "    gamma:  ", gamma_slowerby' )
digamma_slowerby = nbit_bigfloat_slowerby( (digamma), g, fp_precise_bits);println( "    digamma:  ", digamma_slowerby' )
zeta_slowerby = nbit_bigfloat_slowerby( (zeta), g, fp_precise_bits);println( "     zeta:  ", zeta_slowerby' )

println();println( "    bits: ",fp_precise_bits' )


#println("     *      : ", mul_slowerby' );
#println("     /      : ", div_slowerby' );
#println("    cbrt    : ", cbrt_slowerby' );
println( "    exp    : ", exp_slowerby' ); 
println( "    log    : ", log_slowerby' );
println( "    cos    : ", cos_slowerby' );
println( "    tan    : ", tan_slowerby' );
println( "    acos   : ", acos_slowerby' );
println( "    atan   : ", atan_slowerby' );
println( "    cosh   : ", cosh_slowerby' );
println( "    tanh   : ", tanh_slowerby' );
println( "    acosh  : ", acosh_slowerby' );
println( "    atanh  : ", atanh_slowerby' );

println( "    gamma  : ", gamma_slowerby' );
println( "    digamma: ", digamma_slowerby' );
println( "    zeta   : ", zeta_slowerby' );

bf_slower_table = [fp_precise_bits 
    exp_slowerby log_slowerby 
    cos_slowerby tan_slowerby acos_slowerby atan_slowerby 
    cosh_slowerby tanh_slowerby acosh_slowerby atanh_slowerby 
    gamma_slowerby digamma_slowerby zeta_slowerby]
