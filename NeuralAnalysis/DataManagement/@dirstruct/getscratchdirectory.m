function p = getscratchdirectory(cksds,createit)

%  P = GETSCRATCHDIRECTORY(MYDIRSTRUCT [, CREATEIT ] )
%
%  Returns the scratch directory path for the directories associated with
%  CKSDIRSTRUCT.  If CREATEIT is present and is 1, then the directory is 
%  created if it does not already exist.
%
%  If the original pathname associated with MYDIRSTRUCT does not exist,
%  then the function returns [].
%
%  See also:  DIRSTRUCT

if exist(cksds.pathname)~=7, p = [];
else, str=[cksds.pathname 'analysis' filesep]; p = [str 'scratch' filesep];
	if nargin==2&createit==1,
		if exist(p)~=7,
			if exist(str)~=7,
				mkdir(cksds.pathname,'analysis');
			end;
			mkdir(str,'scratch');
		end;
	end;
end;
