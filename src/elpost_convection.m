function [el, Q] = elpost_convection(el, Tel)

h    = el.h;
Area = el.A;

Q = (h*Area)*(Tel(1) - Tel(2));
el.Q = Q;
el.U = h;
