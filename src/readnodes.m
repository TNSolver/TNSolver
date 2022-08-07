function [lnum, eof, inperr, nnd, nd] = readnodes(fid, lnum, eof, inperr, nnd, nd)
%
%
%==========================================================================

global logfID;

while ~eof
  [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
  if isempty(regexpi(str,'end.*nodes'))
    tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
    if length(tok) ~= 3                 % Need 3 tokens
      fprintf('\nERROR: Invalid node command at line %d in the input file:\n%s\n',lnum,str);
      fprintf('Three parameters are required, %d were found.\n',length(tok));
      fprintf(logfID,'\nERROR: Invalid node command at line %d in the input file:\n%s\n',lnum,str);
      fprintf(logfID,'Three parameters are required, %d were found.\n',length(tok));
      inperr = 1;
    else
      nnd = nnd + 1;                    % Add another node to the model
      nd(nnd).label = tok{1};           % Node label
      [num, status] = str2num(tok{2});  % Volumetric heat capacity, rho*c
      if status
        nd(nnd).rhocv = num;
      else
        nd(nnd).mat = tok{2};           % Material name or function name
      end
      [num, status] = str2num(tok{3});  % Node volume
      if status
        nd(nnd).vol = num;
      else
        nd(nnd).strvol = tok{3};        % Function name for volume
      end
    end
  else
    break
  end
end
