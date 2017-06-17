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
isless{ T<:ArbFloat}(a::T, b::T) = succ(a,b)
isequal{T<:ArbFloat}(a::Void, b::T) = false
isequal{T<:ArbFloat}(a::T, b::Void) = false
isless{ T<:ArbFloat}(a::Void, b::T) = true
isless{ T<:ArbFloat}(a::T, b::Void) = true


function max{T<:ArbFloat}(x::T, y::T)
    (isnan(x) || isnan(y)) && return x
    if isinf(x)
       isposinf(x) && return x
       isneginf(x) && return y
    elseif isinf(y)
       isposinf(y) && return y
       isneginf(y) && return x
    end
    return (x + y + abs(x - y))/2
end

function min{T<:ArbFloat}(x::T, y::T)
    (isnan(x) || isnan(y)) && return x
    if isinf(x)
       isposinf(x) && return y
       isneginf(x) && return x
    elseif isinf(y)
       isposinf(y) && return x
       isneginf(y) && return y
    end
    return (x + y - abs(x - y))/2
end
#=
min{T<:ArbFloat}(a::T, b::T) = smartvalue(a) < smartvalue(b) ? a : b
max{T<:ArbFloat}(a::T, b::T) = smartvalue(b) < smartvalue(a) ? a : b

function min2{T<:ArbFloat}(x::T, y::T)
    return
        if donotoverlap(x,y)
            x < y ? x : y
        else
            xlo, xhi = bounds(x)
            ylo, yhi = bounds(y)
            lo,hi = min(xlo, ylo), min(xhi, yhi)
            md = (hi+lo)/2
            rd = (hi-lo)/2
            midpoint_radius(md, rd)
        end
end

function max2{T<:ArbFloat}(x::T, y::T)
    return
        if donotoverlap(x,y)
            return x > y ? x : y
        else
            xlo, xhi = bounds(x)
            ylo, yhi = bounds(y)
            lo,hi = max(xlo, ylo), max(xhi, yhi)
            md = (hi+lo)/2
            rd = (hi-lo)/2
            return midpoint_radius(md, rd)
        end
end
=#
#=
function max{T<:ArbFloat}(x::T, y::T)
    return ((x>=y) | !(y<x)) ? x : y
end
=#

function minmax{T<:ArbFloat}(x::T, y::T)
   return min(x,y), max(x,y) # ((x<=y) | !(y>x)) ? (x,y) : (y,x)
end


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

