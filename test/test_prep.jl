
#= prepare to test =#

typealias AD15  ArbFloat{50}    # 15 digits
typealias AD30  ArbFloat{100}   # 31 digits
typealias AD100 ArbFloat{333}   # 100 digits
typealias AD300 ArbFloat{997}   # 300 digits

af0 = zero(ArbFloat)
af1 = one(ArbFloat)
af2 = two(ArbFloat)
af3 = three(ArbFloat)
af4 = four(ArbFloat)
afhalf = inv(af2)

#= prepared =#
