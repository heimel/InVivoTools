function results_wctestrecord( record )
%RESULTS_WCTESTRECORD shows measures from webcam record
%
% RESULTS_WCTESTRECORD( RECORD )
%
% 2015-2016, Alexander Heimel

global measures global_record

global_record = record;

experimentpath(record)

measures = record.measures

evalin('base','global measures');
evalin('base','global global_record');
logmsg('Measures available in workspace as ''measures'',, record as ''global_record''.');

%% plots the arena 
figHandles = findall(0,'Type','figure');
fig_n = max(figHandles)+1;

if isfield(measures,'stimstart') && ~isempty(measures.stimstart)
    stimstart = measures.stimstart;
else
    error('stim start is not determined. use "track" button')
    
end

if isfield(measures,'frameRate') && ~isempty(measures.frameRate)
    frameRate = measures.frameRate;
else
    error('frame rate is not determined. use "track" button')
    
end

if isfield(measures,'arena') && ~isempty(measures.arena)
    arena = measures.arena;
else
    error('Arena is not assigned. use "track" button')
    
end

if isfield(measures,'brightness') && ~isempty(measures.brightness)
    brightness = measures.brightness;
else
    error('Brightness is not calculated. use "track" button')
    
end

if isfield(measures,'frame1') && ~isempty(measures.frame1)
    frame1 = measures.frame1;
else
    error('Brightness is not calculated. use "track" button')
    
end


figure(fig_n); imshow(frame1, []); % just show it

W = 15; H = 30;
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
imshow(frame1,[]); axis on; title('Sample Frame');
subplot(m,n,2);
burned_frame = frame1;
burned_frame(binaryImage) = 0;
imshow(burned_frame,[]); axis on; title('Selection of arena');

subplot(m,n,3);
burned_frame = frame1;
burned_frame(binaryImage2 | binaryImage3) = 255;
imshow(burned_frame,[]); axis on; title('ROI');

%% plots stimulus onset brightness

if isfield(measures,'thresholdsStimOnset') && ~isempty(measures.thresholdsStimOnset)
    thresholdsStimOnset = measures.thresholdsStimOnset;
else
    error('thresholdsStimOnset is not determined. use "track" button')
    
end
if isfield(measures,'peakPoints') && ~isempty(measures.peakPoints)
    peakPoints = measures.peakPoints;
else
    error('Peaks are not determined. use "track" button')
    
end

peakPointR = peakPoints(1,:);
peakPointL = peakPoints(2,:);
stimFrame = stimstart*frameRate;
start_frame = stimFrame-30-10; %30:length of the stim, 10:for interval
end_frame = stimFrame+90+30;
frames = start_frame:end_frame;
figure(fig_n);
subplot(m,n,4:6);
plot(frames,brightness(1,:),'color',[0 2/3 1]); hold on;
plot(frames,brightness(2,:),'color',[1 2/3 0]); hold on;
plot(frames,thresholdsStimOnset(1,:),'--','color',[0 1/3 1]);
plot(frames,thresholdsStimOnset(2,:),'--','color',[0 1/3 1]);
plot(frames,thresholdsStimOnset(3,:),'--','color',[1 1/3 0]);
plot(frames,thresholdsStimOnset(4,:),'--','color',[1 1/3 0]);
plot(peakPointR(1,2),peakPointR(1,3),'k^','markerfacecolor','k'); axis tight;
plot(peakPointL(1,2),peakPointL(1,3),'k^','markerfacecolor','m'); axis tight;

%% plots movement trajectory
if isfield(measures,'mousemove') && ~isempty(measures.mousemove)
    mousemove = measures.mousemove ;
else
    error('mouse movement is not determined. use "analyse" button')
    
end

if isfield(measures,'move2der') && ~isempty(measures.move2der)
    move2der = measures.move2der ;
else
    error('movement 2nd derivative is not determined. use "analyse" button')
    
end
if isfield(measures,'trajectorylength') && ~isempty(measures.trajectorylength)
    trajectorylength = measures.trajectorylength ;
else
    error('trajectory length is not determined. use "analyse" button')
    
end
if isfield(measures,'averagemovement') && ~isempty(measures.averagemovement)
    averagemovement = measures.averagemovement ;
else
    error('average movement is not determined. use "analyse" button')
    
end
if isfield(measures,'minimalmovement') && ~isempty(measures.minimalmovement)
    minimalmovement = measures.minimalmovement ;
