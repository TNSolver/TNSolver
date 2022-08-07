function [T, Q, spar, nd, el, src, func] = tnsdriver(T, Q, spar, nd, el, bc, src, func, mat)
%[T, Q, spar, nd, el, src] = tnsdriver(T, Q, spar, nd, el, bc, src, mat)
%
%  Description:
%
%  Inputs:
%
%  Outputs:
%
%==========================================================================

global time   %  Current time for the simulation
global scrout %  Screen output flag

%  Set singular matrix warnings to an error condition, so that they
%    can be used on try-catch for linear solve

warning('error','MATLAB:singularMatrix')   % [msgStr,msgId] = lastwarn;
warning('error','MATLAB:nearlySingularMatrix')   % [msgStr,msgId] = lastwarn;

nnd  = length(nd);  %  Number of nodes
nel  = length(el);  %  Number of elements
nsrc = length(src); %  Number of sources
nbc  = length(bc);  %  Number of boundary conditions

u   = setunits(spar.units);  %  Set the units

%  Initialize the linear system

A = zeros(nnd,nnd);
b = zeros(nnd,1);
lhs = zeros(2,2);  %  Left hand side element matrix
rhs = zeros(2,1);  %  Right hand side element vector

if spar.steady
  ntimesteps = 1;  %  Only one "time step" for steady problems
  time       = 0.0;
  spar.time  = time;
  dt         = 0.0;
  transient  = 0;
else
  transient  = 1;
  time       = spar.begtime;  %  Start time
  spar.time  = time;
  if ~isempty(spar.dt)
    dt         = spar.dt;     %  Time step
    ntimesteps = (spar.endtime - spar.begtime)/dt;
  elseif ~isempty(spar.ntimesteps)
    ntimesteps = spar.ntimesteps;
    dt = (spar.endtime - spar.begtime)/ntimesteps;    
  else
    error('TNSolver - You must set a time step or number of steps.')
  end
  Q = zeros(nel,1);
  for e=1:nel
    el(e).Q = Q(e);
  end
  fplt = fopen([spar.inpfile '_timedata.csv'],'wt');
  wrttime(fplt, 0, time, nd, el);
  nextout = spar.printint;
  nt = 1;
  timeT(nt,1) = time;
  timeT(nt,2:length(T)+1) = T - spar.Toff;
  timeQ(nt,1) = time;
  timeQ(nt,2:length(Q)+1) = Q;
end

%--------------------------------------------------------------------------
%  Top of the time step loop - ntimesteps = 1 for steady problem
%--------------------------------------------------------------------------

for n=1:ntimesteps

  if transient
    midtime = time + dt/2;  %  Midpoint time
    time    = time + dt;    %  Time we are trying to get to in this step
    if n == ntimesteps
      time = spar.endtime;  %  Set last time step to end time
    end
    spar.time = time;
    if scrout fprintf('\n  Taking a time step to: %g (%s)\n',time, u.time); end;
    for nn=1:nnd
      nd(nn).Told = nd(nn).T;  %  Save previous time step temperature
    end
  end
  
  for i=1:nsrc
    switch src(i).ntype
      case 1   %  Constant source

        if ~isempty(src(i).fncqdot)
          src(i).qdot = evalfunc(func(src(i).fncqdot), time);
        end
        qdot = src(i).qdot;
        for j=1:length(src(i).nd)
          vol = nd(src(i).nd(j)).vol;
          src(i).Sc(j) = qdot*vol;
        end
      
      case 2   %  Constant total source

        if ~isempty(src(i).fncQ)
          src(i).Q = evalfunc(func(src(i).fncQ), time);
        end
        for j=1:length(src(i).nd)
          src(i).Sc(j) = src(i).Q;
        end
        
      case 3  %  Thermostat controlled source
          
        for j=1:length(src(i).nd)
          if nd(src(i).tnd).T < src(i).Ton && nd(src(i).tnd).T < src(i).Toff
            src(i).Sc(j) = src(i).Q;
          else
            src(i).Sc(j) = 0.0;
          end
        end
        
      otherwise
        error('TNSolver: Oops - unknown source type in assembly.')
    end
  end
  
