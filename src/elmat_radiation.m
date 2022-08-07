function [lhs, rhs] = elmat_radiation(el, Tel, rhs)

global sigma

sF    = el.sF;
Area  = el.A;
Ti    = Tel(1);
Tj    = Tel(2);

lhs = (4.0*sigma*sF*Area)*[  Ti^3, -Tj^3 ;   ...
                            -Ti^3,  Tj^3 ];

rhs = (3.0*sigma*sF*Area)*[  Ti^4 - Tj^4 ;   ...
                            -Ti^4 + Tj^4 ]   ...
      - lhs*Tel;  
