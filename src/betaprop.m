function [ beta ] = betaprop( mat, T )
%
%  Evaluate the material properties
%
%==========================================================================

n = length(T);
beta(1:n,1) = NaN;

%  Thermal expansion coefficient

switch mat.betatype
  case 1  %  Constant
    beta(:) = mat.betadata(2);
  case 2  %  Table - piecewise linear
    T = max(mat.betadata(1,1),T);
    T = min(mat.betadata(end,1),T);
    beta(:) = interp1(mat.betadata(:,1), mat.betadata(:,2), T, 'linear');
  case 3  %  Monotonic spline
    T = max(mat.betadata(1,1),T);
    T = min(mat.betadata(end,1),T);
    beta(:) = interp1(mat.betadata(:,1), mat.betadata(:,2), T, 'pchip');
  case 4  %  Polynomial
    beta(:) = polyval(mat.betadata, T);
end
