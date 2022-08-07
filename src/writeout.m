function writeout(fid, spar, nd, el, bc, src, ic, enc, mat)
%writeout(fid, spar, nd, el, bc, src, ic, enc)
%
%  Description:
%
%    Write the model to the requested output.
%
%  Inputs:
%
%    fid = file ID to write to
%
%  Outputs:
%
%    Model written to requested file.
%
%==========================================================================

u = setunits(spar.units);

fprintf(fid,'\n**********************************************************\n');
fprintf(fid,  '*                                                        *\n');
fprintf(fid,  '*          TNSolver - A Thermal Network Solver           *\n');
fprintf(fid,  '*                                                        *\n');
fprintf(fid,  '*           %33s            *\n',verdate);
fprintf(fid,  '*                                                        *\n');
fprintf(fid,  '**********************************************************\n');

endtime = clock;  %  Current time and date
fprintf(fid,'\nModel run finished at %s, on %s\n',   ...
        datestr(endtime,'HH:MM AM'), datestr(endtime,'mmmm dd, yyyy'));

fprintf(fid,'\n*** Solution Parameters ***\n\n');
fprintf(fid,  '  Title: %s\n\n', spar.title);
fprintf(fid,  '  Type                          =  %s\n', spar.type);
fprintf(fid,  '  Units                         =  %s\n', spar.units);
fprintf(fid,  '  Temperature units             =  %s\n', spar.Tunits);
fprintf(fid,  '  Nonlinear convergence         =  %g\n', spar.nonlinconv);
fprintf(fid,  '  Maximum nonlinear iterations  =  %d\n', spar.maxit);
fprintf(fid,  '  Gravity                       =  %g (%s)\n', spar.g, u.a);
fprintf(fid,  '  Stefan-Boltzmann constant     =  %g (%s)\n', spar.sigma, u.sigma);

%--------------------------------------------------------------------------
%  Write out the nodes
%--------------------------------------------------------------------------

nnd = length(nd);
fprintf(fid,'\n*** Nodes ***\n\n');
fprintf(fid,  '                        Volume   Temperature\n');
fprintf(fid,  '   Label    Material     (%s)       (%s)\n',u.V,u.T);
fprintf(fid,  ' --------- ---------- ---------- -----------\n');
for n=1:nnd
  fprintf(fid,'%10s %10s %10g %11g\n', nd(n).label, nd(n).mat, nd(n).vol, nd(n).T);
end

%--------------------------------------------------------------------------
%  Write out the conductors
%--------------------------------------------------------------------------

nel = length(el);
fprintf(fid,'\n*** Conductors ***\n\n');
fprintf(fid,  '                                                 Q_ij\n');
fprintf(fid,  '    Label        Type       Node i     Node j      (%s)\n', u.Q);
fprintf(fid,  ' ---------- ------------- ---------- ---------- ----------\n');
for e=1:nel
  fprintf(fid,' %10s %13s %10s %10s %10g\n',el(e).label, el(e).type, el(e).nd1, el(e).nd2, el(e).Q);
end

%--------------------------------------------------------------------------
%  Write out the sources
%--------------------------------------------------------------------------

nsrc = length(src);
if nsrc > 0
  fprintf(fid,'\n*** Sources ***\n\n');
  fprintf(fid,  '               Q_i\n');
  fprintf(fid,  '    Type       (%s)     Node(s)\n', u.Q);
  fprintf(fid,  ' ---------- ---------- --------------------\n');
  for i=1:nsrc
    fprintf(fid,' %10s %10g ', src(i).type, src(i).Qtot);
    for j=1:length(src(i).nds)
      fprintf(fid,' %s', char(src(i).nds(j)));
    end
    fprintf(fid,'\n');
  end  
end

%--------------------------------------------------------------------------
%  Write out the boundary conditions
%--------------------------------------------------------------------------

nbc = length(bc);
if nbc > 0
  fprintf(fid,'\n*** Boundary Conditions ***\n\n');
  fprintf(fid,  '    Type       Parameter(s)        Node(s)\n');
  fprintf(fid,  ' ---------- ------------------ --------------------\n');
  for i=1:nbc
    if strcmpi(bc(i).type,'fixed_T')
      fprintf(fid,' %10s %8g          ', bc(i).type, bc(i).Tinf);
    elseif strcmpi(bc(i).type,'heat_flux')
      fprintf(fid,' %10s %8g %8g ', bc(i).type, bc(i).q, bc(i).A);
    end
    for j=1:length(bc(i).nds)
      fprintf(fid,' %s', char(bc(i).nds(j)));
    end
    fprintf(fid,'\n');
  end  
