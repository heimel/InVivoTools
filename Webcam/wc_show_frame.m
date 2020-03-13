function [h,im] = wc_show_frame(record,vid,time,h,gamma)
%WC_SHOW_FRAME show single frame from movie
%
% [h,im] = WC_SHOW_FRAME(RECORD,VID,TIME,H,GAMMA)
%
% 2019, Alexander Heimel

if nargin<5 || isempty(gamma)
    gamma = 1;
end
if nargin<4 || isempty(h)
    h = figure;
end
if nargin<3 
    time = [];
end
if nargin<2 || isempty(vid)
    [~,filename] = wc_getmovieinfo(record);
    vid = VideoReader(filename);
end
if ~isempty(time)
    vid.CurrentTime = time;
end

time = vid.CurrentTime;
im = readFrame(vid);
gim = uint8(double(im).^gamma / (255^gamma) * 255);
image(gim);
axis image off
set(gca,'clipping','off')
text(-10,500,'Keys: left = previous frame, right = next frame, down = play until up, q = quit, +/- = increase/decrease gamma',...
    'color',[0 0 0]);
text(570,450,[num2str(time,'%.2f') ' s' ],'color',[1 1 1]);

if ~isempty(record.measures) && isfield(record.measures,'body_trajectory') && ~isempty(record.measures.body_trajectory)
    ind = find(record.measures.frametimes>=time & ...
        record.measures.frametimes<=time+vid.FrameRate,1);
    hold on
    if isfield(record.measures,'stim_trajectory')
        plot(record.measures.stim_trajectory(ind,1),record.measures.stim_trajectory(ind,2),'or');
    end
    if isfield(record.measures,'body_trajectory') 
        plot(record.measures.body_trajectory(ind,1),record.measures.body_trajectory(ind,2),'ob');
        plot(record.measures.nose_trajectory(ind,1),record.measures.nose_trajectory(ind,2),'*w');
        plot(record.measures.arse_trajectory(ind,1),record.measures.arse_trajectory(ind,2),'*r');
    end
    
    if isfield(record.measures,'azimuth_trajectory')
        text(10,10,['Azimuth = ' num2str(record.measures.azimuth_trajectory(ind,1))],...
            'color',[1 1 1])
    end
    
    d=(record.measures.freezetimes_aut - vid.CurrentTime)>0;
    if ~isempty(d) && any(d(:,2)-d(:,1))
        plot(record.measures.body_trajectory(ind,1),record.measures.body_trajectory(ind,2),'ob','MarkerFaceColor',[1 0 0]);
    end
    hold off
end

draw_screen_outline(record)
drawnow



function draw_screen_outline(record)
% plot screen sides
if ~isempty(record.measures) && isfield(record.measures,'arena') && length(record.measures.arena)==4
    hold on
    a = record.measures.arena;
    line([a(1) a(1)],[a(2) a(2)+a(4)],'color',[1 1 0]);
    line([a(1) a(1)+a(3)],[a(2)+a(4) a(2)+a(4)],'color',[1 1 0]);
    line([a(1)+a(3) a(1)+a(3)],[a(2)+a(4) a(2)],'color',[1 1 0]);
    line([a(1)+a(3) a(1)],[a(2) a(2)],'color',[1 1 0]);
    hold off
end

