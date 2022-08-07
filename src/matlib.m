function [mat] = matlib
%[mat] = matlib;
%
% Description:
%
%   Initialize the material property library data structure.
%
% Output:
%
%   mat() = material property data structure
%
%==========================================================================

%  "enumurations"
%  state
SOLID  = 1;
LIQUID = 2;
GAS    = 3;
%  type of data for this property
CONST  = 1;
TABLE  = 2;  % use interp1(x,y,u,'linear')
SPLINE = 3;  % use interp1(x,y,u,'pchip'), same as: pchip(x,y,u)
POLY   = 4;  % use polyval(a,u)
USER   = 5;  % user function - @func(t, T) time and temperature

%--------------------------------------------------------------------------
%  The material property data struct
%--------------------------------------------------------------------------

nmat = 0;                          % int    - number of materials defined
mat  = struct('name',     {}, ...  % string - material name
              'state',    {}, ...  % int    - state
              'ref',      {}, ...  % string - reference for data source
              'ktype',    {}, ...  % int    - type of conductivity
              'kunits',   {}, ...  % cell   - conductivity units
              'kdata',    {}, ...  % double - conductivity data
              'krange',   {}, ...  % double - conductivity polynomial range
              'rhotype',  {}, ...  % int    - type of density
              'rhounits', {}, ...  % cell   - density units
              'rhodata',  {}, ...  % double - density data
              'rhorange', {}, ...  % double - density polynomial range
              'cptype',   {}, ...  % int    - type of c_p specific heat
              'cpunits',  {}, ...  % cell   - c_p specific heat units
              'cpdata',   {}, ...  % double - c_p specific heat data
              'cprange',  {}, ...  % double - c_p polynomial range
              'cvtype',   {}, ...  % int    - type of c_v specific heat
              'cvunits',  {}, ...  % cell   - c_v specific heat units
              'cvdata',   {}, ...  % double - c_v specific heat data
              'cvrange',  {}, ...  % double - c_v polynomial range
              'mutype',   {}, ...  % int    - type of dynamic/shear viscosity
              'muunits',  {}, ...  % cell   - dynamic/shear viscosity units
              'mudata',   {}, ...  % double - dynamic/shear viscosity data
              'murange',  {}, ...  % double - viscosity polynomial range
              'betatype', {}, ...  % int    - type of thermal expansion coeff
              'betaunits',{}, ...  % cell   - thermal expansion coeff units
              'betadata', {}, ...  % double - thermal expansion coeff data
              'betarange',{}, ...  % double - thermal expansion polynomial range
              'Prtype',   {}, ...  % int    - type of Prandtl number
              'Prunits',  {}, ...  % cell   - Prandtl number units
              'Prdata',   {}, ...  % double - Prandtl number data
              'Prrange',  {}, ...  % double - Prandtl number polynomial range
              'R',        {}, ...  % double - gas constant
              'Runits',   {});     % cell   - gas constant units

nmat = nmat + 1;
mat(nmat).name = 'N/A';
            
%--------------------------------------------------------------------------
%  Air at atmospheric pressure, 101.325 kPa
%--------------------------------------------------------------------------

nmat = nmat + 1;
mat(nmat).name     = 'air';
mat(nmat).state    = GAS;
mat(nmat).ref      = ['Table A.6, page 718, in:\n'  ...
                      'J. H. Lienhard, IV and J. H. Lienhard, V. A Heat Transfer Textbook.\n'  ...
                      '  Phlogiston Press, Cambridge, Massachusetts, fourth edition, 2012.\n'    ...
                      '  version 2.02, available at: http://ahtt.mit.edu\n'];
mat(nmat).ktype    = SPLINE;
mat(nmat).kunits   = { '(K)', '(W/m-K)' };
mat(nmat).kdata    = [ 100.0,  0.00941;
                       150.0,  0.01406;
                       200.0,  0.01836;
                       250.0,  0.02241;
                       260.0,  0.02329;
                       280.0,  0.02473;
                       300.0,  0.02623;
                       320.0,  0.02753;
                       340.0,  0.02888;
                       350.0,  0.02984;
                       400.0,  0.03328;
                       450.0,  0.03656];
mat(nmat).rhotype  = SPLINE;
mat(nmat).rhounits = { '(K)', '(kg/m^3)' };
mat(nmat).rhodata  = [ 100.0,   3.605;
                       150.0,   2.368;
                       200.0,   1.769;
                       250.0,   1.412;
                       260.0,   1.358;
                       280.0,   1.261;
                       300.0,   1.177;
                       320.0,   1.103;
                       340.0,   1.038;
                       350.0,   1.008;
                       400.0,   0.8821;
                       450.0,   0.7840];
