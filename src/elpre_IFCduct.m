function [el] = elpre_IFCduct(el, mat, Tel)

D   = el.D;
U   = el.vel;
elT = (Tel(1) + Tel(2))/2.0;   %  Film T
        
[h, Re, Nu]  = IFCduct(mat(el.matID), U, D, elT);
el.h  = h;
el.Re = Re;
el.Nu = Nu;
