#=
    types that mirror the layout used in Arb
        for the mag, arf, and arb structs
    see Cstructs.txt for the C library versions
=#

type MagFloat <: AbstractFloat
    radius_exponentOf2::Int
    radius_significand::UInt   ## radius is unsigned (nonnegative), by definition

    function MagFloat()
         z = new()
         ccall(@libarb(mag_init), Void, (Ptr{MagFloat}, ), &z)
         finalizer(z, c_release_mag)
         return z
    end
end

function c_release_mag(x::MagFloat)
  ccall(@libarb(mag_clear), Void, (Ptr{MagFloat}, ), &x)
end



    #       P is the precision in bits as a parameter
    #
type ArfFloat{P} <: AbstractFloat
    exponentOf2 ::Int
    nwords_sign::Int           ## Int, as words is an offset; lsb holds sign of significand
    significand1::UInt         ## UInt, as each significand word is a subspan of significand
    significand2::UInt         ##   the significand words are unsigned (sign is in nwords_sign)

    function ArfFloat()
         z = new{P}()
         ccall(@libarb(arf_init), Void, (Ptr{ArfFloat{P}}, ), &z)
         finalizer(z, c_release_arf)
         return z
    end
end


function c_release_arf{P}(x::ArfFloat{P})
  ccall(@libarb(arf_clear), Void, (Ptr{ArfFloat{P}}, ), &x)
end

    #       P is the precision in bits as a parameter
    #
type ArbFloat{P} <: AbstractFloat
                               ##     ArfFloat{P}
    exponentOf2 ::Int          ##        exponentOf2
    nwords_sign::Int           ##        nwords_sign
    significand1::UInt         ##        significand1
    significand2::UInt         ##        significand2
                               ###    ArbMag{P}
    radius_exponentOf2::Int    ####      radius_exponentOf2
    radius_significand::UInt   ####      radius_significand

    function ArbFloat()
         z = new{P}(0,0%UInt,0%UInt,0%UInt,0,0%UInt)
         ccall(@libarb(arb_init), Void, (Ptr{ArbFloat{P}}, ), &z)
         finalizer(z, c_release_arb)
         return z
    end
end

function c_release_arb{P}(x::ArbFloat{P})
  ccall(@libarb(arb_clear), Void, (Ptr{ArbFloat{P}}, ), &x)
end
