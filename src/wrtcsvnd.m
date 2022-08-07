function wrtcsvnd(fid, spar, nd)
%wrtcsvnd(fid, spar, nd)
%
%==========================================================================

u = setunits(spar.units);

fprintf(fid,'"label","material","volume (%s)","temperature (%s)"\n',u.V,u.T);

for n=1:length(nd)
  fprintf(fid,'"%s","%s",%g,%g\n', nd(n).label, nd(n).mat, nd(n).vol, nd(n).T);
end  

