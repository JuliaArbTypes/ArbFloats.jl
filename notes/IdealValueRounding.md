```
```

ArbReals come in two flavors of type, ArbReal floats and  ArbReal intervals,   
__ArbFloats__ and __ArbIntervals__.  `ArbFloats` are shown as transparent  
values rather than as fixed digit expansions,  which are more opaque.  

> ArbFloats.jl determines the maximally informing, least misleading value that characterizes any relatively small interval.  
> The result is a floating point expansion, usually rounded in significance from the underlying interval bounds.  
> It is where lower and upper bounds agree on the assignation of a value that is as accurate as it is precise.  
> This is the most transparent value for the interval: it best informs and least misleads our perception of the interval.

Internally, ArbReals are quantities used with the Arb C library, and so are maintained as intervals (midpoint, radius).  An ArbReal may have a radius that is zero, that is still a radius (this occurs when it is constructed using an integer).  Each finite ArbReal quantity, as an interval, has a lower bound and an upper bound.  Arb asserts all finite real math operations return an interval that contains the theoretically resolved point.  These bounds are obtained from an ArbReal `a` with `lowerbound(a), upperbound(a)` or `bounds(a)`, functions for internal use when using ArbFloats.

An interval is determined by two floating point quantities, e.g. (midpoint, radius), (lowerbound, upperbound).  A floating point evaluand is a single floating point quantity.  The one float that best characterizes any relatively small interval is the most `transparent` value for that interval.  Here, best means the value is most informing and least misleading.  If `clean` is the most transparent value for an interval then each of `prevfloat(clean), nextfloat(clean)` are perceptually less informative or more misleading or both.

The way this most transparent value for a given interval is found on this fourth of July predawn is sound, but slow.  Frequently, the method requires converting from an ArbReal to a string six or eight times and sometimes more times.
  
*simplified successive rounding of both bounds over more digits until their decimal strings match*  
```
lwr, upr = bounds(x)
# string(round(lwr, significant_digits))
lwrStr = String(lwr, digits) 
uprStr = String(upr, digits)
while digits>1 && (lwrStr[end] != uprStr[end] || lwrStr != uprStr)
   digits -= 1
   lwrStr = String(lwr, digits)
   uprStr = String(upr, digits)
end
uprStr
```  
There is a way to accomplish this that is considerably more efficient. It uses the ratio of `unit_last_place(midpoint(a))` and `radius(a)` or `unit_first_place(radius(a))` along with `log10` to obtain a count of trailing digits to round away (rounding over) from the lower bound and the upper bound to obtain their most expressive exact agreement.  

```ruby
Ideal Value (Meromorphic) Rounding                         Jeffrey Sarnoff on 2016-07-04
```
