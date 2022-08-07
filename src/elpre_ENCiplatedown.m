function [el] = elpre_ENCiplatedown(el, mat, Tel)

H     = el.H;
L     = el.L;
theta = el.theta;
Ts    = Tel(1);
Tinf  = Tel(2);

[h, Ra, Nu]  = ENCiplatedown(mat(el.matID), H, L, theta, Ts, Tinf);
el.h  = h;
el.Ra = Ra;
el.Nu = Nu;
