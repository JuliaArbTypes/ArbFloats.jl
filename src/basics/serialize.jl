function serialize(ser::AbstractSerializer, a::T) where {T <: ArbFloat}
    serialize_type(ser, T)
    write(ser.io, stringall(a))
end

function deserialize(ser::AbstractSerializer, ::Type{T}) where {T <: ArbFloat}
    T( read(ser.io, String) )
end
