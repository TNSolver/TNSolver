function [el] = elpre_advection(el, mat, Tel)

Area = el.A;
U    = el.vel;
elT  = Tel(1);   %  Use upwind node temperature for properties
if U < 0.0
  elT = Tel(2);
end

[rho, cp]  = rhoCpprop(mat(el.matID), elT);
el.mdot    = rho*U*Area;
el.cp      = cp;
