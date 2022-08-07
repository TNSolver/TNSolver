function [lhs, rhs] = elmat_advection(el, Tel, rhs)

cp   = el.cp;
mdot = el.mdot;
        
lhs = cp*[  max(mdot,0.0),   min(mdot,0.0) ;   ...
           -max(mdot,0.0),  -min(mdot,0.0) ];

rhs = rhs - lhs*Tel;
