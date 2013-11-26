function list=fullfilelist(varargin)
%FULLFILELIST Build full filename from parts.
%   FULLFILELIST(D1,D2, ... ,{FILES}) builds a cell list of 
%   full file name from the directories D1,D2, etc and filenames
%   FILES specified.  This is  conceptually equivalent to
%
%      F{i} = [D1 filesep D2 filesep ... filesep FILE{i}]
%   the function is just a wrapper around FULLFILE
%
% 2005, Alexander Heimel
%

f=varargin{end};
for i=1:length(f)
  args={varargin{1:end-1},f{i}};
  list{i}=fullfile( args{:} );
end
