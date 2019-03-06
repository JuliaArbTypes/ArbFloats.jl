"""
precision(ArbFloat)           # show the current default precision  
setprecision(ArbFloat, 120)   # change the current default precision  
setprecision(ArbFloat, 53+7)  # akin to setprecision(BigFloat, 53)  

ArbFloat(12)       # use the default precision, at run time  
ArbFloat{200}(12)  # use specified precision, at run time  
ArbFloat(200,"12") # use the specified precision, at run time  
@ArbFloat(12)      # use the default precision, at compile time  
@ArbFloat(200,12)  # use specified precision, at compile time  

@ArbFloat(1.2345) == ArbFloat("1.2345")

          remember to do this        and           to avoid this

    goodValue = @ArbFloat(1.2345)         wrongValue = ArbFloat(1.2345);
        1.234500000000000000                   1.2344999999999999307

     ArbFloat(12345)/ArbFloat(1000)        ArbFloat(12.345)/ArbFloat(10)
        1.234500000000000000                   1.234500000000000064


```
setprecision(ArbFloat, 80)

exp1 = exp(ArbFloat(1));
stringsmall(exp1),stringcompact(exp1),string(exp1),stringall(exp1)
> ("2.7182818","2.71828182845905","2.71828182845904523536029","2.71828182845904523536029")
showall_pm(exp1)
> 2.718281828459045235360286±3.3216471534462276e-24
bounds(exp1)
> ( 2.71828182845904523536028,  2.718281828459045235360293 )

setprecision(ArbFloat, 116); # the initial default precision
fuzzed_e = tan(atanh(tanh(atan(exp(one(ArbFloat))))))
> 2.718281828459045235360287
showall(fuzzed_e)
> 2.7182818284590452353602874713527
bounds(fuzzed_e)
> ( 2.718281828459045235360287,   
    2.718281828459045235360287 )
> they are not really the same ...    
lo, hi = bounds(fuzzed_e); showall(lo,hi)
> ( 2.7182818284590452353602874713526543,  
    2.7182818284590452353602874713526701 )

smartstring(fuzzed_e)  
> "2.7182818284590452353602874713527-"
```
"""
module ArbFloats


export ArbFloat,      # co-matched decimal rounding, n | round(hi,n,10) == round(lo,n,10)
       @ArbFloat,     # converts string form of argument, precision is optional first arg
       simeq, nsime, prec, preceq, succ, succeq, # non-strict total ordering comparisons
       (≃), (≄), (≺), (⪯), (≻), (⪰),           #    matched binary operators
       upperbound, lowerbound, bounds,
       midpoint, radius, midpoint_radius,
       bounding_midpoint, bounding_radius, bounding_midpoint_radius,
       stringsmall, stringcompact, stringmedium, stringlarge, stringall,
       stringsmall_pm, stringcompact_pm, string_pm,
       stringlarge_pm, stringall_pm, string_exact,
       showsmall, showcompact, showlarge, showall, showpretty,
       showsmall_pm, showcompact_pm, show_pm,
       showlarge_pm, showall_pm,
       stringpretty, smartvalue, smartstring, showsmart,
       readable, show_readable, ReadableNumStyle,
       two, three, four, copymidpoint, copyradius, deepcopyradius,
       get_emax, get_emin, bounded, boundedrange,
       fmod, decompose, 
       integerpart, decimalpart, fractionalpart, smartmodf,
       isexact, notexact,
       isposinf, isneginf,
       notnan, notinf, notposinf, notneginf, notfinite,
       iszero, notzero, nonzero, isone, notone, notinteger,
       ispositive, notpositive, isnegative, notnegative,
       includes_integer, excludes_integer, includes_zero, excludes_zero,
       includes_positive, excludes_positive, includes_negative, excludes_negative,
       includes_nonpositive,  includes_nonnegative,
       areequal, notequal, approxeq, (≊),
       narrow, overlap, donotoverlap,
       contains, iscontainedby, doesnotcontain, isnotcontainedby,
       absz, absz2, invsqrt, pow, root, 
       tanpi, cotpi, logbase, sincos, sincospi, sinhcosh,
       doublefactorial, risingfactorial, rgamma, agm, polylog,
       relative_error, relative_accuracy, midpoint_precision, trimmed,
       PI,SQRTPI,LOG2,LOG10,EXP1,EULER,CATALAN,KHINCHIN,GLAISHER,APERY, # constants
       get_midpoint_digits_shown, get_radius_digits_shown,  # some interface control
       set_midpoint_digits_shown, set_radius_digits_shown,
       isolate_nonnegative_content, isolate_positive_content, # for interval algorithms
       force_nonnegative_content, force_positive_content,
       sort_intervals                                         # uses weak total ordering over intervals 

