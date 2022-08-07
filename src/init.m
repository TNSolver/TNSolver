function [T, Q, spar, nd, el, bc, src, ic, func, enc, mat] = init(spar, nd, el, bc, src, ic, func, enc, mat)
%[T, Q, spar, nd, el, bc, src, ic, enc, mat] = init(spar, nd, el, bc, src, ic, enc, mat)
%
%  Description:
%
%    This function will initialize the model.
%
%  Input:
%
%    spar   = solution parameters struct
%    nd()   = node data struct
%    el()   = element/conductor data struct
%    bc()   = boundary condition data struct
%    src()  = source data struct
%    ic()   = initial condition data struct
%    func() = function data struc
%    enc()  = radiation enclosure data struct
%    mat()  = material property data struct
%
%  Output:
%
%    T() = initial temperature vector
%    Q() = initial total heat flux vector
%    spar = solution parameters structure
%    nd() = node data structure
%    el() = element/conductor data structure
%    bc()   = boundary condition data struct
%    src()  = source data struct
%    ic()   = initial condition data struct
%    func() = function data struc
%    enc()  = radiation enclosure data struct
%    mat()  = material property data struct
%
%  Functions Called:
%
%    None
%
%  History:
%
%    Who    Date   Version  Note
%    ---  -------- -------  -----------------------------------------------
%    RJC  00/00/14  0.0.0   
%
%==========================================================================

time = spar.begtime;  %  Set the current time at initialization

nnd   = length(nd);   %  The number of nodes read from the input file
nel   = length(el);   %  The number of elements
nbc   = length(bc);   %  The number of boundary conditions
nsrc  = length(src);  %  The number of sources
nfunc = length(func); %  The number of functions
nenc  = length(enc);  %  The number of radiation enclosures

nmat = length(mat); %  The number of materials in the library

%  Output a PDF plot of each function in the model, if requested

if nfunc > 0 && spar.plotfnc
  for n=1:nfunc
    plotfunc(func(n));
  end
end  

%  Add the radiation conductors for each enclosure in the model

if nenc > 0
  for i=1:nenc

%  Do a quality check on the supplied view factor matrix

    [rowsum, symcheck] = QCF(enc(i).A, enc(i).F);
    for n=1:length(rowsum)  %  Should be 1.0 for each surface
      if abs(1.0 - rowsum(n)) > 100.0*eps
        fprintf('WARNING: Row sum = %g, for surface %s in enclosure %d, is not equal to 1.0.\n',rowsum(n),char(enc(i).label(n)),i);
      end
    end
    for n=1:length(symcheck)  %  Should be 0.0 for each surface
      if abs(symcheck(n)) > 100.0*eps
        fprintf('WARNING: Symmetry check = %g, for surface %s in enclosure %d, is not equal to 0.0.\n',symcheck(n),char(enc(i).label(n)),i);
      end
    end

%  Calculate the script-F values for this view factor matrix    
    
    [sF] = scriptF(enc(i).emiss, enc(i).F);

%  Generate the radiation conductors

    m = 0;
    for j=1:enc(i).nsurf-1
      for k=j+1:enc(i).nsurf
        nel = nel + 1;
        m = m + 1;
        el(nel).label  = char(strcat(enc(i).label(j),'-',enc(i).label(k)));
        el(nel).type   = 'radiation';
        el(nel).nd1    = char(enc(i).label(j));
        el(nel).nd2    = char(enc(i).label(k));
        el(nel).sF     = sF(j,k);
        el(nel).A      = enc(i).A(j);
        el(nel).elst   = 3;
        el(nel).elmat  = @elmat_radiation;
        el(nel).elpre  = @elpre_radiation;
        el(nel).elpost = @elpost_radiation;
        enc(i).eln(m) = nel;
      end
    end
  end
  nel  = length(el);  %  Reset the number of elements
end  

%  Create a cell array of all the unique node labels in the model

ndlabels = cell(nnd+nel*2+nbc+nsrc,1);
for n=1:nnd  %  Node labels
  ndlabels{n} = nd(n).label;
end
nndl = nnd;
for e=1:nel  %  Element node labels
  nndl = nndl + 1;
  ndlabels{nndl} = el(e).nd1;
  nndl = nndl + 1;
  ndlabels{nndl} = el(e).nd2;
end
for i=1:nbc  %  BC node labels
  for j=length(bc(i).nds)
    nndl = nndl + 1;
    ndlabels{nndl} = bc(i).nds{j};
  end
end
for i=1:nsrc  %  Source node labels
  for j=length(src(i).nds)
    nndl = nndl + 1;
    ndlabels{nndl} = src(i).nds{j};
  end
end

ndlabels = unique(ndlabels);
ndlabels = sortndlabels(ndlabels);

%  Add referenced nodes that were not parsed from a node block

