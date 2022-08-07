function [val] = evalfunc(func, indv)
%
%
%==========================================================================

val = NaN;

switch func.type
  case 0
    val = func.data;
  case 1
    val = interp1(func.data(:,1), func.data(:,2), indv, 'linear');
  case 2
    val = interp1(func.data(:,1), func.data(:,2), indv, 'pchip');
  otherwise
     
end    
