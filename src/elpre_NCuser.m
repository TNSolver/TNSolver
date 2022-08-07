function [el] = elpre_NCuser(el, mat, Tel)
        
[h, Ra, Nu]  = el.function(mat(el.matID), Tel(1), Tel(2), el.params);

el.h  = h;
el.Ra = Ra;
el.Nu = Nu;
