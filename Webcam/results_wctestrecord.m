function results_wctestrecord( record )
%RESULTS_WCTESTRECORD shows measures from webcam record
%
% RESULTS_WCTESTRECORD( RECORD )
%
% 2015-2019, Azadeh Tafreshiha, Alexander Heimel

global measures global_record analysed_script

global_record = record;

measures = record.measures;

evalin('base','global measures');
evalin('base','global global_record');
evalin('base','global analysed_script');
analysed_stimulus = getstimsfile(record);
if ~isempty(analysed_stimulus) && isfield(analysed_stimulus,'saveScript')
    analysed_script = analysed_stimulus.saveScript; %#ok<NASGU>
else
    logmsg('No savedscript');
end

logmsg('Measures available in workspace as ''measures'', stimulus as ''analysed_script'', record as ''global_record''.');
%
% filename = fullfile(experimentpath(record),'firstframe.mat');
% if exist(filename,'file')
%     load(filename);
% end



if isfield(record,'measures')
    
    if isfield(record.measures,'session_type_first')
        logmsg(['Session = ' num2str(record.measures.session)  ' Session type first =' num2str(record.measures.session_type_first) ...
            ', last = ' num2str(record.measures.session_type_last) ...
            ', n_stims = ' num2str(record.measures.session_n_stim) ...
            ', stim_seqnr = ' num2str(record.measures.stim_seqnr)]);
    elseif  isfield(record.measures,'session')
        logmsg(['Session = ' num2str(record.measures.session)]);
    end
end

if ~isfield(record,'measures') || ~isfield(record.measures,'stimstart')
    logmsg('stim start is not determined. use "track" button')
    return
end




% plots the arena
showstimpeaks = false;
if showstimpeaks
    plot_azadeh(record);
end


% plots movement trajectory
% if isfield(measures,'mousemove') && ~isempty(measures.mousemove)
%     mousemove = measures.mousemove ;
%     move2der = measures.move2der ;
%     trajectorylength = measures.trajectorylength ;
%     averagemovement = measures.averagemovement ;
%     minimalmovement = measures.minimalmovement ;
%     diftreshold = measures.diftreshold ;
%     deriv2tresh = measures.deriv2tresh ;
% else
%     logmsg(['Information missing. Reanalyse ' recordfilter(record)]);
% end

my_blue = [0 0.2 0.6];
my_purple = [0.6 0.2 0.6];

% if exist('mousemove','var') && ~isempty(mousemove)
%     figure;
%     subplot(2,1,1);
%     plot([1 trajectorylength],averagemovement*[1 1],'--k');hold on;
%     plot([1 trajectorylength],(minimalmovement+diftreshold)*[1 1],'linestyle' ,'--');
%     plot(mousemove,'color',my_blue,'linewidth',2);
%     set(gca, 'xtick', (0:30:600), 'XTickLabel', (-10:10),'xgrid','off');
%     title('Mouse movement trajectory');
%     subplot(2,1,2);
%     plot([1,trajectorylength],[deriv2tresh,deriv2tresh], '--k'); hold on;
%     plot([1,trajectorylength],[-deriv2tresh,-deriv2tresh], '--k');
%     plot(move2der, 'color',[0.8 0 0.6],'linewidth',1.4);
%     xlabel('seconds');
%     ylim([-0.7 0.7]);
%     set(gca, 'xtick', (0:30:600), 'XTickLabel', (-10:10),'xgrid','on');
%     title('2nd derivative of the trajectory');
% else
%     logmsg('No trajectory data available');
% end


showangles = false;

% plots angles
if isfield(measures,'nose') && ~isempty(measures.nose) && ...
        isfield(measures,'arse') && ~isempty(measures.arse)&& ...
        isfield(measures,'head_theta') && ~isempty(measures.head_theta)
    nose = measures.nose;
    arse = measures.arse;
    head_theta = measures.head_theta;
    pos_theta = measures.pos_theta;
else
    %logmsg(['Body coordinates are not available. Analyse ' recordfilter(record)])
    nose = NaN;
    arse = NaN;
    showangles = false;
end

if isfield(measures,'stim') && ~isempty(measures.stim)
    stim = measures.stim;
else
    %logmsg('Stim coordinate is not determined. use "analyse" button')
    showangles = false;
end


if showangles
    L = size(nose,1);
    sbrange = round(L/2);
    figure
    for k = 1:L
        arse_a(k, :) = arse(k,:) - nose(k,:);  %THE COORDINATES ALIGNED TO NOSE
        nose_a(k, :) = nose(k,:) - nose(k,:);
        if ~isempty(nose) && ~isempty(arse)
            if sbrange ~= 1
                subplot((round(L/2)),(round(L/2)),k);
            else
                subplot(L,L,k);
            end
            plot([0, nose_a(k,1)], [0, nose_a(k,2)],'v','MarkerSize',8,...
                'MarkerFaceColor', my_blue);
            hold on
            grid on
            extent1 = abs(arse_a)+50;
            ax1 = max(max(extent1));
            plot([-ax1 ax1],[0 0],'--k',[0 0],[-ax1 ax1],'--k');
            text(-15,-30,'nose','color',my_blue, 'BackgroundColor','w');
            plot([0, arse_a(k,1)], [0, arse_a(k,2)], 'linewidth',3,'color',my_blue);
            head_txt = text(50,(ax1-10),...
                sprintf('head \\theta = %.1f%c',head_theta(k),char(176)),...
                'color',my_blue, 'BackgroundColor','w'); %char(176) is deg
            if ~isempty(stim)
                stim_present = any(stim,2);
                if stim_present(k)== 1
                    if sbrange ~= 1
                        subplot((round(L/2)),(round(L/2)),k);
                    else
                        subplot(L,L,k);
                    end
                    stim_a(k, :) = stim(k,:) - nose(k,:);
                    plot([0, stim_a(k,1)], [0, stim_a(k,2)], 'linewidth',3,...
                        'color',my_purple);
                    hold on;
                    grid on;
                    extent = abs(stim_a)+60; ax= max(max(extent));
                    plot([-ax ax],[0 0],'--k',[0 0],[-ax ax],'--k');
                    set(head_txt, 'Position',[50 (extent(2))] );
                    text(50,(extent(2)-50),...
                        sprintf('position \\theta = %.1f%c',pos_theta(k),char(176)),...
                        'color',my_purple,'BackgroundColor','w');
                    
                end
            end
        else
            logmsg('No mouse coordinates available');
        end
    end
