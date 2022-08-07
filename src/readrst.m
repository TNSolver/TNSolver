function [ ic ] = readrst( rstfile, nic, ic )
%[ ic, err ] = readrst( filen, nic, ic )
%
%  Description:
%
%    Open and read the restart file.
%
%  Input:
%
%  Output:
%
%==========================================================================

fid = fopen(rstfile,'r');
if (fid < 0)
  error('TNSolver: Cannot open the restart file: %s\n', rstfile)
end

lnum = 0;  %  Line number in the input file
eof = 0;   %  End of input file flag
ndat = 0;

while ~eof
  [str, lnum, eof] = nextline(fid, lnum);  %  Fetch the next input line
  if ~eof
    if isempty(regexpi(str,'time.*='))
      tok = regexp(str,'[a-zA-Z_0-9+-./]*','match');  %  Split string into tokens
      ndat = ndat + 1;
      ic(nic).nds{ndat} = tok{1};
      ic(nic).Tinit(ndat)   = str2double(tok{2});
    end
  else
    fprintf('\nRestart file: %s, has been read.\n',rstfile)
    break
  end
end

end

