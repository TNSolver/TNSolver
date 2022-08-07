function [el] = elpre_FCuser(el, mat, Tel)
        
[h, Re, Nu]  = el.function(mat(el.matID), Tel(1), Tel(2), el.params);

el.h  = h;
el.Re = Re;
el.Nu = Nu;
