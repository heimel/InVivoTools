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

params.sample_rate = 1/median(diff(time)); % Hz 

if verbose
    figure('Name','Raw');
    plotdata(time, data, [0.7 0.7 0.7])
    hold on
end

% Clean data with Savitzky-Golayfilter
analysed.clean = sgolayfilt(data,params.poly_order,params.window_size);
logmsg('Savitzky-Golayfilter applied to data');

if verbose
    plotdata(time,analysed.clean,[1 0 0]);
end

%analysed.modulation = smoothen(analysed.clean,params.sigma);
analysed.modulation = smooth(analysed.clean,params.sigma);
logmsg('Trend calculated');

analysed.detrend =  analysed.clean - (params.factor .* analysed.modulation);
logmsg('Trend data used to detrend original data');
%
% if verbose
%     figure('Name','Detrended');
%     plotdata(t, analysed.detrend, [0.7 0.7 0.7])
%     hold on
% end

analysed.hilbert_trans = angle(hilbert(analysed.detrend));
logmsg('Hilbert transform applied to detrended data');

%
% if verbose
%     figure('Name','Hilbert transform');
%      plotdata(t, analysed.detrend, [0.7 0.7 0.7])
%      hold on
%      plotdata(t, analysed.hilbert_trans, [1 0 0 ])
%      hold on
% end
%

% find peaks in hilbert transform
% [~,locsThr] = findpeaks(analysed.hilbert_trans,'MinPeakDistance',...
%     params.minimal_distance_peaks,'MINPEAKHEIGHT',params.minimal_height_peaks);
% logmsg('Peak finding algorithm applied to Hilbert transformed data');


% get positive zero crossings
zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0 & v(:)<circshift(v(:),[-1 0]));
locsThr = zci(analysed.hilbert_trans);


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
    figure('Name','Hilbert transform');
    n = find(time-time(1) > 1,1);
    
    xlabel('Time (s)');
    hold on
    
    for i=1:100:length(time)-n
        
        plot(time(i:n+i), analysed.detrend(i:n+i), 'Color',[0.7 0.7 0.7])
        hold on
        xlim([time(i) time(n+i)]);
        plot(time(i:n+i), analysed.hilbert_trans(i:n+i),'Color',[1 0 0 ])
        
        ind = find(locsThr>=i & locsThr<=n+i);
        
        plot(time(locsThr(ind)),analysed.detrend(locsThr(ind)),'ok');
        pause(0.1);
        if KbCheck
            break
        end
        break
        hold off
    end
end








% Instantanous HR faulty peaks removed from data
heartrate = heartrate(2:end-1);
beattime = beattime(2:end-1);


record.measures.heartrate_median = median(heartrate);
logmsg(['Median heartrate = ' num2str(record.measures.heartrate_median)]);

stdheartrate = std(heartrate);
logmsg(['Standard deviation = ' num2str(stdheartrate)]);

record.measures.heartrate = movmedian(heartrate,params.beats,'omitnan','Endpoints','shrink');

if verbose
    figure;
    hold
    plot(beattime,record.measures.heartrate,'r');
    ylim([0 25]);
    xlim([0 150]);
    xlabel('Time (s)');
    ylabel('Heart rate (Hz)');
    plot_stimulus_timeline(stim)
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


if verbose
    figure('Name','Trial median');
    hold on
    plot(record.measures.beattime_trialaverage,record.measures.heartrate_trialmedian+record.measures.heartrate_trialsem,'Color',0.7*[1 1 1]);
    plot(record.measures.beattime_trialaverage,record.measures.heartrate_trialmedian-record.measures.heartrate_trialsem,'Color',0.7*[1 1 1]);
    
    plot(record.measures.beattime_trialaverage,record.measures.heartrate_trialmedian,'b');
    ylim([0 20]);
    plot([0 0],ylim,'y-');
    xlabel('Time from stimulus onset (s)');
    ylabel('Heart rate (Hz)');
end






logmsg('Done with heart rate analysis');

function plotdata( t,data, clr)
subplot(1,2,1);
plot(t,data,'-','Color',clr);
xlim([t(1) t(end)]);
xlabel('Time (s)');
subplot(1,2,2)
n_zoom_samples = find(t-t(1) > 1,1);
i = 1;
plot(t(i:i+n_zoom_samples),data(i:i+n_zoom_samples),'-','Color',clr);
xlim([t(i) t(i+n_zoom_samples)]);
xlabel('Time (s)');
