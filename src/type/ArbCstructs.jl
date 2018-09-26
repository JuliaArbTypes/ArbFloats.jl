#=
    types that mirror the layout used in Arb
        for the mag, arf, and arb structs
    see Cstructs.txt for the C library versions
=#

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



    #       P is the precision in bits as a parameter
    #
mutable struct ArfFloat{P} <: AbstractFloat
    exponentOf2 ::Int
    nwords_sign::Int           ## Int, as words is an offset; lsb holds sign of significand
    significand1::UInt         ## UInt, as each significand word is a subspan of significand
    significand2::UInt         ##   the significand words are unsigned (sign is in nwords_sign)
#=
    function ArfFloat()
         z = new{P}(0,0%UInt,0%UInt,0%UInt)
         ccall(@libarb(arf_init), Void, (Ref{ArfFloat{P}}, ), z)
         finalizer(z, c_release_arf)
         return z
    end
=#    
end


function c_release_arf(x::ArfFloat{P}) where {P}
  ccall(@libarb(arf_clear), Cvoid, (Ref{ArfFloat{P}}, ), x)
end

    #       P is the precision in bits as a parameter
    #
mutable struct ArbFloat{P} <: AbstractFloat
                               ##     ArfFloat{P}
    exponentOf2 ::Int          ##        exponentOf2
    nwords_sign::Int           ##        nwords_sign
    significand1::UInt         ##        significand1
    significand2::UInt         ##        significand2
                               ###    ArbMag{P}
    radius_exponentOf2::Int    ####      radius_exponentOf2
    radius_significand::UInt   ####      radius_significand
#=
    function ArbFloat()
         z = new{P}(0,0,0,0,0,0)#(0,0%UInt,0%UInt,0%UInt,0,0%UInt)
         ccall(@libarb(arb_init), Void, (Ref{ArbFloat{P}}, ), z)
         finalizer(z, c_release_arb)
         return z
    end
=#    
end

function c_release_arb(x::ArbFloat{P}) where {P}
  ccall(@libarb(arb_clear), Cvoid, (Ref{ArbFloat{P}},), x)
end
