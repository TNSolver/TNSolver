function [el] = elpre_EFCimpjet(el, mat, Tel)

D   = el.D;
H   = el.H;
U   = el.vel;
r   = el.r;
elT = (Tel(1) + Tel(2))/2.0;   %  Film T
        
[h, Re, Nu]  = EFCimpjet(mat(el.matID), U, D, H, r, elT);
el.h  = h;
el.Re = Re;
el.Nu = Nu;
