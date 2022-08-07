function [sF] = scriptF(emiss, F)
%[sF] = scriptF(emiss, F)
%
%  Description:
%
%    Evaluate the "script-F" or transfer factors for an enclosure radiation
%    problem, given the geometric view factors and surface emissivities.
%
%  Input:
%
%    emiss(:) = vector of surface emissivities
%                 - length(emiss) = number of enclosure surfaces
%    F(:,:)   = geometric view factor matrix
%                 - can be a full or sparse matrix
%
%  Output:
%
%    sF(:,:)  = script-F matrix
%                 - if F is sparse, then sF will be sparse
%
%  Reference:
%
%    B. Gebhart, "Heat Transfer," McGraw-Hill, New York, second edition, 
%      1971
%
%==========================================================================

nsurf = length(emiss);    %  Number of surfaces in the enclosure

%  Initialize matrices based on full or sparse F

if issparse(F)
  I   = speye(nsurf);        %  Sparse identity matrix
  eps = spdiags(emiss(:),0,nsurf,nsurf);  %  Emissivity diagonal matrix
else  
  I   = eye(nsurf);          %  Identity matrix
  eps = diag(emiss);         %  Emissivity diagonal matrix
end

rho = I - eps;               %  Reflectivity diagonal matrix

%  Solve for script-F using Gebhart's aborption factor formulation
%    ([I] - [F][rho])[B] = [F][eps]

 B = (I - F*rho)\(F*eps);  %  Absorption factors matrix from view factors
sF = eps*B;  %  script-F is absorption factors times emissivity
