
#= prepare to test =#

const AD15  =  ArbFloat{50}    # 15 digits
const AD30  =  ArbFloat{100}   # 31 digits
const AD100 = ArbFloat{333}   # 100 digits
const AD300 = ArbFloat{997}   # 300 digits

af0 = zero(ArbFloat)
af1 = one(ArbFloat)
af2 = two(ArbFloat)
af3 = three(ArbFloat)
af4 = four(ArbFloat)
afhalf = inv(af2)

#= prepared =#
