function [el] = elpre_ENCvplate(el, mat, Tel)

L    = el.L;
Ts   = Tel(1);
Tinf = Tel(2);

[h, Ra, Nu]  = ENCvplate(mat(el.matID), L, Ts, Tinf);
el.h  = h;
el.Ra = Ra;
el.Nu = Nu;
