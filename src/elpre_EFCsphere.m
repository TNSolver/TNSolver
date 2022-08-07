function [el] = elpre_EFCsphere(el, mat, Tel)

D   = el.D;
U   = el.vel;
        
[h, Re, Nu]  = EFCsphere(mat(el.matID), U, D, Tel(1), Tel(2));
el.h  = h;
el.Re = Re;
el.Nu = Nu;