import Base: stdout,
    hash, convert, promote_rule, isa,
    string, show, parse,
    finalizer, decompose, precision, setprecision,
    typemin, typemax, floatmin, floatmax,
    copy, deepcopy,
    size, length,
    zero, one, isinteger,
    ldexp, frexp, modf, eps,
    isequal, isless, (==),(!=),(<),(<=),(>=),(>),
    min, max, minmax,
    typemax, typemin, floatmax, floatmin,
    float, nextfloat, prevfloat,
    isnan, isinf, isfinite, issubnormal,
    signbit, sign, flipsign, copysign, abs, abs2,
    (+),(-),(*),(/),(\),(%),(^), inv, sqrt, hypot,
    trunc, round, ceil, floor,
    fld, cld, div, mod, rem, divrem, fldmod,
    muladd, fma,
    exp, expm1, log, log1p, log2, log10,
    sin, cos, tan, csc, sec, cot, asin, acos, atan,
    sinh, cosh, tanh, csch, sech, coth, asinh, acosh, atanh,
    sinc, factorial,
    in, union, intersect,
    rand, randn, sort,
    BigInt, BigFloat, Rational

import Base.Rounding: rounding_raw, setrounding_raw, rounding, setrounding

using Serialization
using SpecialFunctions

import SpecialFunctions: gamma, lgamma, digamma, zeta

if isdefined(Base, :iszero)
  import Base:iszero
else
  export iszero
end          

NotImplemented(info::AbstractString="") = error(string("this is not implemented\n\t",info,"\n"))

include("support/libarb.jl")                 # for precompiled libraries
#include("support/NemoLibs.jl")                 # for precompiled libraries

using ReadableNumbers

include("type/ArbCstructs.jl")
include("type/MagFloat.jl")
include("type/ArfFloat.jl")
include("type/ArbFloat.jl")
include("type/ArbInterval.jl")


include("basics/primitive.jl")
include("basics/IEEEfp.jl")

include("basics/predicates.jl")
include("basics/convert.jl")
include("basics/compare.jl")
include("basics/sort.jl")

include("basics/string.jl")
include("basics/smartstring.jl")
include("basics/show.jl")
include("basics/serialize.jl")

include("math/arith.jl")
include("math/round.jl")
include("math/elementary.jl")
include("math/constants.jl")
include("math/special.jl")

include("math/rounding.jl")
include("math/rand.jl")
include("math/arrayops.jl")


#=
# precision is significand precision, significand_bits(FloatNN) + 1, for the hidden bit
=#
const ArbFloat16 = ArbFloat{ 11}  # read   2 ? 3 or fewer decimal digits to write the same digits ( 16bit Float)
const ArbFloat32 = ArbFloat{ 24}  # read   6 ? 7 or fewer decimal digits to write the same digits ( 32bit Float)
const ArbFloat64  = ArbFloat{ 53}  # read  15 ?15 or fewer decimal digits to write the same digits ( 64bit Float)
const ArbFloat128 = ArbFloat{113}  # read  33 ?34 or fewer decimal digits to write the same digits (128bit Float)
const ArbFloat256 = ArbFloat{237}  # read  71 ?71 or fewer decimal digits to write the same digits (256bit Float)
const ArbFloat512 = ArbFloat{496}  # read 148?149 or fewer decimal digits to write the same digits (512bit Float)

end # ArbFloats
