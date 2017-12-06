#=
   -x, abs(x), inv(x),
   sqrt(x), invsqrt(x)
   x+y, x-y, x*y, x/y, hypot(x,y)
   muladd(a,b,c), fma(a,b,c)
=#

function signbit(x::ArbFloat{P}) where {P}
    0 != ccall(@libarb(arb_is_negative), Int, (Ref{ArbFloat{P}},), x)
end

function abs(x::ArbFloat{P}) where {P}
    z  = initializer(ArbFloat{P})
    lo = initializer(ArfFloat{P})
    hi = initializer(ArfFloat{P})
    ccall(@libarb(arb_get_abs_lbound_arf), Void, (Ptr{ArfFloat{P}}, Ref{ArbFloat{P}}, Int), &lo, x, P) 
    ccall(@libarb(arb_get_abs_ubound_arf), Void, (Ptr{ArfFloat{P}}, Ref{ArbFloat{P}}, Int), &hi, x, P)
    ccall(@libarb(arb_set_interval_arf), Void, (Ref{ArbFloat{P}}, Ptr{ArfFloat{P}}, Ptr{ArfFloat{P}}, Int), z, &lo, &hi, P)
    return z
end

function abs2(x::T) where {T <: ArbFloat}
    a = abs(x)
    return a*a
end

for (op,cfunc) in ((:-,:arb_neg), (:sign, :arb_sgn), (:absz, :arb_abs))
  @eval begin
    function ($op)(x::ArbFloat{P}) where {P}
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}), z, x)
      return z
    end
  end
end

for (op,cfunc) in ((:inv, :arb_inv), (:sqrt, :arb_sqrt), (:invsqrt, :arb_rsqrt))
  @eval begin
    function ($op)(x::ArbFloat{P}) where {P}
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, P)
      return z
    end
  end
end

for (op,cfunc) in ((:+,:arb_add), (:-, :arb_sub), (:/, :arb_div), (:hypot, :arb_hypot))
  @eval begin
    function ($op)(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, y, P)
      return z
    end
    ($op)(x::ArbFloat{P}, y::ArbFloat{Q}) where {P,Q} = ($op)(promote(x,y)...)
    ($op)(x::T, y::F) where {T <: ArbFloat,F <: AbstractFloat} = ($op)(x, convert(T, y))
    ($op)(x::F, y::T) where {T <: ArbFloat,F <: AbstractFloat} = ($op)(convert(T, x), y)
    ($op)(x::T, y::R) where {T <: ArbFloat,R <: Rational} = ($op)(x, convert(T, y))
    ($op)(x::R, y::T) where {T <: ArbFloat,R <: Rational} = ($op)(convert(T, x), y)
    ($op)(x::T, y::R) where {T <: ArbFloat,R <: Real} = ($op)(x, convert(T, y))
    ($op)(x::R, y::T) where {T <: ArbFloat,R <: Real} = ($op)(convert(T, x), y)
  end
end

function (*)(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_mul), Void, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, y, P)
    return z
end
(*)(x::T, y::F) where {T <: ArbFloat,F <: AbstractFloat} = (*)(x, convert(T, y))
(*)(x::F, y::T) where {T <: ArbFloat,F <: AbstractFloat} = (*)(convert(T, x), y)
(*)(x::T, y::R) where {T <: ArbFloat,R <: Rational} = (*)(x, convert(T, y))
(*)(x::R, y::T) where {T <: ArbFloat,R <: Rational} = (*)(convert(T, x), y)
(*)(x::T, y::R) where {T <: ArbFloat,R <: Real} = (*)(x, convert(T, y))
(*)(x::R, y::T) where {T <: ArbFloat,R <: Real} = (*)(convert(T, x), y)

(+)(x::T, y::T, z::T) where {T <: ArbFloat} = (x + y) + z

(+)(x::I, y::T, z::T) where {T <: ArbFloat,I <: Integer} = x + (y + z)
(+)(x::T, y::T, z::I) where {T <: ArbFloat,I <: Integer} = (x + y) + z
(+)(x::T, y::T, z::R) where {T <: ArbFloat,R <: Real} = (x + y) + z
(+)(x::R, y::T, z::T) where {T <: ArbFloat,R <: Real} =  x + (y + z)

(*)(x::T, y::T, z::T) where {T <: ArbFloat} = (x * y) * z

(*)(x::I, y::T, z::T) where {T <: ArbFloat,I <: Integer} = x * (y * z)
(*)(x::T, y::T, z::I) where {T <: ArbFloat,I <: Integer} = (x * y) * z
(*)(x::T, y::T, z::R) where {T <: ArbFloat,R <: Real} = (x * y) * z
(*)(x::R, y::T, z::T) where {T <: ArbFloat,R <: Real} =  x * (y * z)

(-)(x::T, y::T, z::T) where {T <: ArbFloat} = (x - y) - z
(/)(x::T, y::T, z::T) where {T <: ArbFloat} = (x / y) / z


for (op,cfunc) in ((:+,:arb_add_si), (:-, :arb_sub_si), (:*, :arb_mul_si), (:/, :arb_div_si))
  @eval begin
    function ($op)(x::ArbFloat{P}, y::Int) where {P}
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int, Int), z, x, y, P)
      return z
    end
  end
end

(+)(x::Int, y::T) where {T <: ArbFloat} = (+)(y,x)
(-)(x::Int, y::T) where {T <: ArbFloat} = -((-)(y,x))
(*)(x::Int, y::T) where {T <: ArbFloat} = (*)(y,x)
(/)(x::Int, y::T) where {T <: ArbFloat} = (/)(T(x),y)

(+)(x::T, y::Integer) where {T <: ArbFloat} = (+)(x, convert(T, y))
(-)(x::T, y::Integer) where {T <: ArbFloat} = (-)(x, convert(T, y))
(*)(x::T, y::Integer) where {T <: ArbFloat} = (*)(x, convert(T, y))
(/)(x::T, y::Integer) where {T <: ArbFloat} = (/)(x, convert(T, y))

(+)(x::Integer, y::T) where {T <: ArbFloat} = (+)(convert(T, x), y)
(-)(x::Integer, y::T) where {T <: ArbFloat} = -((-)(y, convert(T, x)))
(*)(x::Integer, y::T) where {T <: ArbFloat} = (*)(convert(T,x), y)
(/)(x::Integer, y::T) where {T <: ArbFloat} = (/)(convert(T,x), y)

for (op,cfunc) in ((:addmul,:arb_addmul), (:submul, :arb_submul))
  @eval begin
    function ($op)(w::ArbFloat{P}, x::ArbFloat{P}, y::ArbFloat{P}) where {P}
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, &w, x, y, P)
      z
    end
  end
end

muladd(a::T, b::T, c::T) where {T <: ArbFloat} = addmul(c,a,b)
mulsub(a::T, b::T, c::T) where {T <: ArbFloat} = addmul(-c,a,b)
