for (op,dotop) in ((:(+),:(.+)), (:(-),:(.-)), (:(*),:(.*)), (:(/),:(./)))
  @eval begin
      function ($op){P}(x::ArbFloat{P}, y::Array{ArbFloat{P},1})
          return x ($dotop) y
      end
      function ($op){P}(x::Array{ArbFloat{P},1}, y::ArbFloat{P})
          return x ($dotop) y
      end
      function ($op){P}(x::Array{ArbFloat{P},1}, y::Array{ArbFloat{P},1})
          return x ($dotop) y
      end
  end
  end
end
