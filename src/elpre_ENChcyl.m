function [el] = elpre_ENChcyl(el, mat, Tel)

D    = el.D;
Ts   = Tel(1);
Tinf = Tel(2);
        
[h, Ra, Nu]  = ENChcyl(mat(el.matID), D, Ts, Tinf);
el.h  = h;
el.Ra = Ra;
el.Nu = Nu;
