
ArbFloats.jl
============

#### Arb available as an extended precision floating point context.  

Jeffrey Sarnoff © 2016 Sep 15 in New York, USA

===========  
 
   This package is a faster alternative to BigFloats when working with significands  
   that do not exceed ~3,250 bits (~1000 digits).

   The base C library implements floating point intervals and operations thereupon  
   which are guaranteed to produce results that enclose the theoretical math value.  
   While not the package focus, full access to interval-based functions is present.

   ArbFloats provides more performant extended precision floating point math 
   and will show results as accurately as possible by using a precision that
   does not misrepresent the information content of the underlying interval.


#### version 0.1.8 (for Julia v0.5).

If you find something to be an issue for you, submit it as an [issue](https://github.com/JuliaArbTypes/ArbFloats.jl/issues).  
If you write something that improves this for others, submit it as a [pull request](https://github.com/JuliaArbTypes/ArbFloats.jl/pulls).

Anyone interested in contributing some time is encouraged  
to contact the author (firstname.lastname at-the-gmail).


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
__It is helpful to add Nemo first, quit, then add ArbFloats and quit__.  

#### Initializing ArbFloats

ArbFloats can be initialized from Integers, Floats, Rationals, and Strings

```julia
using ArbFloats

precision(ArbFloat) # show the current default precision
# 116
setprecision(ArbFloat, 120) # change the current default precision
# 100

a = ArbFloat(12);  # use the default precision, at run time
b = @ArbFloat(12); # use the default precision, at compile time
c = ArbFloat{200}(12); # use specified precision, at run time
d = @ArbFloat(200,12); # use specified precision, at compile time

# setprecision(ArbFloat, 53+0); # akin to setprecision(BigFloat, 53)
# to see elementary function evaluations rounded to (at least) N significand bits, 
#   using setprecision(ArbFloat, N+10) is recommended and at least N+7 is suggested
#   setprecisionAugmented(ArbFloat, N) does the N+10 automatically
#   setprecisionAugmented(ArbFloat, N, d) uses N+d for the precision

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

setprecision(ArbFloat, 80)

exp1 = exp(ArbFloat(1));
stringsmall(exp1),stringcompact(exp1),string(exp1),stringall(exp1)
("2.7182818","2.71828182845905","2.71828182845904523536029","2.71828182845904523536029")
showall_pm(exp1)
# 2.718281828459045235360286±3.3216471534462276e-24
bounds(exp1)
# ( 2.71828182845904523536028,  2.718281828459045235360293 )

setprecision(ArbFloat, 116); # the initial default precision

fuzzed_e = tan(atanh(tanh(atan(exp(one(ArbFloat))))))
# 2.718281828459045235360287
showall(fuzzed_e)
# 2.7182818284590452353602874713527

bounds(fuzzed_e)
# ( 2.718281828459045235360287,
#   2.718281828459045235360287 )
# they are not really the same ...    
lo, hi = bounds(fuzzed_e);
showall(lo,hi)
# ( 2.7182818284590452353602874713526543,
    2.7182818284590452353602874713526701 )
    
# use values of the same precision with interval operators

precision(exp1), precision(fuzzed_e)
# 80, 116
overlap(exp1, fuzzed_e), contains(fuzzed_e, exp1), iscontainedby(exp1, fuzzed_e)
# ( true. false, false )
exp1 = exp(ArbFloat(1.0))
precision(exp1), precision(fuzzed_e)
# (116, 116)
overlap(exp1, fuzzed_e), contains(fuzzed_e, exp1), iscontainedby(exp1, fuzzed_e)
# ( true. true, true )


smartstring(exp1)
# "2.71828182845904523536028747135266+"
smartstring(fuzzed_e)
# "2.7182818284590452353602874713527-"
```

####Float32 and ArbFloat32
```julia
typealias ArbFloat32 ArbFloat{24} # Float32 has 24 significand bits
setprecision(ArbFloat, 24) # it is good to keep precisions in concert

fpOneThird = 1.0f0 / 3.0f0
# 0.3333334f0

oneThird = ArbFloat32(1) / ArbFloat32(3)
# 0.3333333
show_pm(oneThird)
# 0.33333331±2.98023223877e-8


# gamma(1/3) is 2.6789_3853_4707_7476_3365_5692_9409_7467_7644~
gamma( fpOneThird )
# 2.6789_384f0

gamma_oneThird = gamma( oneThird )
# 2.6789_4
bounds(gamma_oneThird)
# (2.6789_362, 2.6789_401)
showsmall(gamma_oneThird)
```

#### Display
```julia

# e.g. stringsmall & showsmall, stringsmall_pm & showsmall_pm
# {string,show}{small, compact, all, small_pm, compact_pm, all_pm}
stringsmall(oneThird), stringsmall_pm(oneThird)
("0.3333333",  "0.33333331±2.98e-8")

# show works with vectors and tuples and varargs of ArbFloat
showsmall([oneThird, oneThird]);showsmall((oneThird,oneThird));showsmall(oneThird,oneThird)
# [ 0.3333333,      ( 0.3333333,      ( 0.3333333,
#   0.3333333 ]       0.3333333 )       0.3333333 )


ArbFloat("Inf"), ArbFloat("-Inf"), ArbFloat("NaN")
# +Inf, -Inf, NaN
one(ArbFloat)/ArbFloat(Inf), ArbFloat("Inf")+ArbFloat("-Inf")
# 0, NaN

showmart(exp1)
# 2.71828182845904523536028747135266+
showsmart(fuzzed_e)
# 2.7182818284590452353602874713527-

pi66bits=ArbFloat{66}(pi)
# 3.141592653589793238
showpretty(ArbFloat{66}(pi))
# 3.141_592_653_589_793_238

pi67bits=ArbFloat{67}(pi)
# 3.1415926535897932385
showpretty(ArbFloat{67}(pi),5)
# 3.14159_26535_89793_2385
```

#### Non-Strict Total Ordering
```julia
thinner = midpoint_radius( 1000.0, 1.0);
thicker = midpoint_radius( "1000.0", "2.0");

thicker≻ thinner, thinner  ⪯  thicker, succ(thicker, thinner),
# (true, true, true)
thicker  ⪯  thinner, thinner ≻  thicker, preceq(thicker, thinner)
# (false, false, false)
succ(thicker, thinner), succ(thinner, thicker)
# false, true

```

### Compatible Packages

**using ArbFloats \# goes anywhere**  
DifferentialEquations, DualNumbers, ForwardDiff, HyperDualNumbers, MappedArrays,  
Plots, Polynomials, Quaternions, others

**using ArbFloats \# goes last!**  
TaylorSeries

*partially compatible*  
Roots (accepts ArbFloats, results are Float64)

If you have a package that accepts AbstractFloats or Reals and does not “just work”   
with ArbFloats, please note it as an issue. If you have a package that works well   
with ArbFloats, do let us know.

### More Information

Please the notes directory for more information about ArbFloats.

#### Hewing to the sensible

Arb is happiest, and performs most admirably using intervals where the radius is     
a very small portion of the working precision. Ideally, the radius is kept within      
8*eps(midpoint).  With Arb, you are likely ok up to twice that.  And should your  
approach generate unhelpfully wide intervals, then a way with fewer repeated touches  
(prefer projection techniques to recursively applicative transforms), perhaps run  
at higher working precision, is worth trying.  A toy version is likely to behave  
in the same manner as your the more refined software.  It is worth the look.

The intervals underlying this package are kept by Arb as an extended precision   
`midpoint` and a `radius` (halfwidth) as a float of low precision & high range.  
The radius is stored as a 30 bit significand and a ~60 bit exponent.  The radius   
is like a Float32 (24bit significand) value with a much larger exponent.  

#### Warp and Weft

One way of think of these midpoint+radius intervals is as cereal and milk.  
The cereal  sources nourishment and the milk makes it easy to digest.  
The midpoint associates as a valuation, and the radius engages as a capacity-  
limiting store of value. The more extensive the radius, the more spread out,  
dilute is any value stored.  Value concentrates as the midpoint magnitude  
increases relative to the radius.

Another is to use the pairing of midpoint with its immediate locale (diameter)   
as a semantic descriptor and quantify the semantics.  The veridical presentment   
of floating point quantities is one of the primary motivators for this package.  
And there is software which moves from two floats, `midpoint`+`radius`, through  
the active preternatural simplicty of most informing whilst least misleading,  
into the floating point value that best reflects `the crispness of its novelty`.    


#### Rough Spots

This package does whatever it may through the Arb C library.  On rare occasion,    
this may give a result which makes Arb sense yet appears counter-intuitive here.  
One example is Arb's ability to work with and to return projective infinity (±Inf).  
This package now does now provide a means of working with Arb's complex intervals,  
nor is their access to any of Arb's matrix routines (det, inv, lu, maybe charpoly). 

ArbFloats do not lend themselves easily to higher matrix algebra (svd, eigenvals).    
If someone implements one of the known good algorithms for getting the eigenvalues  
or the svd of a matrix with interval-valued entries, this package is at the ready.  


_We use some of Nemo's libraries.  Nemo is very large, and this work needs less than 1/8th of it._  


### About Arb and using Nemo's libraries

This work is constructed atop a state-of-the-art C library for working with  
*midpoint ± radius* intervals, `Arb`. Arb is designed and written by Fredrik  
Johansson, who graciously allows Julia to use it under the MIT License.  

The C libraries that this package accesses are some of the shared libraries that  
Nemo.jl requires and builds; and, with permission, I call them directly.  

It is a useful fiction to think of `ArbFloats` as Arb values with a zero radius  
– and sometimes they are. When an ArbFloat has a nonzero radius, the user sees  
only those digits that remain after rounding the ArbFloat to subsume the radius.  


### Appropriateness

This package is appropriate to use for extending the precision of floating point   
computations from 64 bits [~17 digits] up to 3,250 bits [~1000 digits].  
While Testing on many different hosts is needed to characterize a most performant  
precision range, I have found working with 800 bits (~240 digits) a welcome change.

#### Conceptual Background

`Transparency`: a desirable quality that may obtain in the presentation of  
numerical quantity. Where transparency exists, it may well not persist.  
A diminution of transparency increases `opacity`, and vice versa. Presentation  
of a floating point value either evinces transparency or furthers opacity.  
With transparent values, ‘looking at a value’ is ‘looking through to see the  
knowable value’. With opaque values, ‘looking at a value’ is ‘looking away from’  
that. And it is that nonresponsive, nonparticipative engagement of cognitive   
attention that is the opaqueness underlying opacity. 

Presented with a transparent floating point value, the perceiver is become  
best informed. There is no other rendition of that floating point realization  
which is intrinsically more informing and none which relays the value of that  
floating point realization more accurately – none with fewer digits, none with  
more digits, none of greater magnitude, none of lesser magnitude.  

An `ArbFloat` is an extended precision float architected to evince transparency.   
It informs without leading or misleading. An ArbFloat, when viewed, appears as   
an extended precision floating point value.  When any of the exported arithmetic,   
elementary or special functions is applied to an ArbFloat, the value transforms   
as an extended precision floating point interval.  



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
>   (==), (!=), (<), (<=), (>=), (>),  #  Arb, strict:  a < b iff upperbound(a) < lowerbound(b)  
>   (≃), (≄), (≺), (⪯), (≻), (⪰),    #  non-strict total ordering  (best for convergence tests)  
>   simeq, nsime, prec, preceq, succ, succeq, # names matching binops above  
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

=====

Many have helped me.  Some with their prior acts of good will.    
Others by explaining subtleties, sharing exemplary Julian ways,  
suggesting improvements, providing fixes, or doing testing.

>> Stefan Karpinski, Jeff Bezanson, Alan Edelman, Viral Shah,     
>> John Myles White, Tim Holy, Thomas Breloff, Katherine Hyatt,   
>> Avik Sengupta, David P. Sanders, Yichao Yu, Chris Rackauckas,  
>> Scott Jones, Luis Benet, Galen O'Neil, Tony Kelman.

