for (op,dotop) in ((:(+),:(.+)), (:(-),:(.-)), (:(*),:(.*)), (:(/),:(./)))
  @eval begin
      function ($op){P}(x::ArbFloat{P}, y::Array{ArbFloat{P},1})
          x ($dotop) y
      end
      function ($op){P}(x::Array{ArbFloat{P},1}, y::ArbFloat{P})
          x ($dotop) y
      end
  end
end
