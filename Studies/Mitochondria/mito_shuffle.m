function mito_shuffle
%MITO_SHUFFLE
%
%  Shuffles mitos along axons and recomputes distance2mito
%
% 2014, Alexander Heimel

global testdb

n_shuffles = 10;
groupname = '11.12 no lesion';
%groupname = '11.12 lesion';

logmsg('Refine sampling of axons for picking random locations');

experiment(11.12);
if ~exist('testdb') || isempty(testdb) % temp for script
    testdb = load_expdatabase('tptestdb_olympus');
end

groupdb = load_groupdb;

ind = find_record(groupdb,['name=' groupname]);
selection = groupdb(ind).filter;

logmsg(['Group is ' groupname ', selection is ' selection ]);
ind = find_record(testdb,selection);

% logmsg('take first only, temporary')
% ind = ind(1);

db = testdb(ind);


distance2mito_org = [];
distance2mito_shuf = [];


for i=1:length(db)
    logmsg(['Record ' num2str(i) ' of ' num2str(length(db))]);
    
    if axons2d( db(i) )
        continue
    end
    
    params = tpreadconfig( db(i) );
    if isempty(params)
        continue
    end
    db(i) = interpolate_axons( db(i), params );
    
    db(i) = pull_mito2axons( db(i), params );
    
    db(i) = tp_mito_close( db(i),params);
    if ~isempty(db(i).measures)
        distance2mito_org = [distance2mito_org [db(i).measures([db(i).measures.bouton] & [db(i).measures.present]).distance2mito]];

        for j=1:n_shuffles
            shuffled_record = shuffle_mitos_record( db(i));
            shuffled_record = tp_mito_close( shuffled_record,params  );
            distance2mito_shuf = [distance2mito_shuf ...
                [shuffled_record.measures([shuffled_record.measures.bouton] & [shuffled_record.measures.present]).distance2mito] ];
        end
    end
end


distance2mito_org = distance2mito_org(~isnan(distance2mito_org));
distance2mito_shuf = distance2mito_shuf(~isnan(distance2mito_shuf));

% make figures
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

% outline of shuffled data
x=flatten([edges;edges]);
x = x(2:end-1);
y = flatten([n_shuf;n_shuf]);
plot(x,y,'color',color_shu);

xlabel('Distance to mito (um)');
ylabel('Fraction');
legend([h.org,h.shu],'Data','Shuffled')
legend boxoff
xlim([0 20]);

save_figure(['mito_shuffle_distance2mito_' groupname '.png']);

% statistics

logmsg(['Original mean distance2mito = ' num2str(mean(distance2mito_org),3) ' +- ' num2str(sem(distance2mito_org),3) ' (SEM), n = ' num2str(length(distance2mito_org))]);
logmsg(['Shuffled mean distance2mito = ' num2str(mean(distance2mito_shuf),3) ' +- ' num2str(sem(distance2mito_shuf),3) ' (SEM), n = ' num2str(length(distance2mito_shuf))]);

[h,p] = kstest2(distance2mito_org,distance2mito_shuf); %#ok<ASGLU>

logmsg(['p = ' num2str(p,3) ', Kolmogorov-Smirnov']);




function record = interpolate_axons( record, params)
celllist = record.ROIs.celllist;
ind_axons = strmatch('axon',{celllist.type});
for i=1:length(ind_axons)
    axon = celllist(ind_axons(i));
    if length(axon.zi)>1
        meanstep_pixel = mean(sqrt((diff(axon.xi)).^2+(diff(axon.yi)).^2+(diff(axon.zi)).^2));
    else
        meanstep_pixel = mean(sqrt((diff(axon.xi)).^2+(diff(axon.yi)).^2));
    end
    meanstep_um = meanstep_pixel * params.x_step;
    required_step_um = 0.1; % minimum interpolation step
    reinterpolate = ceil(meanstep_um/required_step_um);
    % reinterpolate = 0.1;
    
    x = 1:length(axon.xi);
    nx = 1:1/reinterpolate:length(axon.xi);
    axon.xi = interp1(x,axon.xi,nx);
    axon.yi = interp1(x,axon.yi,nx);
    if length(axon.zi)>1
        axon.zi = interp1(x,axon.zi,nx);
    end
    celllist(ind_axons(i)) = axon;
end
record.ROIs.celllist = celllist;



function record = shuffle_mitos_record( record)
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
    
    random_pos_on_axon = random('unid',length(axon.xi),length(ind_mito_on_axon),1);
    random_x = axon.xi(random_pos_on_axon);
    random_y = axon.yi(random_pos_on_axon);
    random_z = axon.zi(random_pos_on_axon);
    
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



function res = axons2d( record)
res = false;
celllist = record.ROIs.celllist;
ind_axons = strmatch('axon',{celllist.type});
for i=1:length(ind_axons)
    axon = celllist(ind_axons(i));
    if length(axon.zi)<length(axon.xi)
        res = true;
        return
    end
end

function record = pull_mito2axons( record, params )
celllist = record.ROIs.celllist;
ind_axons = strmatch('axon',{celllist.type});
ind_mito = strmatch('mito',{celllist.type});
for i=1:length(ind_axons)
    axon = celllist(ind_axons(i));
    index = axon.index;
    ind_mito_on_axon = ind_mito(cellfun(@(x) x(1),{celllist(ind_mito).neurite})==index);
    
    if length(axon.zi) ~= length(axon.xi)
        logmsg(['Axon is 2D only. Pulling mitos to their axon is not possible for ' recordfilter(record)]);
        record = [];
        return
    end
        
    for j=1:length(ind_mito_on_axon) % move mito to random position on axon
        mito = celllist(ind_mito_on_axon(j));
        
        center = [mean(mito.xi); mean(mito.yi); mean(mito.zi)];
        axonr = [axon.xi ; axon.yi; axon.zi];
        d = axonr - repmat(center,1,length(axon.xi));
        d = d.*repmat([params.x_step;params.y_step;params.z_step],1,size(d,2));
        
        [m,ind]=min(sum(d.^2)); %#ok<ASGLU>  axon spot closest to center
        mito.xi = mito.xi - mean(mito.xi) + axon.xi(ind);
        mito.yi = mito.yi - mean(mito.yi) + axon.yi(ind);
        mito.zi = mito.zi - mean(mito.zi) + axon.zi(ind);
        celllist(ind_mito_on_axon(j)) = mito;
        % pixelinds is not updated!
    end % j
end %  i
record.ROIs.celllist = celllist;
