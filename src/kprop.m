function [ k ] = kprop( mat, T )

n        = length(T);
k(1:n,1) = NaN;

%  Thermal conductivity

switch mat.ktype
  case 1  %  Constant
    k(:) = mat.kdata(2);
  case 2  %  Table - piecewise linear
    k(:) = interp1(mat.kdata(:,1), mat.kdata(:,2), T, 'linear');
  case 3  %  Monotonic spline
    k(:) = interp1(mat.kdata(:,1), mat.kdata(:,2), T, 'pchip');
  case 4  %  Polynomial
    k(:) = polyval(mat.kdata, T);
end

