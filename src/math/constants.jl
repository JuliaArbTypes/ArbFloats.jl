

# special values

INF(::Type{ArbFloat{P}}) where {P}     =  ArbFloat{P}("Inf")
NAN(::Type{ArbFloat{P}}) where {P}     =  ArbFloat{P}("NaN")
POSINF(::Type{ArbFloat{P}}) where {P}  =  ArbFloat{P}("Inf")
NEGINF(::Type{ArbFloat{P}}) where {P}  =  ArbFloat{P}("-Inf")
ZERO(::Type{ArbFloat{P}}) where {P}    =  ArbFloat{P}(0)
ONE(::Type{ArbFloat{P}}) where {P}     =  ArbFloat{P}(1)
#=
TWO{P}(::Type{ArbFloat{P}})     =  ArbFloat{P}(2)
QRTRPI{P}(::Type{ArbFloat{P}})  =  atan(ArbFloat{P}(1))
PI{P}(::Type{ArbFloat{P}})      =  atan(ArbFloat{P}(1))*4
INVPI{P}(::Type{ArbFloat{P}})   =  ArbFloat{P}( inv(atan(ArbFloat{32+P}(1))*4) )
PHI{P}(::Type{ArbFloat{P}})     =  (sqrt(ArbFloat{P}(5)) + ArbFloat{P}(1)) / ArbFloat{P}(2)
INVPHI{P}(::Type{ArbFloat{P}})  =  (sqrt(ArbFloat{P}(5)) - ArbFloat{P}(1)) / ArbFloat{P}(2)
=#

INF(::Type{T}) where {T <: ArbFloat}     =  INF(ArbFloat{precision(ArbFloat)})
NAN(::Type{T}) where {T <: ArbFloat}     =  NAN(ArbFloat{precision(ArbFloat)})
POSINF(::Type{T}) where {T <: ArbFloat}  =  POSINF(ArbFloat{precision(ArbFloat)})
NEGINF(::Type{T}) where {T <: ArbFloat}  =  NEGINF(ArbFloat{precision(ArbFloat)})
ZERO(::Type{T}) where {T <: ArbFloat}    =  ZERO(ArbFloat{precision(ArbFloat)})
ONE(::Type{T}) where {T <: ArbFloat}     =  ONE(ArbFloat{precision(ArbFloat)})
#=
TWO{T<:ArbFloat}(::Type{T})     =  TWO(ArbFloat{precision(ArbFloat)})
QRTRPI{T<:ArbFloat}(::Type{T})  =  QRTRPI(ArbFloat{precision(ArbFloat)})
PI{T<:ArbFloat}(::Type{T})      =  PI(ArbFloat{precision(ArbFloat)})
PHI{T<:ArbFloat}(::Type{T})     =  PHI(ArbFloat{precision(ArbFloat)})
INVPHI{T<:ArbFloat}(::Type{T})  =  INVPHI(ArbFloat{precision(ArbFloat)})


=#

function PI(::Type{ArbFloat{P}}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_const_pi), Void, (Ptr{ArbFloat}, Int), &z, P)
    return z
end
PI(::Type{ArbFloat}) = PI(ArbFloat{precision(ArbFloat)})

function SQRTPI(::Type{ArbFloat{P}}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_const_sqrt_pi), Void, (Ptr{ArbFloat}, Int), &z, P)
    return z
end
SQRTPI(::Type{ArbFloat}) = SQRTPI(ArbFloat{precision(ArbFloat)})

function LOG2(::Type{ArbFloat{P}}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_const_log2), Void, (Ptr{ArbFloat}, Int), &z, P)
    return z
end
LOG2(::Type{ArbFloat}) = LOG2(ArbFloat{precision(ArbFloat)})

function LOG10(::Type{ArbFloat{P}}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_const_log10), Void, (Ptr{ArbFloat}, Int), &z, P)
    return z
end
LOG10(::Type{ArbFloat}) = LOG10(ArbFloat{precision(ArbFloat)})

function EXP1(::Type{ArbFloat{P}}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_const_e), Void, (Ptr{ArbFloat}, Int), &z, P)
    return z
end
EXP1(::Type{ArbFloat}) = EXP1(ArbFloat{precision(ArbFloat)})


function EULER(::Type{ArbFloat{P}}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_const_euler), Void, (Ptr{ArbFloat}, Int), &z, P)
    return z
end
EULER(::Type{ArbFloat}) = EULER(ArbFloat{precision(ArbFloat)})

function CATALAN(::Type{ArbFloat{P}}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_const_catalan), Void, (Ptr{ArbFloat}, Int), &z, P)
    return z
end
CATALAN(::Type{ArbFloat}) = CATALAN(ArbFloat{precision(ArbFloat)})

function KINCHIN(::Type{ArbFloat{P}}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_const_kinchin), Void, (Ptr{ArbFloat}, Int), &z, P)
    return z
end
KHINCHIN(::Type{ArbFloat}) = KINCHIN(ArbFloat{precision(ArbFloat)})

function GLAISHER(::Type{ArbFloat{P}}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_const_apery), Void, (Ptr{ArbFloat}, Int), &z, P)
    return z
end
GLAISHER(::Type{ArbFloat}) = GLAISHER(ArbFloat{precision(ArbFloat)})

function APERY(::Type{ArbFloat{P}}) where {P}
    z = initializer(ArbFloat{P})
    ccall(@libarb(arb_const_apery), Void, (Ptr{ArbFloat}, Int), &z, P)
    return z
end
APERY(::Type{ArbFloat}) = APERY(ArbFloat{precision(ArbFloat)})

