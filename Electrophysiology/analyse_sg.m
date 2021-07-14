function measures=analyse_sg(inp,n_spikes,record,verbose)
%ANALYSE_SG analyses stochastic grid stimulus ecdata
%
%  MEASURES=ANALYSE_SG(INP,N_SPIKES,RECORD)
%
% n_spikes used for calculating feature mean, should be dropped and spont
% rate should be used instead for doing RF patch size calculation.
%
% 2007-2019 Alexander Heimel
%

if nargin<4 || isempty(verbose)
    verbose = true;
end

processparams = ecprocessparams(record);

saved_stims = getstimsfile( record ); % to get monitorinfo

% calc feature mean
para_stim = getparameters(inp.stimtime(1).stim);

measures.usable=1;

if processparams.rc_interactive && verbose 
    where.figure=figure;
    where.rect=[0 0 1 1];
    where.units='normalized';
else
    where = [];
end

para_rc.interval = processparams.rc_interval;
para_rc.timeres = processparams.rc_timeres;
para_rc.gain = processparams.rc_gain;

rc = reverse_corr(inp,para_rc,where);
if isempty(rc)
    errormsg( ['Could not compute reverse correlation for ' recordfilter(record)]);
    return
end

para_rc = getparameters(rc);
%rc = setparameters(rc,para_rc);
rcs = getoutput(rc);

measures.rc_transience = rcs.crc.transience;
measures.rc_onoff = rcs.crc.onoff;  % 1 is on, 0 is off
%measures.rc_pixelcenter = rcs.crc.pixelcenter;
measures.rc_crc = rcs.crc.crc; % spike triggered average
measures.rc_lags = rcs.crc.lags; % stimulus time - spike time
measures.rc_feamean = para_rc.feamean;

% store normalized receptive field plots
%measures.rf(:,:,:) = max(rcs.reverse_corr.rc_avg(1,:,:,:,end),[],5);  
measures.rf = squeeze(max(rcs.reverse_corr.rc_avg(1,:,:,:,end),[],5));

% find rf center
if ndims(measures.rf)>2
    rff = squeeze(max(abs(measures.rf - para_rc.feamean),[],1));
    [m,xy] = max(rff(:));
    maxtimeint_ind = find(abs(measures.rf(:,xy)-para_rc.feamean)==m,1);
else
    maxtimeint_ind = 1;
    rff = abs(measures.rf - para_rc.feamean);
end
[~,xy] = max(rff(:));
[x,y,rect]=getgrid(inp.stimtime.stim);
rfx = ceil(xy/y);
rfy = rem(xy-1,y)+1;
measures.rf_center = [rfx rfy];
measures.rf_center_pixel = rect([1 2]) + [ (rfx-0.5)*para_stim.pixSize(1) (rfy-0.5)*para_stim.pixSize(2)];
logmsg(['Center pixel = ' mat2str( measures.rf_center_pixel ) ]);
if rfx<=1 || rfx>=x || rfy<=1 || rfy>=y
    logmsg('RF center is on edge of screen.');
    measures.usable=0;
end


rcs = rcs.reverse_corr;
if ndims(measures.rf)>2  %#ok<ISMAT>  % i.e. multiple intervals
    rf = squeeze(measures.rf(maxtimeint_ind,:,:)); % take max over all intervals
else
    rf = measures.rf;
end

%below assume enough spikes or stimuli for multinomial distribution to
%resemble gaussian distribution

% if there are very few spikes, than perhaps not all
% stimuli are sampled. To correct for this we assume
% poisson-spiking (not accurate in case of periodic bursts)
% and deduct the number of samples which were probably not
% sampled by spikes)
spikes_per_sample = n_spikes/para_stim.N;
prob_notsampled = exp(-spikes_per_sample);
% from poisson-dist: p_l(m)=l^m exp(-l)/m!
n_samples = para_stim.N*(1 - prob_notsampled); %

feamean_std = ...
    sqrt(sum(repmat(para_stim.dist,1,3).*(para_stim.values.^2),1)/sum(para_stim.dist)...
    -para_rc.feamean.^2);
feamean_sem = feamean_std/sqrt(n_samples);

%flatten feature mean and sem, only works for gray levels
feamean_sem = mean(feamean_sem);

% take all point within first and third quartile
topbox = prctile(rf(:),75);
minbox = prctile(rf(:),25);
mrf=mean(rf(  rf(:)<topbox & rf(:)>minbox  ));