mat(nmat).cptype   = SPLINE;
mat(nmat).cpunits  = {  '(K)', '(J/kg-K)' };
mat(nmat).cpdata   = [ 100.0,    1039.0;
                       150.0,    1012.0;
                       200.0,    1007.0;
                       250.0,    1006.0;
                       260.0,    1006.0;
                       280.0,    1006.0;
                       300.0,    1007.0;
                       320.0,    1008.0;
                       340.0,    1009.0;
                       350.0,    1009.0;
                       400.0,    1014.0;
                       450.0,    1021.0];
mat(nmat).cvtype   = SPLINE;
mat(nmat).cvunits  = {  '(K)', '(J/kg-K)' }; 
mat(nmat).cvdata   = [ 100.0,  728.1930;
                       150.0,  717.5362;
                       200.0,  716.1623;
                       250.0,  716.4042;
                       260.0,  716.6014;
                       280.0,  717.1636;
                       300.0,  717.9716;
                       320.0,  719.0505;
                       340.0,  720.4217;
                       350.0,  721.2220;
                       400.0,  726.4106;
                       450.0,  733.5475];
mat(nmat).mutype   = SPLINE;
mat(nmat).muunits  = {  '(K)', '(kg/m-s)' };
mat(nmat).mudata   = [ 100.0,   0.711e-5;
                       150.0,   1.035e-5;
                       200.0,   1.333e-5;
                       250.0,   1.606e-5;
                       260.0,   1.649e-5;
                       280.0,   1.747e-5;
                       300.0,   1.857e-5;
                       320.0,   1.935e-5;
                       340.0,   2.025e-5;
                       350.0,   2.090e-5;
                       400.0,   2.310e-5;
                       450.0,   2.517e-5];
mat(nmat).betatype   = SPLINE;  %  thermal expansion coefficient
mat(nmat).betaunits  = {  '(K)', '(1/K)' };
mat(nmat).betadata   = [ 100.0,  10.000e-3;
                         150.0,   6.667e-3;
                         200.0,   5.000e-3;
                         250.0,   4.000e-3;
                         260.0,   3.846e-3;
                         280.0,   3.571e-3;
                         300.0,   3.333e-3;
                         320.0,   3.125e-3;
                         340.0,   2.941e-3;
                         350.0,   2.857e-3;
                         400.0,   2.500e-3;
                         450.0,   2.222e-3];
mat(nmat).Prtype   = SPLINE;
mat(nmat).Prunits  = {  '(K)', '(dimensionless)' };
mat(nmat).Prdata   = [ 100.0,   0.784;
                       150.0,   0.745;
                       200.0,   0.731;
                       250.0,   0.721;
                       260.0,   0.712;
                       280.0,   0.711;
                       300.0,   0.713;
                       320.0,   0.708;
                       340.0,   0.707;
                       350.0,   0.707;
                       400.0,   0.704;
                       450.0,   0.703];

%--------------------------------------------------------------------------
%  Water
%--------------------------------------------------------------------------

nmat = nmat + 1;
mat(nmat).name     = 'water';
mat(nmat).state    = LIQUID;
mat(nmat).ref      = ['Table A.3, page 713, in:\n'  ...
                      'J. H. Lienhard, IV and J. H. Lienhard, V. A Heat Transfer Textbook.\n'  ...
                      '  Phlogiston Press, Cambridge, Massachusetts, fourth edition, 2012.\n'    ...
                      '  version 2.02, available at: http://ahtt.mit.edu\n'];
mat(nmat).ktype    = SPLINE;
mat(nmat).kunits   = { '(K)', '(W/m-K)' };
mat(nmat).kdata    = [ 273.15, 0.5610;
                       275.0,  0.5645;
                       285.0,  0.5835;
                       295.0,  0.6017;
                       305.0,  0.6184;
                       320.0,  0.6396;
                       340.0,  0.6605;
                       360.0,  0.6737;
                       373.15, 0.6791];
mat(nmat).rhotype  = SPLINE;
mat(nmat).rhounits = { '(K)', '(kg/m^3)' };
mat(nmat).rhodata  = [ 273.15,  999.8;
                       275.0,   999.9;
                       285.0,   999.5;
                       295.0,   997.8;
                       305.0,   995.0;
                       320.0,   989.3;
                       340.0,   979.5;
                       360.0,   967.4;
                       373.15,  958.3];
