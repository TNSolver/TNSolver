function [h, Re, Nu] = IFCduct(mat, V, D, Tf)
%[h, Re, Nu] = IFCduct(mat, V, D, Tf)
%
%  Description:
%
%    Internal, fully developed, forced convection in a duct.
%
%  Inputs:
%
%    mat  = mat struct for fluid
%    V    = fluid velocity
%    D    = hydraulic diameter of the duct, 4A/P
%    Tf   = film temperature for fluid properties
%
%  Outputs:
%
%    h  = heat transfer coefficient
%    Re = Reynolds number
%    Nu = Nusselt number
%
%  Reference:
%
%    Gnielinski, V., "On heat transfer in tubes," International Journal of 
%      Heat and Mass Transfer, V. 63, 2013, pp. 134-140
%      http://dx.doi.org/10.1016/j.ijheatmasstransfer.2013.04.015
%    Gnielinski, V., Corrigendum to "On heat transfer in tubes," 
%      International Journal of Heat and Mass Transfer, V. 81, 2015, 
%      p. 638, http://dx.doi.org/10.1016/j.ijheatmasstransfer.2014.10.063
%    Gnielinski, V., "G1: Heat Transfer in Pipe Flow," in VDI Heat Atlas, 
%      Springer, Berlin, 2010
%      http://dx.doi.org/10.1007/978-3-540-77877-6_34
%
%==========================================================================

if D <= 0.0
  error('IFCduct: Invalid hydraulic diameter, D = %g\n',D)
end

%  Evaluate the fluid properties

[k, rho, cp, mu, Pr] = fluidprop(mat, Tf);

if Pr < 0.5 || Pr > 2000
  fprintf('WARNING: IFCduct: Pr = %g, is out of the range 0.5 < Pr < 2000.\n', Pr)
end

%  Reynolds number

Re = (rho*V*D)/mu;

%  Nusselt number correlation

if Re <= 2300           %  Laminar flow
  
  Nu = 3.66;

elseif 2300 < Re < 4000 %  Transition flow

  Nu_lam = 3.66;
  f = (1.8*log10(Re) - 1.5)^-2;  %  friction factor
  Nu_turb = ((f/8)*(Re - 1000)*Pr)/(1 + 12.7*sqrt(f/8)*(Pr^(2/3) - 1));
  gamma = (Re - 2300)/(4000 - 2300);
  Nu = (1 - gamma)*Nu_lam + gamma*Nu_turb;  %  linear interpolate

else                    %  Turbulent flow

  f = (1.8*log10(Re) - 1.5)^-2;  %  friction factor
  Nu = ((f/8)*(Re - 1000)*Pr)/(1 + 12.7*sqrt(f/8)*(Pr^(2/3) - 1));

end

if Re > 5.0E6
  fprintf('WARNING: IFCduct: Re = %g, is greater than 5.0E6.\n', Re)
end  

%  Evaluate the heat transfer coefficient

h  = Nu*k/D;
