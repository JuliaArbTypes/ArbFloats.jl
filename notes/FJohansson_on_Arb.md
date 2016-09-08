```
```
Arb is a library for arbitrary-precision interval arithmetic, the most significant difference compared to e.g. MPFI being that it uses a mid-rad representation instead of an inf-sup representation.

The mid-rad representation is worse for representing "wide" intervals, but superior for "narrow" intervals. It goes very well together with high-precision arithmetic. If you're doing floating-point arithmetic with 128+ bits of precision, you may as well carry along a low-precision error bound, because updating the error bound costs much less than the high-precision midpoint arithmetic.

Mid-rad arithmetic an old idea (there are earlier implementations in Mathemagix, iRRAM, and probably others). There is a nice paper by Joris van der Hoeven on "ball arithmetic" [1]. It should be noted that Arb does "ball arithmetic" for real numbers, and builds everything else out of those real numbers, rather than using higher-level "balls"; you get rectangular enclosures (and not mid-rad disks) for complex numbers, entrywise error bounds (and not matrix-norm "matricial balls") for matrices, and so on. This has pros and cons.

A few the technical details in the blog post that Stefan Karpinski linked to are outdated now; I've rewritten the underlying floating-point arithmetic in Arb to improve efficiency. It now uses a custom arbitrary-precision floating-point type (arf_t) for midpoints and a fixed-precision unsigned floating-point type (mag_t) for error bounds. The reason why Arb uses custom floating-point types instead of MPFR has a little to do with efficiency, and a little to do with aesthetics.

Concerning efficiency, the arf_t mantissa is allocated dynamically to the number of used bits rather than to the full working precision (MPFR always zero-pads to full precision); this helps when working with integer-valued coefficients and mixed-precision floating-point values. The arf_t type also avoids separate memory allocations completely up to 128 bits of precision; the 256-bit arf_t struct then stores the whole value directly without a separate heap allocation for the mantissa. The mag_t type, of course, is a lot faster than an arbitrary-precision type.

As a result, Arb sometimes uses less memory than MPFR, and less than half as much memory as MPFI, and has less overhead for temporary allocations and deallocations. However, arithmetic operations are not currently as well optimized as MPFR in all cases; additions are a bit slower, for example. I hope to work more on this in the future (for example, by always throwing away bits that are insignificant compared to the error bound).

Concerning aesthetics, I wanted bignum exponents and I wanted to avoid having any kind of global (or thread-local) state for default precision, exponent ranges, and exception flags.

Anyway, the number representation makes some overall difference in efficiency, but the biggest difference comes from algorithms. The selling point of Arb is that I've spent a lot of time optimizing high-precision computation of transcendental functions (this was the subject of my PhD thesis). You can find more details in the docs, in my papers, and on my blog. The implementation of elementary functions in Arb for precisions up to a few thousands of bits is described in [2].

Obviously, Arb is not meant to be competitive with double precision software. It seems to be competitive with some of the existing software for quad precision (~100 bits) arithmetic. At even higher precision, it should do well overall, if you know its limitations.

Fundamentally, interval arithmetic suffers from the dependency problem. It works perfectly in some instances, not at all in others. I wrote Arb mainly for doing computational number theory, where it typically happens to work very well.

It turns out to work quite nicely as a black box for isolated parts of floating-point computations, too -- you need to evaluate, say, some complex Bessel functions; you feed it a floating-point number, you get an interval back and convert it to a floating-point approximation that is guaranteed to be accurate, and you go on doing floating-point arithmetic, being confident that at least the part with the Bessel function isn't going to cause trouble. I recently wrote a simple Arb wrapper implementing transcendental functions for C99 complex doubles this way [3].

[Fredrik Johansson, 2016-Jan-03](https://groups.google.com/forum/#!searchin/julia-users/johansson/julia-users/QDSyknHBjqc/G-qFSyJcCQA)
