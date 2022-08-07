function [el] = elpre_ENChplateup(el, mat, Tel)

L    = el.L;
Ts   = Tel(1);
Tinf = Tel(2);
        
[h, Ra, Nu]  = ENChplateup(mat(el.matID), L, Ts, Tinf);
el.h  = h;
el.Ra = Ra;
el.Nu = Nu;
