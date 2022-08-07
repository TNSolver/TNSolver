function [str, lnum, eof] = nextline(fid, lnum)
%[str, lnum, eof] = nextline(fid, lnum)
%
%  Description:
%
%    Fetch the next line from the input file that has content.
%    Skip comment and blank lines in the file.  Close the file and
%    return when the end of file is reached.
%
%  Inputs:
%
%    fid  = opened file ID
%    lnum = last line number read
%
%  Outputs:
%
%    str  = the trimmed line from the file ready for parsing
%    lnum = the line number from the file
%    eof  = end of file indicator
%             0 = no end of file
%             1 = end of file reached - file has been closed
%
%==========================================================================

eof = 0;     %  Initialize end of file as false
str = '';    %  Initialize return string as an empty string

while 1   %  Just keep looping, until a return occurs within the loop

  line = fgetl(fid);  %  Fetch a line from the input file

  if ~ischar(line)    %  Check for end of file
    if ~fclose(fid)   %  Close the file
      eof = 1;
      return
    else
      error('TNSolver: Error closing the input file.')
    end
  end

  lnum = lnum + 1;  %  Have an input line from the file

  str = regexp(line, '!', 'split');  %  str{1} is line before comment

  str = strtrim(str{1});  %  Trim off the leading/trailing blanks

  if ~isempty(str)  %  If the string is empty after trim, it is blank
    return  %  We have a line from the input file to parse, so return
  end

end  %  Fetch another line from the file
