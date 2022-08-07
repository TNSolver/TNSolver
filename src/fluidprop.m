function [ k, rho, cp, mu, Pr ] = fluidprop( mat, T )
%
%  Evaluate the material properties
%
%==========================================================================

n = length(T);
k(1:n,1)    = NaN;
rho(1:n,1)  = NaN;
cp(1:n,1)   = NaN;
mu(1:n,1)   = NaN;
beta(1:n,1) = NaN;
Pr(1:n,1)   = NaN;

%  Thermal conductivity

switch mat.ktype
  case 1  %  Constant
    k(:) = mat.kdata(2);
  case 2  %  Table - piecewise linear
    T = max(mat.kdata(1,1),T);
    T = min(mat.kdata(end,1),T);
    k(:) = interp1(mat.kdata(:,1), mat.kdata(:,2), T, 'linear');
  case 3  %  Monotonic spline
    T = max(mat.kdata(1,1),T);
    T = min(mat.kdata(end,1),T);
    k(:) = interp1(mat.kdata(:,1), mat.kdata(:,2), T, 'pchip');
  case 4  %  Polynomial
    k(:) = polyval(mat.kdata, T);
end
    
%  Density

switch mat.rhotype
  case 1  %  Constant
    rho(:) = mat.rhodata(2);
  case 2  %  Table - piecewise linear
    T = max(mat.rhodata(1,1),T);
    T = min(mat.rhodata(end,1),T);
    rho(:) = interp1(mat.rhodata(:,1), mat.rhodata(:,2), T, 'linear');
  case 3  %  Monotonic spline
    T = max(mat.rhodata(1,1),T);
    T = min(mat.rhodata(end,1),T);
    rho(:) = interp1(mat.rhodata(:,1), mat.rhodata(:,2), T, 'pchip');
  case 4  %  Polynomial
    rho(:) = polyval(mat.rhodata, T);
end

%  Specific heat

switch mat.cptype
  case 1  %  Constant
    cp(:) = mat.cpdata(2);
  case 2  %  Table - piecewise linear
    T = max(mat.cpdata(1,1),T);
    T = min(mat.cpdata(end,1),T);
    cp(:) = interp1(mat.cpdata(:,1), mat.cpdata(:,2), T, 'linear');
  case 3  %  Monotonic spline
    T = max(mat.cpdata(1,1),T);
    T = min(mat.cpdata(end,1),T);
    cp(:) = interp1(mat.cpdata(:,1), mat.cpdata(:,2), T, 'pchip');
  case 4  %  Polynomial
    cp(:) = polyval(mat.cpdata, T);
end

%  Viscosity

switch mat.mutype
  case 1  %  Constant
    mu(:) = mat.mudata(2);
  case 2  %  Table - piecewise linear
    T = max(mat.mudata(1,1),T);
    T = min(mat.mudata(end,1),T);
    mu(:) = interp1(mat.mudata(:,1), mat.mudata(:,2), T, 'linear');
  case 3  %  Monotonic spline
    T = max(mat.mudata(1,1),T);
    T = min(mat.mudata(end,1),T);
    mu(:) = interp1(mat.mudata(:,1), mat.mudata(:,2), T, 'pchip');
  case 4  %  Polynomial
    mu(:) = polyval(mat.mudata, T);
end

%  Prandtl number

switch mat.Prtype
  case 1  %  Constant
    Pr(:) = mat.Prdata(2);
  case 2  %  Table - piecewise linear
    T = max(mat.Prdata(1,1),T);
    T = min(mat.Prdata(end,1),T);
    Pr(:) = interp1(mat.Prdata(:,1), mat.Prdata(:,2), T, 'linear');
  case 3  %  Monotonic spline
    T = max(mat.Prdata(1,1),T);
    T = min(mat.Prdata(end,1),T);
    Pr(:) = interp1(mat.Prdata(:,1), mat.Prdata(:,2), T, 'pchip');
  case 4  %  Polynomial
    Pr(:) = polyval(mat.Prdata, T);
end

