% mkae figure 1c of Camillo, Levelt & Heimel, 2014
%

experiment(13.29);
db = load_graphdb;

record1 = db(find_record(db,'name=Figure 1Csub colabeling CR_mouse_Millipore and Tomato xy 250'));
record2 = db(find_record(db,'name=Figure 1C colabeling CR_mouse_Millipore and Tomato xy both'));

hgraph = [];

record = record1;
[r1,p,filename,hgraph] = groupgraph(record.groups,record.measures,...
    'criteria',record.criteria,...
    'style',record.style,'test',record.test,'showpoints',record.showpoints,...
    'color',record.color,'prefax',record.prefax,'spaced',record.spaced,...
    'signif_y',record.signif_y,'grouplabels',record.grouplabels,...
    'measurelabels',record.measurelabels,'extra_options',record.extra_options,...
    'extra_code',record.extra_code,'filename',record.filename,...
    'name',record.name,...
    'path',record.path,'value_per',record.value_per,'ylab',record.ylab,...
    'add2graph_handle',hgraph,'limit',record.limit);

record = record2;
[r2,p,filename,hgraph] = groupgraph(record.groups,record.measures,...
    'criteria',record.criteria,...
    'style',record.style,'test',record.test,'showpoints',record.showpoints,...
    'color',record.color,'prefax',record.prefax,'spaced',record.spaced,...
    'signif_y',record.signif_y,'grouplabels',record.grouplabels,...
    'measurelabels',record.measurelabels,'extra_options',record.extra_options,...
    'extra_code',record.extra_code,'filename',record.filename,...
    'name',record.name,...
    'path',record.path,'value_per',record.value_per,'ylab',record.ylab,...
    'add2graph_handle',hgraph.fig,'limit',record.limit);
set(gca,'position',[0.15 0.15 0.6 0.6])
x = r1{1};
y = r1{2};
for i=1:length(x)
    x{i} = [x{i} r2{1}{i}];
    y{i} = [y{i} r2{2}{i}];
end

ax = axis;

% x histogram
hx = subplot('position',[0.15 0.8 0.6 0.1]);
[n,xc] = hist(log10([x{:}]),100);
bar(xc,n+1); % plus 1 is for logscale
set(gca,'yscale','log')
hx = get(hx,'Children');
set(hx,'facecolor',[ 0 0 0]);
box off
xlim(log10(ax([1 2])))
set(gca,'xtick',[]);
set(gca,'ytick',[]);
ht=text(-1.8,1.5,'log count','Rotation',90);

% y histogram
hy = subplot('position',[0.8 0.15 0.1 0.6]);
[n,xc]=hist(log10([y{:}]),100);
bar(xc,n+1) % plus 1 is for logscale
set(gca,'yscale','log')
set(gca,'CameraUpVector',[1 0 0])
hy = get(hy,'Children');
set(hy,'facecolor',[ 0 0 0]);
box off
xlim(log10(ax([3 4])));
set(gca,'xtick',[]);
set(gca,'ytick',[]);
set(gca,'CameraUpVector',[-1 0 0]);
set(gca,'xdir','reverse')
text(-1.8,1.5,'log count')
set(gca,'Yaxislocation','right')

save_figure('figure_1c_colabeling',getdesktopfolder,gcf);