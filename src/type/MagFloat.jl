#=
   The mag type used by Arb (fredrikj.net/arb/mag.html)
   see also (https://github.com/Nemocas/Nemo.jl/blob/master/src/arb/ArbTypes.jl)
   see also (https://github.com/thofma/Hecke.jl/blob/master/src/Misc/mag.jl)
=#

#=
type MagFloat
    radius_exponent :: Int        # exponent
    radius_mantissa :: UInt64     # mantissa
end
=#

# initializing a MagFloat sets the value to zero
@inline initial0(z::MagFloat) = ccall(@libarb(mag_init), Void, (Ptr{MagFloat}, ), &z)
@inline finalize(x::MagFloat) = ccall(@libarb(mag_clear), Void, (Ptr{MagFloat}, ), &x)

# initialize and zero a variable of type MagFloat
function initialize(::Type{MagFloat})
    z = MagFloat(zero(Int), zero(UInt64))
    initial0(z)
    finalizer(z, finalize)
    return z
end

for (T,M) in ((:UInt, :ui), (:Int, :si), (:Float64, :d))
  @eval begin
    function convert(::Type{MagFloat}, x::($T))
        z = MagFloat(zero(Int), zero(UInt64))
        initial0(z)
        ccall($(@libarb("mag_set_"*M)), Void, (Ptr{MagFloat}, ($T)), &z, x)
        finalizer(z, finalize)
    end
  end
end

MagFloat(radius_exponent::Int, radius_mantissa::Int64) =
    MagFloat(radius_exponent, radius_mantissa % UInt64)

MagFloat(radius_exponent::Int, radius_mantissa::Int32) =
    MagFloat(radius_exponent, UInt64(radius_mantissa % UInt32) )

MagFloat(radius_exponent::Int, radius_mantissa::Float64) =
    MagFloat(radius_exponent, convert(UInt64, abs(radius_mantissa))

MagFloat(radius_exponent::Int, radius_mantissa::Float32) =
    MagFloat(radius_exponent, convert(UInt64, abs(radius_mantissa))


MagFloat() = initialize(MagFloat)

# define hash so other things work
const hash_arbmag_lo = (UInt === UInt64) ? 0x29f934c433d9a758 : 0x2578e2ce
const hash_0_arbmag_lo = hash(zero(UInt), hash_arbmag_lo)
if UInt===UInt64
   hash(z::MagFloat, h::UInt) = hash( reinterpret(UInt64, z.radius_exponent), z.radius_mantissa )
else
   hash(z::MagFloat, h::UInt) = hash( reinterpret(UInt32, z.radius_exponent) % UInt64, z.radius_mantissa )
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
   lowerbound returns upper bound of value
   upperbound returns lower bound of value
=#

function upperbound(::Type{MagFloat}, x::UInt64)
    z = MagFloat()
    ccall(@libarb(mag_set_ui), Void, (Ptr{MagFloat}, Ptr{UInt64}), &z, &x)
    return z
end
function lowerbound(::Type{MagFloat}, x::UInt64)
    z = MagFloat()
    ccall(@libarb(mag_set_ui_lower), Void, (Ptr{MagFloat}, Ptr{UInt64}), &z, &x)
    return z
end
for T in (:UInt128, :UInt32, :UInt16, :UInt8)
    @eval upperbound(::Type{MagFloat}, x::($T)) = upperbound(MagFloat, convert(UInt64, x))
    @eval lowerbound(::Type{MagFloat}, x::($T)) = lowerbound(MagFloat, convert(UInt64, x))
end

function convert(::Type{MagFloat}, x::Int64)
    signbit(x) && Error_MagIsNegative()
    return convert(MagFloat, reinterpret(UInt64, x))
end

for T in (:Int128, :Int32, :Int16, :Int8)
    @eval convert(::Type{MagFloat}, x::($T))  = convert(MagFloat, convert(Int64, x))
end



# convert from MagFloat

function convert(::Type{Float64}, x::MagFloat)
    z = ccall(@libarb(mag_get_d), Float64, (Ptr{MagFloat}, ), &x)
    return z
end
function convert(::Type{Float32}, x::MagFloat)
    z = convert(Float64, x)
    convert(Float32, z)
    return z
end

function convert(::Type{UInt}, x::MagFloat)

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
