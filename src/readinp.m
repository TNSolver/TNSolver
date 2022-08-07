function [inperr, spar, nd, el, bc, src, ic, func, enc, mat] = readinp(fid, inpfile)
%[inperr, spar, nd, el, bc, src, ic, enc, mat] = readinp(fid, inpfile)
%
%  Description:
%
%    This function will parse the input file.
%
%  Input:
%
%    fid = file ID for the opened input file
%
%  Output:
%
%    inperr = input error flag
%               0 - no errors during input file read
%               1 - errors occured during input
%    spar   = solution parameters structure
%    nd()   = node data structure
%    el()   = element/conductor data structure
%    bc()   = boundary condition data structure
%    src()  = source data structure
%    ic()   = initial condition structure
%    enc()  = radiation enclosure structure
%    mat()  = material property structure
%
%  Functions Called:
%
%    nextline = fetch the next line from the input file
%
%  History:
%
%    Who    Date   Version  Note
%    ---  -------- -------  -----------------------------------------------
%    RJC  00/00/14  0.0.0   
%
%==========================================================================

global Toff

inperr = 0;  %  Input error flag

%  The node data struct

nnd  = 0;                        %  Number of nodes in the model
nd   = struct('label', {},  ...  %  string - node label
              'mat',   {},  ...  %  string - material name
              'vol',   {},  ...  %  double - volume
              'strvol',{},  ...  %  string - volume function name
              'T',     {},  ...  %  double - temperature
              'Told',  {},  ...  %  double - previous time step temperature
              'matID', {},  ...  %  int    - material library ID
              'mfncID',{},  ...  %  int    - heat capacity function ID
              'vfncID',{},  ...  %  int    - volume function ID
              'rhocv', {});      %  double - volumetric heat capacity 

%  The element data struct
            
nel  = 0;                        %  Number of elements in the model
el   = struct('label', {},  ...  %  string - element label
              'type',  {},  ...  %  string - type of element
              'nd1',   {},  ...  %  string - node i label
              'nd2',   {},  ...  %  string - node j label
              'mat',   {},  ...  %  string - material name
              'A',     {},  ...  %  double - area
              'k',     {},  ...  %  double - thermal conductivity
              'L',     {},  ...  %  double - length
              'theta', {},  ...  %  double - angle
              'ri',    {},  ...  %  double - inner radius
              'ro',    {},  ...  %  double - outer radius
              'cylL',  {},  ...  %  double - cylinder length
              'h',     {},  ...  %  double - convection coefficient
              'xbeg',  {},  ...  %  double - begin x coordinate
              'xend',  {},  ...  %  double - end x coordinate
              'sF',    {},  ...  %  double - script-F exchange factor
              'vel',   {},  ...  %  double - fluid flow velocity
              'mdot',  {},  ...  %  double - mass flow rate
              'cp',    {},  ...  %  double - specific heat
              'elnd',  {},  ...  %  (2,1)  - element internal nodes
              'elst',  {},  ...  %  int    - element type ID
              'elmat', {},  ...  %  function - element matrix function
              'elpre', {},  ...  %  function - element pre function
              'elpost',{},  ...  %  function - element post function
              'matID', {},  ...  %  int    - material library ID
              'Q',     {},  ...  %  double - Q_ij heat flow rate
              'U',     {},  ...  %  double - thermal conductance         
              'Nu',    {},  ...  %  double - Nusselt number
              'Re',    {},  ...  %  double - Reynolds number
              'Ra',    {},  ...  %  double - Rayleigh number
              'hr',    {});      %  double - radiation h

%  The boundary condition data struct

nbc  = 0;                          %  Number of BC's in the model
bc   = struct('type',    {},  ...  %  string - type of BC
              'Tinf',    {},  ...  %  double - BC temperature
              'q',       {},  ...  %  double - heat flux
              'A',       {},  ...  %  double - area
              'strTinf', {},  ...  %  string - BC temperature function
              'strq',    {},  ...  %  string - heat flux function
              'strA',    {},  ...  %  string - area function
              'fncTinf', {},  ...  %  int    - BC temperature function ID
              'fncq',    {},  ...  %  int    - heat flux function ID
              'fncA',    {},  ...  %  int    - area function ID
              'nds',     {},  ...  %  cell{} - node labels to apply BC to
              'nd',      {});      %  int    - internal node numbers

%  The source data struct

