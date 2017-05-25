function show{T<:ArbFloat}(io::IO, x::T)
    if isexact(x)
      s = string(midpoint(x))
    else
      s = stringall(x)
      if precision(T) > 128
          s = string(s[1:20],"..",s[(end-10),end])
      end
    end
    print(io, s)
end
show{T<:ArbFloat}(x::T) = show(STDOUT, x)

function showsmall{T<:ArbFloat}(io::IO, x::T)
    s = stringsmall(x)
    print(io, s)
end
showsmall{T<:ArbFloat}(x::T) = showsmall(STDOUT, x)

function showsmall_pm{T<:ArbFloat}(io::IO, x::T)
    s = stringsmall_pm(x)
    print(io, s)
end
showsmall_pm{T<:ArbFloat}(x::T) = showsmall_pm(STDOUT, x)

function showcompact{T<:ArbFloat}(io::IO, x::T)
    s = stringcompact(x)
    print(io, s)
end
showcompact{T<:ArbFloat}(x::T) = showcompact(STDOUT, x)

function showcompact_pm{T<:ArbFloat}(io::IO, x::T)
    s = stringcompact_pm(x)
    print(io, s)
end
showcompact_pm{T<:ArbFloat}(x::T) = showcompact_pm(STDOUT, x)

function showmedium{T<:ArbFloat}(io::IO, x::T)
    s = stringmedium(x)
    print(io, s)
end
showmedium{T<:ArbFloat}(x::T) = showmedium(STDOUT, x)

function show_pm{T<:ArbFloat}(io::IO, x::T)
    s = stringmedium_pm(x)
    print(io, s)
end
show_pm{T<:ArbFloat}(x::T) = show_pm(STDOUT, x)

function showlarge{T<:ArbFloat}(io::IO, x::T)
    s = stringlarge(x)
    print(io, s)
end
showlarge{T<:ArbFloat}(x::T) = showlarge(STDOUT, x)

function showlarge_pm{T<:ArbFloat}(io::IO, x::T)
    s = stringlarge_pm(x)
    print(io, s)
end
showlarge_pm{T<:ArbFloat}(x::T) = showlarge_pm(STDOUT, x)

function showall{T<:ArbFloat}(io::IO, x::T)
    s = stringall(x)
    print(io, s)
end
showall{T<:ArbFloat}(x::T) = showall(STDOUT, x)

function showall_pm{T<:ArbFloat}(io::IO, x::T)
    s = stringall_pm(x)
    print(io, s)
end
showall_pm{T<:ArbFloat}(x::T) = showall_pm(STDOUT, x)

function showallcompact{T<:ArbFloat}(io::IO, x::T)
    s = stringallcompact(x)
    print(io, s)
end
showallcompact{T<:ArbFloat}(x::T) = showallcompact(STDOUT, x)


function showsmart{T<:ArbFloat}(io::IO, x::T)
    s = smartstring(x)
    print(io, s)
end
# showsmart is not a Base show function, it needs explict version without io parameter
showsmart{T<:ArbFloat}(x::T) = showsmart(STDOUT, x)

function showmany{T<:ArbFloat,N}(io::IO, x::NTuple{N,T}, stringformer::Function)
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

showmany{T<:ArbFloat,N}(x::NTuple{N,T}, stringformer::Function) =
   showmany(STDOUT,x,stringformer)


function showmany{T<:ArbFloat}(io::IO, x::Vector{T}, stringformer::Function)
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

showmany{T<:ArbFloat}(x::Vector{T}, stringformer::Function) =
    showmany(STDOUT,x,stringformer)

for (F,S) in [(:showsmall, :stringsmall), (:showcompact, :stringcompact),
              (:show, :stringmedium), (:showlarge, :stringlarge), 
              (:showall, :stringall), (:showsmart, :smartstring)]
  @eval begin
     ($F){P,N}(io::IO, x::NTuple{N,ArbFloat{P}}) = showmany(io, x, $S)
     ($F){P,N}(x::NTuple{N,ArbFloat{P}}) = showmany(STDOUT, x, $S)
     ($F){P}(io::IO, x::Vector{ArbFloat{P}}) = showmany(io, x, $S)
     ($F){P}(x::Vector{ArbFloat{P}}) = showmany(STDOUT, x, $S)
     ($F){P,N}(io::IO, x::Vararg{ArbFloat{P},N}) = showmany(io, x, $S)
     ($F){P,N}(x::Vararg{ArbFloat{P},N}) = showmany(STDOUT, x, $S)
  end
end

for (F,S) in [(:showsmall_pm, :stringsmall_pm), 
              (:showcompact_pm, :stringcompact_pm),
              (:show_pm, :stringmedium_pm), 
              (:showlarge_pm, :stringlarge_pm), 
              (:showall_pm, :stringall_pm)]
  @eval begin
     ($F){P,N}(io::IO, x::NTuple{N,ArbFloat{P}}) = showmany(io, x, $S)
     ($F){P,N}(x::NTuple{N,ArbFloat{P}}) = showmany(STDOUT, x, $S)
     ($F){P}(io::IO, x::Vector{ArbFloat{P}}) = showmany(io, x, $S)
     ($F){P}(x::Vector{ArbFloat{P}}) = showmany(STDOUT, x, $S)
     ($F){P,N}(io::IO, x::Vararg{ArbFloat{P},N}) = showmany(io, x, $S)
     ($F){P,N}(x::Vararg{ArbFloat{P},N}) = showmany(STDOUT, x, $S)
  end
end
