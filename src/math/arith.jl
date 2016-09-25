#=
   -x, abs(x), inv(x),
   sqrt(x), invsqrt(x)
   x+y, x-y, x*y, x/y, hypot(x,y)
   muladd(a,b,c), fma(a,b,c)
=#

function signbit{T<:ArbFloat}(x::T)
    0 != ccall(@libarb(arb_is_negative), Int, (Ptr{T},), &x)
end

function abs{T<:ArbFloat}(x::T)
    lo,hi = bounds(x)
    lo = signbit(lo) ? -lo : lo
    hi = signbit(hi) ? -hi : hi
    if lo > hi
       lo, hi = hi, lo
    end
    return bounds( lo, hi )
end

function abs2{T<:ArbFloat}(x::T)
    lo, hi = bounds(abs(x))
    lo = lo^2
    hi = hi^2
    return bounds( lo, hi )
end

for (op,cfunc) in ((:-,:arb_neg), (:sign, :arb_sgn))
  @eval begin
    function ($op){T<:ArbFloat}(x::T)
      z = T()
      ccall(@libarb($cfunc), Void, (Ptr{T}, Ptr{T}), &z, &x)
      z
    end
  end
end

for (op,cfunc) in ((:inv, :arb_inv), (:sqrt, :arb_sqrt), (:invsqrt, :arb_rsqrt))
  @eval begin
    function ($op){T<:ArbFloat}(x::T)
      P = precision(T)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{T}, Ptr{T}, Int), &z, &x, P)
      return z
    end
  end
end

for (op,cfunc) in ((:+,:arb_add), (:-, :arb_sub), (:/, :arb_div), (:hypot, :arb_hypot))
  @eval begin
    function ($op){T<:ArbFloat}(x::T, y::T)
      P = precision(T)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{T}, Ptr{T}, Ptr{T}, Int), &z, &x, &y, P)
      z
    end
    ($op){P,Q}(x::ArbFloat{P}, y::ArbFloat{Q}) = ($op)(promote(x,y)...)
    ($op){T<:ArbFloat, F<:AbstractFloat}(x::T, y::F) = ($op)(x, convert(T, y))
    ($op){T<:ArbFloat, F<:AbstractFloat}(x::F, y::T) = ($op)(convert(T, x), y)
    ($op){T<:ArbFloat, R<:Rational}(x::T, y::R) = ($op)(x, convert(T, y))
    ($op){T<:ArbFloat, R<:Rational}(x::R, y::T) = ($op)(convert(T, x), y)
    ($op){T<:ArbFloat, R<:Real}(x::T, y::R) = ($op)(x, convert(T, y))
    ($op){T<:ArbFloat, R<:Real}(x::R, y::T) = ($op)(convert(T, x), y)
  end
end

function (*){T<:ArbFloat}(x::T, y::T)
    P = precision(T)
    z = ArbFloat{P}()
    ccall(@libarb(arb_mul), Void, (Ptr{T}, Ptr{T}, Ptr{T}, Int), &z, &x, &y, P)
    return z
end
(*){T<:ArbFloat, F<:AbstractFloat}(x::T, y::F) = (*)(x, convert(T, y))
(*){T<:ArbFloat, F<:AbstractFloat}(x::F, y::T) = (*)(convert(T, x), y)
(*){T<:ArbFloat, R<:Rational}(x::T, y::R) = (*)(x, convert(T, y))
(*){T<:ArbFloat, R<:Rational}(x::R, y::T) = (*)(convert(T, x), y)
(*){T<:ArbFloat, R<:Real}(x::T, y::R) = (*)(x, convert(T, y))
(*){T<:ArbFloat, R<:Real}(x::R, y::T) = (*)(convert(T, x), y)


(+){T<:ArbFloat}(x::T, y::T, z::T) = (x + y) + z

(+){T<:ArbFloat,I<:Integer}(x::I, y::T, z::T) = x + (y + z)
(+){T<:ArbFloat,I<:Integer}(x::T, y::T, z::I) = (x + y) + z
(+){T<:ArbFloat,R<:Real}(x::T, y::T, z::R) = (x + y) + z
(+){T<:ArbFloat,R<:Real}(x::R, y::T, z::T) =  x + (y + z)

(*){T<:ArbFloat}(x::T, y::T, z::T) = (x * y) * z

(*){T<:ArbFloat,I<:Integer}(x::I, y::T, z::T) = x * (y * z)
(*){T<:ArbFloat,I<:Integer}(x::T, y::T, z::I) = (x * y) * z
(*){T<:ArbFloat,R<:Real}(x::T, y::T, z::R) = (x * y) * z
(*){T<:ArbFloat,R<:Real}(x::R, y::T, z::T) =  x * (y * z)

(-){T<:ArbFloat}(x::T, y::T, z::T) = (x - y) - z
(/){T<:ArbFloat}(x::T, y::T, z::T) = (x / y) / z


for (op,cfunc) in ((:+,:arb_add_si), (:-, :arb_sub_si), (:*, :arb_mul_si), (:/, :arb_div_si))
  @eval begin
    function ($op){T<:ArbFloat}(x::T, y::Int)
      P = precision(T)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{T}, Ptr{T}, Int, Int), &z, &x, y, P)
      return z
    end
  end
end

(+){T<:ArbFloat}(x::Int, y::T) = (+)(y,x)
(-){T<:ArbFloat}(x::Int, y::T) = -((-)(y,x))
(*){T<:ArbFloat}(x::Int, y::T) = (*)(y,x)
(/){T<:ArbFloat}(x::Int, y::T) = (/)(T(x),y)

(+){T<:ArbFloat}(x::T, y::Integer) = (+)(x, convert(T, y))
(-){T<:ArbFloat}(x::T, y::Integer) = (-)(x, convert(T, y))
(*){T<:ArbFloat}(x::T, y::Integer) = (*)(x, convert(T, y))
(/){T<:ArbFloat}(x::T, y::Integer) = (/)(x, convert(T, y))

(+){T<:ArbFloat}(x::Integer, y::T) = (+)(convert(T, x), y)
(-){T<:ArbFloat}(x::Integer, y::T) = -((-)(y, convert(T, x)))
(*){T<:ArbFloat}(x::Integer, y::T) = (*)(convert(T,x), y)
(/){T<:ArbFloat}(x::Integer, y::T) = (/)(convert(T,x), y)

for (op,cfunc) in ((:addmul,:arb_addmul), (:submul, :arb_submul))
  @eval begin
    function ($op){T<:ArbFloat}(w::T, x::T, y::T)
      P = precision(T)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{T}, Ptr{T}, Ptr{T}, Ptr{T}, Int), &z, &w, &x, &y, P)
      z
    end
  end
end

muladd{T<:ArbFloat}(a::T, b::T, c::T) = addmul(c,a,b)
mulsub{T<:ArbFloat}(a::T, b::T, c::T) = addmul(-c,a,b)

