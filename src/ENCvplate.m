function [h, Ra, Nu] = ENCvplate(mat, L, Ts, Tinf)
%[h, Ra, Nu] = ENCvplate(mat, L, Ts, Tinf)
%
%  Description:
%
%    External natural convection from a vertical plate.
%
%  Inputs:
%
%    mat  = mat struct for fluid
%    L    = characteristic length, height of the plate
%    Ts   = surface temperature of the plate
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
%    S.W. Churchill and H.H.S. Chu, "Correlating Equations for Laminar and 
%      Turbulent Free Convection from a Vertical Plate," Int. J. Heat Mass 
%      Transfer, Vol. 18, pp. 1323-1329, 1975,
%      http://dx.doi.org/10.1016/0017-9310(75)90243-4
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
%    RJC  12/06/14  0.1.0   Initial release.
%
%==========================================================================

global g  %  Gravity

if L <= 0.0
  error('ENCvplate: Invalid charcteristic length = %g\n',L)
end

%  Evaluate the fluid properties

Tf = (Ts + Tinf)/2.0;
[k, rho, cp, mu, Pr] = fluidprop(mat, Tf);

[beta] = betaprop(mat, Tinf);

%  Rayleigh number

Ra = (g*rho^2*cp*beta*L^3*(abs(Ts - Tinf)))/(k*mu);

if Ra < 1.0E9
  
  Nu = 0.68 + (0.670*Ra^(1/4))/(1 + (0.492/Pr)^(9/16))^(4/9);
  
else
  
  Nu = (0.825 + (0.387*Ra^(1/6))/(1 + (0.492/Pr)^(9/16))^(8/27))^2;
  
end

%  Evaluate the heat transfer coefficient

h  = (Nu*k)/L;
