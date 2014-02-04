function mito_shuffle
%MITO_SHUFFLE
%
%  Shuffles mitos along axons and recomputes distance2mito
% 
% 2014, Alexander Heimel

global db

experiment(11.12);
if ~exist('db') || isempty(db) % temp for script
    db = load_expdatabase('tptestdb_olympus');
    
end

%selection = 'reliable=1';
selection = 'mouse=11.12.15|mouse=11.12.28|mouse=11.12.31'; % no lesion

logmsg(['Selection is ' selection ]);
ind = find_record(db,selection);

% logmsg('take first only, temporary')
% ind = ind(1);

db = db(ind);


distance2mito_org = [];
distance2mito_shuf = [];

n_shuffles = 10;

for i=1:length(db)
    distance2mito_org = [distance2mito_org [db(i).measures(:).distance2mito]];
    for j=1:n_shuffles
        shuffled_record = analyse_tptestrecord( shuffle_mitos_record( db(i)) );
        distance2mito_shuf = [distance2mito_shuf [shuffled_record.measures(:).distance2mito] ];
    end
end

figure; hold on;
[n_org,x]=hist(distance2mito_org,20);
n_org = n_org / length(distance2mito_org);
h.org = bar(x,n_org);
set(h.org,'facecolor',[1 0 0]);
[n_shuf,x]=hist(distance2mito_shuf,x);
n_shuf = n_shuf / length(distance2mito_shuf);
h.shu = bar(x+mean(diff(x))/6,n_shuf);
c.su = get(h.shu, 'child');
set(c.su,'facea',0.3);
xlabel('Distance to mito (um)');
ylabel('Fraction');
legend('Data','Shuffled')
legend boxoff

[h,p] = kstest2(distance2mito_org,distance2mito_shuf)

keyboard


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
        random_z = axon.zi*ones(size(axon.xi));
    end
        
    for j=1:length(ind_mito_on_axon) % move mito to random position on axon
        mito = celllist(ind_mito_on_axon(j));
        mito.xi = mito.xi - mean(mito.xi) + random_x(j);
        mito.yi = mito.yi - mean(mito.yi) + random_y(j);
        mito.zi = mito.zi - mean(mito.zi) + random_z(j);
        celllist(ind_mito_on_axon(j)) = mito;
        % pixelinds is not updated!
    end % j
    
end %  i
record.ROIs.celllist = celllist;

