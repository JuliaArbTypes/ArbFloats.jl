__precompile__()

module ArbFloats

import Base: STDOUT,
    hash, convert, promote_rule, isa,
    string, show, showcompact, showall, parse,
    finalizer, decompose, precision, setprecision,
    serialize, deserialize,
    typemin, typemax, realmin, realmax,
    copy, deepcopy,
    zero, one, isinteger,
    ldexp, frexp, eps,
    isequal, isless, (==),(!=),(<),(<=),(>=),(>), contains,
    min, max, minmax,
    typemax, typemin, realmax, realmin,
    float, nextfloat, prevfloat,
    isnan, isinf, isfinite, issubnormal,
    signbit, sign, flipsign, copysign, abs, ab2,
    (+),(-),(*),(/),(\),(%),(^), inv, sqrt, hypot,
    (.+),(.-),(.*),(./),
    trunc, round, ceil, floor,
    fld, cld, div, mod, rem, divrem, fldmod,
    muladd, fma,
    exp, expm1, log, log1p, log2, log10,
    sin, cos, tan, csc, sec, cot, asin, acos, atan, atan2,
    sinh, cosh, tanh, csch, sech, coth, asinh, acosh, atanh,
    sinc, gamma, lgamma, digamma, zeta, factorial,
    in, union, intersect,
    BigInt, BigFloat, Float64, Float32, Int128, Int64, Int32, Rational,
    Cint

export ArbFloat,      # co-matched decimal rounding, n | round(hi,n,10) == round(lo,n,10)
       @ArbFloat,     # converts string form of argument, precision is optional first arg
       setprecisionAugmented,
       simeq, nsime, prec, preceq, succ, succeq, # non-strict total ordering comparisons
       (≃), (≄), (≺), (⪯), (≻), (⪰),           #    matched binary operators
       upperbound, lowerbound, bounds,
       midpoint, radius, midpoint_radius,
       bounding_midpoint, bounding_radius, bounding_midpoint_radius,
       stringsmall, stringcompact, stringmedium, stringlarge, stringall,
       stringsmall_pm, stringcompact_pm, string_pm,
       stringlarge_pm, stringall_pm,
       showsmall, showcompact, showlarge, showallcompact, showpretty,
       showsmall_pm, showcompact_pm, show_pm,
       showlarge_pm, showall_pm,
       stringpretty, smartvalue, smartstring, showsmart,
       two, three, four, copymidpoint, copyradius, deepcopyradius,
       get_emax, get_emin, bounded, boundedrange,
       decompose, isexact, notexact,
       isposinf, isneginf,
       notnan, notinf, notposinf, notneginf, notfinite,
       iszero, notzero, nonzero, isone, notone, notinteger,
       ispositive, notpositive, isnegative, notnegative,
       includesAnInteger, excludesIntegers, includesZero, excludesZero,
       includesPositive, excludesPositive, includesNegative, excludesNegative,
       includesNonpositive,  includesNonnegative,
       areequal, notequal, approxeq, (≊),
       narrow, overlap, donotoverlap,
       contains, iscontainedby, doesnotcontain, isnotcontainedby,
       invsqrt, pow, root, tanpi, cotpi, logbase, sincos, sincospi, sinhcosh,
       doublefactorial, risingfactorial, rgamma, agm, polylog,
       relativeError, relativeAccuracy, midpointPrecision, trimmed,
       PI,SQRTPI,LOG2,LOG10,EXP1,EULER,CATALAN,KHINCHIN,GLAISHER,APERY, # constants
       get_midpoint_digits_shown, get_radius_digits_shown,  # some interface control
       set_midpoint_digits_shown, set_radius_digits_shown,
       isolate_nonnegative_content, isolate_positive_content, # for interval algorithms
       force_nonnegative_content, force_positive_conent

NotImplemented(info::AbstractString="") = error(string("this is not implemented\n\t",info,"\n"))

include("support/NemoLibs.jl")                 # for precompiled libraries
include("support/ReadableNumbers.jl")          # digit subsequence separators

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

include("math/arrayops.jl")


#=
# precision is significand precision, significand_bits(FloatNN) + 1, for the hidden bit
typealias ArbFloat16  ArbFloat{ 11}  # read   2 ? 3 or fewer decimal digits to write the same digits ( 16bit Float)
typealias ArbFloat32  ArbFloat{ 24}  # read   6 ? 7 or fewer decimal digits to write the same digits ( 32bit Float)
typealias ArbFloat64  ArbFloat{ 53}  # read  15 ?15 or fewer decimal digits to write the same digits ( 64bit Float)
typealias ArbFloat128 ArbFloat{113}  # read  33 ?34 or fewer decimal digits to write the same digits (128bit Float)
typealias ArbFloat256 ArbFloat{237}  # read  71 ?71 or fewer decimal digits to write the same digits (256bit Float)
typealias ArbFloat512 ArbFloat{496}  # read 148?149 or fewer decimal digits to write the same digits (512bit Float)
=#

end # ArbFloats