%  Update the BC values for the current time

    for bcn=1:nbc
      if ~isempty(bc(bcn).fncTinf)
        bc(bcn).Tinf = evalfunc(func(bc(bcn).fncTinf), time);
        for j=1:length(bc(bcn).nd)
          eqn       = nd(bc(bcn).nd(j)).eqn;
          nd(eqn).T = bc(bcn).Tinf + spar.Toff;
          T(eqn)    = nd(eqn).T;
        end
      end
      if ~isempty(bc(bcn).fncq)
        bc(bcn).q = evalfunc(func(bc(bcn).fncq), time);
      end
      if ~isempty(bc(bcn).fncA)
        bc(bcn).A = evalfunc(func(bc(bcn).fncA), time);
      end
    end

%--------------------------------------------------------------------------
%  Top of the nonlinear loop - iterate until converged
%--------------------------------------------------------------------------

  converged = 0;
  iter = 0;
  if scrout fprintf('\n     Nonlinear Solve\n'); end;
  if scrout fprintf(  '  Iteration    Residual\n'); end;
  if scrout fprintf(  '  ---------  ------------\n'); end;
  
  while ~converged
      
    iter = iter + 1;
    
%  Update the parameters for each node

    if transient
      for nn=1:nnd
        if ~isempty(nd(nn).matID)
          if nd(nn).matID > 1   % Material library for rho*c
            ndT  = (nd(nn).T + nd(nn).Told)/2.0;  %  Midpoint node T
            [rho, cv] = rhocvprop(mat(nd(nn).matID), ndT);
            nd(nn).rhocv = rho*cv;
          end
        end
        if ~isempty(nd(nn).mfncID)   % Function for rho*c
          nd(nn).rhocv = evalfunc(func(nd(nn).mfncID), time);
        end
        if ~isempty(nd(nn).vfncID)   % Function for volume
          nd(nn).vol = evalfunc(func(nd(nn).vfncID), time);
        end        
      end
    end

%  Update the parameters for each element

    for e=1:nel

      nd1 = el(e).elnd(1);
      nd2 = el(e).elnd(2);
      Tel  = [nd(nd1).T;
              nd(nd2).T];
%       Tel  = (1/2)*[nd(nd1).T + nd(nd1).Told;  %  Midpoint element T
%                     nd(nd2).T + nd(nd2).Told];

      [el(e)] = el(e).elpre(el(e), mat, Tel);
      
    end
    

    A(:,:) = 0.0;
    b(:)   = 0.0;

%  Add the capacitance term to the global matrix

    if transient
    for nn=1:nnd
      if nd(nn).vol > 0
        row = nd(nn).eqn;
        cap = (nd(nn).rhocv*nd(nn).vol)/dt;
        A(row,row) = A(row,row) + cap;
        b(row)     = b(row)     + cap*(nd(nn).Told - nd(nn).T);
      end
    end
    end
    
%  Add each element/conductor to the linear system

    for e=1:nel

      lhs(:,:) = 0.0;
      rhs(:)   = 0.0;

      nd1 = el(e).elnd(1);
      nd2 = el(e).elnd(2);
      eq1 = nd(nd1).eqn;
      eq2 = nd(nd2).eqn;
      row = [ eq1; eq2 ];
      col = [ eq1, eq2 ];

%  Evaluate the element matrix for this conductor

      Tel  = [nd(nd1).T;
              nd(nd2).T];
%       Tel  = (1/2)*[nd(nd1).T + nd(nd1).Told;
%                     nd(nd2).T + nd(nd2).Told];

      [lhs, rhs] = el(e).elmat(el(e), Tel, rhs);
      
%  Add to the global matrix and right-hand-side

      A(row,col) = A(row,col) + lhs;
      b(row)     = b(row)     + rhs;
  
    end  

%  Add the source terms

    for i=1:nsrc

      for j=1:length(src(i).nd)
        eqn = nd(src(i).nd(j)).eqn;
        b(eqn) = b(eqn) + src(i).Sc(j);
      end

    end  

