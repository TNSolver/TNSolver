function [lhs, rhs] = elmat_conduction(el, Tel, rhs)

 k    = el.k;
 L    = el.L;
 Area = el.A;
            
 lhs = (k*Area/L)*[  1.0, -1.0 ;   ...
                    -1.0,  1.0 ];

 rhs = rhs - lhs*Tel;  %  Element residual
