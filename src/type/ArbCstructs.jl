#=
    types that mirror the layout used in Arb
        for the mag, arf, and arb structs
    see Cstructs.txt for the C library versions
=#


type MagFloat
    radius_exponent::Int
    radius_mantissa::UInt   ## radius is unsigned (nonnegative), by definition
end

    #       P is the precision in bits as a parameter
    #
type ArfFloat{P}
    exponent ::Int
    words_sgn::Int          ## Int, as words is an offset; lsb holds sign of mantissa
    mantissa1::UInt         ## UInt, as each mantissa word is a subspan of mantissa
    mantissa2::UInt         ##   the mantissa words are unsigned (sign is in words_sgn)
end


    #       P is the precision in bits as a parameter
    #
type ArbFloat{P}            ##     ArfFloat{P}
    exponent ::Int          ##        exponent
    words_sgn::Int          ##        words_sgn
    mantissa1::UInt         ##        mantissa1
    mantissa2::UInt         ##        mantissa2
                            ###    ArbMag{P}
    radius_exponent::Int    ####      radius_exponent
    radius_mantissa::UInt   ####      radius_mantissa
end
