function [h, Ra, Nu] = ENCiplateup(mat, H, L, theta, Ts, Tinf)
%[h, Ra, Nu] = ENCiplateup(mat, H, L, theta, Ts, Tinf)
%
%  Description:
%
%    External natural convection from the upper surface of an inclined 
%    plate (hot if Ts > Tinf and cold if Ts < Tinf).
%
%  Inputs:
%
%    mat   = mat struct for fluid
%    H     = vertical height length
%    L     = characteristic length, L=A/P
%    theta = angle from vertical, degrees
%    Ts    = surface temperature of the plate
%    Tinf  = fluid temperature
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
%    G. D. Raithby and K. G. T. Hollands, "Natural Convection," Chapter 4
%      in W. M. Rohsenow, J. R. Hartnett and Y. I. Cho, Handbook of 
%      Heat Transfer, McGraw-Hill, New York, third edition, 1998
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
%    RJC  12/08/14  0.1.0   Initial release.
%
%==========================================================================

global g  %  Gravity

if H <= 0.0
  error('ENCiplateup: Invalid charcteristic height, H = %g\n',H)
end
if L <= 0.0
  error('ENCiplateup: Invalid charcteristic length, L = A/P = %g\n',L)
end
if theta < 0 || theta > 90
  error('ENCiplateup: Invalid inclination angle = %g\n',theta)
end  

%  Evaluate the fluid properties

Tf = (Ts + Tinf)/2.0;
[k, rho, cp, mu, Pr] = fluidprop(mat, Tf);

[beta] = betaprop(mat, Tinf);

%--------------------------------------------------------------------------
if Ts < Tinf  %  Stable - cold plate facing up
%--------------------------------------------------------------------------

%  Rayleigh number

  Ra = (g*cosd(theta)*rho^2*cp*beta*H^3*(abs(Ts - Tinf)))/(k*mu);

  if Ra < 1.0E9
  
    Nu = 0.68 + (0.670*Ra^(1/4))/(1 + (0.492/Pr)^(9/16))^(4/9);
  
  else
  
    Nu = (0.825 + (0.387*Ra^(1/6))/(1 + (0.492/Pr)^(9/16))^(8/27))^2;
  
  end
  
%  Evaluate the heat transfer coefficient

  h  = (Nu*k)/H;
  
%--------------------------------------------------------------------------
else  %  Ts > Tinf  Unstable - hot plate facing up  
%--------------------------------------------------------------------------

%  Use Raithby and Hollands approach

%  Rayleigh number - vertical plate

  Rav = (g*cosd(theta)*rho^2*cp*beta*H^3*(abs(Ts - Tinf)))/(k*mu);

  if Rav < 1.0E9
  
    Nuv = 0.68 + (0.670*Rav^(1/4))/(1 + (0.492/Pr)^(9/16))^(4/9);
  
  else
  
    Nuv = (0.825 + (0.387*Rav^(1/6))/(1 + (0.492/Pr)^(9/16))^(8/27))^2;
  
  end
  
%  Evaluate the heat transfer coefficient

  hv  = (Nuv*k)/H;
  
%  Rayleigh number - horizontal plate

  Rah = (g*cosd(90-theta)*rho^2*cp*beta*L^3*(abs(Ts - Tinf)))/(k*mu);

  if Rah < 1.0E4 || Rah > 1.0E11
    fprintf('WARNING: ENCiplateup - Ra_h = %g, is out of range: 1.0E4-1.0e11\n',Rah)
  end

  if Rah < 1.0E7
    Nuh = 0.54*Rah^(1/4);
  else
    Nuh = 0.15*Rah^(1/3);
  end

%  Evaluate the heat transfer coefficient

  hh  = (Nuh*k)/L;

%  Use the maximum of the two

  if hv > hh
    h  = hv;
    Ra = Rav;
    Nu = Nuv;
  else
    h  = hh;
    Ra = Rah;
    Nu = Nuh;
  end
  
end
