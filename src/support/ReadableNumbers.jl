# module ReadableNumbers

export stringpretty, showpretty

import Base: parse


if VERSION <= v"0.4.999"
   typealias String AbstractString
end

#=
export
  # generating and showing prettier numeric strings
      stringpretty, showpretty,
  # span char: UTF8 char used to separate spans of contiguous digits
      betweenNums , betweenInts , betweenFlts ,
      betweenNums!, betweenInts!, betweenFlts!,
  # span size: the number of contiguous digits used to form a span
      numsSpanned , intsSpanned , fltsSpanned ,
      numsSpanned!, intsSpanned!, fltsSpanned!
=#

# module level control of numeric string formatting (span char, span size)
#   span char and span size are each the only value within a const vector
#   span char and span size are assignable for all parts of numeric strings
#     or they may be assigned to constrain
#        (a) integers & integral part of float strings
#        (b) floats of abs() < 1.0 & the fractional part of float strings

const charBetweenNums = '_'
const lengthOfNumSpan =  3

const ints_spanned = [ lengthOfNumSpan ]; intsSpanned() = ints_spanned[1]
const between_ints = [ charBetweenNums ]; betweenInts() = between_ints[1]
const flts_spanned = [ lengthOfNumSpan ]; fltsSpanned() = flts_spanned[1]
const between_flts = [ charBetweenNums ]; betweenFlts() = between_flts[1]


#  make numeric strings easier to read


stringpretty(val::Signed, group::Int, sep::Char=betweenInts()) =
    prettyInteger(val, group, sep)
stringpretty(val::Signed, sep::Char, group::Int=intsSpanned()) =
    stringpretty(val, group, sep)
function stringpretty(val::Signed)
    group, sep = intsSpanned(), betweenInts()
    stringpretty(val, group, sep)
end

stringpretty{T<:Signed}(val::Rational{T}, group::Int, sep::Char=betweenInts()) =
    string(prettyInteger(val.num, group, sep),"//",prettyInteger(val.den, group, sep))
stringpretty{T<:Signed}(val::Rational{T}, sep::Char, group::Int=intsSpanned()) =
    stringpretty(val, group, sep)
function stringpretty{T<:Signed}(val::Rational{T})
    group, sep = intsSpanned(), betweenInts()
    stringpretty(val, group, sep)
end

stringpretty(val::AbstractFloat,
        intGroup::Int, fracGroup::Int, intSep::Char, fltSep::Char) =
    prettyFloat(val, intGroup, fracGroup, intSep, fltSep)
stringpretty(val::AbstractFloat,
        intGroup::Int, fracGroup::Int, sep::Char=betweenFlts()) =
    stringpretty(val, intGroup, fracGroup, sep, sep)
stringpretty(val::AbstractFloat,
        group::Int, intSep::Char, fltSep::Char) =
    stringpretty(val, group, group, intSep, fltSep)
stringpretty(val::AbstractFloat,
        group::Int, sep::Char=betweenFlts()) =
    stringpretty(val, group, group, sep, sep)
stringpretty(val::AbstractFloat,
        intSep::Char, fltSep::Char, intGroup::Int, fracGroup::Int) =
    stringpretty(val, intGroup, fracGroup, intSep, fltSep)
stringpretty(val::AbstractFloat,
        intSep::Char, fltSep::Char, group::Int) =
    stringpretty(val, group, group, intSep, fltSep)
stringpretty(val::AbstractFloat,
        sep::Char, intGroup::Int, fracGroup::Int) =
    stringpretty(val, intGroup, fracGroup, sep, sep)
stringpretty(val::AbstractFloat,
        sep::Char, group::Int=fltsSpanned()) =
    stringpretty(val, group, group, sep, sep)
function stringpretty(val::AbstractFloat)
    group, sep = fltsSpanned(), betweenFlts()
    stringpretty(val, group, group, sep, sep)
end


function stringpretty(val::Real,
          intGroup::Int, fracGroup::Int, intSep::Char, fltSep::Char)
    if !prettyfiable(val)
       ty = typeof(val)
       throw(ErrorException("type $ty is not supported"))
    end
    prettyFloat(string(val), intGroup, fracGroup, intSep, fltSep)
