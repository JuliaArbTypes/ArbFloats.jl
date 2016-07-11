function show{P}(io::IO, x::ArbFloat{P})
    if isexact(x)
      s = string(midpoint(x))
    else
      s = string(x)
    end  
    print(io, s)
end

show{P}(x::ArbFloat{P}) = show(Base.STDOUT, x)

function showcompact{P}(io::IO, x::ArbFloat{P})
    s = stringCompact(x)
    print(io, s)
end

function showall{P}(io::IO, x::ArbFloat{P})
    s = stringAll(x)
    print(io, s)
end

function showallcompact{P}(io::IO, x::ArbFloat{P})
    s = stringAllCompact(x)
    print(io, s)
end


function showsmart{P}(io::IO, x::ArbFloat{P})
    s = smartstring(x)
    print(io, s)
end
# showsmart is not a Base show function, it needs explict version without io parameter
showsmart{P}(x::ArbFloat{P}) = showsmart(Base.STDOUT, x)

function showmany{P,N}(io::IO, x::NTuple{N,ArbFloat{P}}, stringformer::Function)
    if N==0
       print(io,"()")
       return nothing
    elseif N==1
       print(io,string("( ",stringformer(x[1]),", )"))
       return nothing
    end
    
    ss = Vector{String}(N)
    for i in 1:N
      ss[i] = stringformer(x[i])
    end
    
    println(io,string("( ", ss[1], ","));
    for s in ss[2:end-1]
      println(io, string("  ", s, ","))
    end  
    println(io,string("  ", ss[end], " )"))
end

showmany{P,N}(x::NTuple{N,ArbFloat{P}}, stringformer::Function) = 
   showmany(Base.STDOUT,x,stringformer)


function showmany{P}(io::IO, x::Vector{ArbFloat{P}}, stringformer::Function)
    n = length(x)

    if n==0
       print(io,"[]")
       return nothing
    elseif n==1
       print(io,string("[ ",stringformer(x[1])," ]"))
       return nothing
    end
    
    ss = Vector{String}(n)
    for i in 1:n
      ss[i] = stringformer(x[i])
    end
    
    println(io,string("[ ", ss[1], ","));
    for s in ss[2:end-1]
      println(io, string("  ", s, ","))
    end  
    println(io,string("  ", ss[end], " ]"))
end

showmany{P}(x::Vector{ArbFloat{P}}, stringformer::Function) = 
    showmany(Base.STDOUT,x,stringformer)


show{P,N}(io::IO, x::NTuple{N,ArbFloat{P}}) = showmany(io, x, string)
showall{P,N}(io::IO, x::NTuple{N,ArbFloat{P}}) = showmany(io, x, stringAll)
showcompact{P,N}(io::IO, x::NTuple{N,ArbFloat{P}}) = showmany(io, x, stringCompact)
# showsmart is not a Base show function, it needs explict version without io parameter
showsmart{P,N}(io::IO, x::NTuple{N,ArbFloat{P}}) = showmany(io, x, smartstring)
showsmart{P,N}(x::NTuple{N,ArbFloat{P}}) = showmany(Base.STDOUT, x, smartstring)

show{P}(io::IO, x::Vector{ArbFloat{P}}) = showmany(io, x, string)
showall{P}(io::IO, x::Vector{ArbFloat{P}}) = showmany(io, x, stringAll)
showcompact{P}(io::IO, x::Vector{ArbFloat{P}}) = showmany(io, x, stringCompact)
# showsmart is not a Base show function, it needs explict version without io parameter
showsmart{P}(io::IO, x::Vector{ArbFloat{P}}) = showmany(io, x, smartstring)
showsmart{P}(x::Vector{ArbFloat{P}}) = showmany(Base.STDOUT, x, smartstring)

show{P,N}(io::IO, x::Vararg{ArbFloat{P},N}) = showmany(io, x, string)
showall{P,N}(io::IO, x::Vararg{ArbFloat{P},N}) = showmany(io, x, stringAll)
showcompact{P,N}(io::IO, x::Vararg{ArbFloat{P},N}) = showmany(io, x, stringCompact)
# showsmart is not a Base show function, it needs explict version without io parameter
showsmart{P,N}(io::IO, x::Vararg{ArbFloat{P},N}) = showmany(io, x, smartstring)
showsmart{P,N}(x::Vararg{ArbFloat{P},N}) = showmany(Base.STDOUT, x, smartstring)

