function [h, Re, Nu] = EFCplate(mat, V, Xbeg, Xend, Tf)
%[h, Re] = EFCplate(mat, V, Xbeg, Xend, Tf)
%
%  Description:
%
%    External forced convection over a flat plate.
%
%  Inputs:
%
%    mat  = mat struct for fluid
%    V    = fluid velocity
%    Xbeg = distance from leading edge of the plate
%    Xend = distance to end of plate
%    Tf   = film temperature for fluid properties
%
%  Outputs:
%
%    h  = heat transfer coefficient
%    Re = Reynolds number
%    Nu = Nusselt number
%
%  Reference:
%
%    [Kre73] Table 6-5, p. 371
%
%==========================================================================

if Xbeg < 0.0
  error('EFCplate: Invalid Xbeg = %g\n',Xbeg)
elseif Xend - Xbeg <= 0.0
  error('EFCplate: Invalid length, Xend - Xbeg = %g\n',Xend-Xbeg)
elseif V < 0
  error('EFCplate: Negative velocity, V = %g\n',V)
end

Recr = 5.0e5;   %  transition Reynolds number

if V > 0.0

%  Evaluate the fluid properties

  [k, rho, cp, mu, Pr] = fluidprop(mat, Tf);

  if Xbeg > 0.0

    Reb = (rho*V*Xbeg)/mu;
    Re  = (rho*V*Xend)/mu;
    Xcr  = Recr*(mu/(rho*V));
  
    if Xend <= Xcr      %  laminar flow

      Nu = 0.664*(Re^(1/2) - Reb^(1/2))*Pr^(1/3);
      h  = (k*Nu)/(Xend - Xbeg);
      
    elseif Xbeg <= Xcr  % mixed laminar and turbulent

      Nu = ( 0.664*(Recr^(1/2) - Reb^(1/2)) ...
           + 0.037*(Re^(4/5) - Recr^(4/5)))*Pr^(1/3);
      h  = (k*Nu)/(Xend - Xbeg);
      
    else                % all turbulent

      Nu = 0.037*(Re^(4/5) - Reb^(4/5))*Pr^(1/3);
      h  = (k*Nu)/(Xend - Xbeg);
      
    end

  else  %  Xbeg = 0.0
  
    Re = (rho*V*Xend)/mu;
    if Re <= Recr  % laminar flow
      Nu = 0.664*Re^(1/2)*Pr^(1/3);
    else           % turbulent flow
      Nu = (0.037*Re^(4/5) - 871.3)*Pr^(1/3);
    end
    h = (k*Nu)/Xend;
  
  end
    
else  %  no flow velocity, V = 0

  Re = 0.0;
  Nu = 0.0;
  h  = 0.0;
 
end