if mrf<para_rc.feamean-feamean_sem || mrf>para_rc.feamean+feamean_sem
    logmsg('Not sampled long enough. Feature mean too far from data mean');
end

rf_on = (rf> (para_rc.feamean+3*feamean_sem));
rf_off = (rf< (para_rc.feamean-3*feamean_sem));
measures.rf_n_on=sum(rf_on(:));
measures.rf_onsize_sqdeg=compute_rf_size_sqdeg( rf_on,record.monitorpos, para_stim, saved_stims,record);
measures.rf_n_off=sum(rf_off(:));
measures.rf_offsize_sqdeg=compute_rf_size_sqdeg( rf_off,record.monitorpos, para_stim, saved_stims,record);


bins=rcs.bins{1}{1};

switch measures.rc_onoff
    case 1 %on
        measures.rf_size = sqrt(measures.rf_onsize_sqdeg);
    case 0 % off
        measures.rf_size = sqrt(measures.rf_offsize_sqdeg);
    otherwise
        measures.rf_size = NaN;
end

if (rf_on+rf_off)==0
    logmsg('No rf ON or OFF-patches');
    measures.usable = 0;
end

% in the remaining onframes is also used for offframes
v = getgridvalues(inp.stimtime.stim);
p.feature = 3;
f = getstimfeatures(v,inp.stimtime.stim,p,x,y,rect);
% f contains *changes* in the frames!

% calculate rate for stim on in rf center
switch p.feature
    case 3 % feature difference
        
        switch measures.rc_onoff
            case 1 %on
                onframes = find(f(rfy,rfx,:,1)>0);
            case 0 % off
                onframes = find(f(rfy,rfx,:,1)<0);
            otherwise
                onframes = find(f(rfy,rfx,:,1)>0);
        end
    case 1
        switch measures.rc_onoff
            case 1 %on
                onframes = find(f(rfy,rfx,:,1)>para_rc.feamean+1);
            case 0 % off
                onframes = find(f(rfy,rfx,:,1)<para_rc.feamean-1);
            otherwise
                onframes = find(f(rfy,rfx,:,1)>0);
        end
end
measures.rate_early = sum(bins(1,onframes))/length(onframes)/para_rc.timeres;
measures.rate_late = sum(bins(end,onframes))/length(onframes)/para_rc.timeres;
intervals = para_rc.interval(1):para_rc.timeres:para_rc.interval(2);
measures.rate_intervals = mat2cell( [intervals(1:end-1);intervals(2:end)],2,ones(1,length(intervals)-1));

% compute peristimulus histograms of ON-responses
onframetimes = inp.stimtime.mti{1}.frameTimes(onframes);
frameduration = 1 / para_stim.fps; % stimulus frameduration in s
hist_start = -2*frameduration; %used to be 0, 2013-01-20
hist_end = 2*frameduration;
spiketimes_afterframe = [];
% for ROC analysis:
n_spikes_per_onframe=zeros(1,length(onframetimes));
for i=1:length(onframetimes)
    try
        spiketimes_afterthisframe = ...
            get_data(inp.spikes,[onframetimes(i)+hist_start onframetimes(i)+hist_end]) - onframetimes(i);
        % for peristimulus histogram:
        spiketimes_afterframe = [spiketimes_afterframe; spiketimes_afterthisframe]; %#ok<AGROW>
        % for ROC analysis and rate change during stimulation
        n_spikes_per_onframe(i) = length(spiketimes_afterthisframe);
    catch
        % probable only happens for first or last frame
        logmsg(['Data not sampled over entire requested interval around onframe ' num2str(i) ' for ' recordfilter(record)]);
    end
end

% for ROC analysis also calculate number of spikes for no onframetimes
no_onframetimes=inp.stimtime.mti{1}.frameTimes(...
    setdiff( (1:length(inp.stimtime.mti{1}.frameTimes)), onframes));
n_spikes_per_no_onframe=zeros(length(no_onframetimes),1);
for i=1:length(onframetimes)
    try
        spiketimes_afterthisframe = ...
            get_data(inp.spikes,[no_onframetimes(i)+hist_start no_onframetimes(i)+hist_end]) - onframetimes(i);
        % for ROC analysis and rate change during stimulation
        n_spikes_per_no_onframe(i)=length(spiketimes_afterthisframe);
    catch
        % probable only happens for first or last frame
        warning('ANALYSE_SG:DATA_NOT_FULLY_SAMPLED',['data not sampled over entire requested interval around onframe ' num2str(i)]);
        warning('off','ANALYSE_SG:DATA_NOT_FULLY_SAMPLED');
    end
