function writerst( fid, time, nd )
%writerst( fid, time, nd )
%
%  Description:
%
%    Write current solution state to restart file.
%
%  Inputs:
%
%    fid  - file ID
%    time - current time
%    nd() - node data structure
%
%==========================================================================

fprintf(fid,' time = %g\n', time);
for i=1:length(nd)
  fprintf(fid,'  %s  %g\n', nd(i).label, nd(i).T);
end

end

