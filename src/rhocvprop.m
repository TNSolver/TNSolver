function [ rho, cv ] = rhocvprop( mat, T )
%
% Description:
%
%   Evaluate the density and constant volume specific heat material 
%   properties.
%
%==========================================================================

n          = length(T);
rho(1:n,1) = NaN;
cv(1:n,1)  = NaN;

%  Density

switch mat.rhotype
  case 1  %  Constant
    rho(:) = mat.rhodata(2);
  case 2  %  Table - piecewise linear
    rho(:) = interp1(mat.rhodata(:,1), mat.rhodata(:,2), T, 'linear','extrap');
  case 3  %  Monotonic spline
    rho(:) = interp1(mat.rhodata(:,1), mat.rhodata(:,2), T, 'pchip','extrap');
  case 4  %  Polynomial
    rho(:) = polyval(mat.rhodata, T);
end
    
%  Constant volume specific heat

switch mat.cvtype
  case 1  %  Constant
    cv(:) = mat.cvdata(2);
  case 2  %  Table - piecewise linear
    cv(:) = interp1(mat.cvdata(:,1), mat.cvdata(:,2), T, 'linear','extrap');
  case 3  %  Monotonic spline
    cv(:) = interp1(mat.cvdata(:,1), mat.cvdata(:,2), T, 'pchip','extrap');
  case 4  %  Polynomial
    cv(:) = polyval(mat.cvdata, T);
end
