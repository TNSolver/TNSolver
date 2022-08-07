function [el, Q] = elpost_conduction(el, Tel)

k    = el.k;
L    = el.L;
Area = el.A;

Q = ((k*Area)/L)*(Tel(1) - Tel(2));
el.Q = Q;
el.U = k/L;
