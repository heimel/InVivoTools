function [saveScript,MTI] = getstimscript(cksds,thedir)

%  Part of the NelsonLabTools package
%  
%  [SAVESCRIPT,MTI] = GETSTIMSCRIPT(MYCKSDIRSTRUCT,THEDIR)
%
%  Gets the stimscript and MTI (timing) record associated with a particular
%  test directory.

saveScript=[];MTI=[];

p = getpathname(cksds);

if ~exist([p thedir]),
	error(['Directory ' p thedir ' does not exist.']);
elseif ~exist([p fixpath(thedir) 'stims.mat']),
	error(['No stims in directory ' p thedir '.']);
else,
	g = load([p fixpath(thedir) 'stims.mat']);
	saveScript = g.saveScript;
	MTI = g.MTI2;
end;


