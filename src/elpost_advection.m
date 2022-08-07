function [el, Q] = elpost_advection(el, Tel)

mdot = el.mdot;
cp   = el.cp;

Q    = (cp*mdot)*(Tel(1) - Tel(2));
el.Q = Q;

el.U = cp*mdot/el.A;
