function [h, Ra, Nu] = ENChcyl(mat, D, Ts, Tinf)
%[h, Ra, Nu] = ENChcyl(mat, D, Ts, Tinf)
%
%  Description:
%
%    External natural convection over a horizontal cylinder.
%
%  Inputs:
%
%    mat  = mat struct for fluid
%    D    = cylinder diameter
%    Ts   = surface temperature of the cylinder
%    Tinf = fluid temperature
%
%  Outputs:
%
%    h  = heat transfer coefficient
%    Ra = Rayleigh number
%    Nu = Nusselt number
%
%  Reference:
%
%    S.W. Churchill and H.H.S. Chu, "Correlating Equations for Laminar
%      and Turbulent Free Convection from a Horizontal Cylinder," Int. J.
%      Heat Mass Transfer, Vol. 18, pp. 1049-1053, 1975,
%      http://dx.doi.org/10.1016/0017-9310(75)90222-7
%
%==========================================================================

global g  %  Gravity

if D <= 0.0
  error('ENChcyl: Invalid cylinder diameter = %g\n',D)
end

%  Evaluate the fluid properties

Tf = (Ts + Tinf)/2.0;
[k, rho, cp, mu, Pr] = fluidprop(mat, Tf);

[beta] = betaprop(mat, Tinf);

%  Rayleigh number

Ra = (g*rho^2*cp*beta*D^3*(abs(Ts - Tinf)))/(k*mu);

if Ra > 1.0e12
  fprintf('WARNING: ENChcyl - Ra = %g, is out of range: 0 - 1.0e12\n',Ra)
end  

%  Evaluate the heat transfer coefficient

Nu = (0.60 + (0.387*Ra^(1.0/6.0))/(1.0 + (0.559/Pr)^(9.0/16.0))^(8.0/27.0));
h  = (Nu*k)/D;