end

%--------------------------------------------------------------------------
%  Write out the initital conditions
%--------------------------------------------------------------------------

nic = length(ic);
if nic > 0
  fprintf(fid,'\n*** Initial Conditions ***\n\n');
  fprintf(fid,  ' Temperature       Node (s)\n');
  fprintf(fid,  ' -----------  --------------------\n');
  for i=1:nic
    fprintf(fid,' %10g  ', ic(i).Tinit(1));
    for j=1:length(ic(i).nd)
      fprintf(fid,' %s', char(nd(ic(i).nd(j)).label));
    end
    fprintf(fid,'\n');
  end  
end

%--------------------------------------------------------------------------
%  Write out radiation enclosures
%--------------------------------------------------------------------------

nenc = length(enc);
if nenc > 0
  for i=1:nenc
    fprintf(fid,'\n*** Radiation Enclosure Number %d ***\n\n',i);
    fprintf(fid,  '   Surface   Emissivity     Area    View Factors\n');
    fprintf(fid,  ' ----------- ---------- ----------- -------------------\n');
    for k=1:enc(i).nsurf
      fprintf(fid,' %11s %10g  %10g ', char(enc(i).label(k)), enc(i).emiss(k), enc(i).A(k));
      for j=1:length(enc(i).F(k,:))
        fprintf(fid,' %6.4f', enc(i).F(k,j));
      end
      fprintf(fid,'\n');
    end
    fprintf(fid,'\n    Generated Radiation Conductors for this Enclosure\n\n');
    fprintf(fid,  '    Label        Type       Node i     Node j    script-F     Area\n', u.Q);
    fprintf(fid,  ' ---------- ------------- ---------- ---------- ---------- ----------\n');
    for k=1:length(enc(i).eln)
      e = enc(i).eln(k);
      fprintf(fid,' %10s %13s %10s %10s %10g %10g\n',el(e).label, el(e).type, el(e).nd1, el(e).nd2, el(e).sF, el(e).A);
    end
  end
end

%--------------------------------------------------------------------------
%  Write out the element parameters grouped by element type
%--------------------------------------------------------------------------

fprintf(fid,'\n*** Conductor Parameters ***\n');

for e=1:nel
  types(e) = el(e).elst;
end  
types = unique(types);

