function wc_kinetogram(records,clim,sessionboundarycolor)
%WC_KINETOGRAM plots a figure of movement over records
%
% WC_KINETOGRAM( RECORDS, CLIM, SESSIONBOUNDARYCOLOR )
%
% 2019, Alexander Heimel

if nargin<2
    clim = [];
end
if nargin<3 || isempty(sessionboundarycolor)
    sessionboundarycolor = [0 0 0];
end


t = -1: 1/30:  2.8;

mousemove = NaN( length(records),length(t));
freezestarts = [];
freezestops = [];
stimnums = [];
count = 1;

session_limits = [];
cur_session = 0;
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
    
    %   freezetimes = record.measures.freezetimes_aut - stimstart;
    if ~isfield(record.measures,'freezetimes')
        errormsg(['Missing freezetimes in ' recordfilter(record)],false);
        record.measures.freezetimes = [];
    end
    
    freezetimes = record.measures.freezetimes - stimstart; % taking manually detected
    
    freezetimes = select_freezetimes(freezetimes,record,stimstart);
    
    if isnan(record.measures.freezing_from_comment)
        continue
    end
    
    
    if (record.measures.freezing_from_comment && isempty(freezetimes))
        logmsg(['Freezing scored in comment but not in measures' recordfilter(record)]);
        freezetimes = record.measures.freezetimes_aut - stimstart;
        freezetimes = select_freezetimes(freezetimes,record,stimstart);
        if (record.measures.freezing_from_comment && isempty(freezetimes))
            logmsg(['Freezing scored in comment but not in aut' recordfilter(record)]);
            p  = strfind(record.comment,'freezestart');
            if isempty(p)
                record.measures
                errormsg(['No freezestart in comment in ' recordfilter(record)],true);
            else
                pk = strfind(record.comment(p:end),'=');
                lp = find(record.comment(p+pk:end)>57 |record.comment(p+pk:end)<46,1,'first');
                if isempty(lp)
                    lp = length(record.comment) - (p+pk-1);
                end
                freezestart = str2num(record.comment(p+pk:p+pk-1+lp));
                
                
                freezetimes(1,:) = freezestart - stimstart +  [0 record.measures.freeze_duration_from_comment];
            end
        end
    end
    
    if (~record.measures.freezing_from_comment && ~isempty(freezetimes))
        logmsg(['Freezing not scored in comment ' recordfilter(record)]);
        freezetimes = [];
    end
    
    n_freezes = size(freezetimes,1);
    if n_freezes>0
        newfreezes = [count*ones(n_freezes,1) freezetimes(:,1)];
        freezestarts = cat(1,freezestarts,newfreezes);
        stimnums = cat(1,stimnums,record.measures.stim_seqnr*ones(size(newfreezes)));
        newfreezes = [count*ones(n_freezes,1) freezetimes(:,2)];
        freezestops = cat(1,freezestops,newfreezes);
    end
    
    logmsg(['Freezetimes : ' mat2str(freezetimes,2) ' in ' recordfilter(record)]);
    
    if record.measures.session~=cur_session
        session_limits(end+1) = count - 0.5; %#ok<AGROW>
        cur_session = record.measures.session;
    end
    count = count+1;
end
session_limits(end+1) = count - 0.5;
count = count - 1;

if count==0 % no data
    return
end

mousemove = mousemove(1:count,:);

figure('Name','Kinetogram','NumberTitle','off');

imagesc('XData',t,'YData',1:count,'CData',mousemove);
box off
axis square
set(gca,'Clim',[0 max(mousemove(:))]);
hold on
%colors = {[1 0 0],[0 0 0.7],[0 0.7 0]};
colors = {[0.7 0.7 0.7],[0.1 0.1 0.8],[0 0.7 0]};
for i=1:size(freezestarts,1)
    %     plot(freezestarts(i,2) +[0  0],...
    %         freezestarts(i,1) +[-0.5 0.5] ,'-r','linewidth',3);
    %     plot(freezestops(i,2) +[0  0],...
    %         freezestops(i,1) +[-0.5 0.5] ,'-g','linewidth',3);
    %     plot([freezestarts(i,2)  freezestops(i,2)],...
    %         freezestarts(i,1) +[0 0] ,'-r','linewidth',3);
    %
    
    rectangle('position',...
        [freezestarts(i,2) freezestarts(i,1)-0.5 freezestops(i,2)-freezestarts(i,2) 1],...
        'facecolor',colors{stimnums(i)},'linestyle','none')
end
for i = 1:length(session_limits)
    plot([-1 max(t)],session_limits(i)*[1 1],'-','color',sessionboundarycolor);
end

f = linspace(0,1,64)';
f = f ./ (0.5 +f );
f = f./max(f);

c = zeros(64,3);
c(:,3) = f;
c(:,2) = 0.7*f;
c(:,1) = 0.7*f;
colormap(c)

colormap gray
if ~isempty(clim)
    set(gca,'clim',clim);
end

set(gca,'xtick',-1:0.5:3)
xlim([-1 max(t)]);
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


function freezetimes = select_freezetimes(freezetimes,record,stimstart)
if isempty(freezetimes)
    return
end

% only show freezetimes after stimulus starts
ind = find(freezetimes(:,1)>0);
freezetimes = freezetimes(ind,:);

% only show freezes starting before end of stimulus
%stimsfile = getstimsfile(record);
%dur = duration(stimsfile.saveScript);
dur = record.measures.frametimes(find(~isnan(record.measures.stim_trajectory(:,1)),1,'last'))-stimstart;
ind = find(freezetimes(:,1)<dur);
freezetimes = freezetimes(ind,:);

% only show first freezetimes
if ~isempty(freezetimes)
    freezetimes = freezetimes(1,:);
end

