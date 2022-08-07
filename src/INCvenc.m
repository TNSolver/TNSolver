function [h, Ra, Nu] = INCvenc(mat, W, H, T1, T2)
%[h, Ra, Nu] = ENCvenc(mat, W, H, T1, T2)
%
%  Description:
%
%    Internal natural convection in a vertical, rectangular enclosure.
%
%  Inputs:
%
%    mat = mat struct for fluid
%    W   = width of the enclosure
%    H   = height of the enclosure
%    T1  = surface temperature one side
%    T2  = surface temperature of the other side
%
%  Outputs:
%
%    h  = heat transfer coefficient
%    Ra = Rayleigh number
%    Nu = Nusselt number
%
%  Reference:
%
%    [Cat78] I. Catton, "Natural Convection in Enclosures," Proceedings of
%            the 6th International Heat Transfer Conference, Toronto, 
%            Canada, Vol. 6, p. 13-31, 1978
%    [ME69] R. K. MacGregor and A. F. Emery, "Free Convection Through 
%           Vertical Plane Layers - Moderate and High Prandtl Number 
%           Fluids," J. Heat Transfer, Vol. 91, Num. 3, p. 391-401, 1969
%           http://dx.doi.org/10.1115/1.3580194
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
%    RJC  06/06/16  0.1.0   Initial release.
%
%==========================================================================

global g  %  Gravity

if H <= 0.0
  error('INCvenc: Invalid height, H = %g\n',H)
end
if W <= 0.0
  error('INCvenc: Invalid width, W = %g\n',W)
end

%  Evaluate the fluid properties

Tf = (T1 + T2)/2.0;
[k, rho, cp, mu, Pr] = fluidprop(mat, Tf);

[beta] = betaprop(mat, Tf);

%  Rayleigh number

Ra = (g*rho^2*cp*beta*W^3*(abs(T1 - T2)))/(k*mu);

AR = H/W;  %  Aspect ratio of the vertical enclosure
if AR >= 1 && AR <= 2  %  [Cat78] Correlation
  RaPr = (Ra*Pr)/(0.2 + Pr);
  Nu = 0.18*(RaPr)^0.29;
  if Ra*Pr <= 1.0e3
    fprintf('WARNING: INCvenc - Ra*Pr/(0.2 + Pr) = %g, is less than 10^3.\n',RaPr)
  end
elseif AR > 2 && AR <= 10  %  [Cat78] Correlation
  RaPr = (Ra*Pr)/(0.2 + Pr);
  Nu = 0.22*(RaPr^0.28)/(AR)^0.25;
  if Ra <= 1.0e3 || Ra >= 1.0e10
    fprintf('WARNING: INCvenc - Ra number = %g, out of range for aspect ratio, H/W = %g\n',Ra,AR)
  end
else   %  [ME69] Correlation
  Nu = 0.42*Ra^0.25*Pr^0.012*AR^-0.3;
  if AR > 40
    fprintf('WARNING: INCvenc - Aspect ratio, H/W = %g\n, is greater than 40.\n',AR)
  end
  if Ra < 1.0e4 || Ra > 1.0e7
    fprintf('WARNING: INCvenc - Ra number = %g, out of range for aspect ratio, H/W = %g\n',Ra,AR)
  end
end  

%  Evaluate the heat transfer coefficient

h  = (Nu*k)/W;
