macro ArfFloat(x)
    convert(ArfFloat, string(:($x)))
end
macro ArfFloat(p,x)
    convert(ArfFloat{:($p)}, string(:($x)))
end

macro ArbFloat(x)
    convert(ArbFloat, string(:($x)))
end
macro ArbFloat(p,x)
    convert(ArbFloat{:($p)}, string(:($x)))
end

convert{T<:ArfFloat}(::Type{T}, x::T) = x
convert{T<:ArbFloat}(::Type{T}, x::T) = x
convert{P}(::Type{ArfFloat{P}}, x::ArfFloat{P}) = x
convert{P}(::Type{ArbFloat{P}}, x::ArbFloat{P}) = x

function convert{Q}(::Type{ArfFloat}, x::ArfFloat{Q})
   P = precision(ArfFloat)
   z = ArfFloat{P}()
   ccall(@libarb(arf_set_round), Void, (Ptr{ArfFloat{P}}, Ptr{ArfFloat{Q}}, Clong), &z, &x, Clong(P))
   return z
end
function convert{P,Q}(::Type{ArfFloat{P}}, x::ArfFloat{Q})
   z = ArfFloat{P}()
   ccall(@libarb(arf_set_round), Void, (Ptr{ArfFloat{P}}, Ptr{ArfFloat{Q}}, Clong), &z, &x, Clong(P))
   return z
end

function convert{Q}(::Type{ArbFloat}, x::ArbFloat{Q})
   P = precision(ArbFloat)
   z = ArbFloat{P}()
   ccall(@libarb(arb_set_round), Void, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{Q}}, Clong), &z, &x, Clong(P))
   return z
end
function convert{P,Q}(::Type{ArbFloat{P}}, x::ArbFloat{Q})
   z = ArbFloat{P}()
   ccall(@libarb(arb_set_round), Void, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{Q}}, Clong), &z, &x, Clong(P))
   return z
end


function convert{P}(::Type{ArbFloat{P}}, x::ArfFloat{P})
   z = ArbFloat{P}()
   ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat{P}}, Ptr{ArfFloat{P}}), &z, &x)
   return z
end

function convert{P}(::Type{ArfFloat{P}}, x::ArbFloat{P})
    z = ArfFloat{P}()
    z.exponentOf2  = x.exponentOf2
    z.nwords_sign  = x.nwords_sign
    z.significand1 = x.significand1
    z.significand2 = x.significand2
    return z
end

function convert{P,Q}(::Type{ArbFloat{P}}, x::ArfFloat{Q})
    y = convert(ArfFloat{P}, x)
    z = convert(ArbFloat{P}, y)
    return z
end
function convert{Q}(::Type{ArbFloat}, x::ArfFloat{Q})
    P = precision(ArbFloat)
    y = convert(ArfFloat{P}, x)
    z = convert(ArbFloat{P}, y)
    return z
end

function convert{P,Q}(::Type{ArfFloat{P}}, x::ArbFloat{Q})
    y = convert(ArbFloat{P}, x)
    z = convert(ArfFloat{P}, y)
    return z
end
function convert{Q}(::Type{ArfFloat}, x::ArbFloat{Q})
    P = precision(ArfFloat)
    y = convert(ArbFloat{P}, x)
    z = convert(ArfFloat{P}, y)
    return z
end

# convert ArbFloat with other types

function convert{T<:ArbFloat}(::Type{T}, x::UInt32)
    z = T()
    ccall(@libarb(arb_set_ui), Void, (Ptr{T}, UInt32), &z, x)
    return z
end
function convert{T<:ArbFloat}(::Type{T}, x::Int32)
    z = T()
    ccall(@libarb(arb_set_si), Void, (Ptr{T}, Int32), &z, x)
    return z
end

function convert{T<:ArbFloat}(::Type{T}, x::UInt64)
    z = x<=typemax(UInt32) ? convert(ArbFloat{P}, UInt32(x)) : T(string(x))
    return z
end
convert{T<:ArbFloat}(::Type{T}, x::UInt16) = convert(ArbFloat{P}, UInt32(x))
convert{T<:ArbFloat}(::Type{T}, x::UInt8) = convert(ArbFloat{P}, UInt32(x))

function convert{T<:ArbFloat}(::Type{T}, x::Int64)
    z = (abs(x)<=typemax(Int32)) ? convert(ArbFloat{P}, Int32(x)) : T(string(x))
    return z
end
convert{T<:ArbFloat}(::Type{T}, x::Int16) = convert(ArbFloat{P}, Int32(x))
convert{T<:ArbFloat}(::Type{T}, x::Int8) = convert(ArbFloat{P}, Int32(x))


function convert{T<:ArbFloat}(::Type{T}, x::Float64)
    P = precision(T)
    z = ArbFloat{P}()
    ccall(@libarb(arb_set_d), Void, (Ptr{T}, Float64), &z, x)
    return z
end
convert{T<:ArbFloat}(::Type{T}, x::Float32) = convert(T, convert(Float64,x))
convert{T<:ArbFloat}(::Type{T}, x::Float16) = convert(T, convert(Float64,x))