mat(nmat).cptype   = SPLINE;
mat(nmat).cpunits  = { '(K)', '(J/kg-K)' };
mat(nmat).cpdata   = [ 273.15,  4220.0;
                       275.0,   4214.0;
                       285.0,   4193.0;
                       295.0,   4183.0;
                       305.0,   4180.0;
                       320.0,   4181.0;
                       340.0,   4189.0;
                       360.0,   4202.0;
                       373.15,  4216.0];
mat(nmat).mutype   = SPLINE;
mat(nmat).muunits  = {  '(K)', '(kg/m-s)' };
mat(nmat).mudata   = [ 273.15,  1.787E-3;
                       275.0,   1.682E-3;
                       285.0,   1.239E-3;
                       295.0,   9.579E-4;
                       305.0,   7.669E-4;
                       320.0,   5.770E-4;
                       340.0,   4.220E-4;
                       360.0,   3.261E-4;
                       373.15,  2.817E-4];
mat(nmat).betatype   = SPLINE;  %  thermal expansion coefficient
mat(nmat).betaunits  = {  '(K)', '(1/K)' };
% mat(nmat).betadata   = [ 273.15, -6.80E-5;
%                          275.0,  -3.55E-5;
mat(nmat).betadata   = [ 280.0,   4.36E-5;
                         285.0,   0.000112;
                         295.0,   0.000226;
                         305.0,   0.000319;
                         320.0,   0.000436;
                         340.0,   0.000565;
                         360.0,   0.000679;
                         373.15,  0.000751];
mat(nmat).Prtype   = SPLINE;
mat(nmat).Prunits  = {  '(K)', '(dimensionless)' };
mat(nmat).Prdata   = [ 273.15,  13.47;
                       275.0,   12.55;
                       285.0,    8.91;
                       295.0,    6.66;
                       305.0,    5.18;
                       320.0,    3.77;
                       340.0,    2.68;
                       360.0,    2.03
                       373.15,   1.75];

%--------------------------------------------------------------------------
%  Steel AISI 1010
%--------------------------------------------------------------------------

nmat = nmat + 1;
mat(nmat).name     = 'steel';
mat(nmat).state    = SOLID;
mat(nmat).ref      = ['Table A.1, page 702, in:\n'  ...
                      'J. H. Lienhard, IV and J. H. Lienhard, V. A Heat Transfer Textbook.\n'  ...
                      '  Phlogiston Press, Cambridge, Massachusetts, fourth edition, 2012.\n'    ...
                      '  version 2.02, available at: http://ahtt.mit.edu\n'];
mat(nmat).ktype    = SPLINE;
mat(nmat).kunits   = {  '(K)', '(W/m-K)' };
mat(nmat).kdata    = [  173.15,   70.0;
                        273.15,   65.0;
                        373.15,   61.0;
                        473.15,   55.0;
                        573.15,   50.0];
mat(nmat).rhotype  = CONST;
mat(nmat).rhounits = {  '(K)', '(kg/m^3)' };
mat(nmat).rhodata  = [  293.15,  7830.0];
mat(nmat).cvtype   = CONST;
mat(nmat).cvunits  = {  '(K)', '(J/kg-K)' };
mat(nmat).cvdata   = [  293.15,   434.0];

%--------------------------------------------------------------------------
%  Fir - perpendicular to the grain
%--------------------------------------------------------------------------

nmat = nmat + 1;
mat(nmat).name     = 'fir';
mat(nmat).state    = SOLID;
mat(nmat).ref      = ['Perpendicular to the grain, Table A.2, page 707, in:\n'  ...
                      'J. H. Lienhard, IV and J. H. Lienhard, V. A Heat Transfer Textbook.\n'  ...
                      '  Phlogiston Press, Cambridge, Massachusetts, fourth edition, 2012.\n'    ...
                      '  version 2.02, available at: http://ahtt.mit.edu\n'];
mat(nmat).ktype    = CONST;
mat(nmat).kunits   = {  '(K)', '(W/m-K)' };
mat(nmat).kdata    = [ 288.15,    0.12];
mat(nmat).rhotype  = CONST;
mat(nmat).rhounits = {  '(K)', '(kg/m^3)' };
mat(nmat).rhodata  = [ 288.15,   600.0];
mat(nmat).cvtype   = CONST;
mat(nmat).cvunits  = {  '(K)'; '(J/kg-K)' };
mat(nmat).cvdata   = [ 288.15,   2720.0];
