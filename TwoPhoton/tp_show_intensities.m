function tp_show_intensities( record )
%TP_SHOW_INTENSITIES shows ROI intensities
%
%  TP_SHOW_INTENSITIES( RECORD )
%
%  2011-2015, Alexander Heimel
%

roilist =record.ROIs.celllist;

params = tpreadconfig( record );

ln = cellfun(@length,{roilist.intensity_mean});
for i=find(ln==1)
    roilist(i).intensity_mean(2) = NaN;
end

intensities_abs = reshape([roilist.intensity_mean],params.NumberOfChannels,length(roilist))';
intensities_rel = reshape([roilist.intensity_rel2dendrite],numel([roilist.intensity_rel2dendrite])/length(roilist),length(roilist))';
intensities_rank = reshape([roilist.intensity_rank],numel([roilist.intensity_rank])/length(roilist),length(roilist))';
intensities_rel2synapse = reshape([roilist.intensity_rel2synapse],numel([roilist.intensity_rel2synapse])/length(roilist),length(roilist))';
intensities(:,1) = intensities_rel2synapse(:,1); % take abs for GFP
intensities(:,2) = intensities_rel(:,2); % take rel to dendrite for RFP

present = logical([roilist.present]);
dendrite = logical(strcmp({roilist.type},'dendrite'));
liness = logical(strcmp({roilist.type},'line'));
puncta = ~dendrite & ~isnan(intensities(:,1))';
aggregate = logical(strcmp({roilist.type},'aggregate'));
spine = logical(strcmp({roilist.type},'spine'));

figure('numbertitle','off','name',...
    ['Intensities: ' record.mouse ' ' record.stack ' ' record.slice]);
p = get(gcf,'Position');
p(4) = 2/3*p(4);
set(gcf,'Position',p);

subplot(1,2,1)
hold on
h = plot(intensities(present&aggregate,1),...
    intensities(present&aggregate,2),'gx');
set(h,'ButtonDownFcn',@buttondownfcn)
h = plot(intensities(present&spine,1),...
    intensities(present&spine,2),'go');
set(h,'ButtonDownFcn',@buttondownfcn)

h = plot(intensities(present&~aggregate&~spine,1),...
    intensities(present&~aggregate&~spine,2),'g.');
set(h,'ButtonDownFcn',@buttondownfcn)
h = plot(intensities(~present&aggregate,1),...
    intensities(~present&aggregate,2),'rx');
set(h,'ButtonDownFcn',@buttondownfcn)
h = plot(intensities(~present&spine,1),...
    intensities(~present&spine,2),'ro');
set(h,'ButtonDownFcn',@buttondownfcn)
h = plot(intensities(~present&~aggregate&~spine,1),...
    intensities(~present&~aggregate&~spine,2),'r.');
set(h,'ButtonDownFcn',@buttondownfcn)
xlabel('Channel 1')
ylabel('Channel 2')

ud.record = record;
ud.intensities = intensities;
ud.roilist = roilist;
set(gcf,'userdata',ud);

if ~all(present(puncta))
    data1 = [intensities(puncta,1) present(puncta)'];
    data2 = [intensities(puncta,2) present(puncta)'];
    rocdata = roc(data1,0.05,false);
    rocdata.AUC;
    optimal_cutoff1 = rocdata.co;
    rocdata = roc(data2,0.05,false);
    optimal_cutoff2 = rocdata.co;
    rocdata.AUC;
    ax=axis;
    plot( [optimal_cutoff1,optimal_cutoff1],[ax(3) ax(4)],'y');
end
set(gca,'ButtonDownFcn',@buttondownfcn)

subplot(1,2,2)
[np,x] = hist(log(intensities_abs(logical([roilist.present]),1)),20);
[na,x] = hist(log(intensities_abs(~logical([roilist.present]),1)),x);
if size(np,1)>size(np,2) % if no rois present, hist produces a column instead row
    np = np';
end
if size(na,1)>size(na,2)
    na = na';
end

bar(x',[np;na]',1,'stacked');colormap([0 0.8 0; 1 0 0]);
ylabel('Count');
xlabel('Log intensity channel 1');
box off
legend('Present','Absent');
legend boxoff

function buttondownfcn(obj,event_obj) %#ok<INUSD>
p=get(gca,'currentpoint');
r = [p(1,1) p(1,2)];
ud = get(gcf,'userdata');
d = sum( ((ud.intensities-repmat(r,size(ud.intensities,1),1))./ ...
     repmat(range(ud.intensities),size(ud.intensities,1),1 ) ).^2,2);
[~,ind] = min(d);

logmsg(['ROI ' num2str(ud.roilist(ind).index) ': intensities = ' mat2str(ud.intensities(ind,:),2)]);
sync2otherslices(ud.record,ud.roilist(ind).index);



