#=
   -x, abs(x), inv(x),
   sqrt(x), invsqrt(x)
   x+y, x-y, x*y, x/y, hypot(x,y)
   muladd(a,b,c), fma(a,b,c)
=#

function signbit{P}(x::ArbFloat{P})
    0 != ccall(@libarb(arb_is_negative), Int, (Ptr{ArbFloat{P}},), &x)
end
function signbit{T<:ArbFloat}(x::T)
    0 != ccall(@libarb(arb_is_negative), Int, (Ptr{ArbFloat},), &x)
end

function abs{P}(x::ArbFloat{P})
    z  = initializer(ArbFloat{P})
    lo = initializer(ArfFloat{P})
    hi = initializer(ArfFloat{P})
    ccall(@libarb(arb_get_abs_lbound_arf), Void, (Ptr{ArfFloat{P}}, Ptr{ArbFloat{P}}, Int), &lo, &x, P) 
    ccall(@libarb(arb_get_abs_ubound_arf), Void, (Ptr{ArfFloat{P}}, Ptr{ArbFloat{P}}, Int), &hi, &x, P)
    ccall(@libarb(arb_set_interval_arf), Void, (Ptr{ArbFloat{P}}, Ptr{ArfFloat{P}}, Ptr{ArfFloat{P}}, Int), &z, &lo, &hi, P)
    return z
end
function abs{T<:ArbFloat}(x::T)
    P = precision(T)
    z  = initializer(ArbFloat{P})
    lo = initializer(ArfFloat{P})
    hi = initializer(ArfFloat{P})
    ccall(@libarb(arb_get_abs_lbound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), &lo, &x, P) 
    ccall(@libarb(arb_get_abs_ubound_arf), Void, (Ptr{ArfFloat}, Ptr{ArbFloat}, Int), &hi, &x, P)
    ccall(@libarb(arb_set_interval_arf), Void, (Ptr{ArbFloat}, Ptr{ArfFloat}, Ptr{ArfFloat}, Int), &z, &lo, &hi, P)
    return z
end

function abs2{T<:ArbFloat}(x::T)
    a = abs(x)
    return a*a
end

function absz2{T<:ArbFloat}(x::T)
    a = absz(x)
    return a*a
end

for (op,cfunc) in ((:-,:arb_neg), (:sign, :arb_sgn), (:absz, :arb_abs))
  @eval begin
    function ($op){P}(x::ArbFloat{P})
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &z, &x)
      return z
    end
    function ($op){T<:ArbFloat}(x::T)
      P = precision(T)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
      return z
    end
  end
end

for (op,cfunc) in ((:inv, :arb_inv), (:sqrt, :arb_sqrt), (:invsqrt, :arb_rsqrt))
  @eval begin
    function ($op){P}(x::ArbFloat{P})
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Int), &z, &x, P)
      return z
    end
  end
end

for (op,cfunc) in ((:+,:arb_add), (:-, :arb_sub), (:/, :arb_div), (:hypot, :arb_hypot))
  @eval begin
    function ($op){P}(x::ArbFloat{P}, y::ArbFloat{P})
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Int), &z, &x, &y, P)
      return z
    end
    function ($op){T<:ArbFloat}(x::T, y::T)
      P = precision(T)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      return z
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

function (*){P}(x::ArbFloat{P}, y::ArbFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_mul), Void, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Int), &z, &x, &y, P)
    return z
end
function (*){T<:ArbFloat}(x::T, y::T)
    P = precision(T)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_mul), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
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
    function ($op){P}(x::ArbFloat{P}, y::Int)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Int, Int), &z, &x, y, P)
      return z
    function ($op){T<:ArbFloat}(x::T, y::Int)
      P = precision(T)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Int, Int), &z, &x, y, P)
      return z
    end
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
    function ($op){P}(w::ArbFloat{P}, x::ArbFloat{P}, y::ArbFloat{P})
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}, Int), &z, &w, &x, &y, P)
      z
    end
    function ($op){T<:ArbFloat}(w::T, x::T, y::T)
      P = precision(T)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &w, &x, &y, P)
      z
    end
  end
end

muladd{T<:ArbFloat}(a::T, b::T, c::T) = addmul(c,a,b)
mulsub{T<:ArbFloat}(a::T, b::T, c::T) = addmul(-c,a,b)
