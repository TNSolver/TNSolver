function [lnum, eof, inperr, nsrc, src] = readsrc(fid, lnum, eof, inperr, nsrc, src)
%
%
%==========================================================================

global logfID;

while ~eof
  [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
  if isempty(regexpi(str,'end.*sources'))
    tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
    ntok = length(tok);
    if ntok < 3
      fprintf('\nERROR: Invalid source command at line %d in the input file:\n%s\n',lnum,str)
      fprintf(logfID,'\nERROR: Invalid source command at line %d in the input file:\n%s\n',lnum,str);
      inperr = 1;
    else
      switch upper(tok{1})
        case 'QDOT'
          if ntok < 3
            fprintf('\nERROR: Not enough qdot parameters at line %d in the input file:\n%s\n',lnum,str)
            fprintf(logfID,'\nERROR: Not enough qdot parameters at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          else
            nsrc = nsrc + 1;
            src(nsrc).type  = tok{1};
            src(nsrc).ntype = 1;
            [num, status] = str2num(tok{2});
            if status
              src(nsrc).qdot = num;        % qdot value for the source
            else
              src(nsrc).strqdot = tok{2};  % function name
            end
            for i=3:ntok
              src(nsrc).nds{i-2} = tok{i}; % node labels
            end
          end
        case 'QSRC'
          if ntok < 3
            fprintf('\nERROR: Not enough Qsrc parameters at line %d in the input file:\n%s\n',lnum,str)
            fprintf(logfID,'\nERROR: Not enough Qsrc parameters at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          else
            nsrc = nsrc + 1;
            src(nsrc).type  = tok{1};
            src(nsrc).ntype = 2;
            [num, status] = str2num(tok{2});
            if status
              src(nsrc).Q = num;        % total source value
            else
              src(nsrc).strQ = tok{2};  % function name
            end
            for i=3:ntok
              src(nsrc).nds{i-2} = tok{i}; % node labels
            end
          end
        case 'TSTATQ'
          if ntok < 5
            fprintf('\nERROR: Not enough tstatQ parameters at line %d in the input file:\n%s\n',lnum,str)
            fprintf(logfID,'\nERROR: Not enough tstatQ parameters at line %d in the input file:\n%s\n',lnum,str)
            inperr = 1;
          else
            nsrc = nsrc + 1;
            src(nsrc).type  = tok{1};
            src(nsrc).ntype = 3;
            src(nsrc).Q     = str2double(tok{2});
            src(nsrc).tstat = tok{3};
            src(nsrc).Ton   = str2double(tok{4});
            src(nsrc).Toff  = str2double(tok{5});
            for i=6:ntok
              src(nsrc).nds{i-5} = tok{i};
            end
          end
        otherwise
          fprintf('\nERROR: Unknown type of source at line %d in the input file:\n%s\n',lnum,str)
          fprintf(logfID,'\nERROR: Unknown type of source at line %d in the input file:\n%s\n',lnum,str);
          inperr = 1;    
      end
    end
  else
    break
  end
end
