function changed_process_parameters(params,oldparams)
%CHANGED_PROCESS_PARAMETERS checks for local overrides of changed parameters
%
%  CHANGED_PROCESS_PARAMETERS(PARAMS,OLDPARAMS)
%
% 2014, Alexander Heimel

persistent mentioned

[identical,flds] = structdiff(params,oldparams);
if ~identical
    %     if isempty(mentioned)
    %         logmsg('Overriding process parameters with possible local settings');
    %     end
    for f = flds
        if isfield(oldparams,f{1})
            if isnumeric(params.(f{1}))
                str = mat2str(params.(f{1}));
            elseif islogical(params.(f{1}))
                if params.(f{1})
                    str = 'true';
                else
                    str = 'false';
                end
            else
                str = params.(f{1});
            end
            if isempty(mentioned)
                logmsg(['Set ' f{1} '=' str]);
            end
        end
    end
    mentioned = true;
end