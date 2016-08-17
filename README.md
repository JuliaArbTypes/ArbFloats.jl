ArbFloats.jl
============

###### Arb available as an extended precision floating point context.

<p align="right">Jeffrey Sarnoff © 2016˗May˗26 in New York City</p>


>   This is a foundational library that substitutes for BigFloat when
>   prespecified significand lengths are required.  
>   ArbDecimal, which built on top of this library, is a better choice when
>   standard digit spans (significand lengths)  
>   are used and *highly reliable* results are desired.

##### version 0.1.0 (This is for Julia v0.5).

### Compatable Packages

**using ArbFloats \# goes anywhere**  
DifferentialEquations, DualNumbers, ForwardDiff, HyperDualNumbers, MappedArrays,
Plots, Polynomials, Quaternions, , others

**using ArbFloats \# goes last!** TaylorSeries

*partially compatible* Roots (accepts ArbFloats, results are Float64)

If you have a package that accepts AbstractFloats or Reals and does not “just
work” with ArbFloats, please note it as an issue. If you have a package that
works well with ArbFloats, let us know.

### Appropriateness

Preferred for extending the precision of floating point computations from 64
bits [17 digits] up to 512 bits [150 digits]. Recommended for use where
elementary or special functions are evaluated to obtain results with up to 250
digits [800 bits].

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

### About Arb

This work is constructed atop a state-of-the-art C library for working with
*midpoint ± radius* intervals, `Arb`. `Arb` is designed and written by Fredrik
Johansson, who graciously allows Julia to use it under the MIT License.

The C libraries that this package accesses are some of the shared libraries that
Nemo.jl requires and builds when it is installed; and I am calling them
directly. Nemo is a computational environment where the most important software
for number theory and related work. Julia is used to create a cohesive whole
that shares a manner of use. Fredrik Johansson, William Hart, and Tommy Hoffman
have been especially helpful, taking the time to explain details of Arb as I was
working on ArbFloats.

###### Hint

It is a useful fiction to think of `ArbFloats` as Arb values with a zero radius
– and sometimes they are. When an `ArbFloat` has a nonzero radius, the user sees
only those digits that \_don`t care_:  the digits which remain after rounding
the`ArbFloat\` so that the radius is subsumed (as if 0.0).

#### Install

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ julia
Pkg.add("Nemo")
Pkg.add("ArbFloats")
# or Pkg.clone("https://github.com/JuliaArbTypes/ArbFloats.jl")
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#### Use with other Numeric Types

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ julia
setprecision(ArbFloat, 64);
#==
          remember to do this    and       to avoid this
==#
    goodValue = @ArbFloat(1.2345);    wrongValue = ArbFloat(1.2345);
#       1.234500000000000000                1.2344999999999999307
    ArbFloat(12345)/ArbFloat(1000);    ArbFloat(12.345)/ArbFloat(10)
#       1.234500000000000000                1.234500000000000064

@ArbFloat(1.2345) == ArbFloat("1.2345")
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#### Use

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.f#}
using ArbFloats

five = ArbFloat(5)
5

e = exp(ArbFloat(1))
2.7182_8182_8459_0452_3536_0287_4713_5266_2 ± 4.8148250e-35
fuzzed_e = tan(atanh(tanh(atan(e))))
2.7182_8182_8459_0452_3536_0287_4713_52662 ± 7.8836806e-33

bounds(e)
( 2.7182_8182_8459_0452_3536_0287_4713_52663,
  2.7182_8182_8459_0452_3536_0287_4713_52664 )
smartstring(e)
2.7182_8182_8459_0452_3536_0287_4713_5266₊

bounds(fuzzed_e)
( 2.7182_8182_8459_0452_3536_0287_4713_52654,
  2.7182_8182_8459_0452_3536_0287_4713_52670 )
smartstring(fuzzed_e)
2.7182_8182_8459_0452_3536_0287_4713_527₋


# Float32 and ArbFloat32
# typealias ArbFloat32 ArbFloat{24}  # predefined
setprecision(ArbFloat, 24)


fpOneThird = 1.0f0 / 3.0f0
0.3333_334f0

oneThird = ArbFloat(1) / ArbFloat(3)
0.3333_333 ± 2.9803_322e-8

# gamma(1/3) is 2.6789_3853_4707_7476_3365_5692_9409_7467_7644~

gamma_oneThird = gamma( oneThird )
2.6789_380  ± 1.8211887e-6

bounds(gamma_oneThird)
(2.6789_360, 2.6789_400)

gamma( fpOneThird )
2.6789_384f0

pi66bits=ArbFloat{66}(pi)
3.141592653589793238

pi67bits=ArbFloat{67}(pi)
3.1415926535897932385
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ArbFloat values: Arb seen as precisely accurate floats
   elevates transparent information over number mumble
   each digit shown is an accurate refinement of value

The least significant digit observable, through show(af) or with string(af),
  is smallest transparent _(intrinsically non-misleading)_ refinement of value.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

| ArbFloat attributes                                         | nature                   |
|-------------------------------------------------------------|--------------------------|
| isnan, isinf, isfinite, issubnormal, isinteger, notinteger, | floatingpoint predicates |
| iszero, notzero, nonzero, isone, notone,                    | number predicates        |
| ispositive, notpositive, isnegative, notnegative,           | numerical predicates     |

>   copy, deepcopy, zero, one, eps, epsilon, isequal, notequal, isless,
>   (==),(!=),(\<),(\<=),(\>=),(\>), approxeq, ≊, min, max, minmax,

>   signbit, sign, flipsign, copysign, abs, (+),(-),(\*),(/),(),(%),(\^), inv,
>   sqrt, invsqrt, hypot, factorial, doublefactorial, risingfactorial, trunc,
>   round, ceil, floor,

>   pow, root, exp, expm1, log, log1p, log2, log10, logbase, sin, cos, sincos,
>   sincospi, tan, csc, sec, cot, asin, acos, atan, atan2, sinh, cosh, sinhcosh,
>   tanh, csch, sech, coth, asinh, acosh, atanh,

>   gamma, lgamma, digamma, sinc, zeta, polylog, agm




#### Credits, References, Thanks

This work relies on Fredrik Johansson's Arb software, using parts of that extensive C library.  
He has been greatly helpful.  The Arb library documentation is [here](http://fredrikj.net/arb/).    

Much of the early development was well informed from study of Nemo.jl, a number theory and  
numerical algebra package that incorporates some of Arb's capabilities along with many others.  
William Hart andTommy Hofmann have been gracious with their work and generous with their time.

Others have helped with conceptual subtilties, software from which I learned Julia, clarifying or fixing bugs, testing and specific good will: Stefan Karpinski, Jeff Bezanson, Alan Edelman, John Myles White, Tim Holy, Tom Breloff, David P. Sanders, Scott Jones, Luis Benet, Chris Rackauckas. 

=====
=====
developer info
===============

#### other, sometimes overlapping, software development is with

[ArbDecimal](https://github.com/JuliaArbTypes/ArbDecimal.jl)
[ArbReals](https://github.com/JuliaArbTypes/ArbReals.jl)

### current flows are in

[the ArbFloats gitter](https://gitter.im/JuliaArbTypes/ArbFloats.jl)  
[the ArbReals wiki](https://github.com/JuliaArbTypes/ArbReals.jl/wiki) and [on
gitter](https://gitter.im/JuliaArbTypes/ArbReals.jl)
