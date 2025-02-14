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
    errordlg(['Folder ' p thedir ' does not exist.']);
	return
elseif ~exist([p fixpath(thedir) 'stims.mat']),
    errordlg(['No stims.mat file with stimulus info in ' p thedir ]);
	return
else,
	g = load([p fixpath(thedir) 'stims.mat']);
	saveScript = g.saveScript;
	MTI = g.MTI2;
end;


