__precompile__(true)

module ReadableNumbers

#=
    generating and showing prettier numeric strings
=#     

export ReadableNumStyle, readable, show_readable 

import Base: STDOUT, parse


if typeof(Base.split("a","b")[1]) == SubString{String}
    split(str::String, sep::Char=" ") = map(String, Base.split(str, sep))  # do not work with SubStrings
end    

# determine locale convention for the fractional (decimal) point
const LOCALE_STR = string( 1.5 )
const FRACPOINT  = LOCALE_STR[ nextind(LOCALE_STR, 1) ]

include("type.jl")
include("dothework.jl")
include("iohelp.jl")


end # module
