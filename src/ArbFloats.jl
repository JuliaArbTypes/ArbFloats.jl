module ArbFloats

import Base: hash, convert, promote_rule, isa,
    string, show, showcompact, showall, parse,
    finalizer, decompose, precision, setprecision,
    copy, deepcopy,
    zero, one, isinteger, ldexp, frexp, eps,
    isequal, isless, (==),(!=),(<),(<=),(>=),(>), contains,
    min, max, minmax,
    typemax, typemin, realmax, realmin,
    isnan, isinf, isfinite, issubnormal,
    signbit, sign, flipsign, copysign, abs, inv,
    (+),(-),(*),(/),(\),(%),(^), sqrt, hypot,
    trunc, round, ceil, floor,
    fld, cld, div, mod, rem, divrem, fldmod,
    muladd, fma,
    exp, expm1, log, log1p, log2, log10,
    sin, cos, tan, csc, sec, cot, asin, acos, atan, atan2,
    sinh, cosh, tanh, csch, sech, coth, asinh, acosh, atanh,
    sinc, gamma, lgamma, digamma, zeta, factorial,
    BigInt, BigFloat,
    Cint

export ArbFloat,      # co-matched decimal rounding, n | round(hi,n,10) == round(lo,n,10)
       ArbFloat512, ArbFloat256, ArbFloat128, ArbFloat64, ArbFloat32, ArbFloat16,
       @ArbFloat,     # converts string form of argument, precision is optional first arg in two arg form
       midpoint, radius, upperbound, lowerbound, bounds,
       stringcompact, stringall, stringallcompact, stringpretty,
       smartvalue, smartstring, showsmart, showallcompact, showpretty,
       two, three, four, copymidpoint, copyradius, deepcopyradius,
       get_emax, get_emin,
       epsilon, trim, decompose, isexact, notexact,
       iszero, notzero, nonzero, isone, notone, notinteger,
       ispositive, notpositive, isnegative, notnegative,
       includesAnInteger, excludesIntegers, includesZero, excludesZero,
       includesPositive, excludesPositive, includesNegative, excludesNegative,
       includesNonpositive,  includesNonnegative,
       notequal, approxeq, ≊,
       overlap, donotoverlap,
       contains, iscontainedby, doesnotcontain, isnotcontainedby,
       invsqrt, pow, root, tanpi, cotpi, logbase, sincos, sincospi, sinhcosh,
       doublefactorial, risingfactorial, rgamma, agm, polylog,
       relativeError, relativeAccuracy, midpointPrecision, trimmedAccuracy,
       PI,SQRTPI,LOG2,LOG10,EXP1,EULER,CATALAN,KHINCHIN,GLAISHER,APERY, # constants
       MullerKahanChallenge


# ensure the requisite libraries are available

isdir(Pkg.dir("Nemo")) || throw(ErrorException("Nemo not found"))

libDir = Pkg.dir("Nemo/local/lib");
libFiles = readdir(libDir);
libarb   = joinpath(libDir,libFiles[findfirst([startswith(x,"libarb") for x in libFiles])])
libflint = joinpath(libDir,libFiles[findfirst([startswith(x,"libflint") for x in libFiles])])
isfile(libarb)   || throw(ErrorException("libarb not found"))
isfile(libflint) || throw(ErrorException("libflint not found"))

@static if is_linux() || is_bsd() || is_unix()
    libarb = String(split(libarb,".so")[1])
    libflint = String(split(libflint,".so")[1])
end
@static if is_apple()
    libarb = String(split(libarb,".dynlib")[1])
    libflint = String(split(libflint,".dynlib")[1])
end
@static if is_windows()
    libarb = String(split(libarb,".dll")[1])
    libflint = String(split(libflint,".dll")[1])
end

macro libarb(sym)
    (:($sym), libarb)
end

macro libflint(sym)
    (:($sym), libflint)
end


NotImplemented(info::AbstractString="") = error(string("this is not implemented\n\t",info,"\n"))

include("support/ReadableNumbers.jl")

include("type/ArfFloat.jl")
include("type/ArbFloat.jl")

include("basics/primitive.jl")
include("basics/IEEEfp.jl")
include("basics/predicates.jl")
include("basics/string.jl")
include("basics/convert.jl")
include("basics/compare.jl")
include("basics/io.jl")

include("math/arith.jl")
include("math/round.jl")
include("math/elementary.jl")
include("math/constants.jl")
include("math/special.jl")

end # ArbFloats
