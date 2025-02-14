function ppm = ParforProgressStarter2(s, n, percentage, do_debug, run_javaaddpath, show_execution_time)
% Starter function for parfor progress-monitor, that will automatically 
% choose between a text or a GUI progress monitor. You can use this 
% progress-monitor in both for and parfor loops.
%
% ParforProgressStarter2 is the successor of ParforProgressStarter - it is 
% roughly 12 times more performant during GUI mode!
% 
% You should use ParforProgressStarter2 like this:
%
%%%%%%%%%%%%%% Begin ParforProgressStarter2 suggested usage %%%%%%%%%%%%%%%
%
%   % how many iterations of the for loop do we expect?
%   N = 1000;
%   % how often should the monitor update it's progress?
%   percentage_update = 0.1;
%   % show debugging information.
%   do_debug = 1;
%   % by default we always run 'javaaddpath'. Set this to 0 if you are 
%   % making use of globals.
%   run_javaaddpath = 1; 
%   % by default we show the execution time once ParforProgress ends.
%   show_execution_time = 1;
%   try % Initialization
%       ppm = ParforProgressStarter2('test', N, percentage_update, do_debug, run_javaaddpath, show_execution_time);
%   catch me % make sure "ParforProgressStarter2" didn't get moved to a different directory
%       if strcmp(me.message, 'Undefined function or method ''ParforProgressStarter2'' for input arguments of type ''char''.')
%           error('ParforProgressStarter2 not in path.');
%       else
%           % this should NEVER EVER happen.
%           msg{1} = 'Unknown error while initializing "ParforProgressStarter2":';
%           msg{2} = me.message;
%           print_error_red(msg);
%           % backup solution so that we can still continue.
%           ppm.increment = nan(1, nbr_files);
%       end
%   end
%
%
%   !! PARFOR behaviour has changed !!
%
%   With Matlab >= 2014a, "parfor" will automatically startup the
%   parallel pool, even if you don't want it:
%   "Starting parallel pool (parpool) using the 'local' profile"
%
%   With Matlab < 2014a, "parfor" will be ignored and would fallback to 
%   a simple "for", if parallel pool wasn't manually started.
%
%   parfor i = 1 : N
%       your_crazy_function();
%       ppm.increment(i);
%   end
%
%   try % use try / catch here, since delete(struct) will raise an error.
%       delete(ppm);
%   catch me %#ok<NASGU>
%   end
%
%%%%%%%%%%%%%% End ParforProgressStarter2 suggested usage %%%%%%%%%%%%%%%%%
% 
% Copyright (c) 2010-2014, Andreas Kotowicz
%
    %%

    if nargin < 2
        disp('usage: ppm = ParforProgressStarter2( text, number_runs, update_percentage, do_debug, run_javaaddpath, show_execution_time )');
        ppm = [];
        return;
    end
    
    if nargin < 3
        percentage = 0.1;
    end
    
    if nargin < 4
        do_debug = 0;
    end
    
    if nargin < 5
        run_javaaddpath = 1;
    end
    
    if nargin < 6
        show_execution_time = 1;
    end

    %% determine whether java and awt are available
    java_enabled = 1;
    if usejava('jvm') == 0
        java_enabled = 0;
    end
    
    awt_available = 1;
    if usejava('awt') == 0
        awt_available = 0;
    end
    
    % is matlab pool active?
    pool_slaves = pool_size();
    
    %% check for different usage scenarios:
    
    % 1 = ParforProgress2(GUI)
    % 2 = ParforProgress2(CONSOLE)
    % 3 = fallback ParforProgressConsole2
    
    % by default we use the GUI version.
    version_to_use = 1;
    
    if java_enabled == 0 % no java -> use console only
        version_to_use = 3;
    else
        if awt_available == 0 % java but no AWT -> java console
            version_to_use = 2;
        end
    end
    
    % check for old matlab version
    % - everything before 2008b (7.7) can cause trouble (because of saveobj /
    % loadobj)
    if get_matlab_version() < 7.07
        version_to_use = 3;
    end
    
    %% add directory to javapath and path
    a = which(mfilename);
    dir_to_add = fileparts(a);
    
    if pool_slaves > 0
        if java_enabled == 1 && run_javaaddpath == 1
            pctRunOnAll(['javaaddpath({''' dir_to_add '''})']);
        end
        pctRunOnAll(['addpath(''' dir_to_add ''')']);
    else
        if java_enabled == 1 && run_javaaddpath == 1
            javaaddpath({dir_to_add});
        end
        addpath(dir_to_add);
    end
    
    %%
    switch version_to_use
        case 1
            use_gui = 1;
            ppm = ParforProgress2(s, n, percentage, do_debug, use_gui, show_execution_time);
        case 2
            use_gui = 0;            
            ppm = ParforProgress2(s, n, percentage, do_debug, use_gui, show_execution_time);
        case 3
            % no java, no awt, or old matlab version
            disp('Progress will update in arbitrary order.');
            ppm = ParforProgressConsole2(s, n, percentage);
        otherwise
            disp('not defined');
            ppm = [];
    end
    
end
%% EOF
