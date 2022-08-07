function [lnum, eof, inperr, mat] = readmat(fid, lnum, eof, inperr, matname, mat)
%[lnum, eof, inperr, mat] = readfunc(fid, lnum, eof, inperr, matname, mat)
%
%  Description:
%
%    Read a material property block from the input file and store it in the
%    mat structure.
%
%  Inputs:
%
%    fid     - file ID to read from
%    lnum    - current line number in the file
%    eof     - end of file flag
%    inperr  - input error flag
%    matname - name of the material
%    mat()   - the material property library structure
%
%  Outputs:
%
%    lnum   - current line number in the file
%    eof    - end of file flag
%    inperr - input error flag
%    mat()  - the material property structure
%
%==========================================================================

global Toff

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

%  Add material parsed from input file

nmat = length(mat);
nmat = nmat + 1;
mat(nmat).name = matname;

while ~eof
  [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
  if isempty(regexpi(str,'end.*material'))
    tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
    ntok = length(tok);
    matcmd = upper(tok{1});
    switch matcmd
%--------------------------------------------------------------------------
      case 'STATE'
        state = upper(tok{2});
        if state == 'SOLID'
          mat(nmat).state = SOLID;
        elseif state == 'LIQUID'
          mat(nmat).state = LIQUID;
        elseif state == 'GAS'
          mat(nmat).state = GAS;
        else
          fprintf('\nERROR: Invalid state at line %d in the input file:\n%s\n',lnum,str)
          inperr = 1;
        end
%--------------------------------------------------------------------------
      case 'DENSITY'
        dens = upper(tok{2});
        switch dens
          case 'TABLE'
            mat(nmat).rhotype = TABLE;
            mat(nmat).rhounits = { '(K)', '(kg/m^3)' };
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*density.*table'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid density data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).rhodata(ndat,1) = tdata + Toff;
                mat(nmat).rhodata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'SPLINE'
            mat(nmat).rhotype = SPLINE;
            mat(nmat).rhounits = { '(K)', '(kg/m^3)' };
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*density.*spline'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid density data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).rhodata(ndat,1) = tdata + Toff;
                mat(nmat).rhodata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'POLYNOMIAL'
            mat(nmat).rhotype = POLY;
            mat(nmat).rhounits = { '(K)', '(kg/m^3)' };
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*density.*polynomial'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                rcmd = upper(tok{1});
                switch rcmd
                  case 'RANGE'
                    mat(nmat).rhorange = [str2double(tok{2}) + Toff, str2double(tok{3}) + Toff];
                  otherwise
                    for i=1:ntok
                    mat(nmat).rhodata(i) = str2double(tok{i});
                    if isnan(mat(nmat).rhodata(i))
                      fprintf('\nERROR: Invalid density data at line %d in the input file:\n%s\n',lnum,str)
                      inperr = 1;
                    end
                  end
                end
              else
                break
              end
            end
          case 'IDEAL'

          otherwise
            mat(nmat).rhotype  = CONST;
            mat(nmat).rhounits = { '(K)', '(kg/m^3)' };
            mat(nmat).rhodata  = [Toff, str2double(tok{2})];
            if isnan(mat(nmat).rhodata(2))
              fprintf('\nERROR: Invalid density data at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
        end
%--------------------------------------------------------------------------
      case 'CONDUCTIVITY'
        cond = upper(tok{2});
        switch cond
          case 'TABLE'
            mat(nmat).ktype = TABLE;
            mat(nmat).kunits = {  '(K)', '(W/m-K)' };
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*conductivity.*table'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid conductivity data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).kdata(ndat,1) = tdata + Toff;
                mat(nmat).kdata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'SPLINE'
            mat(nmat).ktype = SPLINE;
            mat(nmat).kunits = {  '(K)', '(W/m-K)' };
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*conductivity.*spline'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid conductivity data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).kdata(ndat,1) = tdata + Toff;
                mat(nmat).kdata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'POLYNOMIAL'
            mat(nmat).ktype = POLY;
            mat(nmat).kunits = {  '(K)', '(W/m-K)' };
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*conductivity.*polynomial'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                rcmd = upper(tok{1});
                switch rcmd
                  case 'RANGE'
                    mat(nmat).krange = [str2double(tok{2}) + Toff, str2double(tok{3}) + Toff];
                  otherwise
                    for i=1:ntok
                    mat(nmat).kdata(i) = str2double(tok{i});
                    if isnan(mat(nmat).kdata(i))
                      fprintf('\nERROR: Invalid conductivity data at line %d in the input file:\n%s\n',lnum,str)
                      inperr = 1;
                    end
                  end
                end
              else
                break
              end
            end
          otherwise
            mat(nmat).ktype  = CONST;
            mat(nmat).kunits = { '(K)', '(kg/m^3)' };
            mat(nmat).kdata  = [ Toff, str2double(tok{2})];
            if isnan(mat(nmat).kdata(2))
              fprintf('\nERROR: Invalid conductivity data at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
        end
%--------------------------------------------------------------------------
      case 'SPECIFIC'
        cv = upper(tok{3});
        mat(nmat).cvunits = {'(K)', '(J/kg-K)'};
        switch cv
          case 'TABLE'
            mat(nmat).cvtype = TABLE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*specific.*heat.*table'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid specific heat data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).cvdata(ndat,1) = tdata + Toff;
                mat(nmat).cvdata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'SPLINE'
            mat(nmat).cvtype = SPLINE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*specific.*heat.*spline'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid specific heat data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).cvdata(ndat,1) = tdata + Toff;
                mat(nmat).cvdata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'POLYNOMIAL'
            mat(nmat).cvtype = POLY;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*specific.*heat.*polynomial'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                rcmd = upper(tok{1});
                switch rcmd
                  case 'RANGE'
                    mat(nmat).cvrange = [str2double(tok{2}) + Toff, str2double(tok{3}) + Toff];
                  otherwise
                    for i=1:ntok
                    mat(nmat).cvdata(i) = str2double(tok{i});
                    if isnan(mat(nmat).cvdata(i))
                      fprintf('\nERROR: Invalid specific heat data at line %d in the input file:\n%s\n',lnum,str)
                      inperr = 1;
                    end
                  end
                end
              else
                break
              end
            end
          otherwise
            mat(nmat).cvtype  = CONST;
            mat(nmat).cvdata  = [ Toff, str2double(tok{3})];
            if isnan(mat(nmat).cvdata(2))
              fprintf('\nERROR: Invalid specific heat data at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
        end
%--------------------------------------------------------------------------
      case 'C_V'
        cv = upper(tok{2});
        mat(nmat).cvunits = {'(K)', '(J/kg-K)'};
        switch cv
          case 'TABLE'
            mat(nmat).cvtype = TABLE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*c_v.*table'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid specific heat data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).cvdata(ndat,1) = tdata + Toff;
                mat(nmat).cvdata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'SPLINE'
            mat(nmat).cvtype = SPLINE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*c_v.*spline'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid specific heat data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).cvdata(ndat,1) = tdata + Toff;
                mat(nmat).cvdata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'POLYNOMIAL'
            mat(nmat).cvtype = POLY;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*c_v.*polynomial'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                rcmd = upper(tok{1});
                switch rcmd
                  case 'RANGE'
                    mat(nmat).cvrange = [str2double(tok{2}) + Toff, str2double(tok{3}) + Toff];
                  otherwise
                    for i=1:ntok
                    mat(nmat).cvdata(i) = str2double(tok{i});
                    if isnan(mat(nmat).cvdata(i))
                      fprintf('\nERROR: Invalid specific heat data at line %d in the input file:\n%s\n',lnum,str)
                      inperr = 1;
                    end
                  end
                end
              else
                break
              end
            end
          otherwise
            mat(nmat).cvtype  = CONST;
            mat(nmat).cvdata  = [ Toff, str2double(tok{2})];
            if isnan(mat(nmat).cvdata(2))
              fprintf('\nERROR: Invalid specific heat data at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
        end
%--------------------------------------------------------------------------
      case 'C_P'
        cp = upper(tok{2});
        mat(nmat).cpunits = {'(K)', '(J/kg-K)'};
        switch cp
          case 'TABLE'
            mat(nmat).cptype = TABLE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*c_p.*table'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid c_p data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).cpdata(ndat,1) = tdata + Toff;
                mat(nmat).cpdata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'SPLINE'
            mat(nmat).cptype = SPLINE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*c_p.*spline'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid c_p data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).cpdata(ndat,1) = tdata + Toff;
                mat(nmat).cpdata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'POLYNOMIAL'
            mat(nmat).cptype = POLY;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*c_p.*polynomial'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                rcmd = upper(tok{1});
                switch rcmd
                  case 'RANGE'
                    mat(nmat).cprange = [str2double(tok{2}) + Toff, str2double(tok{3}) + Toff];
                  otherwise
                    for i=1:ntok
                    mat(nmat).cpdata(i) = str2double(tok{i});
                    if isnan(mat(nmat).cpdata(i))
                      fprintf('\nERROR: Invalid c_p data at line %d in the input file:\n%s\n',lnum,str)
                      inperr = 1;
                    end
                  end
                end
              else
                break
              end
            end
          otherwise
            mat(nmat).cptype  = CONST;
            mat(nmat).cpdata  = [ Toff, str2double(tok{2})];
            if isnan(mat(nmat).cpdata(2))
              fprintf('\nERROR: Invalid c_p data at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
        end
%--------------------------------------------------------------------------
      case 'VISCOSITY'
        mu = upper(tok{2});
        mat(nmat).muunits = {'(K)', '(kg/m-s)'};
        switch mu
          case 'TABLE'
            mat(nmat).mutype = TABLE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*viscosity.*table'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid viscosity data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).mudata(ndat,1) = tdata + Toff;
                mat(nmat).mudata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'SPLINE'
            mat(nmat).mutype = SPLINE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*viscosity.*spline'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid viscosity data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).mudata(ndat,1) = tdata + Toff;
                mat(nmat).mudata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'POLYNOMIAL'
            mat(nmat).mutype = POLY;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*viscosity.*polynomial'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                rcmd = upper(tok{1});
                switch rcmd
                  case 'RANGE'
                    mat(nmat).murange = [str2double(tok{2}) + Toff, str2double(tok{3}) + Toff];
                  otherwise
                    for i=1:ntok
                    mat(nmat).mudata(i) = str2double(tok{i});
                    if isnan(mat(nmat).mudata(i))
                      fprintf('\nERROR: Invalid viscosity data at line %d in the input file:\n%s\n',lnum,str)
                      inperr = 1;
                    end
                  end
                end
              else
                break
              end
            end
          otherwise
            mat(nmat).mutype  = CONST;
            mat(nmat).mudata  = [ Toff, str2double(tok{2})];
            if isnan(mat(nmat).mudata(2))
              fprintf('\nERROR: Invalid viscosity data at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
        end
%--------------------------------------------------------------------------
      case {'BETA'}
        beta = upper(tok{2});
        mat(nmat).betaunits = {'(K)', '(1/K)'};
        switch beta
          case 'TABLE'
            mat(nmat).betatype = TABLE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*beta.*table'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid beta data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).betadata(ndat,1) = tdata + Toff;
                mat(nmat).betadata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'SPLINE'
            mat(nmat).betatype = SPLINE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*beta.*spline'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid beta data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).betadata(ndat,1) = tdata + Toff;
                mat(nmat).betadata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'POLYNOMIAL'
            mat(nmat).betatype = POLY;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*beta.*polynomial'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                rcmd = upper(tok{1});
                switch rcmd
                  case 'RANGE'
                    mat(nmat).betarange = [str2double(tok{2}) + Toff, str2double(tok{3}) + Toff];
                  otherwise
                    for i=1:ntok
                    mat(nmat).betadata(i) = str2double(tok{i});
                    if isnan(mat(nmat).betadata(i))
                      fprintf('\nERROR: Invalid viscosity data at line %d in the input file:\n%s\n',lnum,str)
                      inperr = 1;
                    end
                  end
                end
              else
                break
              end
            end
          otherwise
            mat(nmat).betatype  = CONST;
            mat(nmat).betadata  = [ Toff, str2double(tok{2})];
            if isnan(mat(nmat).betadata(2))
              fprintf('\nERROR: Invalid beta data at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
        end
%--------------------------------------------------------------------------
      case {'PR'}
        Pr = upper(tok{2});
        mat(nmat).Prunits = {'(K)', '(dimensionless)'};
        switch Pr
          case 'TABLE'
            mat(nmat).Prtype = TABLE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*Pr.*table'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid Prandtl number data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).Prdata(ndat,1) = tdata + Toff;
                mat(nmat).Prdata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'SPLINE'
            mat(nmat).Prtype = SPLINE;
            ndat = 0;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*Pr.*spline'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                ndat = ndat + 1;
                tdata = str2double(tok{1});
                vdata = str2double(tok{2});
                if isnan(tdata) || isnan(vdata)
                  fprintf('\nERROR: Invalid Prandtl number data at line %d in the input file:\n%s\n',lnum,str)
                  inperr = 1;
                end
                mat(nmat).Prdata(ndat,1) = tdata + Toff;
                mat(nmat).Prdata(ndat,2) = vdata;
              else
                break
              end
            end
          case 'POLYNOMIAL'
            mat(nmat).Prtype = POLY;
            while ~eof
              [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
              if isempty(regexpi(str,'end.*Pr.*polynomial'))
                tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
                ntok = length(tok);
                rcmd = upper(tok{1});
                switch rcmd
                  case 'RANGE'
                    mat(nmat).Prrange = [str2double(tok{2}) + Toff, str2double(tok{3}) + Toff];
                  otherwise
                    for i=1:ntok
                    mat(nmat).Prdata(i) = str2double(tok{i});
                    if isnan(mat(nmat).Prdata(i))
                      fprintf('\nERROR: Invalid Prandtl number data at line %d in the input file:\n%s\n',lnum,str)
                      inperr = 1;
                    end
                  end
                end
              else
                break
              end
            end
          otherwise
            mat(nmat).Prtype  = CONST;
            mat(nmat).Prdata  = [ Toff, str2double(tok{2})];
            if isnan(mat(nmat).Prdata(2))
              fprintf('\nERROR: Invalid Prandtl number data at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
        end
%--------------------------------------------------------------------------
      case 'GAS'
        mat(nmat).Runits = {'(K)', '()'};
        mat(nmat).R = str2double(tok{3});
        if isnan(mat(nmat).R)
          fprintf('\nERROR: Invalid gas constant at line %d in the input file:\n%s\n',lnum,str)
          inperr = 1;
        end
%--------------------------------------------------------------------------
      case 'REFERENCE'
          beg = strfind(str, '=') + 1;
          mat(nmat).ref = strtrim(str(beg:end));
%--------------------------------------------------------------------------
      otherwise
        fprintf('\nERROR: Unknown material command at line %d in the input file:\n%s\n',lnum,str)
        inperr = 1;
    end
  else
    break
  end
end
