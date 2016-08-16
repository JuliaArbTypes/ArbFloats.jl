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
convert{P}(::Type{ArbFloat{P}}, x::ArbFloat{P}) = x
convert{P}(::Type{ArfFloat{P}}, x::ArfFloat{P}) = x

function convert{Q}(::Type{ArfFloat}, x::ArfFloat{Q})
   P = precision(T)
   z = initializer(ArfFloat{P})
   ccall(@libarb(arf_set_round), Void, (Ptr{ArfFloat{P}}, Ptr{ArfFloat{Q}}, Clong), &z, &x, Clong(P))
   return z
end
function convert{P,Q}(::Type{ArfFloat{P}}, x::ArfFloat{Q})
   z = initializer(ArfFloat{P})
   ccall(@libarb(arf_set_round), Void, (Ptr{ArfFloat{P}}, Ptr{ArfFloat{Q}}, Clong), &z, &x, Clong(P))
   return z
end

function convert{Q}(::Type{ArbFloat}, x::ArbFloat{Q})
   P = precision(T)
   z = initializer(ArbFloat{P})
   ccall(@libarb(arb_set_round), Void, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{Q}}, Clong), &z, &x, Clong(P))
   return z
end
function convert{P,Q}(::Type{ArbFloat{P}}, x::ArbFloat{Q})
   z = initializer(ArbFloat{P})
   ccall(@libarb(arb_set_round), Void, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{Q}}, Clong), &z, &x, Clong(P))
   return z
end


function convert{P}(::Type{ArbFloat{P}}, x::ArfFloat{P})
   z = initializer(ArbFloat{P})
   ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat{P}}, Ptr{ArfFloat{P}}), &z, &x)
   return z
end

function convert{P}(::Type{ArfFloat{P}}, x::ArbFloat{P})
    z = initializer(ArfFloat{P})
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

function convert{P,Q}(::Type{ArfFloat{P}}, x::ArbFloat{Q})
    y = convert(ArbFloat{P}, x)
    z = convert(ArfFloat{P}, y)
    return z
end



#=
# libarb low level routines
function arf_sets_arf{T1<:ArfFloat,T2<:ArfFloat}(a::T1, b::T2)
    P = precision(T1)
    ccall(@libarb(arb_set_round), Void, (Ptr{T1}, Ptr{T1}, Clong, Cint), &a, &b, P, 2) # round nearest
    return a
end
function arb_sets_arb{T1<:ArbFloat,T2<:ArbFloat}(a::T1, b::T2)
    P = precision(T1)
    ccall(@libarb(arb_set_round), Void, (Ptr{T1}, Ptr{T1}, Clong), &a, &b, P)
    return a
end
function arb_set_arf{P}(a::ArbFloat{P}, b::ArfFloat{P})
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat{P}}, Ptr{ArfFloat{P}}), &a, &b)
    return a
end
function arb_set_arb{T<:ArbFloat}(a::T, b::T)
    P = precision(T)
    ccall(@libarb(arb_set), Void, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &a, &b)
    return a
end
function arb_sets_arf{T1<:ArbFloat,T2<:ArfFloat}(a::T1, b::T2)
    P = precision(T1)
    z = initializer(ArfFloat{P})
    arf_sets_arf(z, b)
    arb_set_arf(a, z)
    return a
end
function arf_sets_arb{T1<:ArfFloat,T2<:ArbFloat}(a::T1, b::T2)
    P = precision(T1)
    z = initializer(ArbFloat{P})
    arb_sets_arb(z, b)
    arf_set_arb(a, z)
    return a
end

convert{P}(::Type{ArfFloat{P}}, x::ArfFloat{P}) = x
convert{P}(::Type{ArbFloat{P}}, x::ArbFloat{P}) = x

convert{T1<:ArfFloat,T2<:ArfFloat}(a::T1, b::T2) =
    arf_sets_arf(a, b)

convert{T1<:ArbFloat,T2<:ArbFloat}(a::T1, b::T2) =
    arb_sets_arb(a, b)

convert{T1<:ArfFloat,T2<:ArbFloat}(a::T1, b::T2) =
    arf_sets_arb(a,b)

convert{T1<:ArbFloat,T2<:ArfFloat}(a::T1, b::T2) =
    arb_sets_arf(a,b)
=#

#int arf_set_round(arf_t y, const arf_t x, slong prec, arf_rnd_t rnd)




# interconvert Arb with Arf
#=
function convert{ARB<:ArbFloat, ARF<:ArfFloat}(::Type{ARF}, x::ARB)
    P = precision(ARF)
    y = ifelse( P == precision(ARF), x, ArbFloat{P}(x) )

    z = initializer(ArfFloat{P})
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat{P}}, Ptr{ArfFloat{P}}), &z, &y)

    return z
