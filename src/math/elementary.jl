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
    function ($op){P}(x::ArbFloat{P})
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, P)
      z
    end
  end
end


function logbase{P}(x::ArbFloat{P}, base::Int)
    b = UInt(abs(base))
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_log_base_ui), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, UInt, Int), &z, &x, b, P)
    z
end

log2{P}(x::ArbFloat{P}) = logbase(x, 2)
log10{P}(x::ArbFloat{P}) = logbase(x, 10)


for (op,cfunc) in ((:sincos, :arb_sin_cos), (:sincospi, :arb_sin_cos_pi), (:sinhcosh, :arb_sinh_cosh)) 
  @eval begin
    function ($op){P}(x::ArbFloat{P})
        sz = initializer(ArbFloat{P})
        cz = initializer(ArbFloat{P})
        ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &sz, &cz, &x, P)
        sz, cz
    end
  end    
end


function atan2{P}(a::ArbFloat{P}, b::ArbFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_atan2), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &a, &b, P)
    z
end

for (op,cfunc) in ((:^,:arb_pow_ui), (:pow,:arb_pow_ui), (:root, :arb_root_ui))
  @eval begin
    function ($op){P}(x::ArbFloat{P}, y::Int)
      yy = UInt(y)
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, UInt, Int), &z, &x, &yy, P)
      z
    end
  end
end


for (op,cfunc) in ((:^,:arb_pow), (:pow,:arb_pow))
  @eval begin
    function ($op){P}(x::ArbFloat{P}, y::ArbFloat{P})
      z = initializer(ArbFloat{P})
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
  end
end

root{P}(x::ArbFloat{P}, y::ArbFloat{P}) = pow(x, inv(y))
