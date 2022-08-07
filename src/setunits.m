function [units, conv] = setunits(name)
%[units, conv] = setunits(name)
%
%  Description:
%
%    Populates a struct of the unit strings for thermal parameters
%
%  Inputs:
%
%    name = string for system of units: 'SI' or 'US'
%
%  Outputs:
%
%    units = the unit label struct
%
%==========================================================================

switch name
  case 'SI'

    units.time  = 's';
    units.L     = 'm';
    units.A     = 'm^2';
    units.V     = 'm^3';
    units.k     = 'W/m-K';
    units.rho   = 'kg/m^3';
    units.cp    = 'J/kg-K';
    units.visc  = 'Pa-s';
    units.h     = 'W/m^2-K';
    units.eps   = 'dimensionless';
    units.F     = 'dimensionless';
    units.sF    = 'dimensionless';
    units.sigma = 'W/m^2-K^4';
    units.Tabs  = 'K';
    units.T     = 'C';
    units.Q     = 'W';
    units.q     = 'W/m^2';
    units.qdot  = 'W/m^3';
    units.vel   = 'm/s';
    units.a     = 'm/s^2';

    conv.time   = 3600.0;   % s/hr
    conv.L      = 0.3048;   % m/ft
    conv.M      = 0.45359237;  % kg/lbm
    conv.Tabs   = 5.0/9.0;  % K/R
    conv.heat   = (conv.M*conv.L^2)/(conv.time^2);   % M-L^2/t^2 J/Btu
    conv.A      = conv.L^2; % m^2/ft^2
    conv.V      = conv.L^3; % m^3/ft^3
    conv.rho    = (conv.M)/(conv.L^3);  % M/L^3
    conv.k      = (conv.M*conv.L)/(conv.time^3*conv.Tabs); % M-L/t^3-T
    conv.h      = (conv.M)/(conv.time^3*conv.Tabs); % M/t^3-T
    
  case 'US'

    units.time  = 'hr';
    units.L     = 'ft';
    units.A     = 'ft^2';
    units.V     = 'ft^3';
    units.k     = 'Btu/hr-ft-R';
    units.rho   = 'lbm/ft^3';
    units.cp    = 'Btu/lbm-R';
    units.visc  = 'lbm-ft/hr';
    units.h     = 'Btu/hr-ft^2-R';
    units.eps   = 'dimensionless';
    units.F     = 'dimensionless';
    units.sF    = 'dimensionless';
    units.sigma = 'Btu/hr-ft^2-R^4';
    units.Tabs  = 'R';
    units.T     = 'F';
    units.Q     = 'Btu/hr';
    units.q     = 'Btu/hr-ft^2';
    units.qdot  = 'Btu/hr-ft^3';
    units.vel   = 'ft/hr';
    units.a     = 'ft/hr^2';

    conv.time   = 1.0/3600.0;   % hr/s
    conv.L      = 3.280839895;  % ft/m
    conv.M      = 2.2046226218; % lbm/kg
    conv.Tabs   = 9.0/5.0;      % R/K/R
    conv.A      = conv.L^2; % m^2/ft^2
    conv.V      = conv.L^3; % m^3/ft^3
    conv.rho    = (conv.M)/(conv.L^3);  % M/L^3
    conv.heat   = (conv.M*conv.L^2)/(conv.time^2);   % M-L^2/t^2 J/Btu
    conv.k      = (conv.M*conv.L)/(conv.time^3*conv.Tabs); % M-L/t^3-T
    conv.h      = (conv.M)/(conv.time^3*conv.Tabs); % M/t^3-T

  otherwise

    error('setunits: Unknown units name: %s\n',name)

end