end

rocdata1(:,1) = n_spikes_per_no_onframe;
rocdata1(:,2) = 1;
rocdata2(:,1) = n_spikes_per_onframe;
rocdata2(:,2) = 0;
rocdata = [rocdata1;rocdata2];
rocoutput = roc(rocdata,0.05,0);
measures.roc_auc = rocoutput.AUC;
measures.roc_auc_se = rocoutput.SE;

if 0 % show histograms & roc
    figure; %#ok<UNRCH>
    m = max(n_spikes_per_onframe);
    x = (0:m);
    subplot(1,2,1);
    if 1% not-normalized
        dist1=hist(n_spikes_per_no_onframe,x);
        dist2=hist(n_spikes_per_onframe,x);
    else % normalized
        dist1=hist(n_spikes_per_no_onframe,x)/length(no_onframetimes);
        dist2=hist(n_spikes_per_onframe,x)/length(onframetimes);
    end
    h=bar(x-0.15,dist1,0.3);
    set(h,'FaceColor',0.7*[1 1 1]);
    hold on
    h=bar(x+0.15,dist2,0.3);
    set(h,'FaceColor',[1 0 0]);
    legend('no onframe','onframe');
    ylabel('Number of responses per occurence');
    xlabel(['# spikes ' num2str(hist_start) '-' num2str(hist_end) 's after frame' ]);
    set(gca,'YScale','log');
    logmsg(['Number of no onframes: ' num2str(length(no_onframetimes))]);
    logmsg(['Number of onframes   : ' num2str(length(onframetimes))]);
    
    % manually calculate roc curve from normalized data
    false_positive=[];
    true_positive=[];
    for i=1:length(dist1)
        true_positive(i)=sum(dist2(i:end))/sum(dist2);
        false_positive(i)=sum(dist1(i:end))/sum(dist1);
    end
    subplot(1,2,2);
    plot(false_positive,true_positive,'o-');
    axis([0 1 0.5 1]);
    xlabel('False positive rate');
    ylabel('True positive rate');
    title(['ROC AUC = ' num2str(rocoutput.AUC,2) ]);
    
    roc_auc_self=(false_positive-[false_positive(2:end) 0])*(true_positive+[true_positive(2:end) 0])'/2;
    disp(['roc auc self ' num2str(roc_auc_self,2)]);
end

norm_n_spikes_per_onframe=n_spikes_per_onframe/mean(n_spikes_per_onframe);
pfit=polyfit((1:length(n_spikes_per_onframe)),norm_n_spikes_per_onframe,1);
% p(1) is fractional change in rate per presented center frame;
measures.rate_change_rf_center=pfit(1);

binwidth = 0.01; %s
bintimes = (hist_start:binwidth:hist_end);
[psth,x] = hist(spiketimes_afterframe,bintimes);
psth = smoothen(psth,2);
psth_before = psth(x<0);
after_ind = find(x>0);
spont_mean = mean(psth_before);
% is not really spontaneous rate as there were other stimuli on the screen
% before
spont_std = std(psth_before);
onset_threshold = (spont_mean+3*spont_std);

measures.psth.data = psth;
measures.psth.tbins = x;
measures.psth.spont = spont_mean;
measures.psth.onset_threshold = onset_threshold;

% response onset
i2 = after_ind(find(psth(after_ind) > onset_threshold,1));
if isempty(i2)
    logmsg('No response at all.');
    measures.time_onset = NaN;
else
    i1 = i2-1;
    rc = (psth(i2)-psth(i1))/(x(i2)-x(i1));
    measures.time_onset = (onset_threshold - psth(i1) + rc* x(i1))/rc;
end

% peaktime
[m,ind] = max(psth);

measures.rate_peak = m;

spiketimes_around_peak = [];
for i=1:length(onframetimes)
    try
        spiketimes_around_thispeak=...
            get_data(inp.spikes,[onframetimes(i)+x(ind)-binwidth onframetimes(i)+x(ind)+binwidth]) - onframetimes(i);
        spiketimes_around_peak= [spiketimes_around_peak ;...
            spiketimes_around_thispeak]; %#ok<AGROW>
    catch
        % probable only happens for first or last frame
        warning(['data not sampled over entire requested interval around onframe ' num2str(i)]);
    end
end
measures.time_peak=median(spiketimes_around_peak);

