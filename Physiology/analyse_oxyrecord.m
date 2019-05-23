function record = analyse_oxyrecord(record,verbose)
%OXYMETER_ANALYSIS computes heart and breathing rate from raw Oxymeter signal
%
%  RECORD = ANALYSE_OXYRECORD(RECORD,VERBOSE)
%
% 2016, Simon Lansbergen
% 2019, Alexander Heimel


if nargin<2 || isempty(verbose)
    verbose = true;
end


if isfield(record,'measures') && isfield(record.measures,'parameters')
    % delay [prestim stimduration] x repeats 0
    stim = record.measures.parameters;
else
    stim.delay = 5;
    stim.prestim = 2;
    stim.stimduration = 2;
end

stim.mti = cell(stim.repeats,1);
for i=1:stim.repeats
    % BGpre StimStart StimStop BGpost (s)
    stim.mti{i}.startStopTimes = stim.delay + ...
        (i-1)*(stim.prestim+stim.stimduration) + ...
        [0 stim.prestim stim.prestim+stim.stimduration stim.prestim+stim.stimduration];
end
stim.start = 0;
stim.MTI2 = stim.mti;
ss = stimscript([]);
ss = append(ss,stimulus([]));
ss = setDisplayMethod(ss,2,ones(1,stim.repeats));
stim.saveScript = ss;

datapath = experimentpath(record);
time = [];
data = [];
filename = fullfile(datapath,'Heart_Rate.mat');

if ~exist(filename,'file')
    errormsg(['Cannot find ' filename]);
    return
end
logmsg(['Loading ' filename ]);
load(filename,'time','data','settings' )
params = settings;

params = oxyprocessparams(record,params);

params.heartrate_samplerate = 1/median(diff(time)); % Hz

% filtered data with Savitzky-Golayfilter
filtered = sgolayfilt(data,params.heartrate_polyorder,params.heartrate_windowsize);
logmsg('Savitzky-Golayfilter applied to data');

breath = smooth(filtered,params.heartrate_sigma);

heart_detrended =  filtered - breath;
logmsg('Separated heart beat and breathing');


heart_detrended = [0; diff(heart_detrended)];
heart_detrended = sgolayfilt(heart_detrended,params.heartrate_polyorder,params.heartrate_windowsize);

if  params.heartrate_use_hilbert
    heart_detrended = angle(hilbert(heart_detrended));
    logmsg('Hilbert transform applied to heart_detrended data');
end

if params.heartrate_use_zerocrossings
    logmsg('Detecting positive zero crossings');
    zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0 & v(:)<circshift(v(:),[-1 0]));
    locsThr = zci(heart_detrended);
else
    [~,locsThr] = findpeaks(heart_detrended,'MinPeakDistance',...
        params.heartrate_minimal_distance_peaks,'MinPeakHeight',params.heartrate_minimal_height_peaks);
end


breath = angle(hilbert(breath));
zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0 & v(:)<circshift(v(:),[-1 0]));
breath_locs = zci(breath);


% calculate interval differences
ind = 1;
while ~isempty(ind)
    intervals = diff(locsThr); % number of samples between beats
    heartrate = params.sample_rate./intervals; % Hz
    % find and remove extra peaks
    medheartrate = median(heartrate);
    ind = find(heartrate>1.9*circshift(heartrate,1) & ...
        heartrate>1.9*circshift(heartrate,-1) & ...
        heartrate>1.5*medheartrate);
    locsThr(ind) = [];
end

beattime = time(locsThr(2:end));

breathintervals = diff(breath_locs); % number of samples between beats
breathrate = params.sample_rate./breathintervals; % Hz

breathtime = time(breath_locs(2:end));

