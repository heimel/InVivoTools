function ParforProgressStressTest2(N, run_javaaddpath, show_execution_time)
% Stress test for 'ParforProgressStarter2'. In case of timeouts, you can
% use this function to determine how many simultaneous connections your
% computer can handle, and adjust the ppm.increment() call accordingly.
%
% Copyright (c) 2010-2014, Andreas Kotowicz
%
%%

    if nargin < 3
        % by default we show the execution time once ParforProgress ends.
        show_execution_time = 1;
    end

    if nargin < 2
        % by default we always run 'javaaddpath'. Set this to 0 if you are 
        % making use of globals.
        run_javaaddpath = 1;
    end

    if nargin < 1
        % how many iterations of the for loop do we run?
        N = 10000;
    end
    
    %% initialize ParforProgress monitor

    % how often should the monitor update it's progress?
    percentage_update = 0.1;
    % show debugging information.
    do_debug = 1;
    try % Initialization
        ppm = ParforProgressStarter2('test task - ParforProgressStarter2', N, percentage_update, do_debug, run_javaaddpath, show_execution_time);
    catch me % make sure "ParforProgressStarter2" didn't get moved to a different directory
        if strcmp(me.message, 'Undefined function or method ''ParforProgressStarter2'' for input arguments of type ''char''.')
            error('ParforProgressStarter2 not in path.');
        else
            % this should NEVER EVER happen.
            msg{1} = 'Unknown error while initializing "ParforProgressStarter2":';
            msg{2} = me.message;
            print_error_red(msg);
            % backup solution so that we can still continue.
            ppm.increment = nan(1, N);
        end
    end

    %% execute dummy loop - replace 'rand(1, 10000)' with your function.
    
    t0 = tic();
    
    % !! PARFOR behaviour has changed !!
    %
    % With Matlab >= 2014a, "parfor" will automatically startup the
    % parallel pool, even if you don't want it:
    % "Starting parallel pool (parpool) using the 'local' profile"
    %
    % With Matlab < 2014a, "parfor" will be ignored and would fallback to 
    % a simple "for", if parallel pool wasn't manually started.
    % 
    parfor i = 1 : N
        rand(1, 10000);
        ppm.increment(i); %#ok<PFBNS>
    end
    
    total_time = toc(t0);    
    
    %% clean up
    try % use try / catch here, since delete(struct) will raise an error.
        delete(ppm);
    catch me %#ok<NASGU>
    end
    
    %% show runtime

    disp(['ParforProgressStressTest2 running time: ' num2str(total_time) 's.']);
    
end
%% EOF