for i=1:length(ndlabels)
  ndx = matchnd(nd, ndlabels{i});
  if ~ndx
    nnd = length(nd);
    nd(nnd+1).label = char(ndlabels{i});
    nd(nnd+1).mat = 'N/A';
    nd(nnd+1).vol = 0.0;
  end
end
nnd = length(nd);

%  Locate the internal node number for each element node

for e=1:nel
  el(e).elnd = zeros(2,1);
  ndx = matchnd(nd, el(e).nd1);
  if ~ndx
    error('Node %s not found for element %s.\n', el(e).nd1, el(e).label)
  end
  el(e).elnd(1) = ndx;
  ndx = matchnd(nd, el(e).nd2);
  if ~ndx
    error('Node %s not found for element %s.\n', el(e).nd2, el(e).label)
  end
  el(e).elnd(2) = ndx;
end  

T = zeros(nnd,1);
Q = zeros(nel,1);

%  Assign an equation number to each node and set initial temperature

for n=1:nnd
  nd(n).eqn = n;
  nd(n).T   = 0.0;
  nd(n).T   = nd(n).T + spar.Toff;  %  Convert to absolute T
  T(n)      = nd(n).T;
  if isempty(nd(n).mat)
    nd(n).mat = 'N/A';
  end
  if isempty(nd(n).vol)
    nd(n).vol = 0.0;
  end
end

%--------------------------------------------------------------------------
%  Locate the internal node number and functions for each source
%--------------------------------------------------------------------------

for i=1:nsrc

  for j=1:length(src(i).nds)
    ndx = matchnd(nd, src(i).nds{j});
    if ~ndx
      error('Node %s not found for source %s.\n', src(i).nds{j}, src(i))
    end
    src(i).nd(j) = ndx;
  end

  if src(i).ntype == 3
    ndx = matchnd(nd, src(i).tstat);
    if ~ndx
      error('Thermostat node %s not found for source %s.\n', src(i).tstat, src(i))
    end
    src(i).tnd  = ndx;
    src(i).Toff = src(i).Toff + spar.Toff;
    src(i).Ton  = src(i).Ton + spar.Toff;
  end

  if ~isempty(src(i).strqdot)
    ndx = matchfunc(func, src(i).strqdot);
    if ndx > 0
      src(i).fncqdot = ndx;
    else
      error('ERROR: Cannot find matching function %s for source %s.', src(i).strqdot, src(i).type)
    end
  end
    
  if ~isempty(src(i).strQ)
    ndx = matchfunc(func, src(i).strQ);
    if ndx > 0
      src(i).fncQ = ndx;
    else
      error('ERROR: Cannot find matching function %s for source %s.', src(i).strqdot, src(i).type)
    end
  end
  
  if ~isempty(src(i).fncqdot)
    src(i).qdot = evalfunc(func(src(i).fncqdot), time);
  end
  if ~isempty(src(i).fncQ)
    src(i).Q = evalfunc(func(src(i).fncQ), time);
  end

end

%  Find the material number for each node and element, as required

for n=1:nnd
  if ~isempty(nd(n).mat)
    ndx = matchmat(mat,nd(n).mat);
    if ndx > 0
      nd(n).matID = ndx;
    else
      ndx = matchfunc(func,nd(n).mat);
      if ndx > 0
        nd(n).mfncID = ndx;
      end
    end
    if ndx == 0
      error('ERROR: Cannot find matching material or function for node %s material.',nd(n).mat)
    end
  end
  if ~isempty(nd(n).strvol)
    ndx = matchfunc(func,nd(n).strvol);
    if ndx > 0
      nd(n).vfncID = ndx;
    else
      error('ERROR: Cannot find matching function for node %s volume.',nd(n).strvol)
    end
  end
end

for e=1:nel
  if isfield(el(e), 'mat')
    for j=1:nmat
      if strcmpi(el(e).mat, mat(j).name)
        el(e).matID = j;
        break
      end
    end
  end
end

%  Find the Dirichlet and Neuman BC's

nDBC = 0;
nNBC = 0;

