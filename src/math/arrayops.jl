for (op,dotop) in ((:(+),:(.+)), (:(-),:(.-)), (:(*),:(.*)), (:(/),:(./)))
  @eval begin
      function ($op){P}(x::ArbFloat{P}, y::Array{ArbFloat{P},1})
          return ($dotop)(x, y)
      end
      function ($op){P}(x::Array{ArbFloat{P},1}, y::ArbFloat{P})
          return ($dotop)(x, y)
      end
      function ($op){P}(x::Array{ArbFloat{P},1}, y::Array{ArbFloat{P},1})
          return ($dotop)(x, y)
      end
  end
  end
end
