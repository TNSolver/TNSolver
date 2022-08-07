function [el] = elpre_conduction(el, mat, Tel)

if ~isempty(el.matID)
  elT  = (Tel(1) + Tel(2))/2.0;  %  Use average temperature
  el.k = kprop(mat(el.matID), elT);
end
