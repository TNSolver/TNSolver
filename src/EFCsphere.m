function [h, Re, Nu] = EFCsphere(mat, V, D, Ts, Tf)
%[h, Re, Nu] = EFCsphere(mat, V, D, Ts, Tf)
%
%  Description:
%
%    External forced convection over a sphere.
%
%  Inputs:
%
%    mat = mat struct for fluid
%    V   = fluid velocity
%    D   = sphere diameter
%    Ts  = surface temperature for fluid properties
%    Tf  = fluid temperature for fluid properties
%
%  Outputs:
%
%    h  = heat transfer coefficient
%    Re = Reynolds number
%    Nu = Nusselt number
%
%  Reference:
%
%    Whitaker, S., "Forced convection heat transfer correlations for flow 
%      in pipes, past flat plates, single cylinders, single spheres, and 
%      for flow in packed beds and tube bundles," AIChE Journal, V. 18, 
%      N. 2, pp. 361-371, 1972
%      http://dx.doi.org/10.1002/aic.690180219
%
%==========================================================================

if D <= 0.0
  error('EFCsphere: Invalid sphere diameter = %g\n',D)
end

%  Evaluate the fluid properties

[k, rho, cp, mu_s, Pr] = fluidprop(mat, Ts);
[k, rho, cp, mu, Pr] = fluidprop(mat, Tf);

%  Reynolds number

Re = (rho*V*D)/mu;

if Re < 3.5 || Re > 7.6E4
  fprintf('WARNING: EFCsphere - Re = %g, is out of range: 3.5 - 7.6E4\n',Re)
end

%  Evaluate the heat transfer coefficient

Nu = 2.0 + (0.4*Re^(1/2) + 0.06*Re^(2/3))*Pr^(0.4)*(mu/mu_s)^(1/4);

h  = (Nu*k)/D;