% calculate rate for all patches
[arfy, arfx]=find(rf_on>=0);

rate=zeros(1,length(arfy));% pre-allocation
dist=zeros(1,length(arfy));% pre-allocation
for i=1:length(arfy)
    onframes=find(f(arfy(i),arfx(i),:,1)>0);
    rate(i)=sum(bins(1,onframes))/length(onframes)/para_rc.timeres;
    dist(i)=sqrt( (arfy(i)-rfy)^2 + (arfx(i)-rfx)^2);
end
temp_spont_rate=min(rate);
rate=rate-temp_spont_rate;

[rc, offset]=fit_thresholdlinear([dist sqrt(sum(size(rf).^2))*10],[rate 0]);
fitdist=(0:0.01:2*sqrt(sum(size(rf).^2)));
fitrate=thresholdlinear(rc*fitdist+ offset);
halfmax_ind = findclosest(fitrate,max(fitrate)/2);
halfmax_dist = fitdist(halfmax_ind); % in number of patches

rf = zeros(size(rf));
rf(rfy,rfx)=1;

centerpatch_area_sqdeg=compute_rf_size_sqdeg( rf ,record.monitorpos, para_stim, saved_stims, record);
measures.halfmax_deg=sqrt(centerpatch_area_sqdeg)*halfmax_dist;
% spontaneous rate calculation
% only works for 1 repetition!!
if length(inp.st.mti)==1
    recording_interval=get_intervals(inp.spikes);
    stimulus_interval=[inp.stimtime.mti{1}.startStopTimes(1) ...
        inp.stimtime.mti{1}.startStopTimes(end) ];
    if stimulus_interval(1)-recording_interval(1)>3
        measures.rate_spont= length( get_data(inp.spikes, ...
            [recording_interval(1), stimulus_interval(1)])) /...
            ( stimulus_interval(1)-recording_interval(1));
    elseif recording_interval(2)-stimulus_interval(2)>3
        measures.rate_spont=length( get_data(inp.spikes, ...
            [stimulus_interval(2),recording_interval(2) ])) /...
            (recording_interval(2)- stimulus_interval(2));
    else
        logmsg('Recorded too little time before or after stimulation to compute spontaneous rate');
        measures.rate_spont=nan;
    end
else
    logmsg('Spontaneous rate calculation not suitable for multiple repetitions');
    measures.rate_spont=nan;
end

% peaktime (again)
[m,ind]=max(psth);
halfresponse=find(psth(ind:end)<((m-measures.rate_spont)/2+measures.rate_spont),1);
measures.response_halflife=halfresponse*binwidth;

% calculate spike rate adaptation during whole stimulation interval
spikes=get_data(inp.spikes,[inp.st.mti{1}.startStopTimes(2),inp.st.mti{end}.startStopTimes(3)]);
if processparams.ec_compute_spikerate_adaptation && ~isempty(spikes) && length(spikes)>2 
    isi = spikes(2:end)-spikes(1:end-1);
    isitimes=(spikes(2:end)+spikes(1:end-1))/2;
    isitimes = isitimes - isitimes(1); % to avoid warning in polyfit
    pfit = polyfit(isitimes,isi,1);
    isi_start = pfit(1)*isitimes(1)+pfit(2);
    isi_end = pfit(1)*isitimes(end)+pfit(2);
    mean_rate = 1/mean(isi);
    measures.rate_change_global = (1/isi_end - 1/isi_start)/(isitimes(end)-isitimes(1)) / mean_rate ;
else
    measures.rate_change_global = NaN;
end

