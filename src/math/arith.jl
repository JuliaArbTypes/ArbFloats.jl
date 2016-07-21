#=
   -x, abs(x), inv(x),
   sqrt(x), invsqrt(x)
   x+y, x-y, x*y, x/y, hypot(x,y)
   muladd(a,b,c), fma(a,b,c)
=#

function signbit{P}(x::ArbFloat{P})
    0 != ccall(@libarb(arb_is_negative), Int, (Ptr{ArbFloat},), &x)
end

for (op,cfunc) in ((:-,:arb_neg), (:abs, :arb_abs), (:sign, :arb_sgn))
  @eval begin
    function ($op){P}(x::ArbFloat{P})
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}), &z, &x)
      z
    end
  end
end

for (op,cfunc) in ((:inv, :arb_inv), (:sqrt, :arb_sqrt), (:invsqrt, :arb_rsqrt))
  @eval begin
    function ($op){P}(x::ArbFloat{P})
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, P)
      z
    end
  end
end

for (op,cfunc) in ((:+,:arb_add), (:-, :arb_sub), (:*, :arb_mul), (:/, :arb_div), (:hypot, :arb_hypot))
  @eval begin
    function ($op){P}(x::ArbFloat{P}, y::ArbFloat{P})
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
    ($op){P,Q}(x::ArbFloat{P}, y::ArbFloat{Q}) = ($op)(promote(x,y)...)
    ($op){T<:AbstractFloat,P}(x::ArbFloat{P}, y::T) = ($op)(x, convert(ArbFloat{P}, y))
    ($op){T<:AbstractFloat,P}(x::T, y::ArbFloat{P}) = ($op)(convert(ArbFloat{P}, x), y)
  end
end

for (op,cfunc) in ((:+,:arb_add_si), (:-, :arb_sub_si), (:*, :arb_mul_si), (:/, :arb_div_si))
  @eval begin
    function ($op){P}(x::ArbFloat{P}, y::Int)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Int, Int), &z, &x, y, P)
      z
    end
  end
end

(+){P}(x::Int, y::ArbFloat{P}) = (+)(y,x)
(-){P}(x::Int, y::ArbFloat{P}) = -((-)(y,x))
(*){P}(x::Int, y::ArbFloat{P}) = (*)(y,x)
(/){P}(x::Int, y::ArbFloat{P}) = (/)(ArbFloat{P}(x),y)

(+){P}(x::ArbFloat{P}, y::Integer) = (+)(x, convert(ArbFloat{P}, y))
(-){P}(x::ArbFloat{P}, y::Integer) = (-)(x, convert(ArbFloat{P}, y))
(*){P}(x::ArbFloat{P}, y::Integer) = (*)(x, convert(ArbFloat{P}, y))
(/){P}(x::ArbFloat{P}, y::Integer) = (/)(x, convert(ArbFloat{P}, y))
(^){P}(x::ArbFloat{P}, y::Integer) = (^)(x, convert(ArbFloat{P}, y))

(+){P}(x::Integer, y::ArbFloat{P}) = (+)(convert(ArbFloat{P}, x), y)
(-){P}(x::Integer, y::ArbFloat{P}) = -((-)(y, convert(ArbFloat{P}, x)))
(*){P}(x::Integer, y::ArbFloat{P}) = (*)(convert(ArbFloat{P},x), y)
(/){P}(x::Integer, y::ArbFloat{P}) = (/)(convert(ArbFloat{P},x), y)
(^){P}(x::Integer, y::ArbFloat{P}) = (^)(convert(ArbFloat{P},x), y)

for (op,cfunc) in ((:addmul,:arb_addmul), (:submul, :arb_submul))
  @eval begin
    function ($op){P}(w::ArbFloat{P}, x::ArbFloat{P}, y::ArbFloat{P})
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &w, &x, &y, P)
      z
    end
  end
end

muladd{P}(a::ArbFloat{P}, b::ArbFloat{P}, c::ArbFloat{P}) = addmul(c,a,b)
mulsub{P}(a::ArbFloat{P}, b::ArbFloat{P}, c::ArbFloat{P}) = addmul(-c,a,b)