end


try
    wc_kinetogram(record);
catch me
    logmsg(me.message);
end
figure('Name','Trajectory','Numbertitle','off');
h = subplot(1,2,1);
wc_plot_stim_trajectory(record,h);
h = subplot(1,2,2);
wc_plot_polar_trajectory(record,h);




function plot_azadeh(record)
measures = record.measures;
stimstart = measures.stimstart;

if isfield(measures,'brightness')
    arena = measures.arena;
    brightness = measures.brightness;
    
    [~,filename] = wc_getmovieinfo(record);
    if ~isempty(filename)
        vid = VideoReader(filename);
        %    stimstart = wc_getstimstart( record, vid.FrameRate );
        if stimstart>vid.Duration
            errormsg(['Video stops before stimulus starts in ' recordfilter(record)]);
            return
        end
        
        vid.CurrentTime = stimstart;
        frame1 = double(readFrame(vid));
    else
        frame1 = zeros(480,640);
    end
    
    figure;
    image(frame1);
    axis image
    %imshow(frame1, []); % just show it
    
    W = 15;
    H = 30;
    Xmin = arena(1)+arena(3)-W;
    Ymin = arena(2)+arena(4)/2-H/2;
    roiR = [Xmin, Ymin, W, H];
    Xmin = arena(1);
    roiL = [Xmin, Ymin, W, H];
    
    h2 = imrect(gca, roiR);
    h3 = imrect(gca, roiL);
    h_arena = imrect(gca, arena);
    binaryImage = h_arena.createMask();
    binaryImage2 = h2.createMask();
    binaryImage3 = h3.createMask();
    
    m = 2; n = 3;
    subplot(m,n,1);
    image(frame1);
    axis image
    %imshow(frame1,[]);
    axis on;
    title('Sample Frame');
    subplot(m,n,2);
    burned_frame = frame1;
    burned_frame(binaryImage) = 0;
    image(burned_frame);
    %imshow(burned_frame,[]);
    axis image on;
    title('Selection of arena');
    
    subplot(m,n,3);
    burned_frame = frame1;
    burned_frame(binaryImage2 | binaryImage3) = 255;
    %imshow(burned_frame,[]);
    image(burned_frame);
    axis image
    axis on;
    title('ROI');
    
    % plots stimulus onset brightness
    
    if isfield(measures,'thresholdsStimOnset') && ~isempty(measures.thresholdsStimOnset)
        thresholdsStimOnset = measures.thresholdsStimOnset;
    else
        errormsg('thresholdsStimOnset is not determined. use "track" button')
    end
    if isfield(measures,'peakPoints')
        peakPoints = measures.peakPoints;
    else
        errormsg('Peaks are not determined. use "track" button')
    end
    
    if ~isempty(measures.peakPoints)
        peakPointR = peakPoints(1,:);
        peakPointL = peakPoints(2,:);
    end
    
    if isfield(measures,'framerate')
        framerate = measures.framerate;
    elseif isfield(measures,'frameRate')
        framerate = measures.frameRate; % deprecated
    else
        logmsg(['Reanalyse record ' recordfilter(record)]);
        return
    end
    
    stimFrame = stimstart*framerate;
    start_frame = stimFrame-30-10; %30:length of the stim, 10:for interval
    end_frame = stimFrame+90+30;
    frames = start_frame:end_frame;
    % figure;
    subplot(m,n,4:6);
    plot(frames,brightness(1,:),'color',[0 2/3 1], 'LineWidth',2); hold on;
    plot(frames,brightness(2,:),'color',[1 2/3 0], 'LineWidth',2); hold on;
    plot(frames,thresholdsStimOnset(1,:),'--','color',[0 1/3 1]);
    plot(frames,thresholdsStimOnset(2,:),'--','color',[0 1/3 1]);
    plot(frames,thresholdsStimOnset(3,:),'--','color',[1 1/3 0]);
    plot(frames,thresholdsStimOnset(4,:),'--','color',[1 1/3 0]);
    legend('Right ROI','Left ROI','Location',[.705,.46,.2,.1]);
    
    if ~isempty(measures.peakPoints)
        plot(peakPointR(1,2),peakPointR(1,3),'k^','markerfacecolor','k'); axis tight;
        plot(peakPointL(1,2),peakPointL(1,3),'k^','markerfacecolor','m'); axis tight;
    end
end
