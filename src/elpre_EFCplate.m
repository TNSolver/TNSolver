function [el] = elpre_EFCplate(el, mat, Tel)

Xbeg = el.xbeg;
Xend = el.xend;
U    = el.vel;
elT  = (Tel(1) + Tel(2))/2.0;   %  Film T
        
[h, Re, Nu]  = EFCplate(mat(el.matID), U, Xbeg, Xend, elT);
el.h  = h;
el.Re = Re;
el.Nu = Nu;