for i=1:length(types)
  switch types(i)

    case 1  %  Conduction
    case 2  %  Convection
    case 3  %  Radiation
      fprintf(fid,'\nradiation: Surface to Surface Radiation\n\n');
      fprintf(fid,'                h_r\n');
      fprintf(fid,'    label    (%s)\n',u.h);
      fprintf(fid,' ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g\n',el(e).label, el(e).hr);
        end
      end
    case 4  %  Surface Radiation
      fprintf(fid,'\nsurfrad: Surface Radiation\n\n');
      fprintf(fid,'                h_r\n');
      fprintf(fid,'    label    (%s)\n',u.h);
      fprintf(fid,' ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g\n',el(e).label, el(e).hr);
        end
      end
    case 5
    case 6  %  EFC cylinder
      fprintf(fid,'\nEFCcyl: External Forced Convection - Cylinder\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Re Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Re, el(e).Nu, el(e).h);
        end
      end
    case 7  %  ENC Horizontal cylinder
      fprintf(fid,'\nENChcyl: External Natural Convection - Horizontal Cylinder\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Ra Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Ra, el(e).Nu, el(e).h);
        end
      end
    case 8  %  EFC diamond
      fprintf(fid,'\nEFCdiamond: External Forced Convection - Diamond\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Re Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Re, el(e).Nu, el(e).h);
        end
      end
    case 9  %  ENC Horizontal plate up
      fprintf(fid,'\nENChplateup: External Natural Convection - Horizontal Plate Up\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Ra Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Ra, el(e).Nu, el(e).h);
        end
      end
    case 10  %  ENC Horizontal plate down
      fprintf(fid,'\nENChplatedown: External Natural Convection - Horizontal Plate Down\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Ra Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Ra, el(e).Nu, el(e).h);
        end
      end
    case 11  %  ENC Vertical plate
      fprintf(fid,'\nENCvplate: External Natural Convection - Vertical Plate\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Ra Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Ra, el(e).Nu, el(e).h);
        end
      end
    case 12  %  ENC Inclined up plate
      fprintf(fid,'\nENCiplateup: External Natural Convection - Inclined Plate Up\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Ra Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Ra, el(e).Nu, el(e).h);
        end
      end
    case 13  %  ENC Inclined down plate
      fprintf(fid,'\nENCiplatedown: External Natural Convection - Inclined Plate Down\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Ra Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Ra, el(e).Nu, el(e).h);
        end
      end
    case 16  %  IFC Duct
      fprintf(fid,'\nIFCduct: Internal Forced Convection - Duct\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Re Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Re, el(e).Nu, el(e).h);
        end
      end
    case 17  %  EFC Plate
      fprintf(fid,'\nEFCplate: External Forced Convection - Flat Plate\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Re Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Re, el(e).Nu, el(e).h);
        end
      end
    case 18  %  ENC Sphere
      fprintf(fid,'\nENCsphere: External Natural Convection - Sphere\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Ra Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Ra, el(e).Nu, el(e).h);
        end
      end
    case 19  %  EFC sphere
      fprintf(fid,'\nEFCsphere: External Forced Convection - Sphere\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Re Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Re, el(e).Nu, el(e).h);
        end
      end
    case 20  %  EFC impinging jet
      fprintf(fid,'\nEFCimpjet: External Forced Convection - Impinging Round Jet\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Re Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Re, el(e).Nu, el(e).h);
        end
      end
    case 21  %  INC Vertical Enclosure
      fprintf(fid,'\nINCvenc: Internal Natural Convection - Vertical Rectangular Enclosure\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    Ra Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10g %10g %10g\n',el(e).label, el(e).Ra, el(e).Nu, el(e).h);
        end
      end
    case 22  %  Forced Convection User Function
      fprintf(fid,'\nFCuser: Forced Convection User Function\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    function   Re Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10s %10g %10g %10g\n',el(e).label, func2str(el(e).function), el(e).Re, el(e).Nu, el(e).h);
        end
      end
    case 23  %  Natural Convection User Function
      fprintf(fid,'\nNCuser: Natural Convection User Function\n\n');
      fprintf(fid,'                                       h\n');
      fprintf(fid,'    label    function   Ra Number  Nu Number  (%s)\n',u.h);
      fprintf(fid,' ---------- ---------- ---------- ---------- ----------\n');
      for e=1:nel
        if el(e).elst == types(i)
          fprintf(fid,' %10s %10s %10g %10g %10g\n',el(e).label, func2str(el(e).function), el(e).Ra, el(e).Nu, el(e).h);
        end
      end
  end
end  

%--------------------------------------------------------------------------
%  Output the CV energy balance for each node
%--------------------------------------------------------------------------

%  Set up the node-node connectivity for the model

%  First thing is the sparse element-node matrix
%    find(elnd(e,:)) - returns the nodes for element e

elnd = spalloc(nel, nnd, nel*2);  % 2 nodes per element

for e=1:nel
  elnd(e,el(e).elnd(1)) = 1;
  elnd(e,el(e).elnd(2)) = 1;
end

%  node-element connectivity is the tranpsose of element-node
%    find(ndel(n,:)) - returns the elements connected to node n

ndel = spalloc(nnd, nel, nel*2);  %  same number of nonzeros as elnd
ndel = elnd';

%  node-node is node-element x element-node
%    find(ndnd(n,:)) - returns the nodes connected to node n

ndnd = ndel*elnd;

fprintf(fid,'\n*** Control Volume Energy Balances ***\n');

for n=1:nnd
  fprintf(fid,'\nEnergy balance for node: %s\n\n',nd(n).label);
  fprintf(fid,'    nd_i   -  conductor -     nd_j        T_i        T_j       Q_ij    direction\n');
  conels = find(ndel(n,:));  %  Connected elements to node n
  for i=1:length(conels)
    e = conels(i);
    if el(e).elnd(1) == n
      if el(e).Q < 0.0
        dir = 'in';
      else
        dir = 'out';
      end
    elseif el(e).elnd(2) == n
      if el(e).Q < 0.0
        dir = 'out';
      else
        dir = 'in';
      end
    end     
    fprintf(fid,'%10s - %10s - %10s, %10g %10g %10g    %s\n', el(e).nd1, el(e).label, el(e).nd2, ...
      nd(el(e).elnd(1)).T, nd(el(e).elnd(2)).T, el(e).Q,dir);
  end
end


%--------------------------------------------------------------------------
%  Output the library material properties used by the model
%--------------------------------------------------------------------------

j = 0;
for e=1:nel
  if ~isempty(el(e).matID)
    j = j + 1;
    matID(j) = el(e).matID;
  end
end
for n=1:nnd
  if ~isempty(nd(n).matID)
    j = j + 1;
    matID(j) = nd(n).matID;
  end
end

if j > 0
  matID = unique(matID);
  fprintf(fid,'\n*** Material Library Properties Used in the Model ***\n');
  writemat(fid, mat, matID);
end
