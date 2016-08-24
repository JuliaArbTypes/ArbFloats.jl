

# special values

INF{P}(::Type{ArbFloat{P}})     =  ArbFloat{P}("Inf")
NAN{P}(::Type{ArbFloat{P}})     =  ArbFloat{P}("NaN")
POSINF{P}(::Type{ArbFloat{P}})  =  ArbFloat{P}("Inf")
NEGINF{P}(::Type{ArbFloat{P}})  =  ArbFloat{P}("-Inf")
ZERO{P}(::Type{ArbFloat{P}})    =  ArbFloat{P}(0)
ONE{P}(::Type{ArbFloat{P}})     =  ArbFloat{P}(1)
#=
TWO{P}(::Type{ArbFloat{P}})     =  ArbFloat{P}(2)
QRTRPI{P}(::Type{ArbFloat{P}})  =  atan(ArbFloat{P}(1))
PI{P}(::Type{ArbFloat{P}})      =  atan(ArbFloat{P}(1))*4
INVPI{P}(::Type{ArbFloat{P}})   =  ArbFloat{P}( inv(atan(ArbFloat{32+P}(1))*4) )
PHI{P}(::Type{ArbFloat{P}})     =  (sqrt(ArbFloat{P}(5)) + ArbFloat{P}(1)) / ArbFloat{P}(2)
INVPHI{P}(::Type{ArbFloat{P}})  =  (sqrt(ArbFloat{P}(5)) - ArbFloat{P}(1)) / ArbFloat{P}(2)
=#

INF{T<:ArbFloat}(::Type{T})     =  INF(ArbFloat{precision(ArbFloat)})
NAN{T<:ArbFloat}(::Type{T})     =  NAN(ArbFloat{precision(ArbFloat)})
POSINF{T<:ArbFloat}(::Type{T})  =  POSINF(ArbFloat{precision(ArbFloat)})
NEGINF{T<:ArbFloat}(::Type{T})  =  NEGINF(ArbFloat{precision(ArbFloat)})
ZERO{T<:ArbFloat}(::Type{T})    =  ZERO(ArbFloat{precision(ArbFloat)})
ONE{T<:ArbFloat}(::Type{T})     =  ONE(ArbFloat{precision(ArbFloat)})
#=
TWO{T<:ArbFloat}(::Type{T})     =  TWO(ArbFloat{precision(ArbFloat)})
QRTRPI{T<:ArbFloat}(::Type{T})  =  QRTRPI(ArbFloat{precision(ArbFloat)})
PI{T<:ArbFloat}(::Type{T})      =  PI(ArbFloat{precision(ArbFloat)})
PHI{T<:ArbFloat}(::Type{T})     =  PHI(ArbFloat{precision(ArbFloat)})
INVPHI{T<:ArbFloat}(::Type{T})  =  INVPHI(ArbFloat{precision(ArbFloat)})


=#

function PI{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
    ccall(@libarb(arb_const_pi), Void, (Ptr{ArbFloat}, Int), &z, P)
    z
end
PI(::Type{ArbFloat}) = PI(ArbFloat{precision(ArbFloat)})

function SQRTPI{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
    ccall(@libarb(arb_const_sqrt_pi), Void, (Ptr{ArbFloat}, Int), &z, P)
    z
end
SQRTPI(::Type{ArbFloat}) = SQRTPI(ArbFloat{precision(ArbFloat)})

function LOG2{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
    ccall(@libarb(arb_const_log2), Void, (Ptr{ArbFloat}, Int), &z, P)
    z
end
LOG2(::Type{ArbFloat}) = LOG2(ArbFloat{precision(ArbFloat)})

function LOG10{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
    ccall(@libarb(arb_const_log10), Void, (Ptr{ArbFloat}, Int), &z, P)
    z
end
LOG10(::Type{ArbFloat}) = LOG10(ArbFloat{precision(ArbFloat)})

function EXP1{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
    ccall(@libarb(arb_const_e), Void, (Ptr{ArbFloat}, Int), &z, P)
    z
end
EXP1(::Type{ArbFloat}) = EXP1(ArbFloat{precision(ArbFloat)})


function EULER{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
    ccall(@libarb(arb_const_euler), Void, (Ptr{ArbFloat}, Int), &z, P)
    z
end
EULER(::Type{ArbFloat}) = EULER(ArbFloat{precision(ArbFloat)})

function CATALAN{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
    ccall(@libarb(arb_const_catalan), Void, (Ptr{ArbFloat}, Int), &z, P)
    z
end
CATALAN(::Type{ArbFloat}) = CATALAN(ArbFloat{precision(ArbFloat)})

function KINCHIN{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
    ccall(@libarb(arb_const_kinchin), Void, (Ptr{ArbFloat}, Int), &z, P)
    z
end
KHINCHIN(::Type{ArbFloat}) = KINCHIN(ArbFloat{precision(ArbFloat)})

function GLAISHER{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
    ccall(@libarb(arb_const_apery), Void, (Ptr{ArbFloat}, Int), &z, P)
    z
end
GLAISHER(::Type{ArbFloat}) = GLAISHER(ArbFloat{precision(ArbFloat)})

function APERY{P}(::Type{ArbFloat{P}})
    z = ArbFloat{P}()
    ccall(@libarb(arb_const_apery), Void, (Ptr{ArbFloat}, Int), &z, P)
    z
end
APERY(::Type{ArbFloat}) = APERY(ArbFloat{precision(ArbFloat)})

