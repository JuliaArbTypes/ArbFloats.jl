
# do the work


function a_readable_number(str::String, rns::ReadableNumStyle)
    local integral_part, fractional_part, integral_readable, fractional_readable, readable
    integral_part, fractional_part = split(str, FRACPOINT)[1:2]
    integral_readable = ifelse( integral_part == "", "0", 
                    readable_integer(integral_part, rns.integral_digits_spanned, rns.between_integral_spans) )
    fractional_readable = ifelse( fractional_part == "", "" , 
                    readable_fraction(fractional_part, rns.fractional_digits_spanned, rns.between_fractional_spans) )
    readable = (fractional_part == "") ? integral_readable : string(integral_readable, rns.between_parts, fractional_readable)
    return readable
end    


function readable_nonneg_integer{I<:Integer}(str::String, digits_spanned::I, group_separator::Char)
    n = length(str)
    n==0 && return "0"

    sinteger, sexponent =
        if contains(str,"e")
           split(str,'e')
        else
           str, ""
        end

    n = length(sinteger)

    fullgroups, finalgroup = divrem(n, digits_spanned)

    sv = convert(Vector{Char},sinteger)
    p = repeat(" ", n+(fullgroups-1)+(finalgroup!=0))
    pretty = convert(Vector{Char},p)

    sourceidx = n
    targetidx = length(pretty)
    for k in fullgroups:-1:1
        pretty[(targetidx-digits_spanned+1):targetidx] = sv[(sourceidx-digits_spanned+1):sourceidx]
        sourceidx -= digits_spanned
        targetidx -= digits_spanned
        if k > 1
            pretty[targetidx] = group_separator
            targetidx -= 1
        end
    end

    if finalgroup > 0
        if fullgroups > 0
            pretty[targetidx] = group_separator
            targetidx -= 1
        end
        pretty[(targetidx-finalgroup+1):targetidx] = sv[(sourceidx-finalgroup+1):sourceidx]
    end

    prettystring = convert(String, pretty)

    if length(sexponent) != 0
       string(prettystring,"e",sexponent)
    else
       prettystring
    end
end

function readable_integer{I<:Integer}(str::String, digits_spanned::I, group_separator::Char)
    if str[1] != "-"
       readable_nonneg_integer(str, digits_spanned, group_separator)
    else
       s1 = string(s[2:end])
       integral_readable = readable_nonneg_integer(s1, digits_spanned, group_separator)
       string("-", integral_readable)
    end
end

function readable_fraction{I<:Integer}(str::String, digits_spanned::I, group_separator::Char)
    sfrac, sexponent =
        if contains(str,"e")
           split(str,'e')
        else
           str, ""
        end

    fractional_readable = reverse(readable_nonneg_integer(reverse(sfrac), digits_spanned, group_separator))

    if length(sexponent) != 0
       string(fractional_readable,"e",sexponent)
    else
       fractional_readable
    end
end
