function [lhs, rhs] = elmat_convection(el, Tel, rhs)

 h    = el.h;
 Area = el.A;
            
 lhs = (h*Area)*[  1.0, -1.0 ;   ...
                  -1.0,  1.0 ];

 rhs = rhs - lhs*Tel;  %  Element residual
