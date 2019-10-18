function record = wc_cleanup_stimulus_trajectory( record, verbose)
%WC_CLEANUP_STIMULUS_TRAJECTORY takes raw stimulus detection into smooth path
%
% 2019, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end

if isempty(record.measures)
    logmsg(['No measures yet for ' recordfilter(record) ]);
    return
end

% if ~isfield(record.measures,'stimstart')
%     logmsg(['Field stimstart is missing in ' recordfilter(record)]);
%     return
% end

params = wcprocessparams(record);

slackstimtime = 1; % s, for uncertainty in stimulus onset

stim = record.measures.stim_trajectory_raw;

% remove fixed points (faeces?)
ind = (  diff(stim(:,1)).^2+diff(stim(:,2)).^2<5);
stim(ind,:) = NaN;

% remove stim positions outside of arena
if isfield(record.measures,'arena') && ~isempty(record.measures.arena)
    arena = record.measures.arena;
    ind = (stim(:,1)<arena(1)) | (stim(:,1)>(arena(1)+arena(3))) ...
        | stim(:,2)<arena(2) | stim(:,2)>(arena(2)+arena(4));
    stim(ind,:) = NaN;
else
    logmsg(['Arena is not yet drawn for ' recordfilter(record)]);
end

[wcinfo,filename] = wc_getmovieinfo(record);
if ~isempty(record.stimstartframe)
    vid = VideoReader(filename);
    stimStart = record.stimstartframe / vid.frameRate;
elseif ~isempty(wcinfo.stimstart)
    logmsg(['No stimstartframe available for ' recordfilter(record)]);
    stimStart = (wcinfo(1).stimstart-params.wc_playbackpretime) * params.wc_timemultiplier + params.wc_timeshift;
else
    logmsg(['No stimstartframe or stimstart available for ' recordfilter(record)]);
    stimStart = 0;
end

frametimes = record.measures.frametimes;
sf = getstimsfile(record);
stimduration = duration(sf.saveScript);
if isempty(stimduration) || stimduration==0
    logmsg(['Missing stimulus duration for ' recordfilter(record)]);
    stimduration = 3; % temp
end

if verbose
    [~,filename] = wc_getmovieinfo(record);    
    vid = VideoReader(filename);
    vid.CurrentTime = stimStart;
    Frame = readFrame(vid);
    
    figure('Name','Stimulus','NumberTitle','off');
    subplot(1,2,1)
    image(Frame);
    axis image off
    hold on
    if exist('arena','var')
        plot( [arena(1) arena(1)+arena(3) arena(1)+arena(3) arena(1) arena(1)],...
            [arena(2) arena(2) arena(2)+arena(4) arena(2)+arena(4) arena(2)],'y-');
    end
    plot(stim(:,1),stim(:,2),'wo');
    
    subplot(1,2,2)
    axis square
    hold on
    plot(frametimes,stim(:,1),'bo');
    plot(frametimes,stim(:,2),'ro');
    xlabel('Time (s)');
end

% cleanup stimulus trajectory by repeatedly fitting a straight line
ind = find(~isnan(stim(:,1)) & ~isnan(stim(:,2))...
    & frametimes>(stimStart-slackstimtime) ...
    & frametimes<(stimStart+stimduration+slackstimtime));
x = frametimes(ind);
y1 = stim(ind,1);
y2 = stim(ind,2);
p1 = polyfit(x,y1,1);
p2 = polyfit(x,y2,1);

if verbose
    plot(x, p1(2)+p1(1)*x,'b-');
    plot(x, p2(2)+p2(1)*x,'r-');
end

err = (p1(2)+p1(1)*x - y1).^2 + (p2(2)+p2(1)*x - y2).^2;
% select only lowest 50% of errors and refit
indind = ind(err<median(err));
x = frametimes(indind);
y1 = stim(indind,1);
y2 = stim(indind,2);
p1 = polyfit(x,y1,1);
p2 = polyfit(x,y2,1);
x = frametimes(ind);
y1 = stim(ind,1);
y2 = stim(ind,2);
% now allow only 30 pixels difference and refit
err = (p1(2)+p1(1)*x - y1).^2 + (p2(2)+p2(1)*x - y2).^2;
indind = ind(err< 2*30^2 );
x = frametimes(indind);
y1 = stim(indind,1);
y2 = stim(indind,2);
p1 = polyfit(x,y1,1);
p2 = polyfit(x,y2,1);
x = frametimes(ind);
y1 = stim(ind,1);
y2 = stim(ind,2);
% now allow only 20 pixels difference and refit
err = (p1(2)+p1(1)*x - y1).^2 + (p2(2)+p2(1)*x - y2).^2;
indind = ind(err< 2*20^2 );
x = frametimes(indind);
y1 = stim(indind,1);
y2 = stim(indind,2);
p1 = polyfit(x,y1,1);
p2 = polyfit(x,y2,1);
% x = frametimes(ind);
% y1 = stim(ind,1);
% y2 = stim(ind,2);

if p1(1)>0 % stim moves from left to right
    tstart = (arena(1)-p1(2))/p1(1);
    indstartstim = find(frametimes>tstart,1,'first');
    tstop = (arena(1)+arena(3)-p1(2))/p1(1);
    indstopstim = find(frametimes<tstop,1,'last');
else % stim moves from right to left
    tstart = (arena(1)+arena(3)-p1(2))/p1(1);
    indstartstim = find(frametimes>tstart,1,'first');
    tstop = (arena(1)-p1(2))/p1(1);
    indstopstim = find(frametimes<tstop,1,'last');
end

stimpos = NaN(size(stim));
stimpos(indstartstim:indstopstim,1) = p1(2)+p1(1)*frametimes(indstartstim:indstopstim);
stimpos(indstartstim:indstopstim,2) = p2(2)+p2(1)*frametimes(indstartstim:indstopstim);

if verbose
    subplot(1,2,1)
    plot(stimpos(:,1),stimpos(:,2),'g-');
    
    subplot(1,2,2)
    plot(frametimes,stimpos(:,1),'g-','linewidth',3)
    plot(frametimes,stimpos(:,2),'g-','linewidth',3)
end

record.measures.stim_trajectory = stimpos;

ind = find(~isnan(record.measures.stim_trajectory(:,1)),1);
record.measures.stimstart = record.measures.frametimes(ind);

if isempty(record.stimstartframe)
    logmsg(['Filling in stimulus startframe from detected stimulus for ' recordfilter(record)]);
    [~,filename] = wc_getmovieinfo(record);
    vid = VideoReader(filename);
    record.stimstartframe = floor(record.measures.stimstart * vid.FrameRate);
end

