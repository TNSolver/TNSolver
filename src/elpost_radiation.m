function [el, Q] = elpost_radiation(el, Tel)

global sigma

sF   = el.sF;
Area = el.A;
Ti   = Tel(1);
Tj   = Tel(2);

Q    = (sigma*sF*Area)*(Ti^4 - Tj^4);
el.Q = Q;

el.hr = (sigma*sF)*(Ti + Tj)*(Ti^2 + Tj^2);
el.U  = el.hr;
