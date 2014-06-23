function params = processparams_local(oldparams)
%PROCESSPARAMS_LOCAL temporarily and locally override analysis parameters
%
% 2014, Alexander Heimel

persistent mentioned

params = oldparams;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Changes here
%
% e.g.
% params.pre_window = [-Inf 0];
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% don't change below this line
[identical,flds] = structdiff(params,oldparams);
if ~identical
    if isempty(mentioned)
        logmsg('Overriding process parameters with possible local settings');
    end
    for f = flds
        if isnumeric(params.(f{1}))
            str = mat2str(params.(f{1}));
        else
            str = params.(f{1});
        end
        if isempty(mentioned)
            logmsg(['Set ' f{1} '=' str]);
        end
    end
    mentioned = true;
end

