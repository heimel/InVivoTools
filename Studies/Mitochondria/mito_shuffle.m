function mito_shuffle
%MITO_SHUFFLE
%
%  Shuffles mitos along axons and recomputes distance2mito
%
% 2014, Alexander Heimel

global testdb

logmsg('Refine sampling of axons for picking random locations');


experiment(11.12);
if ~exist('testdb') || isempty(testdb) % temp for script
    testdb = load_expdatabase('tptestdb_olympus');
end

groupdb = load_groupdb;

%groupname = '11.12 no lesion';
groupname = '11.12 lesion';

ind = find_record(groupdb,['name=' groupname]);
selection = groupdb(ind).filter;

logmsg(['Group is ' groupname ', selection is ' selection ]);
ind = find_record(testdb,selection);

% logmsg('take first only, temporary')
% ind = ind(1);

db = testdb(ind);


distance2mito_org = [];
distance2mito_shuf = [];

n_shuffles = 10;

for i=1:length(db)
    logmsg(['Record ' num2str(i) ' of ' num2str(length(db))]);
    if ~isempty(db(i).measures)
        shuffled_record = shuffle_mitos_record( db(i));
        if isempty(shuffled_record)
            continue  % no z-info for axon
        end
        shuffled_record = tp_mito_close(shuffled_record  );
        distance2mito_shuf = [distance2mito_shuf ...
            [shuffled_record.measures([shuffled_record.measures.bouton] & [shuffled_record.measures.present]).distance2mito] ];
        db(i) = tp_mito_close( db(i));
        distance2mito_org = [distance2mito_org [db(i).measures([db(i).measures.bouton] & [db(i).measures.present]).distance2mito]];
        
        
        for j=2:n_shuffles
            shuffled_record = tp_mito_close( shuffle_mitos_record( db(i)) );
            distance2mito_shuf = [distance2mito_shuf ...
                [shuffled_record.measures([shuffled_record.measures.bouton] & [shuffled_record.measures.present]).distance2mito] ];
        end
        
        %         if sum(isnan([shuffled_record.measures([shuffled_record.measures.bouton]).distance2mito]))~=sum(isnan([shuffled_record.measures([shuffled_record.measures.bouton]).distance2mito]))
        %         if sum([db(i).measures.bouton] & [db(i).measures.present]) -  sum([shuffled_record.measures.bouton] & [shuffled_record.measures.present]) ~= 0
        %             logmsg('Oops');
        %             keyboard
        %         end
        
        
    end
end


distance2mito_org = distance2mito_org(~isnan(distance2mito_org));
distance2mito_shuf = distance2mito_shuf(~isnan(distance2mito_shuf));

edges = 0:0.5:100;

[n_org]=histc(distance2mito_org,edges);
n_org = n_org / length(distance2mito_org);
[n_shuf]=histc(distance2mito_shuf,edges);
n_shuf = n_shuf / length(distance2mito_shuf);

n_org = n_org(1:end-1); % remove right edge
n_shuf = n_shuf(1:end-1);% remove right edge
x=edges(1:end-1)+(edges(2)-edges(1))/2;
figure;
hold on;
h.shu = bar(x,n_shuf,1);
c.su = get(h.shu, 'child');
color_shu = [0.3 0.3 0.3];
set(h.shu,'facecolor',color_shu);
set(h.shu,'edgecolor',color_shu);
%set(c.su,'facea',0.3);

h.org = bar(x,n_org,1);
set(h.org,'facecolor',[1 0 0]);
set(h.org,'edgecolor',[1 0 0]);

xlabel('Distance to mito (um)');
ylabel('Fraction');
legend([h.org,h.shu],'Data','Shuffled')
legend boxoff
xlim([0 20]);

x=flatten([edges;edges]);
x = x(2:end-1);
y = flatten([n_shuf;n_shuf]);
plot(x,y,'color',color_shu);

save_figure(['mito_shuffle_distance2mito_' groupname '.png']);

logmsg(['Original mean distance2mito = ' num2str(mean(distance2mito_org),3) ' +- ' num2str(sem(distance2mito_org),3) ' (SEM), n = ' num2str(length(distance2mito_org))]);
logmsg(['Shuffled mean distance2mito = ' num2str(mean(distance2mito_shuf),3) ' +- ' num2str(sem(distance2mito_shuf),3) ' (SEM), n = ' num2str(length(distance2mito_shuf))]);


[h,p] = kstest2(distance2mito_org,distance2mito_shuf);

logmsg(['p = ' num2str(p,3) ', Kolmogorov-Smirnov']);





function record = shuffle_mitos_record( record)


params = tpreadconfig(record);
if isempty(params)
    record = [];
    return
end

debug = false;

if debug
    open_tptestrecord(record);
end

celllist = record.ROIs.celllist;
ind_axons = strmatch('axon',{celllist.type});
ind_mito = strmatch('mito',{celllist.type});
for i=1:length(ind_axons)
    axon = celllist(ind_axons(i));
    index = axon.index;
    ind_mito_on_axon = ind_mito(cellfun(@(x) x(1),{celllist(ind_mito).neurite})==index);
    
    if length(axon.zi) ~= length(axon.xi)
        logmsg(['Axon is 2D only. Shuffle is not possible for ' recordfilter(record)]);
        record = [];
        return
    end
    
    
    meanstep_pixel = mean(sqrt((diff(axon.xi)).^2+(diff(axon.yi)).^2+(diff(axon.zi)).^2));
    meanstep_um = meanstep_pixel * params.x_step;
    required_step_um = 0.5; % minimum interpolation step
    reinterpolate = ceil(meanstep_um/required_step_um);
    %    reinterpolate = 0.1;
    %reinterpolate = 1;
    
    x = 1:length(axon.xi);
    nx = 1:1/reinterpolate:length(axon.xi);
    xi = interp1(x,axon.xi,nx);
    yi = interp1(x,axon.yi,nx);
    zi = interp1(x,axon.zi,nx);
    
    random_pos_on_axon = random('unid',length(xi),length(ind_mito_on_axon),1);
    random_x = xi(random_pos_on_axon);
    random_y = yi(random_pos_on_axon);
    random_z = zi(random_pos_on_axon);
    
    
    for j=1:length(ind_mito_on_axon) % move mito to random position on axon
        mito = celllist(ind_mito_on_axon(j));
        mito.xi = mito.xi - mean(mito.xi) + random_x(j);
        mito.yi = mito.yi - mean(mito.yi) + random_y(j);
        
        %           logmsg('Offset and swap x,y for debugging');
        %           mito.xi = mito.xi + 10/params.x_step;
        
        mito.zi = mito.zi - mean(mito.zi) + random_z(j);
        celllist(ind_mito_on_axon(j)) = mito;
        % pixelinds is not updated!
    end % j
    
end %  i
record.ROIs.celllist = celllist;


if debug
    open_tptestrecord(record);
    keyboard
end