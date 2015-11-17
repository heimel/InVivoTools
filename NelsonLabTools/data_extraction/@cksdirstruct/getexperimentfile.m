function [p, expf] = getexperimentfile(cksds,createit)

%  [P, expf] = GETEXPERIMENTFILE(MYCKSDIRSTRUCT [, CREATEIT] )
%
%  Returns the experiment data filename for the directories associated with
%  CKSDIRSTRUCT.  If CREATEIT is present and is 1, then the file is
%  created if it does not already exist.
%
%  EXPF is the name of the experiment, taken from the last directory in the
%  pathname.
%
%  If the original pathname associated with MYCKSDIRSTRUCT does not exist,
%  then the function returns [].
%
%  See also:  CKSDIRSTRUCT

expf = '';

if ~exist(cksds.pathname,'dir')
    p = [];
else
    f = find(cksds.pathname==filesep);
    if length(f)==1
        expf=cksds.pathname([1:f-1 f+1:length(cksds.pathname)]);
    else
        expf=cksds.pathname((f(end-1)+1):(f(end)-1));
    end
    str=fixpath([cksds.pathname 'analysis']); 
    p = [str 'experiment'];
    if nargin==2 && createit==1,
        if exist(p)~=2,
            if ~exist(str,'dir')
                mkdir(cksds.pathname,'analysis');
            end;
            name = expf; %#ok<NASGU>
            save(p,'name','-mat');
        end
    end
end