end
=#
#=
function convert{P}(::Type{ArfFloat{P}}, x::ArbFloat{P})
    z = initializer(ArfFloat{P})
    z.exponentOf2  = x.exponentOf2
    z.nwords_sign  = x.nwords_sign
    z.significand1 = x.significand1
    z.significand2 = x.significand2

    return z
end
function convert{P,Q}(::Type{ArfFloat{Q}}, x::ArbFloat{P})
  y = convert(ArbFloat{Q}, x)
  return convert(ArfFloat{Q}, y)
end

function convert{P}(::Type{ArbFloat{P}}, x::ArfFloat{P})
    z = initializer(ArbFloat{P})
    z.exponentOf2  = x.exponentOf2
    z.nwords_sign  = x.nwords_sign
    z.significand1 = x.significand1
    z.significand2 = x.significand2

    return z
end
function convert{P,Q}(::Type{ArbFloat{Q}}, x::ArfFloat{P})
  y = convert(ArfFloat{Q}, x)
  return convert(ArbFloat{Q}, y)
end
=#
#=
function convert{ARB<:ArbFloat, ARF<:ArfFloat}(::Type{ARF}, x::ARB)
    P = precision(ARF)
    y = ifelse( P == precision(ARF), x, ArbFloat{P}(x) )

    z = initializer(ArfFloat{P})
    z.exponentOf2  = y.exponentOf2
    z.nwords_sign  = y.nwords_sign
    z.significand1 = y.significand1
    z.significand2 = y.significand2

    return z
end
=#
#=
function convert{P}(::Type{ArbFloat}, x::ArfFloat{P})
    P2 = precision(ArbFloat)
    return convert(ArbFloat{P2},x)
end

function convert{P}(::Type{ArfFloat}, x::ArbFloat{P})
    P2 = precision(ArfFloat)
    return convert(ArfFloat{P2},x)
end


function convert{P}(::Type{ArbFloat{P}}, x::ArfFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat{P}}, Ptr{ArfFloat{P}}), &z, &x)
    return z
end

function convert{P}(::Type{ArfFloat{P}}, x::ArbFloat{P})
    z = initializer(ArfFloat{P})
    z.exponentOf2  = x.exponentOf2
    z.nwords_sign  = x.nwords_sign
    z.significand1 = x.significand1
    z.significand2 = x.significand2
    return z
end
=#

#=
function convert{P}(::Type{ArbFloat{P}}, x::ArfFloat{P})
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_arf), Void, (Ptr{ArbFloat{P}}, Ptr{ArfFloat{P}}), &z, &x)
    return z
end

function convert{P}(::Type{ArfFloat{P}}, x::ArbFloat{P})
    z = initializer(ArfFloat{P})
    z.exponentOf2  = x.exponentOf2
    z.nwords_sign  = x.nwords_sign
    z.significand1 = x.significand1
    z.significand2 = x.significand2
    return z
end
=#

#interconvert ArbFloat{P} with ArbFloat{Q}
#=
function convert{P,Q}(::Type{ArbFloat{Q}}, a::ArbFloat{P})
    if (Q < P)
        return round(a, Q, 2)
    elseif (Q > P)
        z = initializer(ArbFloat{Q})
        z.exponentOf2  = a.exponentOf2
        z.nwords_sign  = a.nwords_sign
        z.significand1 = a.significand1
        z.significand2 = a.significand2
        z.radius_exponentOf2  = a.radius_exponentOf2
        z.radius_significand  = a.radius_significand
    else
        return a
    end
    return z
end
=#
#interconvert ArfFloat{P} with ArfFloat{Q}
#=
function convert{P,Q}(::Type{ArfFloat{Q}}, a::ArfFloat{P})
    if (Q < P)
        return round(a, Q, 2)
    elseif (Q > P)
        z = initializer(ArfFloat{Q})
        z.exponentOf2  = a.exponentOf2
        z.nwords_sign  = a.nwords_sign
        z.significand1 = a.significand1
        z.significand2 = a.significand2
    else
        return a
    end
    return z
end
=#
#interconvert ArbFloat{P} with ArfFloat{Q}


#=
function convert{P,Q}(::Type{ArbFloat{P}}, a::ArfFloat{Q})
    ap = ArfFloat{P}(a)
    return convert(ArbFloat{P}, ap)
end

function convert{P,Q}(::Type{ArfFloat{P}}, a::ArbFloat{Q})
    ap = ArbFloat{P}(a)
    return convert(ArfFloat{P}, ap)
end
=#

# convert ArbFloat with other types

function convert{P}(::Type{ArbFloat{P}}, x::UInt)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_ui), Void, (Ptr{ArbFloat{P}}, UInt), &z, x)
    return z
end
if sizeof(Int)==sizeof(Int64)
   convert{P}(::Type{ArbFloat{P}}, x::UInt32) = convert(ArbFloat{P}, convert(UInt64,x))
