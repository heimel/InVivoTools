function wc_kinetogram(records)
%WC_KINETOGRAM plots a figure of movement over records
%
% WC_KINETOGRAM( RECORDS )
%
% 2019, Alexander Heimel


t = -1: 1/30:  2.7;

mousemove = NaN( length(records),length(t));
freezestarts = [];
freezestops = [];
count = 1;

for i=1:length(records)
    record = records(i);
    if isempty(record.measures)
        continue
    end
    if ~isempty(record.stimstartframe)
        stimstart = record.stimstartframe/30;
    elseif isfield(record.measures,'stimstart')
        logmsg(['No stimstartframe in ' recordfilter(record)]);
        stimstart = record.measures.stimstart;
    else
        logmsg(['No stimstartframe and no stimstart field in ' recordfilter(record)]);
        continue
    end
    if ~isfield(record.measures,'frametimes')
        continue
    end
    
    frametimes = record.measures.frametimes - stimstart;
    if abs(median(diff(frametimes))- (1/30))>1E-7
        logmsg(['Framerate not 30 Hz in ' recordfilter(record)]);
    end
    ind1 = find(frametimes>=t(1),1);
    m = record.measures.mousemove_aut(ind1:min(ind1+length(t)-1,end))';
    m =  m - min(m);
    mousemove(count,1:length(m)) = m;

    freezetimes = record.measures.freezetimes_aut;
  %  freezetimes = record.measures.freezetimes;
    n_freezes = size(freezetimes,1);
    if n_freezes>0
        newfreezes = [count*ones(n_freezes,1) freezetimes(:,1)- stimstart];
        freezestarts = cat(1,freezestarts,newfreezes);

        newfreezes = [count*ones(n_freezes,1) freezetimes(:,2)- stimstart];
        freezestops = cat(1,freezestops,newfreezes);
    end
    count = count+1;
end

count = count - 1;

if count==0 % no data
    return
end

mousemove = mousemove(1:count,:);

figure('Name','Kinetogram','NumberTitle','off');
h = imagesc('XData',t,'YData',1:count,'CData',mousemove);
box off
axis square
set(gca,'Clim',[0 max(mousemove(:))]);
hold on
for i=1:size(freezestarts,1)
    plot(freezestarts(i,2) +[0  0],...
        freezestarts(i,1) +[-0.5 0.5] ,'-y','linewidth',3);
    plot(freezestops(i,2) +[0  0],...
        freezestops(i,1) +[-0.5 0.5] ,'-r','linewidth',3);
end

f = linspace(0,1,64)';
f = f ./ (0.5 +f );
f = f./max(f);

c = zeros(64,3);
c(:,3) = f;
c(:,2) = 0.7*f;
c(:,1) = 0.7*f;
colormap(c)

set(gca,'xtick',-1:0.5:3)
xlim([-1 2.7]);
ylim([0.5 count+0.5]);
xlabel('Time from stimulus onset (s)');
ylabel('Trial number');
set(gca,'ydir','reverse');
h = colorbar;
try
    set(get(h,'label'),'string','Pixel change per frame (a.u.)');
end
smaller_font(-6);
drawnow
if count>1
    yt = get(gca,'ytick');
    set(gca,'ytick',[1 yt]);
end