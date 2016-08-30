
ArbFloats.jl
============

#### Arb available as an extended precision floating point context.  

<p align="right">Jeffrey Sarnoff © 2016 August 30 in New York City</p>  

===========  
 
   This is the sixth effort and first reasonably comprehensive ArbFloats release.  
   This package is a faster alternative to BigFloats when working with significands  
   that do not exceed ~3,250 bits (~1000 digits).

   The base C library implements floating point intervals and operations thereupon  
   which are guaranteed to produce results that enclose the theoretical math value.  
   While not the package focus, full access to interval-based functions is present.

   This package has been designed to offer the Julia community more performant  
   extended precision floating point math and to offer extended floating point  
   results as accurately as possible at a precision that does not misrepresent  
   the information content of the unerlying interval valuation.



>
>   This is the sixth effort and first reasonably comprehensive ArbFloats release.  
>   This package is a faster alternative to BigFloats when working with significands  
>   that do not exceed ~3,500 bits.
>
>   The base C library implements floating point intervals and operations thereupon  
>   which are guaranteed to produce results that enclose the theoretical math value.  
>   While not the package focus, full access to interval-based functions is present.
>
>   This package has been designed to offer the Julia community more performant  
>   extended precision floating point math and to offer extended floating point  
>   results as accurately as possible at a precision that does not misrepresent  
>   the information content of the unerlying interval valuation.

#### version 0.0.6 (for Julia v0.5+).

