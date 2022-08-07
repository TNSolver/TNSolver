function [h, Re, Nu] = EFCcyl(mat, V, D, Tf)
%[h, Re] = EFCcyl(mat, V, D, Tf)
%
%  Description:
%
%    External forced convection over a cylinder.
%
%  Inputs:
%
%    mat = mat struct for fluid
%    V   = fluid velocity
%    D   = cylinder diameter
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
%    Hilpert, R., "Wärmeabgabe von geheizten Drähten und Rohren im 
%      Luftstrom," Forschung im Ingenieurwesens, V. 4, N. 5, pp. 215-224,
%      1933
%      http://dx.doi.org/10.1007/BF02719754
%    Knudsen, J. G. and Katz, D. L., Fluid Dynamics and Heat Transfer,
%      McGraw-Hill, New York, pp. 504-506, 1958
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

if Re < 0.4
  C = 0.989;
  m = 0.330;
  fprintf('WARNING: EFCcyl - Re = %g, is out of range: 0.4 - 400,000\n',Re)
elseif Re <= 0.4 && Re <= 4.0
  C = 0.989;
  m = 0.330;
elseif Re > 4.0 && Re <= 40.0  
  C = 0.911;
  m = 0.385;
elseif Re > 40.0 && Re <= 4000.0  
  C = 0.683;
  m = 0.466;
elseif Re > 4000.0 && Re <= 40000.0  
  C = 0.193;
  m = 0.618;
elseif Re > 40000.0 && Re <= 400000.0  
  C = 0.027;
  m = 0.805;
else
  C = 0.027;
  m = 0.805;
  fprintf('WARNING: EFCcyl - Re = %g, is out of range: 0.4 - 400,000\n',Re)
end

%  Evaluate the heat transfer coefficient

Nu = C*Re^m*Pr^(1.0/3.0);
h  = (Nu*k)/D;