end
stringpretty(val::Real, intGroup::Int, fracGroup::Int, sep::Char=betweenFlts()) =
    stringpretty(val, intGroup, fracGroup, sep, sep)
stringpretty(val::Real, group::Int, intSep::Char, fltSep::Char) =
    stringpretty(val, group, group, intSep, fltSep)
stringpretty(val::Real, group::Int, sep::Char=betweenFlts()) =
    stringpretty(val, group, group, sep, sep)
stringpretty(val::Real, intSep::Char, fltSep::Char, intGroup::Int, fracGroup::Int) =
    stringpretty(val, intGroup, fracGroup, intSep, fltSep)
stringpretty(val::Real, intSep::Char, fltSep::Char, group::Int) =
    stringpretty(val, group, group, intSep, fltSep)
stringpretty(val::Real, sep::Char, intGroup::Int, fracGroup::Int) =
    stringpretty(val, intGroup, fracGroup, sep, sep)
stringpretty(val::Real, sep::Char, group::Int=fltsSpanned()) =
    stringpretty(val, group, group, sep, sep)
function stringpretty(val::Real)
    group, sep = fltsSpanned(), betweenFlts()
    stringpretty(val, group, group, sep, sep)
end

# show easy-to-read numbers

showpretty(io::IO, val::Signed, group::Int, sep::Char=betweenInts()) =
    print(io, stringpretty(val, group, sep))
showpretty(io::IO, val::Signed, sep::Char, group::Int=intsSpanned()) =
    print(io, stringpretty(val, group, sep))
function showpretty(io::IO, val::Signed)
    group, sep = intsSpanned(), betweenInts()
    print(io, stringpretty(val, group, sep))
end

showpretty{T<:Signed}(io::IO, val::Rational{T}, group::Int, sep::Char=betweenInts()) =
    print(io,prettyInteger(val.num, group, sep),"//",prettyInteger(val.den, group, sep))
showpretty{T<:Signed}(io::IO, val::Rational{T}, sep::Char, group::Int=intsSpanned()) =
    print(io, stringpretty(val, group, sep))
function showpretty{T<:Signed}(io::IO, val::Rational{T})
    group, sep = intsSpanned(), betweenInts()
    print(io, stringpretty(val, group, sep))
end

function showpretty(io::IO, val::AbstractFloat)
    group, sep = fltsSpanned(), betweenFlts()
    print(io, stringpretty(val, group, group, sep, sep))
end
function showpretty(io::IO, val::AbstractFloat, group::Int)
    sep = betweenFlts()
    print(io, stringpretty(val, group, group, sep, sep))
end
function showpretty(io::IO, val::AbstractFloat, sep::Char)
    group = fltsSpanned()
    print(io, stringpretty(val, group, group, sep, sep))
end
showpretty(io::IO, val::AbstractFloat, prettyFormat...) =
    print(io, stringpretty(val, prettyFormat...))



function showpretty(io::IO, val::Real,
          intGroup::Int, fracGroup::Int, intSep::Char, fltSep::Char)
    if !prettyfiable(val)
       ty = typeof(val)
       throw(ErrorException("type $ty is not supported"))
    end
    print(io, stringpretty(val, intGroup, fracGroup, intSep, fltSep))
end
function showpretty(io::IO, val::Real)
    group, sep = fltsSpanned(), betweenFlts()
    showpretty(io, val, group, group, sep, sep)
end
function showpretty(io::IO, val::Real, group::Int)
    sep = betweenFlts()
    showpretty(io, val, group, group, sep, sep)
end
function showpretty(io::IO, val::Real, sep::Char)
    group = fltsSpanned()
    showpretty(io, val, group, group, sep, sep)
end
showpretty(io::IO, val::Real, prettyFormat...) =
    print(io, stringpretty(val, prettyFormat...))


# show on STDOUT


showpretty(val::Signed, group::Int, sep::Char=betweenInts()) =
    showpretty(Base.STDOUT, val, group, sep)
