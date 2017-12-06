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
    function ($op)(a::T, b::T) where {T <: ArbFloat}
        return Bool(ccall(@libarb($cop), Cint, (Ref{T}, Ref{T}), a, b) )
    end
    ($op)(a::ArbFloat{P}, b::ArbFloat{Q}) where {P,Q} = ($op)(promote(a,b)...)
    ($op)(a::T, b::R) where {T <: ArbFloat,R <: Real} = ($op)(promote(a,b)...)
    ($op)(a::R, b::T) where {T <: ArbFloat,R <: Real} = ($op)(promote(a,b)...)
  end
end

function (≃)(a::T, b::T) where {T <: ArbFloat}
    return Bool(ccall(@libarb(arb_eq), Cint, (Ref{T}, Ref{T}), a, b))
end
simeq(a::T, b::T) where {T <: ArbFloat} = (≃)(a,b)

function (≄)(a::T, b::T) where {T <: ArbFloat}
    return !Bool(ccall(@libarb(arb_eq), Cint, (Ref{T}, Ref{T}), a, b))
end
nsime(a::T, b::T) where {T <: ArbFloat} = (≄)(a,b)

function (⪰)(a::T, b::T) where {T <: ArbFloat}
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    return (alo < blo) || ((alo == blo) & (ahi <= bhi))
end
succeq(a::T, b::T) where {T <: ArbFloat} = (⪰)(a,b)

function (≻)(a::T, b::T) where {T <: ArbFloat} # (a ≼ b) & (a ≄ b)
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    return (alo < blo) || ((alo == blo) & (ahi < bhi))
end
succ(a::T, b::T) where {T <: ArbFloat} = (≻)(a,b)

function (⪯)(a::T, b::T) where {T <: ArbFloat}
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    return (alo > blo) || ((alo == blo) & (ahi >= bhi))
end
preceq(a::T, b::T) where {T <: ArbFloat} = (⪯)(a,b)

function (≺)(a::T, b::T) where {T <: ArbFloat}
    alo, ahi = bounds(a)
    blo, bhi = bounds(b)
    return (alo > blo) || ((alo == blo) & (ahi > bhi))
end
prec(a::T, b::T) where {T <: ArbFloat} = (≺)(a,b)


# for sorted ordering
isequal(a::T, b::T) where {T <: ArbFloat} = !(a != b)
isless(a::T, b::T) where {T <: ArbFloat} = succ(a,b)
isequal(a::Void, b::T) where {T <: ArbFloat} = false
isequal(a::T, b::Void) where {T <: ArbFloat} = false
isless(a::Void, b::T) where {T <: ArbFloat} = true
isless(a::T, b::Void) where {T <: ArbFloat} = true


function max(x::T, y::T) where {T <: ArbFloat}
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

function min(x::T, y::T) where {T <: ArbFloat}
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

function minmax(x::T, y::T) where {T <: ArbFloat}
   return min(x,y), max(x,y) # ((x<=y) | !(y>x)) ? (x,y) : (y,x)
end


# experimental ≖ ≗
(eq)(x::T, y::T) where {T <: ArbFloat} = !(x != y)
(eq)(x::ArbFloat{P}, y::ArbFloat{Q}) where {P,Q} = (eq)(promote(x,y)...)
(eq)(x::T1, y::T2) where {T1 <: ArbFloat,T2 <: Real} = (eq)(promote(x,y)...)
(eq)(x::T2, y::T1) where {T1 <: ArbFloat,T2 <: Real} = (eq)(promote(x,y)...)
(≗)(x::T, y::T) where {T <: ArbFloat} = !(x != y)
(≗)(x::ArbFloat{P}, y::ArbFloat{Q}) where {P,Q} = (≗)(promote(x,y)...)
(≗)(x::T1, y::T2) where {T1 <: ArbFloat,T2 <: Real} = (≗)(promote(x,y)...)
(≗)(x::T2, y::T1) where {T1 <: ArbFloat,T2 <: Real} = (≗)(promote(x,y)...)
(neq)(x::T, y::T) where {T <: ArbFloat} = donotoverlap(x, y)
(neq)(x::ArbFloat{P}, y::ArbFloat{Q}) where {P,Q} = (donotoverlap)(promote(x,y)...)
(neq)(x::T1, y::T2) where {T1 <: ArbFloat,T2 <: Real} = (donotoverlap)(promote(x,y)...)
(neq)(x::T2, y::T1) where {T1 <: ArbFloat,T2 <: Real} = (donotoverlap)(promote(x,y)...)

