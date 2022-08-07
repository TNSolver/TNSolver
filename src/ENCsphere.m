function [h, Ra, Nu] = ENCsphere(mat, D, Ts, Tinf)
%[h, Ra, Nu] = ENCsphere(mat, D, Ts, Tinf)
%
%  Description:
%
%    External natural convection from a sphere.
%
%  Inputs:
%
%    mat  = mat struct for fluid
%    D    = characteristic length, diameter of the sphere
%    Ts   = surface temperature of the sphere
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
%    Equation (9.35), p. 585 in [BLID11]
%
%    Churchill, S.W., "Free Convection Around Immersed Bodies," in
%      G.F. Hewitt, Editor, Heat Exchanger Design Handbook, Section 2.5.7,
%      Begell House, New York, 2002
%
%  Contact:
%
%    Bob Cochran
%    Applied CHT
%    rjc@heattransfer.org
%
%  History:
%
%    Who    Date   Version  Note
%    ---  -------- -------  -----------------------------------------------
%    RJC  10/20/15  0.1.0   Initial release.
%
%==========================================================================

global g  %  Gravity

if D <= 0.0
  error('ENCsphere: Invalid charcteristic length = %g\n',D)
end

%  Evaluate the fluid properties

Tf = (Ts + Tinf)/2.0;
[k, rho, cp, mu, Pr] = fluidprop(mat, Tf);

[beta] = betaprop(mat, Tinf);

%  Rayleigh number

Ra = (g*rho^2*cp*beta*D^3*(abs(Ts - Tinf)))/(k*mu);

Nu = 2.0 + (0.589*Ra^(1/4))/((1.0 + (0.469/Pr)^(9/16))^(4/9));

if Ra > 1.0E11
  
  fprintf('WARNING: ENCsphere - Ra = %g, is out of range: 0 - 1.0e11\n',Ra)
  
end

%  Evaluate the heat transfer coefficient

h  = (Nu*k)/D;