for i=1:nbc
  for j=1:length(bc(i).nds)  %  Determine internal node numbers
    for n=1:nnd
      if strcmpi(bc(i).nds(j), nd(n).label)
        bc(i).nd(j) = n;
      end
    end
  end
  if strcmpi(bc(i).type, 'fixed_T')
    nDBC = nDBC + 1;
    DirBC(nDBC) = i;
    if ~isempty(bc(i).strTinf)
      ndx = matchfunc(func,bc(i).strTinf);
      if ndx > 0
        bc(i).fncTinf = ndx;
      else
        error('ERROR: Cannot find matching function %s for BC temperature.',bc(i).strTinf)
      end
      bc(i).Tinf = evalfunc(func(bc(i).fncTinf), time); % evaluate the function and set the BC T
    end
  else
    nNBC = nNBC + 1;
    NeumannBC(nNBC) = i;
    if ~isempty(bc(i).strq)
      ndx = matchfunc(func,bc(i).strq);
      if ndx > 0
        bc(i).fncq = ndx;
      else
        error('ERROR: Cannot find matching function %s for BC q.',bc(i).strq)
      end
      bc(i).q = evalfunc(func(bc(i).fncq), time); % evaluate the function and set the BC q
    end
    if ~isempty(bc(i).strA)
      ndx = matchfunc(func,bc(i).strA);
      if ndx > 0
        bc(i).fncA = ndx;
      else
        error('ERROR: Cannot find matching function %s for BC area.',bc(i).strA)
      end
      bc(i).A = evalfunc(func(bc(i).fncA), time); % evaluate the function and set the BC A
    end
  end
end  

spar.nDBC = nDBC;
spar.nNBC = nNBC;
if spar.nDBC > 0
  spar.Dirichlet = DirBC;
end  
if spar.nNBC > 0
  spar.Neumann   = NeumannBC;
end  

%  Set the initial conditions

nic = length(ic);
if nic == 0
  ic(1).nd = 1:nnd;
  ic(1).Tinit(1:nnd) = 0.0;
else
  for i=1:length(ic)
    if strcmpi(ic(i).nds{1}, 'all')
      Tinit = ic(i).Tinit;
      ic(i).nd = 1:nnd;
      ic(i).Tinit(1:nnd) = Tinit;
    else
      if length(ic(i).Tinit) == 1
        Tinit = ic(i).Tinit;
        for j=1:length(ic(i).nds)
          ndx         = matchnd(nd, ic(i).nds{j});
          ic(i).nd(j) = ndx;
          ic(i).Tinit(j) = Tinit;
        end
      else
        for j=1:length(ic(i).nds)
          ndx         = matchnd(nd, ic(i).nds{j});
          ic(i).nd(j) = ndx;
        end
      end
    end
  end
end

%  Now set the initial temperature state

for i=1:length(ic)
  for j=1:length(ic(i).nd)
    eqn       = nd(ic(i).nd(j)).eqn;
    nd(eqn).T = ic(i).Tinit(j) + spar.Toff;
    T(eqn)    = nd(eqn).T;
  end
end

%  Apply BC values to the initial temperature state

for i=1:spar.nDBC
  nbc = spar.Dirichlet(i);
  for j=1:length(bc(nbc).nd)
    eqn       = nd(bc(nbc).nd(j)).eqn;
    nd(eqn).T = bc(nbc).Tinf + spar.Toff;
    T(eqn)    = nd(eqn).T;
  end
end

for e=1:nel

  nd1 = el(e).elnd(1);
  nd2 = el(e).elnd(2);
  Tel = [nd(nd1).T;
         nd(nd2).T];

  [el(e)]       = el(e).elpre(el(e), mat, Tel);
  [el(e), Q(e)] = el(e).elpost(el(e), Tel);
  
end  



%==========================================================================
function [ndx] = matchnd(nd, str)
%  locate index of node label
for i=1:length(nd)
  if strcmpi(nd(i).label, str)
    ndx = i;
    return
  end
end
ndx = 0;

%==========================================================================
function [ndx] = matchmat(mat, str)
%  locate index of material name
for i=1:length(mat)
  if strcmpi(mat(i).name, str)
    ndx = i;
    return
  end
end
ndx = 0;

%==========================================================================
function [ndx] = matchfunc(func, str)
%  locate index of material name
for i=1:length(func)
  if strcmpi(func(i).name, str)
    ndx = i;
    return
  end
end
ndx = 0;

%==========================================================================
function [tmp] = sortndlabels(ndlabels)
%  Sort the node labels - numeric first, then alpha

j = 0;
k = 0;
alphalabels = {};
numlabels = [];
for i=1:length(ndlabels)
  [stmp, status] = str2num(ndlabels{i});
  if status
    j = j + 1;
    numlabels(j,1) = stmp;
    numlabels(j,2) = i;
  else
    k = k + 1;
    alphalabels{k,1} = lower(ndlabels{i});
    alphalabels{k,2} = i;
  end
end

if isempty(numlabels)
  nn = 0;
else
  nn = length(numlabels(:,1));
end
if isempty(alphalabels)
  na = 0;
else  
  na = length(alphalabels(:,1));
end  

if nn > 0
  numlabels = sortrows(numlabels,1);
  for i=1:nn
    tmp{i,1} = ndlabels{numlabels(i,2)};
  end
end
if na > 0
  alphalabels = sortrows(alphalabels,1);
  for i=1:na
    tmp{nn+i,1} = ndlabels{alphalabels{i,2}};
  end
end
