function [h, Re, Nu] = EFCdiamond(mat, V, D, Tf)
%[h, Re] = EFCdiamond(mat, V, D, Tf)
%
%  Description:
%
%    External forced convection over a diamond (rotated square).
%
%  Inputs:
%
%    mat = mat struct for fluid
%    V   = fluid velocity
%    D   = cyliner diameter
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
%    Sparrow, E. M., Abrahamb, J. P. and Tonga, J. C. K., "Archival 
%      correlations for average heat transfer coefficients for non-circular
%      and circular cylinders and for spheres in cross-flow," International
%      Journal of Heat and Mass Transfer, V. 47, N. 24, 2004, pp. 5285-5296
%      http://dx.doi.org/10.1016/j.ijheatmasstransfer.2004.06.024
%
%==========================================================================

if D <= 0.0
  error('EFCcyl: Invalid cylinder diameter = %g\n',D)
end

%  Evaluate the fluid properties

[k, rho, cp, mu, Pr] = fluidprop(mat, Tf);

%  Reynolds number

Re = (rho*V*D)/mu;

%  Select correlation coefficients

if Re < 6000.0
  C = 0.304;
  m = 0.59;
  fprintf('WARNING: EFCdiamond - Re = %g, is out of range: 6,000 - 60,000\n',Re)
elseif Re >= 6000.0 && Re <= 60000.0
  C = 0.304;
  m = 0.59;
else
  C = 0.304;
  m = 0.59;
  fprintf('WARNING: EFCdiamond - Re = %g, is out of range: 6,000 - 60,000\n',Re)
end

%  Evaluate the heat transfer coefficient

Nu = C*Re^m*Pr^(1.0/3.0);
h  = (Nu*k)/D;
