function experimentname = experiment( experimentname,verbose )
%EXPERIMENT sets experimental protocol
%
% EXPERIMENTNAME = EXPERIMENT()
%   returns current experiment
%
% EXPERIMENTNAME = EXPERIMENT( EXPERIMENTNAME )
%   sets EXPERIMENTname to EXPERIMENTNAME
%
% EXPERIMENTNAME = EXPERIMENT('')
%   resets hostname to system host
%

persistent experimentname_pers notfirstentry

if nargin<2
    verbose = [];
end
if isempty(verbose)
    verbose = true;
end

loaded = false;
experimentnamedir = tempdir;
filename = fullfile(experimentnamedir,'experiment.asc');

if nargin<1
    if notfirstentry
        experimentname = experimentname_pers;
    else
        if exist(filename,'file') 
            fid = fopen(filename,'r');
            experimentname = fgetl(fid);
            fclose(fid);
            loaded = true;
            experimentname_pers = experimentname;
            if isempty(notfirstentry) && verbose
                disp(['EXPERIMENT: Experiment is ''' experimentname '''. Type ''experiment(''XXX'') to change.']);
            end
        else
            experimentname = '';
        end
    end
else
    if isnumeric(experimentname)
        experimentname = num2str(experimentname);
    end
end
experimentname = lower(experimentname);
if ~strcmp(experimentname,experimentname_pers) && ...
        ~(isempty(experimentname) && isempty(experimentname_pers)) && ...
        ~loaded
    % store experimentname
    experimentname_pers = experimentname;
    if ~exist(experimentnamedir,'dir')
        mkdir(experimentnamedir);
    end
    fid = fopen(filename,'w');
    fprintf(fid,'%s\n',experimentname);
    fclose(fid);
    if verbose
        disp(['EXPERIMENT: Saved experimentname ''' experimentname ''' to ' filename ]);
    end
end


notfirstentry = true;