else
    error('minimal movement is not determined. use "analyse" button')
    
end
if isfield(measures,'diftreshold') && ~isempty(measures.diftreshold)
    diftreshold = measures.diftreshold ;
else
    error('difference treshold is not determined. use "analyse" button')
    
end
if isfield(measures,'deriv2tresh') && ~isempty(measures.deriv2tresh)
    deriv2tresh = measures.deriv2tresh ;
else
    error('difference treshold is not determined. use "analyse" button')
    
end

my_blue = [0 0.2 0.6];
my_purple = [0.6 0.2 0.6];

figHandles = findall(0,'Type','figure');
fig_n = max(figHandles)+1;

if ~isempty(mousemove)
    figure((fig_n));
    subplot(2,1,1);
    plot((1:trajectorylength),averagemovement,'--k');hold on;
    plot((1:trajectorylength),minimalmovement+diftreshold,'linestyle' ,'--');
    plot(mousemove,'color',my_blue,'linewidth',2);
    set(gca, 'xtick', (0:30:600), 'XTickLabel', (-10:10),'xgrid','off');
    title('Mouse movement trajectory');
    
    subplot(2,1,2);
    plot([1,trajectorylength],[deriv2tresh,deriv2tresh], '--k'); hold on;
    plot([1,trajectorylength],[-deriv2tresh,-deriv2tresh], '--k');
    plot(move2der, 'color',[0.8 0 0.6],'linewidth',1.4);
    xlabel('seconds'); ylim([-0.7 0.7]);
    set(gca, 'xtick', (0:30:600), 'XTickLabel', (-10:10),'xgrid','on');
    title('2nd derivative of the trajectory');
else
    disp('No trajectory data available');
end
%% plots angles
nose = measures.nose;
arse = measures.arse;
stim = measures.stim;
head_theta = measures.head_theta;
pos_theta = measures.pos_theta;
L = size(nose,1);

figHandles = findall(0,'Type','figure');
fig_n = max(figHandles)+1;
figure(fig_n)
for k = 1:L;
    arse_a(k, :) = arse(k,:) - nose(k,:);  %THE COORDINATES ALIGNED TO NOSE
    nose_a(k, :) = nose(k,:) - nose(k,:);
    if ~isempty(nose) && ~isempty(arse)
%         figure(k+(fig_n)); 
subplot(L, L,k);
        plot([0, nose_a(k,1)], [0, nose_a(k,2)],'v','MarkerSize',8,...
            'MarkerFaceColor', my_blue); hold on;
        grid on; extent1 = abs(arse_a)+50; ax1= max(max(extent1));
        plot([-ax1 ax1],[0 0],'--k',[0 0],[-ax1 ax1],'--k');hold on;
        text(-15,-30,'nose','color',my_blue, 'fontweight', 'b', 'BackgroundColor','w');
        plot([0, arse_a(k,1)], [0, arse_a(k,2)], 'linewidth',3,'color',my_blue); hold on;
        
        head_txt = text(50,(ax1-10),sprintf('head \\theta = %.1f%c',head_theta(k),...
            char(176)),'color',my_blue, 'fontweight', 'b', 'BackgroundColor','w'); %char(176) is deg
        if ~isempty(stim);
            stim_present = any(stim,2);
            if stim_present(k)== 1
%                 figure(k+(fig_n));
                subplot(L, L ,k);
                stim_a(k, :) = stim(k,:) - nose(k,:);
                plot([0, stim_a(k,1)], [0, stim_a(k,2)], 'linewidth',3,...
                    'color',my_purple); hold on;
                grid on;
                extent = abs(stim_a)+60; ax= max(max(extent));
                plot([-ax ax],[0 0],'--k',[0 0],[-ax ax],'--k');
                set(head_txt, 'Position',[50 (extent(2))] );
                text(50,(extent(2)-50),sprintf('position \\theta = %.1f%c',pos_theta(k),...
                    char(176)),'color',my_purple, 'fontweight', 'b', 'BackgroundColor','w');
                
                %             plot ang arc
                %                     angle_arc_plot([0,0],30,[deg2rad(get_ang(hor,arse_a(k)))
                %                     deg2rad(get_ang...
                %                         (hor,stim_a(k)))],'-','b',2);
            end
        end
        set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
    else
        disp('No mouse coordinates available');
    end
end