nsrc = 0;                          %  Number of sources in the model
src  = struct('type',    {},  ...  %  string - type of source
              'ntype',   {},  ...  %  int    - type ID
              'qdot',    {},  ...  %  double - source
              'strqdot', {},  ...  %  string - heat source function
              'fncqdot', {},  ...  %  int    - heat source function ID
              'Q',       {},  ...  %  double - total source
              'strQ',    {},  ...  %  string - total source function
              'fncQ',    {},  ...  %  int    - total source function ID
              'tstat',   {},  ...  %  string - node label for thermostat
              'Ton',     {},  ...  %  double - thermostat on T
              'Toff',    {},  ...  %  double - thermostat off T
              'nds',     {},  ...  %  cell{} - node labels to apply source to
              'nd',      {},  ...  %  int()  - internal node numbers
              'tnd',     {},  ...  %  int()  - thermostat internal node number
              'Sc',      {},  ...  %  double - S = Sp*T + Sc
              'Qtot',    {});      %  double - total node source for output

%  The initial condition data struct

nic = 0;                         %  Number of ICs in the model
ic  = struct('Tinit', {},  ...   %  double - initial temperature
             'nds',   {},  ...   %  cell{} - node labels to apply IC to
             'nd',    {});       %  int()  - internal node numbers

%  The enclosure radiation data struct

nenc = 0;                        %  int    - number of enclosures
enc  = struct('nsurf',  {},  ... %  int    - number of surfaces in this enclousre
              'label',  {},  ... %  string - surface label
              'emiss',  {},  ... %  double - surface emissivity
              'A',      {},  ... %  double - surface area
              'F',      {},  ... %  double - view factors
              'eln',    {});     %  int    - element numbers of radiation conductors

%  The function data struct

nfunc = 0;                       % int - number of functions
func = struct('name', {},   ...  % string - function name
              'indvar', {}, ...  % string - independent variable
              'type', {},   ...  % int - <0|1|2|3> type of function
              'data', {},   ...  % double - function data
              'range', {});      % double - function range
            
%  The solution parameter data struct

spar = struct('inpfile', {}, ... % string - input file base name
              'title',  {},  ... % string - problem title
              'type',   {},  ... % string - 
              'steady', {},  ...
              'begtime', {},  ...
              'endtime', {},  ...
              'dt',     {},  ...
              'ntimesteps', {},  ...
              'printint', {}, ...
              'units',  {},  ...
              'sigma',  {},  ...
              'Tunits', {},  ...
              'Toff',   {},  ...
              'g',      {},  ...
              'nonlinconv', {},  ...
              'maxit',  {},  ...
              'maxchange', {}, ...
              'graphviz', {}, ...
              'plotfnc', {}, ...
              'nDBC',   {},  ...
              'Dirichlet', {}, ...
              'nNBC',   {},  ...
              'Neumann', {});
            
%  Set the default solution parameters

spar(1).inpfile    = inpfile;
spar(1).type       = 'steady';     %  string - problem type
spar(1).steady     = 1;            %  int    - steady problem flag
spar(1).units      = 'SI';         %  string - model units
spar(1).begtime    = 0.0;          %  double - transient begin time
spar(1).sigma      = 5.670373E-8;  %  double - Stefan-Boltzmann constant (W/m^2-K^4)
spar(1).Tunits     = 'C';          %  string - Temperature I/O units
spar(1).Toff       = 273.15;       %  double - Temperature offset (K = C + Toff)
spar(1).g          = 9.80665;      %  double - gravity (m/s^2)
spar(1).nonlinconv = 1.0e-9;       %  double - Nonlinear convergence
spar(1).maxit      = 100;          %  int    - Max nonlinear iterations
spar(1).maxchange  = 1.0;          %  double - max change in T update
spar(1).printint   = 1;            %  int    - print time data interval
spar(1).scrprint   = 1;            %  int    - screen print interval
spar(1).graphviz   = 0;            %  int    - output graphviz file
spar(1).plotfnc    = 0;            %  int    - output functions to PDF plot
spar(1).nDBC       = 0;            %  int    - number of Dirichlet BCs
spar(1).Dirichlet  = [];           %  int    - list of Dirichlet BCs in bc()
spar(1).nNBC       = 0;            %  int    - number of Neumann BCs
spar(1).Neumann    = [];           %  int    - list of Neumann BCs in bc()

Toff = spar(1).Toff;

mat = matlib;                  %  Load the material library
spar(1).nlibmat = length(mat); %  The number of materials in the library

lnum = 0;  %  Line number in the input file

eof = 0;   %  End of input file flag

while ~eof

  [str, lnum, eof] = nextline(fid, lnum);  %  Fetch an input line
  if eof return; end
  
