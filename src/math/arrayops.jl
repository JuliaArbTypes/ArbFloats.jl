for (op,dotop) in ((:(+),:(.+)), (:(-),:(.-)), (:(*),:(.*)), (:(/),:(./)))
  @eval begin
      function ($op)(x::ArbFloat{P}, y::Array{ArbFloat{P},1}) where {P}
          return ($dotop)(x, y)
      end
      function ($op)(x::Array{ArbFloat{P},1}, y::ArbFloat{P}) where {P}
          return ($dotop)(x, y)
      end
      function ($op)(x::Array{ArbFloat{P},1}, y::Array{ArbFloat{P},1}) where {P}
          return ($dotop)(x, y)
      end
  end
end
