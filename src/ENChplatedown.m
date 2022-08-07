function [h, Ra, Nu] = ENChplatedown(mat, L, Ts, Tinf)
%[h, Ra, Nu] = ENChplatedown(mat, L, Ts, Tinf)
%
%  Description:
%
%    External natural convection over the lower surface of a horizontal
%    plate (hot if Ts > Tinf and cold if Ts < Tinf)
%
%  Inputs:
%
%    mat  = mat struct for fluid
%    L    = characteristic length, (area of the plate)/perimeter = A/P
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
%    J. R. Lloyd and W. R. Moran, "Natural Convection Adjacent to 
%      Horizontal Surface of Various Planforms," J. Heat Transfer, vol. 96,
%      no. 4, pp. 443-447, Nov 01, 1974,
%      http://dx.doi.org/10.1115/1.3450224
%
%    E. Radziemska and W. M. Lewandowski, "Heat transfer by natural 
%      convection from an isothermal downward-facing round plate in 
%      unlimited space," Applied Energy, vol. 68, no. 4, April 2001, 
%      pp. 347–366, http://dx.doi.org/10.1016/S0306-2619(00)00061-1
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
%    RJC  11/23/14  0.1.0   Initial release.
%
%==========================================================================

global g  %  Gravity

if L <= 0.0
  error('ENChplatedown: Invalid charcteristic length = %g\n',L)
end

%  Evaluate the fluid properties

Tf = (Ts + Tinf)/2.0;
[k, rho, cp, mu, Pr] = fluidprop(mat, Tf);

if Pr < 0.7
    fprintf('WARNING: ENChplatedown - Pr = %g, is below 0.7\n',Pr)
end

[beta] = betaprop(mat, Tinf);

%  Rayleigh number

Ra = (g*rho^2*cp*beta*L^3*(abs(Ts - Tinf)))/(k*mu);

if Ts <= Tinf  %  Cold plate facing down
  
  if Ra < 1.0E4 || Ra > 1.0E11
    fprintf('WARNING: ENChplatedown - Ra = %g, is out of range: 1.0E4 - 1.0e11\n',Ra)
  end

  if Ra < 1.0E7
    Nu = 0.54*Ra^(1/4);
  else
    Nu = 0.15*Ra^(1/3);
  end

else  %  Hot plate facing down
  
  if Ra < 1.0E4 || Ra > 1.0E9
    fprintf('WARNING: ENChplatedown - Ra = %g, is out of range: 1.0E4 - 1.0e9\n',Ra)
  end

  Nu = 0.52*Ra^(1/5);
  
end

%  Evaluate the heat transfer coefficient

h  = (Nu*k)/L;
