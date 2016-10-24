These results were obtained using BenchmarkTools.jl on one system with the precisions for BigFloats and ArbFloats set as shown, using variables preassigned BigFloat(0.25) or ArbFloat(0.25).  Relative times use the median time reported.

Relative Time = BigFloat_time / ArbFloat_time  
Relative Speedup = abs( (ArbFloat_time-BigFloat_time)/ArbFloat_time )

Precision = 256 bits

|function     | rel. time | rel. speedup   | 
|:------------|:---------:|:--------------:|
| +           |    1.1    |  0          |
| *           |    1.8    |  1           |
| /           |    2.7    |  2           |
| sin         |   10.9    | 10           |
| atan        |   17.7    | 17           |
| exp         |   19.2    | 18           |
| log         |   25.8    | 25           |
| zeta        |   40.5    | 39           |

Precision = 1024 bits

|function     | rel. time | rel. speedup   | 
|:------------|:---------:|:--------------:|
| +           |    2.8    |  2           |
| *           |    4.4    |  3           |
| /           |    7.7    |  7           |
| sin         |   12.7    | 12           |
| exp         |   18.6    | 18           |
| atan        |   68.9    | 68           |
| log         |   69.1    | 68           |
| zeta        |   98.3    | 97           |

Precision = 2048 bits

|function     | rel. time | rel. speedup   | 
|:------------|:---------:|:--------------:|
| +           |    1.8    |  1           |
| *           |    2.5    |  2           |
| sin         |   11.4    | 10           |
| exp         |   21.6    | 21           |
| zeta        |   24.6    | 24           |
| /           |   36.4    | 35           |
| atan        |   64.7    | 64           |
| log         |  141.7    | 141          |

Precision = 3000 bits

|function     | rel. time | rel. speedup   | 
|:------------|:---------:|:--------------:|
| +           |    2.1    |  1             |
| *           |    2.7    |  3           |
| sin         |   12.8    |  12           |
| exp         |   24.7    |  24           |
| zeta        |   29.4    |  28           |
| atan        |   46.5    |  45           |
| /           |   63.2    |  62            |
| log         |  207.5    | 206          |

Precision = 4096 bits (design limit)
 
|function     | rel. time | rel. speedup   | 
|:------------|:---------:|:--------------:|
| sin         |   1.0    | 0           |
| atan        |   1.7    | 1           |
| +           |    2.3    |  1          |
| exp         |   3.5    | 3           |
| *           |    3.8    |  3           |
| log         |   2.8    | 2           |
| zeta        |   26.4    | 25           |
| /           |   147.5    | 146           |



