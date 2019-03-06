function show(io::IO, x::T) where {T <: ArbFloat}
    if isfinite(x) && isexact(x)
       s = string(midpoint(x))
    else
       s = string(x)
    end    
    dots = (isfinite(x) && !isexact(x)) ? ".." : ""
    print(io, string(s, dots))
end
show(x::T) where {T <: ArbFloat} = show(STDOUT, x)

function showsmall(io::IO, x::T) where {T <: ArbFloat}
    s = stringsmall(x)
    print(io, s)
end
showsmall(x::T) where {T <: ArbFloat} = showsmall(STDOUT, x)

function showsmall_pm(io::IO, x::T) where {T <: ArbFloat}
    s = stringsmall_pm(x)
    print(io, s)
end
showsmall_pm(x::T) where {T <: ArbFloat} = showsmall_pm(STDOUT, x)

function showcompact(io::IO, x::T) where {T <: ArbFloat}
    s = stringcompact(x)
    print(io, s)
end
showcompact(x::T) where {T <: ArbFloat} = showcompact(STDOUT, x)

function showcompact_pm(io::IO, x::T) where {T <: ArbFloat}
    s = stringcompact_pm(x)
    print(io, s)
end
showcompact_pm(x::T) where {T <: ArbFloat} = showcompact_pm(STDOUT, x)

function showmedium(io::IO, x::T) where {T <: ArbFloat}
    s = stringmedium(x)
    print(io, s)
end
showmedium(x::T) where {T <: ArbFloat} = showmedium(STDOUT, x)

function show_pm(io::IO, x::T) where {T <: ArbFloat}
    s = stringmedium_pm(x)
    print(io, s)
end
show_pm(x::T) where {T <: ArbFloat} = show_pm(STDOUT, x)

function showlarge(io::IO, x::T) where {T <: ArbFloat}
    s = stringlarge(x)
    print(io, s)
end
showlarge(x::T) where {T <: ArbFloat} = showlarge(STDOUT, x)

function showlarge_pm(io::IO, x::T) where {T <: ArbFloat}
    s = stringlarge_pm(x)
    print(io, s)
end
showlarge_pm(x::T) where {T <: ArbFloat} = showlarge_pm(STDOUT, x)

function showall(io::IO, x::T) where {T <: ArbFloat}
    s = stringall(x)
    print(io, s)
end
showall(x::T) where {T <: ArbFloat} = showall(STDOUT, x)

function showall_pm(io::IO, x::T) where {T <: ArbFloat}
    s = stringall_pm(x)
    print(io, s)
end
showall_pm(x::T) where {T <: ArbFloat} = showall_pm(STDOUT, x)

function showallcompact(io::IO, x::T) where {T <: ArbFloat}
    s = stringallcompact(x)
    print(io, s)
end
showallcompact(x::T) where {T <: ArbFloat} = showallcompact(STDOUT, x)


function showsmart(io::IO, x::T) where {T <: ArbFloat}
    s = smartstring(x)
    print(io, s)
end
# showsmart is not a Base show function, it needs explict version without io parameter
showsmart(x::T) where {T <: ArbFloat} = showsmart(STDOUT, x)

function showmany(io::IO, x::NTuple{N,T}, stringformer::Function) where {T <: ArbFloat,N}
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

showmany(x::NTuple{N,T}, stringformer::Function) where {T <: ArbFloat,N} =
   showmany(STDOUT,x,stringformer)


function showmany(io::IO, x::Vector{T}, stringformer::Function) where {T <: ArbFloat}
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

showmany(x::Vector{T}, stringformer::Function) where {T <: ArbFloat} =
    showmany(STDOUT,x,stringformer)

for (F,S) in [(:showsmall, :stringsmall), (:showcompact, :stringcompact),
              (:show, :stringmedium), (:showlarge, :stringlarge), 
              (:showall, :stringall), (:showsmart, :smartstring)]
  @eval begin
     ($F)(io::IO, x::NTuple{N,ArbFloat{P}}) where {P,N} = showmany(io, x, $S)
     ($F)(x::NTuple{N,ArbFloat{P}}) where {P,N} = showmany(STDOUT, x, $S)
     ($F)(io::IO, x::Vector{ArbFloat{P}}) where {P} = showmany(io, x, $S)
     ($F)(x::Vector{ArbFloat{P}}) where {P} = showmany(STDOUT, x, $S)
     ($F)(io::IO, x::Vararg{ArbFloat{P},N}) where {P,N} = showmany(io, x, $S)
     ($F)(x::Vararg{ArbFloat{P},N}) where {P,N} = showmany(STDOUT, x, $S)
  end
end

for (F,S) in [(:showsmall_pm, :stringsmall_pm), 
              (:showcompact_pm, :stringcompact_pm),
              (:show_pm, :stringmedium_pm), 
              (:showlarge_pm, :stringlarge_pm), 
              (:showall_pm, :stringall_pm)]
  @eval begin
     ($F)(io::IO, x::NTuple{N,ArbFloat{P}}) where {P,N} = showmany(io, x, $S)
     ($F)(x::NTuple{N,ArbFloat{P}}) where {P,N} = showmany(STDOUT, x, $S)
     ($F)(io::IO, x::Vector{ArbFloat{P}}) where {P} = showmany(io, x, $S)
     ($F)(x::Vector{ArbFloat{P}}) where {P} = showmany(STDOUT, x, $S)
     ($F)(io::IO, x::Vararg{ArbFloat{P},N}) where {P,N} = showmany(io, x, $S)
     ($F)(x::Vararg{ArbFloat{P},N}) where {P,N} = showmany(STDOUT, x, $S)
  end
end
