function [h, Re, Nu] = EFCimpjet(mat, V, D, H, r, Tf)
%[h, Re, Nu] = EFCimpjet(mat, V, D, H, r, Tf)
%
%  Description:
%
%    External forced convection - impinging single round jet.
%
%  Inputs:
%
%    mat = mat struct for fluid
%    V   = mean fluid velocity
%    D   = jet diameter
%    H   = distance from jet to surface
%    r   = surface area radius
%    Tf  = film temperature for fluid properties
%
%  Outputs:
%
%    h  = heat transfer coefficient
%    Re = Reynolds number
%    Nu = Nusselt number
%
%  Reference:
%
%    Martin, H., "Heat and Mass Transfer between Impinging Gas Jets and
%      Solid Surfaces," Advances in Heat Transfer, v. 13, pp. 1-60, 1977
%      http://dx.doi.org/10.1016/S0065-2717(08)70221-1
%
%==========================================================================

if D <= 0.0
  error('EFCimpjet: Invalid jet diameter = %g\n',D)
end
if H <= 0.0
  error('EFCimpjet: Invalid jet height = %g\n',H)
end
if H/D < 2.0 || H/D > 12.0
  fprintf('WARNING: EFCimpjet - H/D = %g, is out of range: 2 - 12\n',H/D)
end

%  Evaluate the fluid properties

[k, rho, cp, mu, Pr] = fluidprop(mat, Tf);

%  Reynolds number

Re = (rho*V*D)/mu;
if Re < 2000.0 || Re > 400000.0
  fprintf('WARNING: EFCimpjet - Re = %g, is out of range: 2,000 - 400,000\n',Re)
end

Ar = D^2/(4.0*r^2);
if Ar < 0.004 || Ar > 0.04
  fprintf('WARNING: EFCimpjet - Ar = %g, is out of range: 0.004 - 0.04\n',Ar)
end
G  = 2.0*sqrt(Ar)*(1.0 - 2.2*sqrt(Ar))/(1.0 + 0.2*(H/D - 6.0)*sqrt(Ar));
Nu = G*(2.0*sqrt(Re)*sqrt(1.0 + 0.005*Re^0.55));

h  = (Nu*k)/D;
