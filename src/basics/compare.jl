# adapted from Nemo
function (>){P}(x::ArbFloat{P}, y::ArbFloat{P})
    return Bool(ccall(@libarb(arb_gt), Cint, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y))
end
function (>=){P}(x::ArbFloat{P}, y::ArbFloat{P})
    return Bool(ccall(@libarb(arb_ge), Cint, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y))
end
function (<){P}(x::ArbFloat{P}, y::ArbFloat{P})
    return Bool(ccall(@libarb(arb_lt), Cint, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y))
end
function (<=){P}(x::ArbFloat{P}, y::ArbFloat{P})
    return Bool(ccall(@libarb(arb_le), Cint, (Ptr{ArbFloat{P}}, Ptr{ArbFloat{P}}), &x, &y))
end

for F in (:(==), :(!=), :(<), :(<=), :(>=), :(>), :(isless), :(isequal))
  @eval ($F){P,Q}(x::ArbFloat{P}, y::ArbFloat{Q}) = ($F)(promote(x,y)...)
end

(==){R<:Real,P}(x::ArbFloat{P}, y::R) = x == ArbFloat{P}(y)
(!=){R<:Real,P}(x::ArbFloat{P}, y::R) = x != ArbFloat{P}(y)
(<=){R<:Real,P}(x::ArbFloat{P}, y::R) = x <= ArbFloat{P}(y)
(>=){R<:Real,P}(x::ArbFloat{P}, y::R) = x >= ArbFloat{P}(y)
(<){R<:Real,P}(x::ArbFloat{P}, y::R) = x < ArbFloat{P}(y)
(>){R<:Real,P}(x::ArbFloat{P}, y::R) = x > ArbFloat{P}(y)

(==){R<:Real,P}(x::R, y::ArbFloat{P}) = ArbFloat{P}(x) == y
(!=){R<:Real,P}(x::R, y::ArbFloat{P}) = ArbFloat{P}(x) != y
(<=){R<:Real,P}(x::R, y::ArbFloat{P}) = ArbFloat{P}(x) <= y
(>=){R<:Real,P}(x::R, y::ArbFloat{P}) = ArbFloat{P}(x) >= y
(<){R<:Real,P}(x::R, y::ArbFloat{P}) = ArbFloat{P}(x) < y
(>){R<:Real,P}(x::R, y::ArbFloat{P}) = ArbFloat{P}(x) > y

# see predicates.jl for isequal{P}(x::ArbFloat{P}, y::ArbFloat{P})
isless{P}(x::ArbFloat{P}, y::ArbFloat{P}) = (x<y)
