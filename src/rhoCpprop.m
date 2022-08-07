function [ rho, cp ] = rhoCpprop( mat, T )
%
% Description:
%
%   Evaluate the density and specific heat material properties.
%
%==========================================================================

n          = length(T);
rho(1:n,1) = NaN;
cp(1:n,1)  = NaN;

%  Density

switch mat.rhotype
  case 1  %  Constant
    rho(:) = mat.rhodata(2);
  case 2  %  Table - piecewise linear
    rho(:) = interp1(mat.rhodata(:,1), mat.rhodata(:,2), T, 'linear');
  case 3  %  Monotonic spline
    rho(:) = interp1(mat.rhodata(:,1), mat.rhodata(:,2), T, 'pchip');
  case 4  %  Polynomial
    rho(:) = polyval(mat.rhodata, T);
end
    
%  Specific heat

switch mat.cptype
  case 1  %  Constant
    cp(:) = mat.cpdata(2);
  case 2  %  Table - piecewise linear
    cp(:) = interp1(mat.cpdata(:,1), mat.cpdata(:,2), T, 'linear');
  case 3  %  Monotonic spline
    cp(:) = interp1(mat.cpdata(:,1), mat.cpdata(:,2), T, 'pchip');
  case 4  %  Polynomial
    cp(:) = polyval(mat.cpdata, T);
end