function convert{P}(::Type{ArbFloat{P}}, x::String)
    # s = String(x)
    z = ArbFloat{P}()
    ccall(@libarb(arb_set_str), Void, (Ptr{ArbFloat}, Ptr{UInt8}, Int), &z, x, P)
    return z
end
function convert{T<:ArbFloat}(::Type{T}, x::String)
    P = precision(T)
    return convert(ArbFloat{P}, x)
end

convert(::Type{BigInt}, x::String) = parse(BigInt,x)
convert(::Type{BigFloat}, x::String) = parse(BigFloat,x)

function convert{T<:ArbFloat}(::Type{T}, x::BigFloat)
     P = precision(T)+24
     x = round(x,P,2)
     s = string(x)
     z = T(s)
     return z
end


function convert{T<:ArbFloat}(::Type{BigFloat}, x::T)
     s = smartarbstring(x)
     return parse(BigFloat, s)
end

function convert{I<:Integer,P}(::Type{Rational{I}}, x::ArbFloat{P})
    bf = convert(BigFloat, x)
    return convert(Rational{I}, bf)
end

for T in (:Integer, :Signed)
  @eval begin
    function convert{P}(::Type{$T}, x::ArbFloat{P})
        y = trunc(x)
        try
           return convert(Int64, x)
        catch
           try
              return convert(Int128, x)
           catch
              DomainError()
           end
        end
    end
  end
end

for F in (:BigInt, :Rational)
  @eval begin
    function convert{T<:ArbFloat}(::Type{T}, x::$F)
        P = precision(T)
        B = precision(BigFloat)
        if B < P+24
            return convert(ArbFloat{P}, string(x))
        else
            return convert(ArbFloat{P}, convert(BigFloat, x))
        end
    end
    function convert{P}(::Type{ArbFloat{P}}, x::$F)
        B = precision(BigFloat)
        if B < P+24
            return convert(ArbFloat{P}, string(x))
        else
            return convert(ArbFloat{P}, convert(BigFloat, x))
        end
    end
  end
end

function convert{T<:ArbFloat,S}(::Type{T}, x::Irrational{S})
    P = precision(T)
    a = ArbFloat{P}()
    setprecision(BigFloat, precision(T)+24) do
         a = convert(T, BigFloat(x))
    end
    return a
end



for T in (:Float64, :Float32)
  @eval begin
    function convert{P}(::Type{$T}, x::ArbFloat{P})
      s = smartarbstring(x)
      try
          parse(($T), s)
      catch
          throw(DomainError)
      end
    end
    function convert{A<:ArbFloat}(::Type{$T}, x::A)
        P = precision(A)
        return convert{P}($T, x)
    end
  end
end

function convert{P}(::Type{BigInt}, x::ArbFloat{P})
   z = trunc(convert(BigFloat, x))
   return convert(BigInt, z)
end
for T in (:Int128, :Int64, :Int32, :Int16, :Int8)
  @eval begin
    function convert{P}(::Type{$T}, x::ArbFloat{P})
      z = convert(BigInt, trunc(x))
      return ($T)(z)
    end
  end
end


for N in (:Int128,
          :(Rational{Int128}), :(Rational{Int64}), :(Rational{Int32}), :(Rational{Int16}),)
  @eval convert{T<:ArbFloat}(::Type{T}, x::$N) = convert(ArbFloat{precision(ArbFloat)}, x)
end



# Promotion
for T in (:Int128, :Int64, :Int32, :Int16, :Float64, :Float32, :Float16,
          :(Rational{Int64}), :(Rational{Int32}), :(Rational{Int16}),
          :String)
  @eval promote_rule{P}(::Type{ArbFloat{P}}, ::Type{$T}) = ArbFloat{P}
end

float{P}(x::ArbFloat{P}) = convert(Float64, x)

promote_rule{P}(::Type{ArbFloat{P}}, ::Type{BigFloat}) = ArbFloat{P}
promote_rule{P}(::Type{ArbFloat{P}}, ::Type{BigInt}) = ArbFloat{P}
promote_rule{P}(::Type{ArbFloat{P}}, ::Type{Rational{BigInt}}) = Rational{BigInt}

promote_rule{P,Q}(::Type{ArbFloat{P}}, ::Type{ArbFloat{Q}}) =
    ifelse(P>Q, ArbFloat{P}, ArbFloat{Q})

@vectorize_1arg(BigFloat, ArbFloat)
@vectorize_1arg(Float64, ArbFloat)
@vectorize_1arg(Float32, ArbFloat)
@vectorize_1arg(BigInt, ArbFloat)
@vectorize_1arg(Int128, ArbFloat)
@vectorize_1arg(Int64, ArbFloat)
@vectorize_1arg(Int32, ArbFloat)
@vectorize_1arg(Rational, ArbFloat)

@vectorize_1arg(ArbFloat, Float64)
@vectorize_1arg(ArbFloat, Float32)
@vectorize_1arg(ArbFloat, BigInt)
@vectorize_1arg(ArbFloat, Int128)
@vectorize_1arg(ArbFloat, Int64)
@vectorize_1arg(ArbFloat, Int32)
@vectorize_1arg(ArbFloat, Rationa)

