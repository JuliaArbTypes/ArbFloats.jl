#=
   The mag type used by Arb (fredrikj.net/arb/mag.html)
   see also (https://github.com/Nemocas/Nemo.jl/blob/master/src/arb/ArbTypes.jl)
   see also (https://github.com/thofma/Hecke.jl/blob/master/src/Misc/mag.jl)
=#

#=
type MagFloat
    radiusExp::Int
    radiusMan::UInt64
end
=#

MagFloat{T<:Union{Int64,Int32}}(radiusExp::Int, radiusMan::T) =
    MagFloat(radiusExp, radiusMan % UInt64)

function release{T<:MagFloat}(x::T)
    ccall(@libarb(mag_clear), Void, (Ptr{T}, ), &x)
    return nothing
end

function init{T<:MagFloat}(::Type{T})
    z = MagFloat(zero(Int), zero(UInt64))
    ccall(@libarb(mag_init), Void, (Ptr{T}, ), &z)
    finalizer(z, release)
    return z
end

MagFloat() = init(MagFloat)

# define hash so other things work
const hash_arbmag_lo = (UInt === UInt64) ? 0x29f934c433d9a758 : 0x2578e2ce
const hash_0_arbmag_lo = hash(zero(UInt), hash_arbmag_lo)
if UInt===UInt64
   hash(z::MagFloat, h::UInt) = hash( reinterpret(UInt64, z.radiusExp), z.radiusMan )
else
   hash(z::MagFloat, h::UInt) = hash( reinterpret(UInt32, z.radiusExp) % UInt64, z.radiusMan )
end

# conversions

# convert to MagFloat

Error_MagIsNegative() = throw(ErrorException("Magnitudes must be nonnegative."))

function convert(::Type{MagFloat}, x::Float64)
    signbit(x) && Error_MagIsNegative()
    z = MagFloat()
    ccall(@libarb(mag_set_d), Void, (Ptr{MagFloat}, Ptr{Float64}), &z, &x)
    return z
end
convert(::Type{MagFloat}, x::Float32) = convert(MagFloat, convert(Float64, x))
convert(::Type{MagFloat}, x::Float16) = convert(MagFloat, convert(Float64, x))

#=
   convertHi returns upper bound of value
   convertLo returns lower bound of value
=#

function convertHi(::Type{MagFloat}, x::UInt64)
    z = MagFloat()
    ccall(@libarb(mag_set_ui), Void, (Ptr{MagFloat}, Ptr{UInt64}), &z, &x)
    return z
end
function convertLo(::Type{MagFloat}, x::UInt64)
    z = MagFloat()
    ccall(@libarb(mag_set_ui_lower), Void, (Ptr{MagFloat}, Ptr{UInt64}), &z, &x)
    return z
end
for T in (:UInt128, :UInt32, :UInt16, :UInt8)
    @eval convertHi(::Type{MagFloat}, x::($T)) = convertHi(MagFloat, convert(UInt64, x))
    @eval convertLo(::Type{MagFloat}, x::($T)) = convertLo(MagFloat, convert(UInt64, x))
end

function convert(::Type{MagFloat}, x::Int64)
    signbit(x) && Error_MagIsNegative()
    return convert(MagFloat, reinterpret(UInt64, x))
end
for T in (:Int128, :Int32, :Int16, :Int8)
    @eval convert(::Type{MagFloat}, x::($T))  = convert(MagFloat, convert(Int64, x))
end



#convert from MagFloat

function convert(::Type{Float64}, x::MagFloat)
    z = ccall(@libarb(mag_get_d), Float64, (Ptr{MagFloat}, ), &x)
    return z
end
function convert(::Type{Float32}, x::MagFloat)
    z = convert(Float64, x)
    convert(Float32, z)
    return z
end


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
