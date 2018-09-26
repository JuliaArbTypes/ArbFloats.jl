#=
    ^, pow, root

    exp, expm1, log, log1p, log2, log10, logbase,
    sin, sinpi, cos, cospi, tan, tanpi, cot, cotpi,
    sinh, cosh, tanh, coth,
    asin, acos, atan, asinh, acosh, atanh,
    sincos, sincospi, sinhcosh,
    sinc,
    gamma, lgamma, zeta
=#

for (op,cfunc) in ((:exp,:arb_exp), (:expm1, :arb_expm1),
    (:log,:arb_log), (:log1p, :arb_log1p),
    (:sin, :arb_sin), (:sinpi, :arb_sinpi), (:cos, :arb_cos), (:cospi, :arb_cospi),
    (:tan, :arb_tan), (:cot, :arb_cot),
    (:sinh, :arb_sinh), (:cosh, :arb_cosh), (:tanh, :arb_tanh), (:coth, :arb_coth),
    (:asin, :arb_asin), (:acos, :arb_asin), (:atan, :arb_atan),
    (:asinh, :arb_asinh), (:acosh, :arb_asinh), (:atanh, :arb_atanh),
    (:sinc, :arb_sinc),
    (:gamma, :arb_gamma), (:lgamma, :arb_lgamma), (:zeta, :arb_zeta),
    (:digamma, :arb_digamma), (:rgamma, :arb_rgamma)
    )
  @eval begin
    function ($op)(x::ArbFloat{P}) where {P}
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, P)
      z
    end
  end
end


function logbase(x::ArbFloat{P}, base::Int) where {P}
    b = UInt(abs(base))
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_log_base_ui), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, UInt, Int), z, x, b, P)
    z
end

log2(x::ArbFloat{P}) where {P} = logbase(x, 2)
log10(x::ArbFloat{P}) where {P} = logbase(x, 10)


for (op,cfunc) in ((:sincos, :arb_sin_cos), (:sincospi, :arb_sin_cos_pi), (:sinhcosh, :arb_sinh_cosh))
  @eval begin
    function ($op)(x::ArbFloat{P}) where {P}
        sz = initializer(ArbFloat{P})
        cz = initializer(ArbFloat{P})
        ccall(@libarb($cfunc), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), sz, cz, x, P)
        sz, cz
    end
  end
end


function atan2(a::ArbFloat{P}, b::ArbFloat{P}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_atan2), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, a, b, P)
    z
end

for (op,cfunc) in ((:root, :arb_root_ui),)
  @eval begin
    function ($op)(x::ArbFloat{P}, y::UInt) where {P}
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, UInt, Int), z, x, y, P)
      z
    end
  end
end


for (op,cfunc) in ((:^,:arb_pow), (:pow,:arb_pow))
  @eval begin
    function ($op)(x::I, y::ArbFloat{P}) where {P,I <: Integer}
      xx = ArbFloat{P}(x)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, xx, y, P)
      return z
    end
    function ($op)(x::ArbFloat{P}, y::I) where {P,I <: Integer}
      sy,ay = signbit(y), abs(y)
      yy = ArbFloat{P}(ay)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, yy, P)
      return sy ? inv(z) : z
    end
    function ($op)(x::R, y::ArbFloat{P}) where {P,R <: Rational}
      xx = ArbFloat{P}(x)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, xx, y, P)
      return z
    end
    function ($op)(x::ArbFloat{P}, y::R) where {P,R <: Rational}
      yy = ArbFloat{P}(y)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, yy, P)
      return z
    end
    function ($op)(x::R, y::ArbFloat{P}) where {P,R <: Real}
      xx = ArbFloat{P}(x)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, xx, y, P)
      return z
    end
    function ($op)(x::ArbFloat{P}, y::R) where {P,R <: Real}
      yy = ArbFloat{P}(y)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, yy, P)
      return z
    end
    function ($op)(x::ArbFloat{P}, y::ArbFloat{P}) where {P}
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, Int), z, x, y, P)
      z
    end
    ($op)(x::ArbFloat{P}, y::ArbFloat{Q}) where {P,Q} = ($op)(promote(x,y)...)
  end
end

root(x::ArbFloat{P}, y::ArbFloat{P}) where {P} = pow(x, inv(y))
root(x::Integer, y::ArbFloat{P}) where {P} = pow(ArbFloat{P}(x), inv(y))
function root(x::ArbFloat{P}, y::Integer) where {P}
   return (
     if y>=0
       yy = UInt64(y)
      z = initializer(ArbFloat{P})
       ccall(@libarb(arb_root_ui), Cvoid, (Ref{ArbFloat{P}}, Ref{ArbFloat{P}}, UInt64, Int), z, x, yy, P)
       z
    else
      pow(ArbFloat{P}(x), inv(y))
    end )
end