If you find something to be an issue for you, submit it as an [issue](https://github.com/JuliaArbTypes/ArbFloats.jl/issues).  
If you write something that improves this for others, submit it as a [pull request](https://github.com/JuliaArbTypes/ArbFloats.jl/pulls).

Anyone interested in contributing some time is encouraged to contact the author (firstname.lastname at-the-gmail).

_We use some of Nemo's libraries.  Nemo is very large, and this package needs perhaps 1/8th of it to function properly._  


#### Install

```julia
Pkg.add("ArbFloats")
# or else Pkg.clone("https://github.com/JuliaArbTypes/ArbFloats.jl")
```
If you have not installed Nemo before, you will see compilation notes and maybe warnings.  
Ignore them.  This is a good time to walk the dog, go for coffee, or play shuffleboard.  
When the prompt comes back,   quit() and restart Julia and ```julia> using ArbFloats```  
should precompile quickly and work well.  This is what I do, to get things set up:

```julia
Pkg.update()
# get current Nemo, if needed do
# Pkg.rm("Nemo"); Pkg.rm("Nemo");
Pkg.add("Nemo")
quit()
# get current ArbFloats, if you have an older realization do
# Pkg.rm("ArbFloats");Pkg.rm("ArbFloats");
Pkg.add("ArbFloats")
Pkg.update()
using ArbFloats
quit()
using ArbFloats
quit()
```

#### Initializing ArbFloats

ArbFloats can be initialized from Integers, Floats, Rationals, and Strings

```julia
using ArbFloats

precision(ArbFloat) # show the current default precision
# 116
setprecision(ArbFloat, 120) # change the current default precision
# 100

a = ArbFloat(12)  # use the default precision, at run time
b = @ArbFloat(12) # use the default precision, at compile time
c = ArbFloat{200}(12) # use specified precision, at run time
d = @ArbFloat(200,12) # use specified precision, at compile time

setprecision(ArbFloat, 64);
#==
          remember to do this        and           to avoid this
==#
    goodValue = @ArbFloat(1.2345);        wrongValue = ArbFloat(1.2345);
#       1.234500000000000000                   1.2344999999999999307
    ArbFloat(12345)/ArbFloat(1000);       ArbFloat(12.345)/ArbFloat(10)
#       1.234500000000000000                   1.234500000000000064

@ArbFloat(1.2345) == ArbFloat("1.2345")
```

#### Use
```julia
using ArbFloats

exp1 = exp(ArbFloat(1))
# 2.7182818284590452353602874713526625
showall(exp1)
# 2.7182818284590452353602874713526625 ± 4.857142666566002e-35

fuzzed_e = tan(atanh(tanh(atan(exp1))))
# 2.7182818284590452353602874713527
showall(fuzzed_e)
# 2.7182818284590452353602874713526622 ± 7.883680925764943e-33

bounds(exp1)
# ( 2.7182818284590452353602874713526624, 2.7182818284590452353602874713526626 )
bounds(fuzzed_e)
# ( 2.7182818284590452353602874713526543, 2.7182818284590452353602874713526701 )
overlap(exp1, fuzzed_e), contains(fuzzed_e, exp1), iscontainedby(exp1, fuzzed_e)
# ( true. true, true )

smartstring(exp1)
# "2.71828182845904523536028747135266+"
smartstring(fuzzed_e)
# "2.7182818284590452353602874713527-"

smartvalue(exp1)
# 2.71828182845904523536028747135266
smartvalue(fuzzed_e)
# 2.7182818284590452353602874713527


# Float32 and ArbFloat32
# typealias ArbFloat32 ArbFloat{24}  # predefined
setprecision(ArbFloat, 24)

fpOneThird = 1.0f0 / 3.0f0
# 0.3333334f0

oneThird = ArbFloat(1) / ArbFloat(3)
# 0.3333333
showall(oneThird)
# 0.33333331 ± 2.9802322387695312e-8

# gamma(1/3) is 2.6789_3853_4707_7476_3365_5692_9409_7467_7644~
gamma( fpOneThird )
# 2.6789_384f0

gamma_oneThird = gamma( oneThird )
# 2.6789_4
bounds(gamma_oneThird)
# (2.6789_362, 2.6789_401)
```

#### Display
```julia
pi66bits=ArbFloat{66}(pi)
# 3.141592653589793238
showpretty(ArbFloat{66}(pi))
# 3.141_592_653_589_793_238

pi67bits=ArbFloat{67}(pi)
 3.1415926535897932385
showpretty(ArbFloat{67}(pi),5)
# 3.14159_26535_89793_2385
```



### Compatable Packages

**using ArbFloats \# goes anywhere**  
DifferentialEquations, DualNumbers, ForwardDiff, HyperDualNumbers, MappedArrays,  
Plots, Polynomials, Quaternions, , others

**using ArbFloats \# goes last!**  
TaylorSeries

*partially compatible*  
Roots (accepts ArbFloats, results are Float64)

If you have a package that accepts AbstractFloats or Reals and does not “just
work” with ArbFloats, please note it as an issue. If you have a package that
works well with ArbFloats, let us know.

### About Arb and using Nemo's libraries

This work is constructed atop a state-of-the-art C library for working with
*midpoint ± radius* intervals, `Arb`. `Arb` is designed and written by Fredrik
Johansson, who graciously allows Julia to use it under the MIT License.

The C libraries that this package accesses are some of the shared libraries that
Nemo.jl requires and builds; and, with permission, I call them directly.

It is a useful fiction to think of `ArbFloats` as Arb values with a zero radius
– and sometimes they are. When an `ArbFloat` has a nonzero radius, the user sees
only those digits that remain after rounding the`ArbFloat\` to subsume the radius.


### Appropriateness

This package is appropriate to use for extending the precision of floating point   
computations from 64 bits [~17 digits] up to 3,250 bits [~1000 digits].  
While Testing on many different hosts is needed to characterize a most performant  
precision range, I have found working with 800 bits (~240 digits) a welcome change.

#### Conceptual Background

`Transparency`: a desirable quality that may obtain in the presentation of
numerical quantity. Where `transparency` exists, it may well not persist. A
diminution of `transparency` increases `opacity`, and vice versa. Presentation
of a floating point value either evinces `transparency` or furthers `opacity`.
With `transparent` values, ‘looking at a value’ is ‘looking through to see the
knowable value’. With `opaque` values, ‘looking at a value’ is ‘looking away
from’ that. And it is that nonresponsive, nonparticipative engagement of
cognitive attention that is the `opaqueness` underlying `opacity`.

Presented with a `transparent` floating point value, the perceiver is become
best informed. There is no other rendition of that floating point realization
which is intrinsically more informing and none which relays the value of that
floating point realization more accurately – none with fewer digits, none with
more digits, none of greater magnitude, none of lesser magnitude.

An `ArbFloat` is an extended precision float architected to evince
`transparency`. It informs without leading or misleading. An `ArbFloat`, when
viewed, appears as an extended precision floating point value. When any of the
exported arithmetic, elementary or special functions is applied to an
`ArbFloat`, the value transforms as an extended precision floating point
interval.



Exports (including re-exports)
------------------------------

| used with ArbFloat                                         | nature                    |
|------------------------------------------------------------|---------------------------|
| precision, setprecision                                    | as with BigFloat          |
| Arb values are intervals                                   | nature                    |
| midpoint, radius, lowerbound, upperbound, bounds,          | Arb’s constituent parts   |
| isexact, notexact,                                         | float-y or interval-y     |
| overlap, donotoverlap,                                     | of interval suborder      |
| contains, iscontainedby, doesnotcontain, isnotcontainedby, | of interval partial order |


| ArbFloat attributes                                         | nature                   |
|-------------------------------------------------------------|--------------------------|
| isnan, isinf, isfinite, issubnormal, isinteger, notinteger, | floatingpoint predicates |
| iszero, notzero, nonzero, isone, notone,                    | number predicates        |
| ispositive, notpositive, isnegative, notnegative,           | numerical predicates     |

>   copy, deepcopy, zero, one, eps, epsilon, isequal, notequal, isless,  
>   (==),(!=),(\<),(\<=),(\>=),(\>),          #  Arb, strict:  a < b iff upperbound(a) < lowerbound(b)  
>   (\≃), (\≄), (\≺), (\≼), (\≻), (\≽ ),    #  non-strict total ordering  (better for convergence testing)   
>   approxeq, ≊, min, max, minmax,  

>   signbit, sign, flipsign, copysign, abs, (+),(-),(\*),(/),(),(%),(\^), inv,  
>   sqrt, invsqrt, hypot, factorial, doublefactorial, risingfactorial, trunc,  
>   round, ceil, floor,  

>   pow, root, exp, expm1, log, log1p, log2, log10, logbase, sin, cos, sincos,  
>   sincospi, tan, csc, sec, cot, asin, acos, atan, atan2, sinh, cosh, sinhcosh,  
>   tanh, csch, sech, coth, asinh, acosh, atanh,  

>   gamma, lgamma, digamma, sinc, zeta, polylog, agm  

#### Credits, References, Thanks

This work relies on Fredrik Johansson's Arb software, using parts of that
extensive C library.  
He has been greatly helpful. The Arb library documentation is
[here](http://fredrikj.net/arb/).  

Much of the early development was well informed from study of Nemo.jl, a number
theory and  
numerical algebra package that incorporates some of Arb's capabilities along
with many others.  
William Hart and Tommy Hofmann have been gracious with their work and generous
with their time.  

Others have helped with conceptual subtilties, software from which I learned Julia,    
suggesting improvements, fixing bugs, testing and other specific acts of good will:   
&nbsp;&nbsp;&nbsp;&nbsp;Stefan Karpinski, Jeff Bezanson, Alan Edelman, John Myles White,  
&nbsp;&nbsp;&nbsp;&nbsp;Tim Holy, Thomas Breloff, David P. Sanders, Yichao Yu,   
&nbsp;&nbsp;&nbsp;&nbsp;Scott Jones, Luis Benet, Chris Rackauckas, Galen O'Neil.

=====
=====
  
  
[//]: # (developer info)

[//]: # (#### other, sometimes overlapping, software development is with)

[//]: # ([ArbDecimals](https://github.com/JuliaArbTypes/ArbDecimals.jl))
[//]: # ([ArbReals](https://github.com/JuliaArbTypes/ArbReals.jl))

[//]: # (### current flows are in)

[//]: # ([the ArbFloats gitter](https://gitter.im/JuliaArbTypes/ArbFloats.jl)  )
[//]: # ([the ArbReals wiki](https://github.com/JuliaArbTypes/ArbReals.jl/wiki) )
[//]: # (and [ongitter](https://gitter.im/JuliaArbTypes/ArbReals.jl) )


