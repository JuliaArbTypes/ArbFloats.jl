#=
   The mag type used by Arb (fredrikj.net/arb/mag.html)
   see also (https://github.com/Nemocas/Nemo.jl/blob/master/src/arb/ArbTypes.jl)
   see also (https://github.com/thofma/Hecke.jl/blob/master/src/Misc/mag.jl)
=#

#=
type MagFloat
    radius_exponentOf2 :: Int        # exponentOf2
    radius_significand :: UInt64     # significand
end
=#

#=
mutable struct MagFloat <: AbstractFloat
    radius_exponentOf2::Int
    radius_significand::UInt   ## radius is unsigned (nonnegative), by definition
#=
    function MagFloat()
         z = new(zero(Int), zero(UInt64))
         ccall(@libarb(mag_init), Void, (Ref{MagFloat}, ), z)
         finalizer(z, c_release_mag)
         return z
    end
=#    
end

function c_release_mag(x::MagFloat)
  ccall(@libarb(mag_clear), Cvoid, (Ref{MagFloat}, ), x)
end
=#

# define hash so other things work
const hash_arbmag_lo = (UInt === UInt64) ? 0x29f934c433d9a758 : 0x2578e2ce
const hash_0_arbmag_lo = hash(zero(UInt), hash_arbmag_lo)
if UInt===UInt64
   hash(z::MagFloat, h::UInt) = hash( reinterpret(UInt64, z.radius_exponentOf2), z.radius_significand )
else
   hash(z::MagFloat, h::UInt) = hash( reinterpret(UInt32, z.radius_exponentOf2) % UInt64, z.radius_significand )
end

# initialize and zero a variable of type MagFloat
function zero(::Type{MagFloat})
    z = MagFloat(0,0x0000000000000000)
    ccall(@libarb(mag_set_ui), Cvoid, (Ref{MagFloat}, UInt64), z, 0x0000000000000000)
    return z
end
#zero(x::MagFloat) = zero(MagFloat)
function zero(x::MagFloat)
    z = MagFloat(0,0x0000000000000000)
    ccall(@libarb(mag_set_ui), Cvoid, (Ref{MagFloat}, UInt64), z, 0x0000000000000000)
    return z
end

function one(::Type{MagFloat})
    z = MagFloat(0, 0x0000000000000000)
    ccall(@libarb(mag_set_ui), Cvoid, (Ref{MagFloat}, UInt64), z,  0x0000000000000001)
    return z
end
function one(x::MagFloat)
    z = MagFloat(0, 0x0000000000000000)
    ccall(@libarb(mag_set_ui), Cvoid, (Ref{MagFloat}, UInt64), z,  0x0000000000000001)
    return z
end

#=
# how to write
for (T, postfix) in ((:Int, :int), (:Float64, :fp))
    @eval  ccall(  ___ )
end
# so Julia sees
ccall( (:convert_from_int, "myClib"), Void, (Ref{ Int     }, ), my_int_va
ccall( (:convert_from_fp,  "myClib"), Void, (Ref{ Float64 }, ), my_fp_var  )
# ------- from Yichao Yu, to get
ccall( (:convert_from_int, "myClib"), Void, (Ref{ Int     }, ), my_int_var )
# ------- the loop content is written this way
ccall( ($(QuoteNode(Symbol("convert_from", postfix))), "myClib"),
Void, (Ref{$T}, ), $(Symbol("my_", postfix, "_var"))
=#

for (T,M) in ((:UInt, :ui), (:Int, :si), (:Float64, :d))
  @eval begin
    function convert(::Type{MagFloat}, x::($T))
        z = MagFloat()
        ccall( :($(QuoteNode(Symbol("mag_set_", $M))), "libarb"), Cvoid, (Ref{$T}, ), z )
        #ccall( ($(QuoteNode(Symbol("mag_set_", M))), "libarb"), Void, (Ref{$T}, ), z )
        return z
    end
  end
end

MagFloat(radius_exponentOf2::Int, radius_significand::Int64) =
    MagFloat(radius_exponentOf2, radius_significand % UInt64)

MagFloat(radius_exponentOf2::Int, radius_significand::Int32) =
    MagFloat(radius_exponentOf2, UInt64(radius_significand % UInt32) )

MagFloat(radius_exponentOf2::Int, radius_significand::Float64) =
    MagFloat(radius_exponentOf2, convert(UInt64, abs(radius_significand)) )

MagFloat(radius_exponentOf2::Int, radius_significand::Float32) =
    MagFloat(radius_exponentOf2, convert(UInt64, abs(radius_significand)) )





# conversions

# convert to MagFloat

Error_MagIsNegative() = throw(ErrorException("Magnitudes must be nonnegative."))

#=
function convert(::Type{MagFloat}, x::Float64)
    signbit(x) && Error_MagIsNegative()
    z = MagFloat()
    ccall(@libarb(mag_set_d), Void, (Ref{MagFloat}, Ref{Float64}), z, x)
    return z
end
convert(::Type{MagFloat}, x::Float32) = convert(MagFloat, convert(Float64, x))
convert(::Type{MagFloat}, x::Float16) = convert(MagFloat, convert(Float64, x))
=#

#=
   lowerbound returns upper bound of value
   upperbound returns lower bound of value
=#

if Int == Int64
  function upperbound(::Type{MagFloat}, x::UInt64)
    z = MagFloat()
    ccall(@libarb(mag_set_ui), Cvoid, (Ref{MagFloat}, Ref{UInt64}), z, x)
    return z
  end
  function lowerbound(::Type{MagFloat}, x::UInt64)
    z = MagFloat()
    ccall(@libarb(mag_set_ui_lower), Cvoid, (Ref{MagFloat}, Ref{UInt64}), z, x)
    return z
  end
  for T in (:UInt128, :UInt32, :UInt16, :UInt8)
    @eval upperbound(::Type{MagFloat}, x::($T)) = upperbound(MagFloat, convert(UInt64, x))
    @eval lowerbound(::Type{MagFloat}, x::($T)) = lowerbound(MagFloat, convert(UInt64, x))
  end
  for T in (:Int128, :Int32, :Int16, :Int8)
    @eval convert(::Type{MagFloat}, x::($T))  = convert(MagFloat, convert(Int64, x))
  end
else
  function upperbound(::Type{MagFloat}, x::UInt32)
    z = MagFloat()
    ccall(@libarb(mag_set_ui), Cvoid, (Ref{MagFloat}, Ref{UInt32}), z, x)
    return z
  end
  function lowerbound(::Type{MagFloat}, x::UInt32)
    z = MagFloat()
    ccall(@libarb(mag_set_ui_lower), Cvoid, (Ref{MagFloat}, Ref{UInt32}), z, x)
    return z
  end
  for T in (:UInt128, :UInt64, :UInt16, :UInt8)
    @eval upperbound(::Type{MagFloat}, x::($T)) = upperbound(MagFloat, convert(UInt32, x))
    @eval lowerbound(::Type{MagFloat}, x::($T)) = lowerbound(MagFloat, convert(UInt32, x))
  end
  for T in (:Int128, :Int64, :Int16, :Int8)
    @eval convert(::Type{MagFloat}, x::($T))  = convert(MagFloat, convert(Int32, x))
  end
end


# convert from MagFloat

function convert(::Type{Float64}, x::MagFloat)
    z = ccall(@libarb(mag_get_d), Float64, (Ref{MagFloat}, ), x)
    return z
end
function convert(::Type{Float32}, x::MagFloat)
    z = convert(Float64, x)
    convert(Float32, z)
    return z
end

# function convert(::Type{UInt}, x::MagFloat)

# promotions

for T in (:UInt, :Int, :Float32, :Float64)
    @eval promote_rule(::Type{MagFloat}, ::Type{$T}) = MagFloat
end

# string, show
#
function string(x::MagFloat)
    fp = convert(Float64, x)
    return string(fp)
end

function stringcompact(x::MagFloat)
    fp = convert(Float32, convert(Float64, x))
    return string(fp)
end

function show(io::IO, x::MagFloat)
    s = string(x)
    print(io, s)
    return nothing
end

function showcompact(io::IO, x::MagFloat)
    s = stringcompact(x)
    print(io, s)
    return nothing
end
