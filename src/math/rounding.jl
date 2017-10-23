#=
#define FMPR_RND_DOWN  0    RoundingMode{:Down}()
#define FMPR_RND_UP    1
#define FMPR_RND_FLOOR 2
#define FMPR_RND_CEIL  3
#define FMPR_RND_NEAR  4
=#

import Base.Rounding: rounding_raw, setrounding_raw, rounding, setrounding;

const ARB_ROUNDING_MODE = Ref{Cint}(0)


to_arb(::RoundingMode{:Nearest}) = Cint(0)
to_arb(::RoundingMode{:ToZero}) = Cint(1)
to_arb(::RoundingMode{:Up}) = Cint(2)
to_arb(::RoundingMode{:Down}) = Cint(3)
to_arb(::RoundingMode{:FromZero}) = Cint(4)

function from_arb(c::Integer)
    if c == 0
        return RoundNearest
    elseif c == 1
        return RoundToZero
    elseif c == 2
        return RoundUp
    elseif c == 3
        return RoundDown
    elseif c == 4
        return RoundFromZero
    else
        throw(ArgumentError("invalid MPFR rounding mode code: $c"))
    end
    RoundingMode(c)
end

rounding_raw(::Type{ArbFloat}) = ARB_ROUNDING_MODE[]
setrounding_raw(::Type{ArbFloat},i::Integer) = ARB_ROUNDING_MODE[] = (Cint)(i)

rounding(::Type{ArbFloat}) = from_arb(rounding_raw(ArbFloat))
setrounding(::Type{ArbFloat},r::RoundingMode) = setrounding_raw(ArbFloat,to_arb(r))

rounding_raw(::Type{ArbFloat{P}}) where {P} = ARB_ROUNDING_MODE[]
setrounding_raw(::Type{ArbFloat{P}},i::Integer) where {P} = ARB_ROUNDING_MODE[] = (Cint)(i)

rounding(::Type{ArbFloat{P}}) where {P} = from_arb(rounding_raw(ArbFloat))
setrounding(::Type{ArbFloat{P}},r::RoundingMode) where {P} = setrounding_raw(ArbFloat,to_arb(r))