%  Verify that we have a correctly formed begin block command

  if ~isempty(regexpi(str,'begin.*solution'))             ||  ...
     ~isempty(regexpi(str,'begin.*nodes'))                ||  ...
     ~isempty(regexpi(str,'begin.*conductors'))           ||  ...
     ~isempty(regexpi(str,'begin.*boundary.*conditions')) ||  ...
     ~isempty(regexpi(str,'begin.*sources'))              ||  ...
     ~isempty(regexpi(str,'begin.*initial.*conditions'))  ||  ...
     ~isempty(regexpi(str,'begin.*radiation.*enclosure')) ||  ...
     ~isempty(regexpi(str,'begin.*material'))             ||  ...
     ~isempty(regexpi(str,'begin.*functions'))
     
  if ~isempty(regexpi(str,'begin.*solution'))

%  Read solution parameter block

    while ~eof
      [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
      if isempty(regexpi(str,'end.*solution'))
        tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens

        if strcmpi(tok{1},'type')
          spar.type = char(tok{2});
          if strcmpi('steady', spar.type)
            spar.steady = 1;
          elseif strcmpi('transient', spar.type)
            spar.steady = 0;
          else
            fprintf('\nERROR: Invalid analysis type at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end

        elseif strcmpi(tok{1},'title')
          beg = strfind(str, '=') + 1;
          spar.title = strtrim(str(beg:end));
          
        elseif strcmpi(tok{1},'units')
          spar.units = char(tok{2});
          if strcmpi(spar.units, 'SI') || strcmpi(spar.units, 'US')
          else
            fprintf('\nERROR: Invalid units at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end            

        elseif strcmpi(tok{1},'T')   &&  ...
               strcmpi(tok{2},'units')
          spar.Tunits = char(tok{3});
          
        elseif strcmpi(tok{1},'gravity')
          spar.gravity = str2double(tok{2});
          if isnan(spar.gravity)
            fprintf('\nERROR: Invalid gravity value at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end

        elseif strcmpi(tok{1},'nonlinear')   &&  ...
               strcmpi(tok{2},'convergence')
          spar.nonlinconv = str2double(tok{3});
          if isnan(spar.nonlinconv) || spar.nonlinconv < 0.0
            fprintf('\nERROR: Invalid nonlinear convergence value at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end

        elseif strcmpi(tok{1},'maximum')    &&  ...
               strcmpi(tok{2},'nonlinear')  &&  ...
               strcmpi(tok{3},'iterations')
          spar.maxit = str2double(tok{4});
          if isnan(spar.maxit) || spar.maxit < 0.0
            fprintf('\nERROR: Invalid maximum nonlinear iterations value at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end

        elseif strcmpi(tok{1},'begin') && ...
               strcmpi(tok{2},'time')
          spar.begtime = str2double(tok{3});
          if isnan(spar.begtime)
            fprintf('\nERROR: Invalid begin time at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end

        elseif strcmpi(tok{1},'end') &&  ...
               strcmpi(tok{2},'time')
          spar.endtime = str2double(tok{3});
          if isnan(spar.endtime)
            fprintf('\nERROR: Invalid end time at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end

        elseif strcmpi(tok{1},'time') &&  ...
               strcmpi(tok{2},'step')
          spar.dt = str2double(tok{3});
          if isnan(spar.dt)
            fprintf('\nERROR: Invalid time step at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end

        elseif strcmpi(tok{1},'print') &&  ...
               strcmpi(tok{2},'interval')
          spar.printint = str2double(tok{3});
          if isnan(spar.printint)
            fprintf('\nERROR: Invalid print interval at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end

        elseif strcmpi(tok{1},'screen') &&  ...
               strcmpi(tok{2},'print') &&  ...
               strcmpi(tok{3},'interval')
          spar.scrprint = str2double(tok{4});
          if isnan(spar.scrprint)
            fprintf('\nERROR: Invalid screen print interval at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end

        elseif strcmpi(tok{1},'number') &&  ...
               strcmpi(tok{2},'of')     &&  ...
               strcmpi(tok{3},'time')   &&  ...
               strcmpi(tok{4},'steps')
          spar.ntimesteps = str2double(tok{5});
          if isnan(spar.ntimesteps) || spar.ntimesteps < 0
            fprintf('\nERROR: Invalid number of time steps at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end

        elseif strcmpi(tok{1},'Stefan-Boltzmann')
          spar.sigma = str2double(tok{2});
          if isnan(spar.sigma) || spar.sigma < 0
            fprintf('\nERROR: Invalid Stefan-Boltzmann constant at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          
        elseif strcmpi(tok{1},'graphviz')  &&  ...
               strcmpi(tok{2},'output')
          spar.graphviz = 0;
          if strcmpi(tok{3},'yes')
            spar.graphviz = 1;
          end
          
        elseif strcmpi(tok{1},'plot')  &&  ...
               strcmpi(tok{2},'functions')
          spar.plotfnc = 0;
          if strcmpi(tok{3},'yes')
            spar.plotfnc = 1;
          end

        else
          fprintf('\nERROR: Unknown command on line %d in the input file:\n%s\n',lnum,str)
          inperr = 1;
        end

      else
        break
      end
    end

  end  

  if ~isempty(regexpi(str,'begin.*nodes'))
  
%  Read node block

    [lnum, eof, inperr, nnd, nd] = readnodes(fid, lnum, eof, inperr, nnd, nd);
    
  end  

  if ~isempty(regexpi(str,'begin.*conductors'))

%  Read conductor block

    while ~eof
      [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
      if isempty(regexpi(str,'end.*conductors'))
        nel = nel + 1;
        tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
%       tok = textscan(str,'%s %s %s %s %s %f %f');
        if length(tok) < 4
          fprintf('\nERROR: Invalid conductor command at line %d in the input file:\n%s\n',lnum,str)
          inperr = 1;
        end
        el(nel).label = tok{1};
        el(nel).type  = tok{2};
        el(nel).nd1   = tok{3};
        el(nel).nd2   = tok{4};
%--------------------------------------------------------------------------
%  Conduction conductors
%--------------------------------------------------------------------------
        if strcmpi(el(nel).type,'conduction')
%--------------------------------------------------------------------------
          if length(tok) < 7
            fprintf('\nERROR: Invalid conduction conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          [num, status] = str2num(tok{5});
          if status
            el(nel).k = num;
          else
            el(nel).mat = tok{5};
          end
          el(nel).L      = str2double(tok{6});  %  NaN, if conversion error
          if isnan(el(nel).L)
            fprintf('\nERROR: Invalid conductor length at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A      = str2double(tok{7});
          if isnan(el(nel).L)
            fprintf('\nERROR: Invalid conductor area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst   = 1;
          el(nel).elmat  = @elmat_conduction;
          el(nel).elpre  = @elpre_conduction;
          el(nel).elpost = @elpost_conduction;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'cylindrical')
%--------------------------------------------------------------------------
          if length(tok) < 8
            fprintf('\nERROR: Invalid cylindrical conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          [num, status] = str2num(tok{5});
          if status
            el(nel).k = num;
          else
            el(nel).mat = tok{5};
          end
          el(nel).ri    = str2double(tok{6});  %  NaN, if conversion error
          if isnan(el(nel).ri) || el(nel).ri <= 0.0
            fprintf('\nERROR: Invalid cylinder inner radius at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).ro    = str2double(tok{7});
          if isnan(el(nel).ro) || el(nel).ro < 0.0 || el(nel).ro <= el(nel).ri
            fprintf('\nERROR: Invalid cylinder outer radius at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).cylL  = str2double(tok{8});
          if isnan(el(nel).cylL) || el(nel).cylL < 0.0
            fprintf('\nERROR: Invalid cylinder length at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          rm            = (el(nel).ro - el(nel).ri)/log(el(nel).ro/el(nel).ri);
          el(nel).A     = 2*pi*el(nel).cylL*rm;
          el(nel).L     = el(nel).ro - el(nel).ri;
          el(nel).elst  = 14;
          el(nel).elmat  = @elmat_conduction;
          el(nel).elpre  = @elpre_conduction;
          el(nel).elpost = @elpost_conduction;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'spherical')
%--------------------------------------------------------------------------
          if length(tok) < 7
            fprintf('\nERROR: Invalid spherical conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          [num, status] = str2num(tok{5});
          if status
            el(nel).k = num;
          else
            el(nel).mat = tok{5};
          end
          el(nel).ri    = str2double(tok{6});  %  NaN, if conversion error
          if isnan(el(nel).ri) || el(nel).ri <= 0.0
            fprintf('\nERROR: Invalid sphere inner radius at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).ro    = str2double(tok{7});
          if isnan(el(nel).ro) || el(nel).ro < 0.0 || el(nel).ro <= el(nel).ri
            fprintf('\nERROR: Invalid sphere outer radius at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = 4*pi*el(nel).ri*el(nel).ro;
          el(nel).L     = el(nel).ro - el(nel).ri;
          el(nel).elst  = 15;
          el(nel).elmat  = @elmat_conduction;
          el(nel).elpre  = @elpre_conduction;
          el(nel).elpost = @elpost_conduction;          
%--------------------------------------------------------------------------
%  Convection conductors
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'convection')
%--------------------------------------------------------------------------
          if length(tok) < 6
            fprintf('\nERROR: Invalid convection conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).h     = str2double(tok{5});
          if isnan(el(nel).h) || el(nel).h < 0.0
            fprintf('\nERROR: Invalid convection coefficient at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{6});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid convection area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst  = 2;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_convection;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'IFCduct')
%--------------------------------------------------------------------------
          if length(tok) < 8
            fprintf('\nERROR: Invalid IFCduct conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).vel   = str2double(tok{6});
          if isnan(el(nel).vel) || el(nel).vel < 0.0
            fprintf('\nERROR: Invalid IFCduct velocity at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).D     = str2double(tok{7});
          if isnan(el(nel).D) || el(nel).D <= 0.0
            fprintf('\nERROR: Invalid IFCduct diameter at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{8});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid IFCduct area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst  = 16;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_IFCduct;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'EFCimpjet')
%--------------------------------------------------------------------------
          if length(tok) < 9
            fprintf('\nERROR: Invalid EFCimpjet conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).vel   = str2double(tok{6});
          if isnan(el(nel).vel) || el(nel).vel < 0.0
            fprintf('\nERROR: Invalid EFCimpjet jet velocity at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).D  = str2double(tok{7});
          if isnan(el(nel).D) || el(nel).D <= 0.0
            fprintf('\nERROR: Invalid EFCimpjet jet diameter at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).H  = str2double(tok{8});
          if isnan(el(nel).H) || el(nel).H <= 0.0
            fprintf('\nERROR: Invalid EFCimpjet height at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).r     = str2double(tok{9});
          if isnan(el(nel).r) || el(nel).r <= 0.0
            fprintf('\nERROR: Invalid EFCimpjet radius at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A = pi*el(nel).r^2;
          el(nel).elst   = 20;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_EFCimpjet;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'EFCplate')
%--------------------------------------------------------------------------
          if length(tok) < 9
            fprintf('\nERROR: Invalid EFCplate conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).vel   = str2double(tok{6});
          if isnan(el(nel).vel) || el(nel).vel < 0.0
            fprintf('\nERROR: Invalid EFCplate velocity at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).xbeg  = str2double(tok{7});
          if isnan(el(nel).xbeg) || el(nel).xbeg < 0.0
            fprintf('\nERROR: Invalid EFCplate X begin location at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).xend  = str2double(tok{8});
          if isnan(el(nel).xend) || el(nel).xend <= el(nel).xbeg
            fprintf('\nERROR: Invalid EFCplate X end location at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{9});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid EFCplate area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst  = 17;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_EFCplate;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'EFCcyl')
%--------------------------------------------------------------------------
          if length(tok) < 8
            fprintf('\nERROR: Invalid EFCcyl conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).vel   = str2double(tok{6});
          if isnan(el(nel).vel) || el(nel).vel < 0.0
            fprintf('\nERROR: Invalid EFCcyl velocity at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).D     = str2double(tok{7});
          if isnan(el(nel).D) || el(nel).D <= 0.0
            fprintf('\nERROR: Invalid EFCcyl diameter at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{8});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid EFCcyl area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst   = 6;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_EFCcyl;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'EFCsphere')
%--------------------------------------------------------------------------
          if length(tok) < 7
            fprintf('\nERROR: Invalid EFCsphere conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).vel   = str2double(tok{6});
          if isnan(el(nel).vel) || el(nel).vel < 0.0
            fprintf('\nERROR: Invalid EFCsphere velocity at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).D     = str2double(tok{7});
          if isnan(el(nel).D) || el(nel).D <= 0.0
            fprintf('\nERROR: Invalid EFCsphere diameter at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          else
            el(nel).A = pi*el(nel).D^2;
          end
          el(nel).elst   = 19;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_EFCsphere;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'INCvenc')
%--------------------------------------------------------------------------
          if length(tok) < 8
            fprintf('\nERROR: Invalid INCvenc conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).W     = str2double(tok{6});
          if isnan(el(nel).W) || el(nel).W <= 0.0
            fprintf('\nERROR: Invalid INCvenc width at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).H     = str2double(tok{7});
          if isnan(el(nel).H) || el(nel).H <= 0.0
            fprintf('\nERROR: Invalid INCvenc height at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{8});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid INCvenc area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst   = 21;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_INCvenc;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'ENChcyl')
%--------------------------------------------------------------------------
          if length(tok) < 7
            fprintf('\nERROR: Invalid ENChcyl conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).D     = str2double(tok{6});
          if isnan(el(nel).D) || el(nel).D <= 0.0
            fprintf('\nERROR: Invalid ENChcyl diameter at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{7});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid ENChcyl area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst   = 7;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_ENChcyl;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'EFCdiamond')
%--------------------------------------------------------------------------
          if length(tok) < 8
            fprintf('\nERROR: Invalid EFCdiamond conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).vel   = str2double(tok{6});
          if isnan(el(nel).vel) || el(nel).vel < 0.0
            fprintf('\nERROR: Invalid EFCdiamond velocity at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).D     = str2double(tok{7});
          if isnan(el(nel).D) || el(nel).D <= 0.0
            fprintf('\nERROR: Invalid EFCdiamond diameter at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{8});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid EFCdiamond area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst   = 8;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_EFCdiamond;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'ENChplateup')
%--------------------------------------------------------------------------
          if length(tok) < 7
            fprintf('\nERROR: Invalid ENChplateup conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).L     = str2double(tok{6});
          if isnan(el(nel).L) || el(nel).L <= 0.0
            fprintf('\nERROR: Invalid ENChplateup length at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{7});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid ENChplateup area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst   = 9;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_ENChplateup;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'ENChplatedown')
%--------------------------------------------------------------------------
          if length(tok) < 7
            fprintf('\nERROR: Invalid ENChplatedown conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).L     = str2double(tok{6});
          if isnan(el(nel).L) || el(nel).L <= 0.0
            fprintf('\nERROR: Invalid ENChplatedown length at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{7});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid ENChplatedown area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst   = 10;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_ENChplatedown;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'ENCvplate')
%--------------------------------------------------------------------------
          if length(tok) < 7
            fprintf('\nERROR: Invalid ENCvplate conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).L     = str2double(tok{6});
          if isnan(el(nel).L) || el(nel).L <= 0.0
            fprintf('\nERROR: Invalid ENCvplate length at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{7});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid ENCvplate area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst   = 11;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_ENCvplate;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'ENCiplateup')
%--------------------------------------------------------------------------
          if length(tok) < 9
            fprintf('\nERROR: Invalid ENCiplateup conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).H     = str2double(tok{6});
          if isnan(el(nel).H) || el(nel).H <= 0.0
            fprintf('\nERROR: Invalid ENCiplateup height at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).L     = str2double(tok{7});
          if isnan(el(nel).L) || el(nel).L <= 0.0
            fprintf('\nERROR: Invalid ENCiplateup length at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).theta = str2double(tok{8});
          if isnan(el(nel).theta) || el(nel).theta <= 0.0
            fprintf('\nERROR: Invalid ENCiplateup angle at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{9});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid ENCiplateup area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst   = 12;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_ENCiplateup;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'ENCiplatedown')
%--------------------------------------------------------------------------
          if length(tok) < 9
            fprintf('\nERROR: Invalid ENCiplatedown conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).H     = str2double(tok{6});
          if isnan(el(nel).H) || el(nel).H <= 0.0
            fprintf('\nERROR: Invalid ENCiplatedown height at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).L     = str2double(tok{7});
          if isnan(el(nel).L) || el(nel).L <= 0.0
            fprintf('\nERROR: Invalid ENCiplatedown length at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).theta = str2double(tok{8});
          if isnan(el(nel).theta) || el(nel).theta <= 0.0
            fprintf('\nERROR: Invalid ENCiplatedown angle at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{9});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid ENCiplatedown area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst   = 13;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_ENCiplatedown;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'ENCsphere')
%--------------------------------------------------------------------------
          if length(tok) < 6
            fprintf('\nERROR: Invalid ENCsphere conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).D     = str2double(tok{6});
          if isnan(el(nel).D) || el(nel).D <= 0.0
            fprintf('\nERROR: Invalid ENCsphere diameter at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          else
            el(nel).A = pi*(el(nel).D^2);
          end
          el(nel).elst   = 18;
          el(nel).elmat  = @elmat_convection;
          el(nel).elpre  = @elpre_ENCsphere;
          el(nel).elpost = @elpost_convection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'FCuser')
          ntok = length(tok);
          if exist(tok{5}) == 2  %  Make sure the user function exists
            el(nel).function = str2func(tok{5});
            if nargout(el(nel).function) ~= 3
              fprintf('\nERROR: Invalid number of output arguments for FCuser function at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
            if nargin(el(nel).function) > 4
              fprintf('\nERROR: Invalid number of input arguments for FCuser function at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end            
            el(nel).mat = tok{6};
            for i=1:ntok-7
              el(nel).params(i) = str2double(tok{6+i});
              if isnan(el(nel).params(i))
                fprintf('\nERROR: Invalid FCuser parameter at line %d in the input file:\n%s\n',lnum,str)
                inperr = 1;
              end
            end
            el(nel).A = str2double(tok{ntok});
            if isnan(el(nel).A) || el(nel).A < 0.0
              fprintf('\nERROR: Invalid FCuser area at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
            el(nel).elst   = 22;
            el(nel).elmat  = @elmat_convection;
            el(nel).elpre  = @elpre_FCuser;
            el(nel).elpost = @elpost_convection;
          else
            fprintf('\nERROR: Can not locate FCuser function at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'NCuser')
          ntok = length(tok);
          if exist(tok{5}) == 2  %  Make sure the user function exists
            el(nel).function = str2func(tok{5});
            if nargout(el(nel).function) ~= 3
              fprintf('\nERROR: Invalid number of output arguments for NCuser function at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
            if nargin(el(nel).function) > 4
              fprintf('\nERROR: Invalid number of input arguments for NCuser function at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end            
            el(nel).mat = tok{6};
            for i=1:ntok-7
              el(nel).params(i) = str2double(tok{6+i});
              if isnan(el(nel).params(i))
                fprintf('\nERROR: Invalid NCuser parameter at line %d in the input file:\n%s\n',lnum,str)
                inperr = 1;
              end
            end
            el(nel).A = str2double(tok{ntok});
            if isnan(el(nel).A) || el(nel).A < 0.0
              fprintf('\nERROR: Invalid NCuser area at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
            el(nel).elst   = 23;
            el(nel).elmat  = @elmat_convection;
            el(nel).elpre  = @elpre_NCuser;
            el(nel).elpost = @elpost_convection;
          else
            fprintf('\nERROR: Can not locate NCuser function at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%  Radiation conductors
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'radiation')
%--------------------------------------------------------------------------
          if length(tok) < 6
            fprintf('\nERROR: Invalid radiation conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).sF    = str2double(tok{5});
          if isnan(el(nel).sF) || el(nel).sF < 0.0
            fprintf('\nERROR: Invalid radiation script-F at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{6});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid radiation area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst  = 3;
          el(nel).elmat  = @elmat_radiation;
          el(nel).elpre  = @elpre_radiation;
          el(nel).elpost = @elpost_radiation;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'surfrad')
%--------------------------------------------------------------------------
          if length(tok) < 6
            fprintf('\nERROR: Invalid surfrad conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).emiss = str2double(tok{5});
          el(nel).sF    = el(nel).emiss;
          if isnan(el(nel).sF) || el(nel).sF < 0.0 || el(nel).sF > 1.0
            fprintf('\nERROR: Invalid surfrad emissivity at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{6});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid surfrad area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst  = 4;
          el(nel).elmat  = @elmat_radiation;
          el(nel).elpre  = @elpre_radiation;
          el(nel).elpost = @elpost_radiation;          
%--------------------------------------------------------------------------
%  Advection conductors
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'advection')
%--------------------------------------------------------------------------
          if length(tok) < 7
            fprintf('\nERROR: Invalid advection conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).vel   = str2double(tok{6});
          if isnan(el(nel).vel)
            fprintf('\nERROR: Invalid advection velocity at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{7});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid advection area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst  = 5;
          el(nel).elmat  = @elmat_advection;
          el(nel).elpre  = @elpre_advection;
          el(nel).elpost = @elpost_advection;          
%--------------------------------------------------------------------------
        elseif strcmpi(el(nel).type,'outflow')
%--------------------------------------------------------------------------
          if length(tok) < 7
            fprintf('\nERROR: Invalid outflow conductor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).mat   = tok{5};
          el(nel).vel   = str2double(tok{6});
          if isnan(el(nel).vel)
            fprintf('\nERROR: Invalid advection velocity at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).A     = str2double(tok{7});
          if isnan(el(nel).A) || el(nel).A < 0.0
            fprintf('\nERROR: Invalid advection area at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
          el(nel).elst  = 30;
          el(nel).elmat  = @elmat_outflow;
          el(nel).elpre  = @elpre_advection;
          el(nel).elpost = @elpost_advection;          
%--------------------------------------------------------------------------
%  Error - unknown conductor type
%--------------------------------------------------------------------------
        else
          fprintf('\nERROR: Unknown type of conductor at line %d in the input file:\n%s\n',lnum,str)
          inperr = 1;
        end
      else
        break
      end
    end

  end  

  if ~isempty(regexpi(str,'begin.*boundary.*conditions'))
  
%  Read boundary condition block

    while ~eof
      [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
      if isempty(regexpi(str,'end.*boundary.*conditions'))
        nbc = nbc + 1;
        tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
        ntok = length(tok);
        bc(nbc).type = tok{1};
        if strcmpi(bc(nbc).type,'fixed_T')
          [num, status] = str2num(tok{2});
          if status            
            bc(nbc).Tinf = num;        % BC T
          else
            bc(nbc).strTinf = tok{2};  % function name for BC T
          end
          for i=3:ntok
            bc(nbc).nds{i-2} = tok{i};
          end
        elseif strcmpi(bc(nbc).type,'heat_flux')
          [num, status] = str2num(tok{2});
          if status
            bc(nbc).q = num;
          else
            bc(nbc).strq = tok{2};  % function name for BC q
          end
          [num, status] = str2num(tok{3});
          if status
            bc(nbc).A = num;
          else
            bc(nbc).strA = tok{3};  % function name for BC A
          end
          for i=4:ntok
            bc(nbc).nds{i-3} = tok{i};
          end
        else
          fprintf('\nERROR: Unknown type of boundary condition at line %d in the input file:\n%s\n',lnum,str)
          inperr = 1;
        end
      else
        break
      end
    end

  end
  
%==========================================================================

  if ~isempty(regexpi(str,'begin.*sources'))
  
%  Read source block

    [lnum, eof, inperr, nsrc, src] = readsrc(fid, lnum, eof, inperr, nsrc, src);
    
  end

%==========================================================================

  if ~isempty(regexpi(str,'begin.*initial'))
  
%  Read initial condition block

    while ~eof
      [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
      if isempty(regexpi(str,'end.*initial'))
        nic = nic + 1;
        tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
        ntok = length(tok);
        if regexpi(tok{1},'read')
          ic = readrst(tok{3}, nic, ic);
        else
          ic(nic).Tinit = str2double(tok{1});
          for i=2:ntok
            ic(nic).nds{i-1} = tok{i};
          end
        end
      else
        break
      end
    end
        
  end

%==========================================================================

  if ~isempty(regexpi(str,'begin.*radiation'))
  
%  Read radiation enclosure block

    nenc = nenc + 1;
    sn = 0;
    while ~eof
      [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
      if isempty(regexpi(str,'end.*radiation'))
        tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
        ntok = length(tok);
        if ntok >= 5  %  Check to see if we have enough for an enclosure
        if sn == 0
          enc(nenc).nsurf = ntok - 3;
          sn = sn + 1;
        else
          if (ntok - 3) ~= enc(nenc).nsurf
            disp('WARNING: Radiation enclosure surface number mismatch.')
          end
          sn = sn + 1;
        end
        enc(nenc).label{sn} = tok{1};
        enc(nenc).emiss(sn) = str2double(tok{2});
        if isnan(enc(nenc).emiss(sn)) || enc(nenc).emiss(sn) < 0 || enc(nenc).emiss(sn) > 1
          fprintf('\nERROR: Invalid emissivity at line %d in the input file:\n%s\n',lnum,str)
          inperr = 1;
        end
        enc(nenc).A(sn)     = str2double(tok{3});
        if isnan(enc(nenc).A(sn)) || enc(nenc).A(sn) < 0
          fprintf('\nERROR: Invalid area at line %d in the input file:\n%s\n',lnum,str)
          inperr = 1;
        end
        for i=4:ntok
          enc(nenc).F(sn,i-3) = str2double(tok{i});
          if isnan(enc(nenc).F(sn,i-3)) || enc(nenc).F(sn,i-3) < 0 || enc(nenc).F(sn,i-3) > 1
            fprintf('\nERROR: Invalid view factor at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          end
        end
        else
          fprintf('\nERROR: Invalid radiation enclosure at line %d in the input file:\n%s\n',lnum,str)
          inperr = 1;
        end
      else
        if sn ~= enc(nenc).nsurf
          disp('WARNING: Radiation enclosure surface number mismatch.')
        end
        break
      end
    end    
  end

%==========================================================================

  if ~isempty(regexpi(str,'begin.*functions'))
  
%  Read functions block

    [lnum, eof, inperr, nfunc, func] = readfunc(fid, lnum, eof, inperr, nfunc, func);
  
  end

%==========================================================================

  if ~isempty(regexpi(str,'begin.*material'))

    tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
    ntok = length(tok);
    if ntok == 3
      matname = tok{3};
%  Read material property block
      [lnum, eof, inperr, mat] = readmat(fid, lnum, eof, inperr, matname, mat);
    else
      fprintf('\nERROR: Invalid material name on line %d in the input file:\n%s\n',lnum,str)
      inperr = 1;
    end

  end
  
%==========================================================================

  else

    fprintf('\nERROR: Unable to parse line %d in the input file:\n%s\n',lnum,str)
    inperr = 1;

  end
  
end
