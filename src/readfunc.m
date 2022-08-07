function [lnum, eof, inperr, nfunc, func] = readfunc(fid, lnum, eof, inperr, nfunc, func)
%[lnum, eof, inperr, nfunc, func] = readfunc(fid, lnum, eof, inperr, nfunc, func)
%
%  Description:
%
%    Read a functions block from the input file and store it in the
%    func structure.
%
%  Inputs:
%
%    fid    - file ID to read from
%    lnum   - current line number in the file
%    nfunc  - number of functions in the func() structure
%    func() - the function structure
%
%  Outputs:
%
%    lnum   - current line number in the file
%    nfunc  - number of functions in the func() structure
%    func() - the function structure
%
%==========================================================================

while ~eof
  [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
  if isempty(regexpi(str,'end.*functions'))
    tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
    ntok = length(tok);
    if ntok == 3
      funcblock = upper(strcat(tok{1},tok{2}));
    else
      funcblock = upper(strcat(tok{1},tok{2},tok{3}));
    end
    switch funcblock
%--------------------------------------------------------------------------
      case 'BEGINCONSTANT'
        nfunc = nfunc + 1;
        func(nfunc).name = tok{3};  % function name
        func(nfunc).indvar = 0;     % no independent variable for constant
        func(nfunc).type = 0;       % constant function
        while ~eof
          [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
          if isempty(regexpi(str,'end.*constant'))
            tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
            ntok = length(tok);
            func(nfunc).data = str2double(tok{1});
            if isnan(func(nfunc).data)
              fprintf('\nERROR: Invalid function data at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
          else
            break
          end
        end
%--------------------------------------------------------------------------
      case 'BEGINTIMETABLE'
        nfunc = nfunc + 1;
        func(nfunc).name = tok{4};  % function name
        func(nfunc).indvar = 1;     % time is the independent variable
        func(nfunc).type = 1;       % piecewise linear function (table)
        ndat = 0;
        while ~eof
          [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
          if isempty(regexpi(str,'end.*time.*table'))
            tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
            ntok = length(tok);
            ndat = ndat + 1;
            tdata = str2double(tok{1});
            vdata = str2double(tok{2});
            if isnan(tdata) || isnan(vdata)
              fprintf('\nERROR: Invalid function data at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
            func(nfunc).data(ndat,1) = tdata;
            func(nfunc).data(ndat,2) = vdata;
          else
            break
          end
        end
%--------------------------------------------------------------------------
      case 'BEGINTIMESPLINE'
        nfunc = nfunc + 1;
        func(nfunc).name = tok{4};  % function name
        func(nfunc).indvar = 1;     % time is the independent variable
        func(nfunc).type = 2;       % spline function
        ndat = 0;
        while ~eof
          [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
          if isempty(regexpi(str,'end.*time.*spline'))
            tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
            ntok = length(tok);
            ndat = ndat + 1;
            tdata = str2double(tok{1});
            vdata = str2double(tok{2});
            if isnan(tdata) || isnan(vdata)
              fprintf('\nERROR: Invalid function data at line %d in the input file:\n%s\n',lnum,str)
              inperr = 1;
            end
            func(nfunc).data(ndat,1) = tdata;
            func(nfunc).data(ndat,2) = vdata;
          else
            break
          end
        end
%--------------------------------------------------------------------------
      case 'BEGINTIMEPOLYNOMIAL'
        nfunc = nfunc + 1;
        func(nfunc).name = tok{4};  % function name
        func(nfunc).indvar = 1;     % time is the independent variable
        func(nfunc).type = 3;       % polynomial function
        while ~eof
          [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
          if isempty(regexpi(str,'end.*time.*polynomial'))
            tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
            ntok = length(tok);
            fcmd = upper(tok{1});
            switch fcmd
              case 'RANGE'
                func(nfunc).range = [str2double(tok{2}), str2double(tok{3})];
              otherwise
                for i=1:ntok
                  func(nfunc).data(i) = str2double(tok{i});
                  if isnan(func(nfunc).data(i))
                    fprintf('\nERROR: Invalid polynomial data at line %d in the input file:\n%s\n',lnum,str)
                    inperr = 1;
                  end
                end
            end
          else
            break
          end
        end
%--------------------------------------------------------------------------
      case 'BEGINCOMPOSITE'
        nfunc = nfunc + 1;
        func(nfunc).name = tok{3};  % function name
        func(nfunc).type = 4;       % composite function
        while ~eof
          [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
          if isempty(regexpi(str,'end.*composite'))
            tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
            ntok = length(tok);
            for i=1:ntok
              func(nfunc).data{i} = tok{i};
            end
          else
            break
          end
        end
%--------------------------------------------------------------------------
      otherwise
        fprintf('\nERROR: Unknown functions block command at line %d in the input file:\n%s\n',lnum,str)
        inperr = 1;
    end
  else
    break
  end
end
