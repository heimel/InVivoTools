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
load(filename,'time','data','settings' )
params = settings;

params = oxyprocessparams(record,params);

params.heartrate_samplerate = 1/median(diff(time)); % Hz

% filtered data with Savitzky-Golayfilter
filtered = sgolayfilt(data,params.heartrate_polyorder,params.heartrate_windowsize);
logmsg('Savitzky-Golayfilter applied to data');

detrended =  filtered - smooth(filtered,params.heartrate_sigma);
logmsg('Detrended');


detrended = [0; diff(detrended)];
detrended = sgolayfilt(detrended,params.heartrate_polyorder,params.heartrate_windowsize);


% logmsg('UNDOING DETRENDING');
% detrended = filtered;

if  params.heartrate_use_hilbert
    detrended = angle(hilbert(detrended));
    logmsg('Hilbert transform applied to detrended data');
end

if params.heartrate_use_zerocrossings
    logmsg('Detecting positive zero crossings');
    zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0 & v(:)<circshift(v(:),[-1 0]));
    locsThr = zci(detrended);
else
    [~,locsThr] = findpeaks(detrended,'MinPeakDistance',...
        params.heartrate_minimal_distance_peaks,'MinPeakHeight',params.heartrate_minimal_height_peaks);
end

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


if verbose
    figure('Name','Raw');
    hold on
    
    
    plotind = find(time>stim.mti{params.plottedtrial}.startStopTimes(2) + params.heartrate_pre_window(1) & ...
        time<(stim.mti{params.plottedtrial}.startStopTimes(2) +stim.stimduration+ params.heartrate_post_window(2)));
    plot(time(plotind),data(plotind),'-','color',0.7*[1 1 1]);
    plot(time(plotind),detrended(plotind),'-k');
    
    % plot beats
    ind = find(beattime>=time(plotind(1)) & beattime<=time(plotind(end)));
    
    plot(time(locsThr(ind)),data(locsThr(ind))   ,'or');
    
    
    xlabel('Time (s)');
    plot([stim.mti{params.plottedtrial}.startStopTimes(2) ...
        stim.mti{params.plottedtrial}.startStopTimes(2)],ylim,'y-');
    ylabel('Voltage (V)');
    ylim([-6 6]);
    xlim([time(plotind(1)) time(plotind(end))]);
    
end


% Instantanous HR faulty peaks removed from data
heartrate = heartrate(2:end-1);
beattime = beattime(2:end-1);

record.measures.heartrate_median = median(heartrate);
record.measures.heartrate_std = std(heartrate);
record.measures.heartrate = movmedian(heartrate,params.heartrate_smoothingbeats,'omitnan','Endpoints','shrink');

if verbose
    figure('Name','Heart rate');
    hold on
    plot(beattime,record.measures.heartrate,'r');
    ylim([0 25]);
    xlim([0 150]);
    xlabel('Time (s)');
    ylabel('Heart rate (Hz)');
    plot_stimulus_timeline(stim);
end


% compute trial averages
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
logmsg('Done with heart rate analysis');

if verbose
    results_oxyrecord(record);
end





function plotdata( t,data, clr)
plot(t,data,'-','Color',clr);
xlim([t(1) t(end)]);
xlabel('Time (s)');