%  Apply the Neumann BC's

    for i=1:spar.nNBC
      bcn = spar.Neumann(i);
      switch bc(bcn).type
      case 'heat_flux'
        for j=1:length(bc(bcn).nd)
          eqn  = nd(bc(bcn).nd(j)).eqn;
          q    = bc(bcn).q;
          Area = bc(bcn).A;
          b(eqn) = b(eqn) + q*Area;
        end
      end
    end

%  Apply the Dirichlet BC's

    for i=1:spar.nDBC
      bcn = spar.Dirichlet(i);
      for j=1:length(bc(bcn).nd)
        eqn = nd(bc(bcn).nd(j)).eqn;
        A(eqn,:)   = 0.0;
        A(eqn,eqn) = 1.0;
        b(eqn)     = 0.0;  %  delta T is zero for a Dirichlet BC
%        b(eqn)     = bc(bcn).Tinf + spar.Toff;
      end
    end

%  What is the residual

%    residual = sum(abs(b));
    residual = norm(b,2)/norm(T,2);  %  Nondimensional L2 residual
    if scrout fprintf('   %6d     %g\n', iter, residual); end;
    if residual < spar.nonlinconv
      converged = 1;
    end
    
%  Solve the linear system for delta T

%    try
      dT = A\b;
%    catch
%      warning('on','MATLAB:singularMatrix')   % [msgStr,msgId] = lastwarn;
%      warning('on','MATLAB:nearlySingularMatrix')   % [msgStr,msgId] = lastwarn;
%      error('ERROR: Singular matrix, thermal model is most likely missing a boundary condition.')
%    end

    for nn=1:nnd
      if abs(dT(nn)) > spar.maxchange*nd(nn).T
        nd(nn).T = nd(nn).T + sign(dT(nn))*(spar.maxchange*nd(nn).T);
      else        
        nd(nn).T = nd(nn).T + dT(nn);  %  Apply delta T to update solution
      end
      T(nn) = nd(nn).T;
    end
    
    if iter > spar.maxit
      if scrout fprintf('\nWARNING: Nonlinear iterations have exceeded their limit of %d.\n',spar.maxit); end;
      break
    end

  end  %  Bottom of nonlinear loop
  
%--------------------------------------------------------------------------
%  Time step has converged, do we need output?
%--------------------------------------------------------------------------

%  Post process the solution - determine heat flow rates

for e=1:nel

  nd1 = el(e).elnd(1);
  nd2 = el(e).elnd(2);
  Tel = [nd(nd1).T;
         nd(nd2).T];

  [el(e), Q(e)] = el(e).elpost(el(e), Tel);
  
end  

for i=1:nsrc
  src(i).Qtot = 0.0;
  for j=1:length(src(i).nd(j))
    switch src(i).ntype
    case 1
      src(i).Qtot = src(i).Qtot + src(i).qdot*nd(src(i).nd(j)).vol;
    case 2
      src(i).Qtot = src(i).Qtot + src(i).Q;
    case 3
      src(i).Qtot = src(i).Qtot + src(i).Q;
    otherwise
      error('TNSolver: Oops - unknown source type in post processing.')
    end
  end
end

if transient && n >= nextout
  nt = nt + 1;
  timeT(nt,1) = time;
  timeT(nt,2:length(T)+1) = T - spar.Toff;
  timeQ(nt,1) = time;
  timeQ(nt,2:length(Q)+1) = Q;
  wrttime(fplt, n, time, nd, el);
  nextout = nextout + spar.printint;
  nextout = min(nextout,ntimesteps);
end

end  %  Bottom of time step loop
%**************************************************************************

%  Upon return, convert all temperatures to I/O units

if transient

  fclose(fplt);
  if scrout fprintf('\nTime data has been written to: %s\n',[spar.inpfile '_timedata.csv']); end;

  T = timeT;
  for n=1:nnd
    nd(n).T = T(end,n+1);
    nd(n).Told = nd(n).Told - spar.Toff;
  end  
  Q = timeQ;
  
else
  
  T = T - spar.Toff;
  for n=1:nnd
    nd(n).T = T(n);
  end  

end

warning('on','MATLAB:singularMatrix')   % [msgStr,msgId] = lastwarn;
warning('on','MATLAB:nearlySingularMatrix')   % [msgStr,msgId] = lastwarn;
