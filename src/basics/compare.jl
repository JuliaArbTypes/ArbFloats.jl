#=
    We use two sets of infixable comparatives.

    The conventional symbols {==,!=,<,<=,>,>=} are defined using
       the Arb C library's implementation of eq,ne,lt,le,gt,ge.

    The predecessor/successor symbols {≃,≄,≺,≼,≻,≽} are defined from
       Hend Dawood's non-strict total ordering for interval values.
       (q.v. Hend's Master's thesis:
        Interval Mathematics Foundations, Algebraic Structures, and Applications)


=#

for (op,cop) in ((:(==), :(arb_eq)), (:(!=), :(arb_ne)),
                 (:(<=), :(arb_le)), (:(>=), :(arb_ge)),
                 (:(<), :(arb_lt)),  (:(>), :(arb_gt))  )
  @eval begin
    function ($op){T<:ArbFloat}(a::T, b::T)
        return Bool(ccall(@libarb($cop), Cint, (Ptr{T}, Ptr{T}), &a, &b) )
    end
    ($op){P,Q}(a::ArbFloat{P}, b::ArbFloat{Q}) = ($op)(promote(a,b)...)
    ($op){T<:ArbFloat,R<:Real}(a::T, b::R) = ($op)(promote(a,b)...)
    ($op){T<:ArbFloat,R<:Real}(a::R, b::T) = ($op)(promote(a,b)...)
  end
end

function (≃){T<:ArbFloat}(a::T, b::T)
    return Bool(ccall(@libarb(arb_eq), Cint, (Ptr{T}, Ptr{T}), &a, &b))
end
simeq{T<:ArbFloat}(a::T, b::T) = (≃)(a,b)

function (≄){T<:ArbFloat}(a::T, b::T)
    return !Bool(ccall(@libarb(arb_eq), Cint, (Ptr{T}, Ptr{T}), &a, &b))
end
nsime{T<:ArbFloat}(a::T, b::T) = (≄)(a,b)

function (⪰){T<:ArbFloat}(a::T, b::T)
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    return (alo < blo) || ((alo == blo) & (ahi <= bhi))
end
succeq{T<:ArbFloat}(a::T, b::T) = (⪰)(a,b)

function (≻){T<:ArbFloat}(a::T, b::T) # (a ≼ b) & (a ≄ b)
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    return (alo < blo) || ((alo == blo) & (ahi < bhi))
end
succ{T<:ArbFloat}(a::T, b::T) = (≻)(a,b)

function (⪯){T<:ArbFloat}(a::T, b::T)
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    return (alo > blo) || ((alo == blo) & (ahi >= bhi))
end
preceq{T<:ArbFloat}(a::T, b::T) = (⪯)(a,b)

function (≺){T<:ArbFloat}(a::T, b::T)
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    return (alo > blo) || ((alo == blo) & (ahi > bhi))
end
prec{T<:ArbFloat}(a::T, b::T) = (≺)(a,b)


# for sorted ordering
isequal{T<:ArbFloat}(a::T, b::T) = !(a != b)
isless{ T<:ArbFloat}(a::T, b::T) = b == max(a,b) # !(a >= b)
isequal{T<:ArbFloat}(a::Void, b::T) = false
isequal{T<:ArbFloat}(a::T, b::Void) = false
isless{ T<:ArbFloat}(a::Void, b::T) = true
isless{ T<:ArbFloat}(a::T, b::Void) = true



# experimental ≖ ≗
(eq){T<:ArbFloat}(x::T, y::T) = !(x != y)
(eq){P,Q}(x::ArbFloat{P}, y::ArbFloat{Q}) = (eq)(promote(x,y)...)
(eq){T1<:ArbFloat,T2<:Real}(x::T1, y::T2) = (eq)(promote(x,y)...)
(eq){T1<:ArbFloat,T2<:Real}(x::T2, y::T1) = (eq)(promote(x,y)...)
(≗){T<:ArbFloat}(x::T, y::T) = !(x != y)
(≗){P,Q}(x::ArbFloat{P}, y::ArbFloat{Q}) = (≗)(promote(x,y)...)
(≗){T1<:ArbFloat,T2<:Real}(x::T1, y::T2) = (≗)(promote(x,y)...)
(≗){T1<:ArbFloat,T2<:Real}(x::T2, y::T1) = (≗)(promote(x,y)...)
(neq){T<:ArbFloat}(x::T, y::T) = donotoverlap(x, y)
(neq){P,Q}(x::ArbFloat{P}, y::ArbFloat{Q}) = (donotoverlap)(promote(x,y)...)
(neq){T1<:ArbFloat,T2<:Real}(x::T1, y::T2) = (donotoverlap)(promote(x,y)...)
(neq){T1<:ArbFloat,T2<:Real}(x::T2, y::T1) = (donotoverlap)(promote(x,y)...)