if 0 % OFF-response analysis not finished
    % compute peristimulus histograms of OFF-responses to RF ON center
    off_frametimes = inp.stimtime.mti{1}.frameTimes(f(rfy,rfx,:,1)<0);
    spiketimes_afterframe = [];
    for i = 1:length(off_frametimes)
        try
            spiketimes_afterthisframe=...
                get_data(inp.spikes,[off_frametimes(i)+hist_start off_frametimes(i)+hist_end])...
                - off_frametimes(i);
            % for peristimulus histogram:
            spiketimes_afterframe=[spiketimes_afterframe; spiketimes_afterthisframe];
        catch
            % probable only happens for first or last frame
            %warning(['data not sampled over entire requested interval around onframe ' num2str(i)]);
        end
    end
    
    [psth,x]=hist(spiketimes_afterframe,bintimes);
    psth=smoothen(psth,2);
    psth_before=psth(x<0);
    after_ind=find(x>0);
    spont_mean=mean(psth_before);
    % is not really spontaneous rate as there were other stimuli on the screen
    % before
    spont_std=std(psth_before);
    offset_threshold=(spont_mean+3*spont_std);
        
    % response offset
    i2=after_ind(find(psth(after_ind) > offset_threshold,1));
    i1=i2-1;
    rc=(psth(i2)-psth(i1))/(x(i2)-x(i1));
    measures.time_offset=(offset_threshold - psth(i1) + rc* x(i1))/rc;
    
    % peaktime
    [m,ind]=max(psth);
    
    measures.rate_off_peak=m;
    
    spiketimes_around_peak=[];
    for i=1:length(off_frametimes)
        try
            spiketimes_around_thispeak=...
                get_data(inp.spikes,[off_frametimes(i)+x(ind)-binwidth ...
                off_frametimes(i)+x(ind)+binwidth]) - off_frametimes(i);
            spiketimes_around_peak= [spiketimes_around_peak ;...
                spiketimes_around_thispeak];
        catch
            % probable only happens for first or last frame
            %warning(['data not sampled over entire requested interval around onframe ' num2str(i)]);
        end
    end
    measures.time_off_peak=median(spiketimes_around_peak);
    
end

return




function area_patch_sqdeg=compute_rf_size_sqdeg( rf ,monitorpos, para_stim, saved_stims, record)

n_patches=sum(rf(:));

% stimulus screen dimensions in pixels
stimscreen_width_pxl = para_stim.rect(3);
stimscreen_height_pxl = para_stim.rect(4);


if isfield(saved_stims,'NewStimPixelsPerCm')
    pixels_per_cm = saved_stims.NewStimPixelsPerCm;
    stimscreen_width_cm=para_stim.rect(3)/pixels_per_cm;
    stimscreen_height_cm=para_stim.rect(4)/pixels_per_cm;
else % stimulus screen dimensions in cm
    stimscreen_width_cm = 75;
    stimscreen_height_cm = 58;
    pixels_per_cm = 640 / 75;
    if datenum(record.date)>datenum('2009-10-01') % don't know when the change was made exactly
        warning('ANALYSE_SG:UNKNOWN_PIXELS_PER_DEGREE',...
            'ANALYSE_SG: Using custom pixels_per_cm and screen size. Should be avoided. This info should be in sg parameters.');
    end
end

% shortest distance from mouse to stimulus screen in cm
if length(monitorpos)==2 % only x and y
    if isfield(saved_stims,'NewStimViewingDistance')
        distance_mouse2screen_cm = saved_stims.NewStimViewingDistance;
    else
        distance_mouse2screen_cm=40;
        if datenum(record.date)>datenum('2009-10-01') % don't know when the change was made exactly
            warning('ANALYSE_SG:UNKNOWN_MONITOR_DISTANCE',...
                'ANALYSE_SG: Using custom monitor distance. Should be avoided. this info should be in sg parameters.');
        end
    end
else
    distance_mouse2screen_cm = monitorpos(3);
    logmsg('Getting viewing distance from record monitor position.');
end
% number of screen patches
[ny,nx]=size(rf);

[ploc(:,2), ploc(:,1)]=find(rf==1);
ploc_pxl(:,1)=(ploc(:,1)-1/2)*stimscreen_width_pxl/nx;
ploc_pxl(:,2)=stimscreen_height_pxl-(ploc(:,2)-1/2)*stimscreen_height_pxl/ny;
ploc_wrt_screenctr_pxl=ploc_pxl- ...
    repmat([stimscreen_width_pxl stimscreen_height_pxl]/2 ,n_patches,1);
ploc_wrt_screenctr_cm=ploc_wrt_screenctr_pxl/pixels_per_cm;
ploc_wrt_mouse_cm =ploc_wrt_screenctr_cm + ...
    repmat(monitorpos,n_patches,1);
distance_mouse2patch_cm=...
    sqrt(sum(ploc_wrt_mouse_cm.^2,2) + distance_mouse2screen_cm^2);

area_patch_cm2=stimscreen_height_cm*stimscreen_width_cm/nx/ny;
area_patch_sterad=area_patch_cm2 ./ (distance_mouse2patch_cm.^2); % 4pi/4pi

area_patch_sqdeg=area_patch_sterad/ (pi/180)^2;

area_patch_sqdeg=sum(area_patch_sqdeg);


return