if verbose
    figure('Name','Raw');
    
    % heart rate
    subplot(2,1,1)
    hold on
    plotind = find(time>stim.mti{params.plottedtrial}.startStopTimes(2) + params.heartrate_pre_window(1) & ...
        time<(stim.mti{params.plottedtrial}.startStopTimes(2) +stim.stimduration+ params.heartrate_post_window(2)));
    plot(time(plotind),data(plotind),'-','color',0.7*[1 1 1]);
    plot(time(plotind),heart_detrended(plotind),'-k');
    % plot beats
    ind = find(beattime>=time(plotind(1)) & beattime<=time(plotind(end)));
    plot(time(locsThr(ind)),data(locsThr(ind))   ,'or');
    xlabel('Time (s)');
    plot([stim.mti{params.plottedtrial}.startStopTimes(2) ...
        stim.mti{params.plottedtrial}.startStopTimes(2)],ylim,'y-');
    ylabel('Heart signal (V)');
    ylim([-6 6]);
    xlim([time(plotind(1)) time(plotind(end))]);


    % breathing
    subplot(2,1,2)
    hold on
    plotind = find(time>stim.mti{params.plottedtrial}.startStopTimes(2) + params.heartrate_pre_window(1) & ...
        time<(stim.mti{params.plottedtrial}.startStopTimes(2) +stim.stimduration+ params.heartrate_post_window(2)));
    plot(time(plotind),data(plotind),'-','color',0.7*[1 1 1]);
    plot(time(plotind),breath(plotind),'-k');
    ind = find(breathtime>=time(plotind(1)) & breathtime<=time(plotind(end)));
    plot(time(breath_locs(ind)),data(breath_locs(ind))   ,'or');
    xlabel('Time (s)');
    plot([stim.mti{params.plottedtrial}.startStopTimes(2) ...
        stim.mti{params.plottedtrial}.startStopTimes(2)],ylim,'y-');
    ylabel('Breathing signal (V)');
    ylim([-6 6]);
    xlim([time(plotind(1)) time(plotind(end))]);



end


% Instantanous HR faulty peaks removed from data
heartrate = heartrate(2:end-1);
beattime = beattime(2:end-1);

breathrate = breathrate(2:end-1);
breathtime = breathtime(2:end-1);

record.measures.heartrate_median = median(heartrate);
record.measures.heartrate_std = std(heartrate);
record.measures.heartrate = movmedian(heartrate,params.heartrate_smoothingbeats,'omitnan','Endpoints','shrink');

record.measures.breathrate_median = median(breathrate);
record.measures.breathrate_std = std(breathrate);
record.measures.breathrate = movmedian(breathrate,params.heartrate_smoothingbeats,'omitnan','Endpoints','shrink');


if verbose
    figure('Name','Heart rate');

    subplot(2,1,1)
    hold on
    plot(beattime,record.measures.heartrate,'r');
    ylim([0 25]);
    xlim([0 150]);
    xlabel('Time (s)');
    ylabel('Heart rate (Hz)');
    plot_stimulus_timeline(stim);


    subplot(2,1,2)
    hold on
    plot(breathtime,record.measures.breathrate,'r');
%    ylim([0 25]);
    xlim([0 150]);
    xlabel('Time (s)');
    ylabel('Breathing rate (Hz)');
    plot_stimulus_timeline(stim);

end


% compute trial averages for heart rate
binedges = params.heartrate_pre_window(1) : params.heartrate_binwidth : (stim.stimduration+params.heartrate_post_window(2));
heartrate_trialmedian = NaN(length(binedges)-1,1);
heartrate_trialsem = NaN(length(binedges)-1,1);
for t = 1:length(binedges)-1
    ind = [];
    for i=1:length(stim.mti)
        ind = [ind;
            find(beattime>stim.mti{i}.startStopTimes(2)+binedges(t) & ...
            beattime<stim.mti{i}.startStopTimes(2)+binedges(t+1))]; %#ok<AGROW>
    end
    if ~isempty(ind)
        heartrate_trialmedian(t) = nanmedian(heartrate(ind));
        heartrate_trialsem(t) = std(bootstrp(100,@nanmedian,heartrate(ind)));
    end
end
record.measures.beattime_trialaverage = (binedges(1:end-1) + binedges(2:end))/2;
record.measures.heartrate_trialmedian = heartrate_trialmedian;
record.measures.heartrate_trialsem = heartrate_trialsem;

% compute trial averages for breathing rate
binedges = params.heartrate_pre_window(1) : params.heartrate_binwidth : (stim.stimduration+params.heartrate_post_window(2));
breathrate_trialmedian = NaN(length(binedges)-1,1);
breathrate_trialsem = NaN(length(binedges)-1,1);
for t = 1:length(binedges)-1
    ind = [];
    for i=1:length(stim.mti)
        ind = [ind;
            find(breathtime>stim.mti{i}.startStopTimes(2)+binedges(t) & ...
            breathtime<stim.mti{i}.startStopTimes(2)+binedges(t+1))]; %#ok<AGROW>
    end
    if length(ind)>1
        breathrate_trialmedian(t) = nanmedian(breathrate(ind));
        breathrate_trialsem(t) = std(bootstrp(100,@nanmedian,breathrate(ind)));
    end
end
record.measures.breathtime_trialaverage = (binedges(1:end-1) + binedges(2:end))/2;
record.measures.breathrate_trialmedian = breathrate_trialmedian;
record.measures.breathrate_trialsem = breathrate_trialsem;


logmsg('Done with heart rate and breathing analysis');

if verbose
    results_oxyrecord(record);
end



