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

if ~isfield(record.measures,'stim_trajectory_raw')
    if ~isempty(record.stim_type)
        logmsg(['No stim_trajectory_raw yet for ' recordfilter(record)]);
    end
    return
end

% params = wcprocessparams(record);

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

% [wcinfo,filename] = wc_getmovieinfo(record);

stimstart = wc_get_stimstart(record);
if isempty(stimstart)
    logmsg(['No guess for stimstart in ' recordfilter(record)]);
    return
end
    
frametimes = record.measures.frametimes;

stimduration = wc_get_stimduration( record);

% cleanup stimulus trajectory by repeatedly fitting a straight line
ind = find(~isnan(stim(:,1)) & ~isnan(stim(:,2))...
    & frametimes>(stimstart-slackstimtime) ...
    & frametimes<(stimstart+stimduration+slackstimtime));
if length(ind)<3
    record.measures.stim_trajectory = inferring_stimpos_from_record(record);
    return
end

x = frametimes(ind);
y1 = stim(ind,1);
y2 = stim(ind,2);
p1 = polyfit(x,y1,1);
p2 = polyfit(x,y2,1);

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


slack = 0.05;
infer_stimpos = false;
if ...
        max(stimpos(:,1))> (record.measures.arena(1)+ record.measures.arena(3))* (1+slack) || ...
        min(stimpos(:,1))< (1-slack) * record.measures.arena(1) || ...
        max(stimpos(:,2)) > (1+6*slack) * (record.measures.arena(2)+ 0.5*record.measures.arena(4)) || ...
        min(stimpos(:,2)) < (1-6*slack) * (record.measures.arena(2)+ 0.5*record.measures.arena(4)) || ...
        min(stimpos(:,1)) > (1+slack) * record.measures.arena(1) || ...
        max(stimpos(:,1))< (record.measures.arena(1)+ record.measures.arena(3))* (1-slack) 
     
    logmsg(['Stim does fit in arena for ' recordfilter(record)]); 
    infer_stimpos = true;
end

if tstart < stimstart - 0.5 || tstart > stimstart + 0.5
    logmsg(['Stim does not appear at stimstart for ' recordfilter(record)]); 
    infer_stimpos = true;
end

if infer_stimpos
    stimpos =  inferring_stimpos_from_record(record);
end

if verbose
    [~,filename] = wc_getmovieinfo(record);
    vid = VideoReader(filename);
    vid.CurrentTime = stimstart;
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
    title(recordfilter(record));

    
    subplot(1,2,2)
    axis square
    hold on
    plot(frametimes,stim(:,1),'bo');
    plot(frametimes,stim(:,2),'ro');
    xlabel('Time (s)');
    
    plot(x, p1(2)+p1(1)*x,'b-');
    plot(x, p2(2)+p2(1)*x,'r-');
    
    
    subplot(1,2,1)
    plot(stimpos(:,1),stimpos(:,2),'g-');
    
    subplot(1,2,2)
    plot(frametimes,stimpos(:,1),'g-','linewidth',3)
    plot(frametimes,stimpos(:,2),'g-','linewidth',3)
    
    ylabel('Stimulus x,y');
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



function stimpos = inferring_stimpos_from_record(record)
stimpos = NaN(length(record.measures.frametimes),2);


if ~isempty(record.stim_type)
    logmsg(['Overruling stimulus trajectory for ' recordfilter(record)]);
    
    stimstart = wc_get_stimstart(record);
    stimduration = wc_get_stimduration( record);

    indstart = find(record.measures.frametimes>stimstart,1);
    indstop = find(record.measures.frametimes<stimstart+stimduration,1,'last');
    
    if ~isfield(record.measures,'arena')
        record = wc_get_arena( record );
        if ~isfield(record.measures,'arena')
            logmsg('No arena found');
            return
        end
    end
    arena = record.measures.arena;
    if contains(lower(record.stim_type),'left') || contains(lower(record.stim_type),'_l')
        stimpos(indstart:indstop,1) = ...
            linspace(arena(1),arena(1)+arena(3),indstop-indstart+1);
        stimpos(indstart:indstop,2) = arena(2) + arena(4)/2;
    elseif contains(lower(record.stim_type),'right') || contains(lower(record.stim_type),'_r')
        % right
        stimpos(indstart:indstop,1) = ...
            linspace(arena(1)+arena(3),arena(1),indstop-indstart+1);
        stimpos(indstart:indstop,2) = arena(2) + arena(4)/2;
    else
        % no stimulus trajectory
    end
end
