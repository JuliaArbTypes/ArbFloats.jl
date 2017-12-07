macro ArfFloat(x)
    convert(ArfFloat, string(:($x)))
end
macro ArfFloat(p,x)
    convert(ArfFloat{:($p)}, string(:($x)))
end

macro ArbFloat(x)
    quote
       if isa($x, Irrational)
           convert(ArbFloat, $x)
       else
            convert(ArbFloat, string($x))
       end
    end
end
    
macro ArbFloat(p,x)
    quote
       if isa($x, Irrational)
           convert(ArbFloat{$p}, $x)
       else
           convert(ArbFloat{$p}, string($x))
       end
    end
end

convert(::Type{T}, x::T) where {T <: ArfFloat} = x
convert(::Type{T}, x::T) where {T <: ArbFloat} = x
convert(::Type{ArfFloat{P}}, x::ArfFloat{P}) where {P} = x
convert(::Type{ArbFloat{P}}, x::ArbFloat{P}) where {P} = x

#=
function convert{Q}(::Type{ArfFloat}, x::ArfFloat{Q})
   P = precision(ArfFloat)
   z = initializer(ArfFloat{P})
   ccall(@libarb(arf_set_round), Void, (Ref{ArfFloat{P}}, Ref{ArfFloat{Q}}, Clong), z, x, Clong(P))
   return z
end
=#
function convert(::Type{ArfFloat{P}}, x::ArfFloat{Q}) where {P,Q}
   z = initializer(ArfFloat{P})
   ccall(@libarb(arf_set_round), Void, (Ref{ArfFloat{P}}, Ref{ArfFloat{Q}}, Clong), z, x, Clong(P))
   return z
end
#=
function convert{Q}(::Type{ArbFloat}, x::ArbFloat{Q})
   P = precision(ArbFloat)
   z = initializer(ArbFloat{P})
   ccall(@libarb(arb_set_round), Void, (Ref{ArbFloat{P}}, Ref{ArbFloat{Q}}, Clong), z, x, Clong(P))
   return z
end
=#
function convert(::Type{ArbFloat{P}}, x::ArbFloat{Q}) where {P,Q}
   z = initializer(ArbFloat{P})
   ccall(@libarb(arb_set_round), Void, (Ref{ArbFloat{P}}, Ref{ArbFloat{Q}}, Clong), z, x, Clong(P))
   return z
end


function convert(::Type{ArbFloat{P}}, x::ArfFloat{P}) where {P}
   z = initializer(ArbFloat{P})
   ccall(@libarb(arb_set_arf), Void, (Ref{ArbFloat{P}}, Ref{ArfFloat{P}}), z, x)
   return z
end

function convert(::Type{ArfFloat{P}}, x::ArbFloat{P}) where {P}
    z = initializer(ArfFloat{P})
    z.exponentOf2  = x.exponentOf2
    z.nwords_sign  = x.nwords_sign
    z.significand1 = x.significand1
    z.significand2 = x.significand2
    return z
end

function convert(::Type{ArbFloat{P}}, x::ArfFloat{Q}) where {P,Q}
    y = convert(ArfFloat{P}, x)
    z = convert(ArbFloat{P}, y)
    return z
end
#=
function convert{Q}(::Type{ArbFloat}, x::ArfFloat{Q})
    P = precision(ArbFloat)
    y = convert(ArfFloat{P}, x)
    z = convert(ArbFloat{P}, y)
    return z
end
=#
function convert(::Type{ArfFloat{P}}, x::ArbFloat{Q}) where {P,Q}
    y = convert(ArbFloat{P}, x)
    z = convert(ArfFloat{P}, y)
    return z
end
function convert(::Type{ArfFloat}, x::ArbFloat{Q}) where {Q}
    P = precision(ArfFloat)
    y = convert(ArbFloat{P}, x)
    z = convert(ArfFloat{P}, y)
    return z
end

# convert ArbFloat with other types

function convert(::Type{T}, x::UInt64) where {T <: ArbFloat}
    P = precision(T)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_ui), Void, (Ref{ArbFloat}, UInt64), z, x)
    return z
end
function convert(::Type{T}, x::Int64) where {T <: ArbFloat}
    P = precision(T)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_si), Void, (Ref{ArbFloat}, Int64), z, x)
    return z
end

function convert(::Type{T}, x::Float64) where {T <: ArbFloat}
    P = precision(T)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_d), Void, (Ref{ArbFloat}, Float64), z, x)
    return z
end

function convert(::Type{T}, x::String) where {T <: ArbFloat}
    P = precision(T)
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_set_str), Void, (Ref{ArbFloat}, Ref{UInt8}, Int), z, x, P)
    return z
end

convert(::Type{T}, x::UInt32) where {T <: ArbFloat}  = convert(T, x%UInt64)
convert(::Type{T}, x::UInt16) where {T <: ArbFloat}  = convert(T, x%UInt64)
convert(::Type{T}, x::UInt8) where {T <: ArbFloat}   = convert(T, x%UInt64)
convert(::Type{T}, x::UInt128) where {T <: ArbFloat} = convert(T, string(x))

convert(::Type{T}, x::Int32) where {T <: ArbFloat}  = convert(T, x%Int64)
convert(::Type{T}, x::Int16) where {T <: ArbFloat}  = convert(T, x%Int64)
convert(::Type{T}, x::Int8) where {T <: ArbFloat}   = convert(T, x%Int64)
convert(::Type{T}, x::Int128) where {T <: ArbFloat} = convert(T, string(x))

convert(::Type{T}, x::Float32) where {T <: ArbFloat} = convert(T, convert(Float64,x))
convert(::Type{T}, x::Float16) where {T <: ArbFloat} = convert(T, convert(Float64,x))

