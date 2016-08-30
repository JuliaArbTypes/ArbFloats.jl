function serialize{T<:ArbFloat}(ser::AbstractSerializer, a::T)
    serialize_type(ser, T)
    write(ser.io, stringall(a))
end

function deserialize{T<:ArbFloat}(ser::AbstractSerializer, ::Type{T})
    T( read(ser.io, String) )
end
