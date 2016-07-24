#=
   -x, abs(x), inv(x),
   sqrt(x), invsqrt(x)
   x+y, x-y, x*y, x/y, hypot(x,y)
   muladd(a,b,c), fma(a,b,c)
=#

function signbit{T<:ArbFloat}(x::T)
    0 != ccall(@libarb(arb_is_negative), Int, (Ptr{ArbFloat},), &x)
end

for (op,cfunc) in ((:-,:arb_neg), (:abs, :arb_abs), (:sign, :arb_sgn))
  @eval begin
    function ($op){T<:ArbFloat}(x::T)
      z = initializer(T)
      ccall(@libarb($cfunc), Void, (Ptr{T}, Ptr{T}), &z, &x)
      z
    end
  end
end

for (op,cfunc) in ((:inv, :arb_inv), (:sqrt, :arb_sqrt), (:invsqrt, :arb_rsqrt))
  @eval begin
    function ($op){T<:ArbFloat}(x::T)
      P = precision(T)
      z = initializer(T)
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, P)
      return z
    end
  end
end

for (op,cfunc) in ((:+,:arb_add), (:-, :arb_sub), (:/, :arb_div), (:hypot, :arb_hypot))
  @eval begin
    function ($op){T<:ArbFloat}(x::T, y::T)
      P = precision(T)
      z = initializer(T)
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
    ($op){P,Q}(x::ArbFloat{P}, y::ArbFloat{Q}) = ($op)(promote(x,y)...)
    ($op){T<:AbstractFloat,P}(x::ArbFloat{P}, y::T) = ($op)(x, convert(ArbFloat{P}, y))
    ($op){T<:AbstractFloat,P}(x::T, y::ArbFloat{P}) = ($op)(convert(ArbFloat{P}, x), y)
  end
end

function (*){T<:ArbFloat}(x::T, y::T)
    P = precision(T)
    z = initializer(T)
    ccall(@libarb(arb_mul), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
    return z
end

(+){T<:ArbFloat}(x::T, y::T, z::T) = (x + y) + z
(+){T<:ArbFloat}(x::T, y::T, z::T) = (x + y) + z

(+){T<:ArbFloat,I<:Integer}(x::I, y::T, z::T) = x + (y + z)
(+){T<:ArbFloat,I<:Integer}(x::T, y::T, z::I) = (x + y) + z)
(+){T<:ArbFloat,R<:Real}(x::T, y::T, z::R) = (x + y) + z
(+){T<:ArbFloat,R<:Real}(x::R, y::T, z::T) =  x + (y + z)

(*){T<:ArbFloat}(x::ArbFloat{P}, y::ArbFloat{P}, z::ArbFloat{P}) = (x * y) * z
(*){T<:ArbFloat}(x::T, y::T, z::T) = (x * y) * z

(*){T<:ArbFloat,I<:Integer}(x::I, y::T, z::T) = x * (y * z)
(*){T<:ArbFloat,I<:Integer}(x::T, y::T, z::I) = (x * y) * z)
(*){T<:ArbFloat,R<:Real}(x::T, y::T, z::R) = (x * y) * z
(*){T<:ArbFloat,R<:Real}(x::R, y::T, z::T) =  x * (y * z)

(-){T<:ArbFloat}(x::T, y::T, z::T) = (x - y) - z
(/){T<:ArbFloat}(x::T, y::T, z::T) = (x / y) / z


for (op,cfunc) in ((:+,:arb_add_si), (:-, :arb_sub_si), (:*, :arb_mul_si), (:/, :arb_div_si))
  @eval begin
    function ($op){T<:ArbFloat}(x::T, y::Int)
      P = precision(T)
      z = initializer(T)
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Int, Int), &z, &x, y, P)
      return z
    end
  end
end

(+){T<:ArbFloat}(x::Int, y::T) = (+)(y,x)
(-){T<:ArbFloat}(x::Int, y::T) = -((-)(y,x))
(*){T<:ArbFloat}(x::Int, y::T) = (*)(y,x)
(/){T<:ArbFloat}(x::Int, y::T) = (/)(ArbFloat{P}(x),y)

(+){T<:ArbFloat}(x::T, y::Integer) = (+)(x, convert(ArbFloat{P}, y))
(-){T<:ArbFloat}(x::T, y::Integer) = (-)(x, convert(ArbFloat{P}, y))
(*){T<:ArbFloat}(x::T, y::Integer) = (*)(x, convert(ArbFloat{P}, y))
(/){T<:ArbFloat}(x::T, y::Integer) = (/)(x, convert(ArbFloat{P}, y))

(+){T<:ArbFloat}(x::Integer, y::T) = (+)(convert(ArbFloat{P}, x), y)
(-){T<:ArbFloat}(x::Integer, y::T) = -((-)(y, convert(ArbFloat{P}, x)))
(*){T<:ArbFloat}(x::Integer, y::T) = (*)(convert(ArbFloat{P},x), y)
(/){T<:ArbFloat}(x::Integer, y::T) = (/)(convert(ArbFloat{P},x), y)

for (op,cfunc) in ((:addmul,:arb_addmul), (:submul, :arb_submul))
  @eval begin
    function ($op){T<:ArbFloat}(w::ArbFloat{P}, x::T, y::T)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &w, &x, &y, P)
      z
    end
  end
end

muladd{T<:ArbFloat}(a::T, b::T, c::T) = addmul(c,a,b)
mulsub{T<:ArbFloat}(a::T, b::T, c::T) = addmul(-c,a,b)