showpretty(val::Signed, sep::Char, group::Int=intsSpanned()) =
    showpretty(Base.STDOUT, val, group, sep)
function showpretty(val::Signed)
    group, sep = intsSpanned(), betweenInts()
    showpretty(Base.STDOUT, val, group, sep)
end

showpretty{T<:Signed}(val::Rational{T}, group::Int, sep::Char=betweenInts()) =
    string(prettyInteger(val.num, group, sep),"//",prettyInteger(val.den, group, sep))
showpretty{T<:Signed}(val::Rational{T}, sep::Char, group::Int=intsSpanned()) =
    showpretty(Base.STDOUT, val, group, sep)
function showpretty{T<:Signed}(val::Rational{T})
    group, sep = intsSpanned(), betweenInts()
    showpretty(Base.STDOUT, val, group, sep)
end

function showpretty(val::AbstractFloat, intGroup::Int, fracGroup::Int, intSep::Char, fltSep::Char)
    showpretty(Base.STDOUT, val, intGroup, fracGroup, intSep, fltSep)
end
showpretty(val::AbstractFloat, group::Int) =
    showpretty(Base.STDOUT, val, group)
showpretty(val::AbstractFloat, sep::Char)  =
    showpretty(Base.STDOUT, val, sep)
showpretty(val::AbstractFloat, prettyFormat...) =
    showpretty(Base.STDOUT, val, prettyFormat...)


function showpretty{T<:Real}(val::T, intGroup::Int, fracGroup::Int, intSep::Char, fltSep::Char)
    if !prettyfiable(val)
       throw(ErrorException("type $T is not supported"))
    end
    showpretty(Base.STDOUT, val, intGroup, fracGroup, intSep, fltSep)
end
showpretty(val::Real, group::Int) =
    showpretty(Base.STDOUT, val, group)
showpretty(val::Real, sep::Char)  =
    showpretty(Base.STDOUT, val, sep)
showpretty(val::Real, prettyFormat...) =
    showpretty(Base.STDOUT, val, prettyFormat...)


# accept integers and floats

prettyInteger{T<:Signed}(val::T, group::Int, span::Char) =
    integerString(string(val), group, span)

prettyFloat{T<:AbstractFloat}(val::T,
  intGroup::Int, fracGroup::Int, intSep::Char, fltSep::Char) =
    prettyFloat(string(val), intGroup, fracGroup, intSep, fltSep)

prettyFloat{T<:AbstractFloat}(val::T,
  intGroup::Int, fracGroup::Int, span::Char) =
    prettyFloat(string(val), intGroup, fracGroup, span, span)

prettyFloat{T<:AbstractFloat}(val::T,
  group::Int, intSep::Char, fltSep::Char) =
    prettyFloat(string(val), group, intSep, fltSep)

prettyFloat{T<:AbstractFloat}(val::T,  group::Int, span::Char) =
    prettyFloat(string(val), group, span, span)

# handle integer and float strings

if VERSION > v"0.4.999"
   splitstr(str::String, at::String) = map(String, split(str, at))
else
   splitstr(str::String, at::String) = map(bytestring, split(str, at))
end

prettyInteger(s::String, group::Int, span::Char) =
    integerString(s, group, span)

function prettyFloat(s::String, intGroup::Int, fracGroup::Int, intSep::Char, fltSep::Char)
    sinteger, sfrac =
        if contains(s,".")
           splitstr(s,".")
        else
           s, ""
        end

    istr = integerString(sinteger, intGroup, intSep)
    if sfrac == ""
       istr
    else
       fstr = fractionalString(sfrac, fracGroup, fltSep)
       string(istr, ".", fstr)
    end
end

prettyFloat(s::String, group::Int, span::Char) =
    prettyFloat(s, group, group, span, span)

prettyFloat(s::String, group::Int, intSep::Char, fltSep::Char) =
    prettyFloat(s, group, group, intSep, fltSep)

prettyFloat(s::String, intGroup::Int, fracGroup::Int, span::Char) =
    prettyFloat(s, intGroup, fracGroup, span, span)

