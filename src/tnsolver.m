function [T, Q, nd, el] = tnsolver(basefilename, quiet)
%[T, Q, nd, el] = tnsolver(basefilename, quiet)
%
%  Description:
%
%    TNSolver is a thermal network solver.  The thermal model is described
%    in the input file.  See the user manual for a description of the input
%    file format.
%
%  Input:
%
%    basefilename = a character string of the base name of the input file
%                     'basefilename'.inp
%    quite        = an optional argument: 'quiet', that turns off screen 
%                     output
%
%  Output:
%
%    Model results written to: 'basefilename'.out
%
%    T()  = nodal temperatures
%    Q()  = conductor total heat flow from first to second node
%    nd() = node data structure
%           nd().label = node label character string
%           nd().mat   = material character string
%           nd().vol   = volume
%           nd().T     = temperature
%    el() = conductor element data structure
%           el().label = conductor label character string
%           el().type  = type of conductor character string
%           el().nd1   = node 1 label character string
%           el().nd2   = node 2 label character string
%
%  Functions Called:
%
%    readinp    = parse the input file
%    init       = initialize the model
%    tnsdriver  = solution driver
%    writeout   = write the output file
%
%  License:
%
%    Developed using Octave: http://www.gnu.org/software/octave/
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%  Contact:
%
%    Bob Cochran
%    Applied CHT
%    rjc@heattransfer.org
%
%  History:
%
%    Who    Date   Version  Note
%    ---  -------- -------  -----------------------------------------------
%    RJC  09/30/14  0.1.0   Initial release.
%    RJC  10/28/14  0.2.0   All forms of a steady model are working.
%    RJC  02/15/15  0.3.0   Transient solver is now working.
%    RJC  10/13/15  0.4.0   Improved error handling, additional
%                           conductors and radiation enclosure
%
%==========================================================================

global scrout
scrout = 1;  %  Screen output is on by default
if nargin == 0
  error('TNSolver: You must supply the base name of the input file.\n')
elseif nargin == 2
  scrout = 0;  %  Turn off screen output
elseif nargin > 2  
  error('TNSolver: You have more than two input arguments.\n')
end  

%  Splash screen

if scrout
fprintf('\n**********************************************************\n')
fprintf(  '*                                                        *\n')
fprintf(  '*          TNSolver - A Thermal Network Solver           *\n')
fprintf(  '*                                                        *\n')
fprintf(  '*           %33s            *\n',verdate);
fprintf(  '*                                                        *\n')
fprintf(  '**********************************************************\n')
end

%  Open the input file

infile = [basefilename '.inp'];
fid = fopen(infile,'r');

global logfID
logfile = [basefilename '.log'];
logfID = fopen(logfile,'w');

fprintf(logfID,'\n**********************************************************\n');
fprintf(logfID,  '*                                                        *\n');
fprintf(logfID,  '*          TNSolver - A Thermal Network Solver           *\n');
fprintf(logfID,  '*                                                        *\n');
fprintf(logfID,  '*           %33s            *\n',verdate);
fprintf(logfID,  '*                                                        *\n');
fprintf(logfID,  '**********************************************************\n');
fprintf(logfID,'\nModel run started at %s, on %s\n',   ...
        datestr(now,'HH:MM AM'), datestr(now,'mmmm dd, yyyy'));

if (fid < 0)
  errmsg = sprintf('TNSolver: Cannot open the input file: %s\n', infile);
  fprintf(logfID,errmsg);
  fclose('all');
  error(errmsg)
end

%  Read the thermal model input file

if scrout fprintf('\nReading the input file: %s\n', which(infile)); end;
fprintf(logfID,'\nReading the input file: %s\n', which(infile));

[inperr, spar, nd, el, bc, src, ic, func, enc, mat] = readinp(fid, basefilename);

if inperr
  fprintf('\nTNSolver: Errors reading the input file.\nPlease correct them and try again.\n\n')
  T  = NaN;
  Q  = NaN;
  nd = NaN;
  el = NaN;
  fclose('all');
  return
end

%  Set the global constants for use with this model

global Toff       %  Set the input/output conversion for T
Toff = spar.Toff; %  T internally is always absolute temperature
global g          %  Gravity
g = spar.g;
global sigma      %  Stefan-Boltzmann constant
sigma = spar.sigma;

%  Initialize the thermal model

if scrout fprintf('\nInitializing the thermal network model ...\n'); end;

[T, Q, spar, nd, el, bc, src, ic, func, enc, mat] = init(spar, nd, el, bc, src, ic, func, enc, mat);

%  Solve the thermal model

if spar.steady
  if scrout fprintf('\nStarting solution of a steady thermal network model ...\n'); end;
else
  if scrout fprintf('\nStarting solution of a transient thermal network model ...\n'); end;
end  

[T, Q, spar, nd, el, src, func] = tnsdriver(T, Q, spar, nd, el, bc, src, func, mat);

outfile = [basefilename '.out'];
fid = fopen(outfile,'wt');
if (fid < 0)
  error('TNSolver: Cannot open the output file: %s\n', outfile)
end
writeout(fid, spar, nd, el, bc, src, ic, enc, mat);
fclose(fid);
if scrout fprintf('\nResults have been written to: %s\n',outfile); end;

outfile = [basefilename '_nd.csv'];
fid = fopen(outfile,'wt');
if (fid < 0)
  error('TNSolver: Cannot open the output file: %s\n', outfile)
end
wrtcsvnd(fid, spar, nd);
fclose(fid);
if scrout fprintf('\nNode results have been written to: %s\n',outfile); end;

outfile = [basefilename '_cond.csv'];
fid = fopen(outfile,'wt');
if (fid < 0)
  error('TNSolver: Cannot open the output file: %s\n', outfile)
end
wrtcsvel(fid, spar, nd, el);
fclose(fid);
if scrout fprintf('\nConductor results have been written to: %s\n',outfile); end;

rstfile = [basefilename '.rst'];
fid = fopen(rstfile,'wt');
if (fid < 0)
  error('TNSolver: Cannot open the restart file: %s\n', rstfile)
end
writerst(fid, spar.time, nd);
fclose(fid);
if scrout fprintf('\nRestart has been written to: %s\n',rstfile); end;

if spar(1).graphviz
  outfile = [basefilename '.gv'];
  fid = fopen(outfile,'wt');
  if (fid < 0)
    error('TNSolver: Cannot open the Graphviz file: %s\n', outfile)
  end
  writegv(fid, spar, nd, el, bc, src);
  fclose(fid);
  if scrout fprintf('\nGraphviz dot file has been written to: %s\n',outfile); end;
end

fclose(logfID);

if scrout fprintf('\nAll done ...\n\n'); end;
