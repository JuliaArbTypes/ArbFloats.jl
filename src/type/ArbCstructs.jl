#=
    types that mirror the layout used in Arb
        for the mag, arf, and arb structs
=#


type ArbMag
    radiusExp::Int
    radiusMan::UInt         ## radius is unsigned (nonnegative), by definition
end

    #       P is the precision in bits as a parameter
    #
type ArbArf{P}
    exponent ::Int
    words_sgn::Int          ## Int, as words is an offset; lsb holds sign of mantissa
    mantissa1::UInt         ## UInt, as each mantissa word is a subspan of mantissa
    mantissa2::UInt         ##   the mantissa words are unsigned (sign is in words_sgn)
end


    #       P is the precision in bits as a parameter
    #
type ArbArb{P}              ##     ArbArf{P}
    exponent ::Int          ##        exponent
    words_sgn::Int          ##        words_sgn
    mantissa1::UInt         ##        mantissa1
    mantissa2::UInt         ##        mantissa2
                            ###    ArbMag{P}
    radiusExp::Int          ####      radiusExp
    radiusMan::UInt         ####      radiusMan
end

#= ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: =#

#=
   The mag type used by Arb (fredrikj.net/arb/mag.html)
   The arf type used by Arb (fredrikj.net/arb/arf.html)
   The arb type used by Arb (fredrikj.net/arb/arb.html)
   see also (https://github.com/Nemocas/Nemo.jl/blob/master/src/arb/ArbTypes.jl)
   see also (https://github.com/thofma/Hecke.jl/blob/master/src/Misc/mag.jl)
   see also (https://github.com/thofma/Hecke.jl/blob/master/src/Misc/arf.jl)
   see also (https://github.com/thofma/Hecke.jl/blob/master/src/Misc/arb.jl)
=#

#= ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: =#


#=
   The two mantissa fields in ArbArf, mantissa1 and mantissa2, are 64bit types
      that cover the second part of the arf struct from the Arb C library.
      In the C arf struct, the second part is a discriminated union of
      two other Arb C library structs, one has 2 mp_limb_t (ulong, UInt64) fields
      and one has mp_size_t (long, Int64, and mp_ptr (mp_limb_t*, UInt64) fields.
    The assignation of two 64 bit Julia types to the second part of the ArbArf type
      is in case (UInt64, UInt64) and in the other case (Int64, UInt64).  All source
      code that accesses the first of those two fields must be responsible for the
      handling and any conversion of either a UInt64 mp_limb_t or an Int64 mp_size_t.


      "The last two words hold the value directly if there are at most two limbs,
       and otherwise contain one alloc field (tracking the total number of allocated limbs,
       not all of which might be used) and a pointer to the actual limbs."


typedef slong fmpz;

typedef struct
{
    fmpz num;
    fmpz den;
}
fmpq;


typedef unsigned long mp_limb_t;
typedef long mp_size_t;
typedef unsigned long mp_bitcnt_t;

typedef mp_limb_t *mp_ptr;


#define ulong mp_limb_t
#define slong mp_limb_signed_t

typedef struct
{
    fmpz exp;
    mp_size_t size;
    mantissa_struct d;
}
arf_struct;


typedef union
{
    mantissa_noptr_struct noptr;
    mantissa_ptr_struct ptr;
}
mantissa_struct;

typedef struct
{
    mp_limb_t d[ARF_NOPTR_LIMBS];
}
mantissa_noptr_struct;

typedef struct
{
    mp_size_t alloc;
    mp_ptr d;
}
mantissa_ptr_struct;

=#

#=
    "An arf_struct contains four words:
       an fmpz exponent (exp),
       a size field tracking the number of limbs used
         (one bit of this field is also used for the sign of the number),
       and two more words.
       The last two words hold the value directly if there are at most two limbs,
       and otherwise contain one alloc field
           (tracking the total number of allocated limbs, not all of which might be used)
       and a pointer to the actual limbs.
       Thus, up to 128 bits on a 64-bit machine and 64 bits on a 32-bit machine,
          no space outside of the arf_struct is used."
    -- http://fredrikj.net/arb/arf.html?highlight=arf_struct
=#
