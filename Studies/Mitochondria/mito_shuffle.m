function mito_shuffle
%MITO_SHUFFLE
%
%  Shuffles mitos along axons and recomputes distance2mito
% 
% 2014, Alexander Heimel

global db

logmsg('Refine sampling of axons for picking random locations');
logmsg('mito_bouton distance should be calculated for same axons puncta only');


experiment(11.12);
if ~exist('db') || isempty(db) % temp for script
    db = load_expdatabase('tptestdb_olympus');
    
end

groupdb = load_groupdb;

%groupname = '11.12 no lesion';
groupname = '11.12 lesion';

ind = find_record(groupdb,['name=' groupname]);
selection = groupdb(ind).filter;

logmsg(['Group is ' groupname ', selection is ' selection ]);
ind = find_record(db,selection);

% logmsg('take first only, temporary')
% ind = ind(1);

db = db(ind);


distance2mito_org = [];
distance2mito_shuf = [];

n_shuffles = 5;

for i=1:length(db)
    if ~isempty(db(i).measures)
        distance2mito_org = [distance2mito_org [db(i).measures([db(i).measures.bouton]).distance2mito]];
        for j=1:n_shuffles
            shuffled_record = tp_mito_close( shuffle_mitos_record( db(i)) );
            distance2mito_shuf = [distance2mito_shuf [shuffled_record.measures([shuffled_record.measures.bouton]).distance2mito] ];
        end
    end
end


[n_org,x]=hist(distance2mito_org,120);
n_org = n_org / length(distance2mito_org);
[n_shuf,x]=hist(distance2mito_shuf,x);
n_shuf = n_shuf / length(distance2mito_shuf);

figure; 
hold on;
h.org = bar(x,n_org);
set(h.org,'facecolor',[1 0 0]);
h.shu = bar(x+mean(diff(x))/6,n_shuf);
c.su = get(h.shu, 'child');
set(c.su,'facea',0.3);
xlabel('Distance to mito (um)');
ylabel('Fraction');
legend('Data','Shuffled')
legend boxoff

save_figure('mito_shuffle_distance2mito.png');

[h,p] = kstest2(distance2mito_org,distance2mito_shuf);

logmsg(['p = ' num2str(p,3) ', Kolmogorov-Smirnov']);


function record = shuffle_mitos_record( record)
celllist = record.ROIs.celllist;
ind_axons = strmatch('axon',{celllist.type});
ind_mito = strmatch('bouton',{celllist.type});
for i=1:length(ind_axons)
    axon = celllist(ind_axons(i));
    index = axon.index;
    ind_mito_on_axon = ind_mito(cellfun(@(x) x(1),{celllist(ind_mito).neurite})==index);
    random_pos_on_axon = random('unid',length(axon.xi),length(ind_mito_on_axon),1);
    random_x = axon.xi(random_pos_on_axon);
    random_y = axon.yi(random_pos_on_axon);
    if length(axon.zi) == length(axon.xi)
        random_z = axon.zi(random_pos_on_axon);
    else
        random_z = axon.zi*ones(1,length(random_pos_on_axon));
    end
        
    for j=1:length(ind_mito_on_axon) % move mito to random position on axon
        mito = celllist(ind_mito_on_axon(j));
        mito.xi = mito.xi - mean(mito.xi) + random_x(j);
        mito.yi = mito.yi - mean(mito.yi) + random_y(j);

%         logmsg('Offset and swap for debugging');
%         mito.xi = mito.xi - mean(mito.xi) + random_y(j);
%         mito.yi = mito.yi - mean(mito.yi) + random_x(j)+100;
        
        mito.zi = mito.zi - mean(mito.zi) + random_z(j);
        celllist(ind_mito_on_axon(j)) = mito;
        % pixelinds is not updated!
    end % j
    
end %  i
record.ROIs.celllist = celllist;

