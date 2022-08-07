function writemat(fid, mat, matID)
%writemat(fid, mat, matID)
%
%  Description:
%
%    Print the material library.
%
%  Inputs:
%
%    fid     = opened file handle
%                1   = output to screen
%                      MATLAB reserves file identifiers 0, 1, and 2 for 
%                      standard input, standard output (the screen), and 
%                      standard error, respectively.
%                fid = fopen('file','wt') 'r'ead|'w'rite|'a'ppend
%    mat     = material library struct
%    matID() = vector of the material ID's to print <optional>
%              if not provided, then print them all
%
%==========================================================================

%  "enumurations"

SOLID  = 1;
LIQUID = 2;
GAS    = 3;

CONST  = 1;
TABLE  = 2;  % use interp1(x,y,u,'linear')
SPLINE = 3;  % use interp1(x,y,u,'pchip'), same as: pchip(x,y,u)
POLY   = 4;  % use polyval(a,u)
USER   = 5;  % user function - @func(t, T) time and temperature

state = {'solid', 'liquid', 'gas'};
type  = {'constant', 'table', 'monotonic spline', 'polynomial', 'user'};

if nargin == 2
  matID = 1:length(mat);
end

for n=matID

  fprintf(fid,'\n');
  fprintf(fid,'Name  = %s\n', mat(n).name);
  if ~isempty(mat(n).state)
  fprintf(fid,'State = %s\n', state{mat(n).state});

  if ~isempty(mat(n).ktype)
  fprintf(fid,'\n');
  fprintf(fid,'Thermal Conductivity\n');
  fprintf(fid,'  Type  = %s\n',type{mat(n).ktype});
  if mat(n).ktype == POLY
  elseif mat(n).ktype == USER
  else
    fprintf(fid,'  %6s      %6s\n',mat(n).kunits{:});
    for i=1:size(mat(n).kdata,1)
      fprintf(fid,'  %7.1f  %10g\n',mat(n).kdata(i,:));
    end
  end
  end
  
  if ~isempty(mat(n).rhotype)
  fprintf(fid,'\n');
  fprintf(fid,'Density\n');
  fprintf(fid,'  Type  = %s\n',type{mat(n).rhotype});
  if mat(n).rhotype == POLY
  elseif mat(n).rhotype == USER
  else
    fprintf(fid,'  %6s      %6s\n',mat(n).rhounits{:});
    for i=1:size(mat(n).rhodata,1)
      fprintf(fid,'  %7.1f  %10g\n',mat(n).rhodata(i,:));
    end
  end
  end

  if ~isempty(mat(n).cptype)
  fprintf(fid,'\n');
  fprintf(fid,'Constant Pressure Specific Heat\n');
  fprintf(fid,'  Type  = %s\n',type{mat(n).cptype});
  if mat(n).cptype == POLY
  elseif mat(n).cptype == USER
  else
    fprintf(fid,'  %6s      %6s\n',mat(n).cpunits{:});
    for i=1:size(mat(n).cpdata,1)
      fprintf(fid,'  %7.1f  %#10g\n',mat(n).cpdata(i,:));
    end
  end
  end

  if ~isempty(mat(n).cvtype)
  fprintf(fid,'\n');
  fprintf(fid,'Constant Volume Specific Heat\n');
  fprintf(fid,'  Type  = %s\n',type{mat(n).cvtype});
  if mat(n).cvtype == POLY
  elseif mat(n).cvtype == USER
  else
    fprintf(fid,'  %6s      %6s\n',mat(n).cvunits{:});
    for i=1:size(mat(n).cvdata,1)
      fprintf(fid,'  %7.1f  %#10g\n',mat(n).cvdata(i,:));
    end
  end
  end

  if mat(n).state == LIQUID || mat(n).state == GAS

  if ~isempty(mat(n).mutype)
  fprintf(fid,'\n');
  fprintf(fid,'Viscosity\n');
  fprintf(fid,'  Type  = %s\n',type{mat(n).mutype});
  if mat(n).mutype == POLY
  elseif mat(n).mutype == USER
  else
    fprintf(fid,'  %6s      %6s\n',mat(n).muunits{:});
    for i=1:size(mat(n).mudata,1)
      fprintf(fid,'  %7.1f  %10g\n',mat(n).mudata(i,:));
    end
  end
  end

  if ~isempty(mat(n).betatype)
  fprintf(fid,'\n');
  fprintf(fid,'Volumetric Thermal Expansion Coefficient, beta\n');
  fprintf(fid,'  Type  = %s\n',type{mat(n).betatype});
  if mat(n).betatype == POLY
  elseif mat(n).betatype == USER
  else
    fprintf(fid,'  %6s      %6s\n',mat(n).betaunits{:});
    for i=1:size(mat(n).betadata,1)
      fprintf(fid,'  %7.1f  %10g\n',mat(n).betadata(i,:));
    end
  end
  end
  
  if ~isempty(mat(n).Prtype)
  fprintf(fid,'\n');
  fprintf(fid,'Prandtl number, Pr\n');
  fprintf(fid,'  Type  = %s\n',type{mat(n).Prtype});
  if mat(n).Prtype == POLY
  elseif mat(n).Prtype == USER
  else
    fprintf(fid,'  %6s      %6s\n',mat(n).Prunits{:});
    for i=1:size(mat(n).Prdata,1)
      fprintf(fid,'  %7.1f  %10g\n',mat(n).Prdata(i,:));
    end
  end
  end
  
  end

  fprintf(fid,'\n');
  fprintf(fid,'Reference:\n');
  fprintf(fid, mat(n).ref);
  end
end  