else
   convert{P}(::Type{ArbFloat{P}}, x::UInt64) = convert(ArbFloat{P}, convert(UInt32,x))
end
convert{P}(::Type{ArbFloat{P}}, x::UInt16) = convert(ArbFloat{P}, convert(UInt,x))

function convert{P}(::Type{ArbFloat{P}}, x::Int)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_si), Void, (Ptr{ArbFloat{P}}, Int), &z, x)
    z
end
if sizeof(Int)==sizeof(Int64)
   convert{P}(::Type{ArbFloat{P}}, x::Int32) = convert(ArbFloat{P}, convert(Int64,x))
else
   convert{P}(::Type{ArbFloat{P}}, x::Int64) = convert(ArbFloat{P}, convert(Int32,x))
end
convert{P}(::Type{ArbFloat{P}}, x::Int16) = convert(ArbFloat{P}, convert(Int,x))


function convert{T<:ArbFloat}(::Type{T}, x::Float64)
    z = initializer(T)
    fp=copy(x)
    ccall(@libarb(arb_set_d), Void, (Ptr{T}, Float64), &z, fp)
    return z
end
convert{T<:ArbFloat}(::Type{T}, x::Float32) = convert(T, convert(Float64,x))
convert{T<:ArbFloat}(::Type{T}, x::Float16) = convert(T, convert(Float64,x))


function convert{P}(::Type{ArbFloat{P}}, x::String)
    s = String(x)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_str), Void, (Ptr{ArbFloat}, Ptr{UInt8}, Int), &z, s, P)
    return z
end


convert(::Type{BigInt}, x::String) = parse(BigInt,x)
convert(::Type{BigFloat}, x::String) = parse(BigFloat,x)

#=
function convert{P}(::Type{ArbFloat{P}}, x::BigFloat)
     x = round(x,P,2)
     s = string(x)
     return ArbFloat{P}(s)
end
=#
function convert{T<:ArbFloat}(::Type{T}, x::BigFloat)
     P = precision(T)
     x = round(x,P,2)
     s = string(x)
     return ArbFloat{P}(s)
end


function convert{T<:ArbFloat}(::Type{BigFloat}, x::T)
     s = smartarbstring(x)
     return parse(BigFloat, s)
end

function convert{I<:Integer,P}(::Type{Rational{I}}, x::ArbFloat{P})
    bf = convert(BigFloat, x)
    return convert(Rational{I}, bf)
end

convert{P}(::Type{ArbFloat{P}}, x::BigInt)   = convert(ArbFloat{P}, convert(BigFloat,x))
convert{P}(::Type{ArbFloat{P}}, x::Rational) = convert(ArbFloat{P}, convert(BigFloat,x))
convert{P,S}(::Type{ArbFloat{P}}, x::Irrational{S}) = convert(ArbFloat{P}, convert(BigFloat,x))


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
  end
end

function convert{P}(::Type{BigInt}, x::ArbFloat{P})
   z = trunc(convert(BigFloat, x))
   return convert(BigInt, z)
end
for T in (:Int128, :Int64, :Int32, :Int16)
  @eval begin
    function convert{P}(::Type{$T}, x::ArbFloat{P})
      z = convert(BigInt, trunc(x))
      return ($T)(z)
    end
  end
end



#=
function convert{I<:Integer,P}(::Type{I}, x::ArbFloat{P})
    s = smartarbstring(x)
    parse(I,split(s,".")[1])
end
=#

for N in (:Int128, :Int64, :Int32, :Int16,
          :(Rational{Int64}), :(Rational{Int32}), :(Rational{Int16}),
          :String)
  @eval convert{T<:ArbFloat}(::Type{T}, x::$N) = convert(ArbFloat{precision(ArbFloat)}, x)
end



# Promotion
for T in (:Int128, :Int64, :Int32, :Int16, :Float64, :Float32, :Float16,
          :(Rational{Int64}), :(Rational{Int32}), :(Rational{Int16}),
          :String)
  @eval promote_rule{P}(::Type{ArbFloat{P}}, ::Type{$T}) = ArbFloat{P}
end

float{P}(x::ArbFloat{P}) = convert(Float64, x)

promote_rule{P}(::Type{ArbFloat{P}}, ::Type{BigFloat}) = BigFloat
promote_rule{P}(::Type{ArbFloat{P}}, ::Type{BigInt}) = ArbFloat{P}
promote_rule{P}(::Type{ArbFloat{P}}, ::Type{Rational{BigInt}}) = Rational{BigInt}

promote_rule{P,Q}(::Type{ArbFloat{P}}, ::Type{ArbFloat{Q}}) =
    ifelse(P>Q, ArbFloat{P}, ArbFloat{Q})
