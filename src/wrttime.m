function wrttime(fid, stepn, time, nd, el)
%wrttime(fid, stepn, time, nd, el);
%
%  Description:
%
%    Write a time step to the CSV file.
%
%  Inputs:
%
%    fid   = 
%    stepn = time step number
%    time  = current time
%    nd()  = node data struct
%    el()  = element data struct
%
%  Outputs:
%
%    none
%
%==========================================================================

global Toff

if stepn == 0

%  Write out the header info to the file  

%   fprintf(fid,',');
%   for n=1:length(nd)
%     fprintf(fid,' "%s",','node T');
%   end
%   for e=1:length(el)
%     fprintf(fid,' "%s",','conductor Q');
%   end
%   fprintf(fid,'\n');
  fprintf(fid,' "%s",','time');
  for n=1:length(nd)
    fprintf(fid,' "T_%s",',nd(n).label);
  end
  for e=1:length(el)
    fprintf(fid,' "Q_%s",',el(e).label);
  end
  for e=1:length(el)
    fprintf(fid,' "U_%s",',el(e).label);
  end
  fprintf(fid,'\n');
end

%  Write the state data at this time point

fprintf(fid,' %g,',time);
for n=1:length(nd)
  fprintf(fid,' %g,',nd(n).T-Toff);
end
for e=1:length(el)
  fprintf(fid,' %g,',el(e).Q);
end
for e=1:length(el)
  fprintf(fid,' %g,',el(e).U);
end
fprintf(fid,'\n');
