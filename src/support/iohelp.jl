import Base: STDOUT


# show 

function show_readable{T<:Real}(io::IO, x::T)
    str = readable(x)
    print(io, str)
end

function show_readable{T<:Real}(x::T)
    str = readable(x)
    print(STDOUT, str)
end    


# parse readable numeric strings

parse{T<:Union{Signed,AbstractFloat}}(::Type{T}, s::String, ch::Char) =
    parse(T, join(split(s,ch),""))

parse{T<:AbstractFloat}(::Type{T}, s::String, ch1::Char, ch2::Char) =
    parse(T, join(split(s,(ch1,ch2)),""))
