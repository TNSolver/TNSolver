function wrtcsvel(fid, spar, nd, el)
%wrtcsvel(fid, spar, nd, el)
%
%==========================================================================

u = setunits(spar.units);

fprintf(fid,  ...
  '"label","type","nd_i","nd_j","T_i (%s)","T_j (%s)","Q (%s)","U (%s)","A (%s)"\n',  ...
  u.T,u.T,u.Q,u.h,u.A);

for e=1:length(el)
  fprintf(fid,'"%s","%s","%s","%s",%g,%g,%g,%g,%g\n', ...
          el(e).label, el(e).type, el(e).nd1, el(e).nd2, ...
          nd(el(e).elnd(1)).T, nd(el(e).elnd(2)).T, el(e).Q,  ...
          el(e).U, el(e).A);
end  