# do the work

function nonnegIntegerString(s::String, group::Int, span::Char)
    n = length(s)
    n==0 && return "0"

    sinteger, sexponentOf2 =
        if contains(s,"e")
           strsplit(s,"e")
        else
           s, ""
        end

    n = length(sinteger)

    fullgroups, finalgroup = divrem(n, group)

    sv = convert(Vector{Char},sinteger)
    p = repeat(" ", n+(fullgroups-1)+(finalgroup!=0))
    pretty = convert(Vector{Char},p)

    sourceidx = n
    targetidx = length(pretty)
    for k in fullgroups:-1:1
        pretty[(targetidx-group+1):targetidx] = sv[(sourceidx-group+1):sourceidx]
        sourceidx -= group
        targetidx -= group
        if k > 1
            pretty[targetidx] = span
            targetidx -= 1
        end
    end

    if finalgroup > 0
        if fullgroups > 0
            pretty[targetidx] = span
            targetidx -= 1
        end
        pretty[(targetidx-finalgroup+1):targetidx] = sv[(sourceidx-finalgroup+1):sourceidx]
    end

    prettystring = convert(String, pretty)

    if length(sexponentOf2) != 0
       string(prettystring,"e",sexponentOf2)
    else
       prettystring
    end
end

function integerString(s::String, group::Int, span::Char)
    if s[1] != '-'
       nonnegIntegerString(s, group, span)
    else
       s1 = string(s[2:end])
       pretty = nonnegIntegerString(s1, group, span)
       string("-", pretty)
    end
end

function fractionalString(s::String, group::Int, span::Char)
    sfrac, sexponentOf2 =
        if contains(s,"e")
           map(String, split(s,"e"))
        else
           s, ""
        end

    pretty = reverse(nonnegIntegerString(reverse(sfrac), group, span))

    if length(sexponentOf2) != 0
       string(pretty,"e",sexponentOf2)
    else
       pretty
    end
end

# get and set shared parameters


function intsSpanned!(n::Int)
    n = max(0,n)
    ints_spanned[1]   = n
    nothing
end
intsSpanned(n::Int) = intsSpanned!(n)

function fltsSpanned!(n::Int)
    n = max(0,n)
    fltsSpanned[1] = n
    nothing
end
fltsSpanned(n::Int) = fltsSpanned!(n)

numsSpanned() = (intsSpanned() == fltsSpanned()) ? intsSpanned() : (intsSpanned(), fltsSpanned())
function numsSpanned!(n::Int)
    n = max(0,n)
    intsSpanned!(n)
    fltsSpanned!(n)
    nothing
end
numsSpanned(n::Int) = numsSpanned!(n)


betweenNums() = (betweenInts() == betweenFlts()) ? betweenInts() : (betweenInts(), betweenFlts())
function betweenNums!(ch::Char)
    betweenFlts!(ch)
    betweenInts!(ch)
    nothing
end
betweenNums!(s::String) = betweenNums!(s[1])
betweenNums(ch::Int)    = betweenNums!(ch)
betweenNums(s::String)  = betweenNums!(s)

function betweenInts!(ch::Char)
    between_ints[1] = ch
    nothing
end
betweenInts(ch::Char)  = betweenInts!(ch)
betweenInts(s::String) = betweenInts!(s[1])

function betweenFlts!(ch::Char)
    between_flts[1] = ch
    nothing
end
betweenFlts(ch::Char)  = betweenFlts!(ch)
betweenFlts(s::String) = betweenFlts!(s[1])

# is this a type that can be handled above
function prettyfiable{T<:Real}(val::T)
    try
        convert(BigFloat,val); true
    catch
        false
    end
end

# parse pretty numeric strings
parse{T<:Union{Signed,AbstractFloat}}(::Type{T}, s::String, ch::Char) =
    parse(T, join(split(s,ch),""))
parse{T<:AbstractFloat}(::Type{T}, s::String, ch1::Char, ch2::Char) =
    parse(T, join(split(s,(ch1,ch2)),""))

# end # module
