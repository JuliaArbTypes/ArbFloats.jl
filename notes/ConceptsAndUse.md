####Conceptual Background

`Transparency`: a desirable quality that may obtain in the presentation of numerical quantity. Where `transparency` exists, it may well not persist. A diminution of `transparency` increases `opacity`, and vice versa. Presentation of a floating point value either evinces `transparency` or furthers `opacity`.  With `transparent` values, 'looking at a value' is 'looking through to see the knowable value'.  With `opaque` values, 'looking at a value' is 'looking away from' that.  And it is that nonresponsive, nonparticipative engagement of cognitive attention that is the `opaqueness` underlying `opacity`. 

Presented with a `transparent` floating point value, the perceiver is become best informed.  There is no other rendition of that floating point realization which is intrinsically more informing and none which relays the value of that floating point realization more accurately -- none with fewer digits, none with more digits, none of greater magnitude, none of lesser magnitude.

An `ArbFloat` is an extended precision float architected to evince `transparency`. It informs without leading or misleading.  An `ArbFloat`, when viewed, appears as an extended precision floating point value.  When any of the exported arithmetic, elementary or special functions is applied to an `ArbFloat`, the value transforms as an extended precision floating point interval.


###About Arb

This work is constructed atop a state-of-the-art C library for working with _midpoint ± radius_ intervals. That library is designed and written by Fredrik Johansson, who graciously allows Julia to use `Arb` under the MIT License.  
  
  The C libraries that this package accesses are some of the shared libraries that Nemo.jl requires and builds when it is installed; and I am calling them directly. Nemo is a computational environment where the most important software for number theory and related work. Julia is used to create a cohesive whole that shares a manner of use.  Fredrik Johansson, William Hart, and Tommy Hoffman have been especially helpful, taking the time to explain details of Arb as I was working on ArbFloats.  
  
######Hint
It is a useful fiction to think of `ArbFloats` as Arb values with a zero radius -- and sometimes they are.  When an `ArbFloat` has a nonzero radius, the user sees only those digits that _don`t care_:  the digits which remain after rounding the `ArbFloat` so that the radius is subsumed (as if 0.0).


####Install
```julia
Pkg.clone("https://github.com/JuliaArbTypes/ArbFloats.jl")  # requires Julia v0.5
```

####Use
```F#
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
# const ArbFloat32 = ArbFloat{24}  # predefined, 24 significand bits in 32bit float
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
```

## Exports (including re-exports)

used with Arb and ArbFloat | nature
---------------------------|-------
precision, setprecision,   | as with BigFloat


Arb values are intervals | nature
--------|--------
midpoint, radius, lowerbound, upperbound, bounds,          | Arb's constituent parts  
isexact, notexact,                                         | float-y or interval-y  
overlap, donotoverlap,                                     | of interval suborder  
contains, iscontainedby, doesnotcontain, isnotcontainedby, | of interval partial order  

```
ArbFloat values: Arb seen as precisely accurate floats   
   elevates transparent information over number mumble  
   each digit shown is an accurate refinement of value  

The least significant digit observable, through show(af) or with string(af),   
  is smallest transparent _(intrinsically non-misleading)_ refinement of value.
```

ArbFloat attributes | nature
--------|--------
isnan, isinf, isfinite, issubnormal, isinteger, notinteger,  | floatingpoint predicates
iszero, notzero, nonzero, isone, notone,  | number predicates
ispositive, notpositive, isnegative, notnegative,   | numerical predicates


> copy, deepcopy, 
> zero, one, eps, epsilon,    
> isequal, notequal, isless, 
> (==),(!=),(<),(<=),(>=),(>), 
> approxeq, ≊,  
> min, max, minmax, 

> signbit, sign, flipsign, copysign, abs,  
> (+),(-),(*),(/),(\),(%),(^),
> inv, sqrt, invsqrt, hypot,  
> factorial, doublefactorial, risingfactorial, 
> trunc, round, ceil, floor,   

> pow, root, 
> exp, expm1, log, log1p, log2, log10, logbase,  
> sin, cos, sincos, sincospi, tan, csc, sec, cot, 
> asin, acos, atan, atan2=atan(y,x),  
> sinh, cosh, sinhcosh, tanh, csch, sech, coth, 
> asinh, acosh, atanh,  

> gamma, lgamma, digamma,  
> sinc, zeta, polylog, agm  