function convert(::Type{Float64}, x::T) where {T <: ArbFloat}
    ptr2mid = ptr_to_midpoint(x)
    fl = ccall(@libarb(arf_get_d), Float64, (Ref{ArfFloat}, Int), ptr2mid, 4) # round nearest
    return fl
end

function convert(::Type{Float32}, x::T) where {T <: ArbFloat}
    return convert(Float32, convert(Float64, x))
end
function convert(::Type{Float16}, x::T) where {T <: ArbFloat}
    return convert(Float16, convert(Float64, x))
end

for I in (:UInt64, :UInt128)
  @eval begin
    function convert(::Type{$I}, x::T) where {T <: ArbFloat}
        if isinteger(x)
           if notnegative(x)
               return convert($I, convert(BigInt,x))
           else
               throw( DomainError() )
           end
        else
           throw( InexactError() )
        end
    end
  end
end

convert(::Type{UInt32}, x::T) where {T <: ArbFloat} = convert(UInt32, convert(UInt64,x))
convert(::Type{UInt16}, x::T) where {T <: ArbFloat} = convert(UInt16, convert(UInt64,x))
convert(::Type{UInt8}, x::T) where {T <: ArbFloat} = convert(UInt8, convert(UInt64,x))

for I in (:Int64, :Int128)
  @eval begin
    function convert(::Type{$I}, x::T) where {T <: ArbFloat}
        if isinteger(x)
           return convert($I, convert(BigInt,x))
        else
           throw( InexactError() )
        end
    end
  end
end

convert(::Type{Int32}, x::T) where {T <: ArbFloat} = convert(Int32, convert(Int64,x))
convert(::Type{Int16}, x::T) where {T <: ArbFloat} = convert(Int16, convert(Int64,x))
convert(::Type{Int8}, x::T) where {T <: ArbFloat} = convert(Int8, convert(Int64,x))

function parse(::Type{T}, x::String) where {T <: ArbFloat}
    return T(x)
end



# =================



convert(::Type{BigInt}, x::String) = parse(BigInt,x)
convert(::Type{BigFloat}, x::String) = parse(BigFloat,x)

function convert(::Type{T}, x::BigFloat) where {T <: ArbFloat}
     P = precision(T)+24
     x = round(x,P,2)
     s = string(x)
     z = T(s)
     return z
end


#=
function convert{T<:ArbFloat}(::Type{BigFloat}, x::T)
     s = string(midpoint(x))
     return parse(BigFloat, s)
end
=#
function convert(::Type{BigFloat}, x::T) where {T <: ArbFloat}
    ptr2mid = ptr_to_midpoint(x)
    bf = zero(BigFloat)
    rounddir = ccall(@libarb(arf_get_mpfr), Int, (Ref{BigFloat}, Ref{ArfFloat}, Int), bf, ptr2mid, 4) # round nearest
    return bf
end



function convert(::Type{Rational{I}}, x::ArbFloat{P}) where {I <: Integer,P}
    bf = convert(BigFloat, x)
    return convert(Rational{I}, bf)
end

for T in (:Integer, :Signed)
  @eval begin
    function convert(::Type{$T}, x::ArbFloat{P}) where {P}
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
    function convert(::Type{T}, x::$F) where {T <: ArbFloat}
        P = precision(T)
        B = precision(BigFloat)
        if B < P+24
            return convert(ArbFloat{P}, string(x))
        else
            return convert(ArbFloat{P}, convert(BigFloat, x))
        end
    end
    function convert(::Type{ArbFloat{P}}, x::$F) where {P}
        B = precision(BigFloat)
        if B < P+24
            return convert(ArbFloat{P}, string(x))
        else
            return convert(ArbFloat{P}, convert(BigFloat, x))
        end
    end
  end
end

function convert(::Type{T}, x::Irrational{Sym}) where {T <: ArbFloat,Sym}
    P = precision(T)
    bf_precision = precision(BigFloat)
    setprecision(BigFloat, precision(T)+24)        
    bf_x = convert(BigFloat, x)
    z = convert(ArbFloat{P}, bf_x)
    setprecision(BigFloat, bf_precision)
    return z
end



function convert(::Type{BigInt}, x::ArbFloat{P}) where {P}
   z = trunc(convert(BigFloat, x))
   return convert(BigInt, z)
end


# Promotion
for T in (:Int128, :Int64, :Int32, :Int16, :Float64, :Float32, :Float16,
          :(Rational{Int64}), :(Rational{Int32}), :(Rational{Int16}),
          :String)
  @eval promote_rule(::Type{ArbFloat{P}}, ::Type{$T}) where {P} = ArbFloat
end

float(x::ArbFloat{P}) where {P} = x

promote_rule(::Type{ArbFloat{P}}, ::Type{BigFloat}) where {P} = ArbFloat
promote_rule(::Type{ArbFloat{P}}, ::Type{BigInt}) where {P} = ArbFloat
promote_rule(::Type{ArbFloat{P}}, ::Type{Rational{BigInt}}) where {P} = Rational{BigInt}

promote_rule(::Type{ArbFloat{P}}, ::Type{ArbFloat{Q}}) where {P,Q} =
    ifelse(P>Q, ArbFloat{P}, ArbFloat{Q})


# convert a vector of ArbFloats to another numeric type
for T in (:BigFloat, :Float64, :Float32, :BigInt, :Int128, :Int64, :Int32, :Rational)
    @eval ($T)(x::Array{ArbFloat{P},1}) where {P} = ($T).(x)
end
# convert a numeric vector into ArbFloats
for T in (:Float64, :Float32, :BigInt, :Int128, :Int64, :Int32, :Rational)
    @eval begin
        function ArbFloat(x::Array{($T),1})
             P=precision(ArbFloat)
             return map(v->ArbFloat{P}(v), x)
        end
    end
end
