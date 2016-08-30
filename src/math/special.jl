for (op,cfunc) in ((:factorial,:arb_fac_ui), (:doublefactorial,:arb_doublefac_ui))
  @eval begin
    function ($op){P}(x::ArbFloat{P})
      signbit(x) && throw(ErrorException("Domain Error: argument is negative"))
      y = trunc(UInt, x)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, UInt, Int), &z, y, P)
      z
    end
  end
end

function doublefactorial{R<:Real}(xx::R)
   P = precision(ArbFloat)
   x = convert(ArbFloat{P},xx)
   doublefactorial(x)
end

for (op,cfunc) in ((:risingfactorial,:arb_rising),)
  @eval begin
    function ($op){P}(x::ArbFloat{P}, y::ArbFloat{P})
      signbit(x) && throw(ErrorException("Domain Error: argument is negative"))
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
    function ($op){R<:Real,P}(xx::R, y::ArbFloat{P}, prec::Int=P)
      x = convert(ArbFloat{P},xx)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
    function ($op){R<:Real,P}(x::ArbFloat{P}, yy::R, prec::Int=P)
      y = convert(ArbFloat{P},yy)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
    function ($op){R1<:Real,R2<:Real}(xx::R1, yy::R2)
      P = precision(ArbFloat)
      x = convert(ArbFloat{P},xx)
      y = convert(ArbFloat{P},yy)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
  end
end

for (op,cfunc) in ((:agm, :arb_agm), (:polylog, :arb_polylog))
  @eval begin
    function ($op){P}(x::ArbFloat{P}, y::ArbFloat{P}, prec::Int=P)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
    function ($op){R<:Real,P}(xx::R, y::ArbFloat{P}, prec::Int=P)
      x = convert(ArbFloat{P},xx)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
    function ($op){R<:Real,P}(x::ArbFloat{P}, yy::R, prec::Int=P)
      y = convert(ArbFloat{P},yy)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
    function ($op){R1<:Real,R2<:Real}(xx::R1, yy::R2)
      P = precision(ArbFloat)
      x = convert(ArbFloat{P},xx)
      y = convert(ArbFloat{P},yy)
      z = ArbFloat{P}()
      ccall(@libarb($cfunc), Void, (Ptr{ArbFloat}, Ptr{ArbFloat}, Ptr{ArbFloat}, Int), &z, &x, &y, P)
      z
    end
  end
end
