function [ rowsum, symcheck ] = QCF( A, F)
%[ rowsum, symcheck ] = QCF( A, F);
%
%  Description:
%
%    Quality control check of view factor matrix for enclosure radiation.
%
%  Inputs:
%
%    A(:)   = column vector of surface areas
%    F(:,:) = square matrix of view factors
%
%  Outputs:
%
%    rowsum()   = column vector of row sums of the view factor
%                   matrix, which should be 1 for each row
%    symcheck() = column vector of the difference between the
%                   AF and AF' rows, which should be zero for 
%                   each row
%
%==========================================================================

% Row sum property: each row should sum to 1

rowsum = sum(F,2);  % Sum each row in the view factor matrix


% Reciprocity relationship: A_i*F_ij = A_j*F_ji
% Take the difference of AF and its transpose and row sum the results.

symcheck = sum(diag(A)*F - (diag(A)*F).',2);
