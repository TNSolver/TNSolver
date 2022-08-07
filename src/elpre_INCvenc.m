function [el] = elpre_INCvenc(el, mat, Tel)

W  = el.W;
H  = el.H;
T1 = Tel(1);
T2 = Tel(2);

[h, Ra, Nu]  = INCvenc(mat(el.matID), W, H, T1, T2);
el.h  = h;
el.Ra = Ra;
el.Nu = Nu;
