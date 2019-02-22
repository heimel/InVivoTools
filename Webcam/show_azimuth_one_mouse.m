
experiment('14.13');
host('tinyhat');

db = load_testdb('wc');

nose = [];
arse = [];
stim = [];

ind=find_record(db,'mouse=172002.1.20,comment=*frz*');
% ind=find_record(db,'mouse=172002.1.35,comment=*frz*');
% 
 ind=find_record(db,'mouse=172002.1.17,comment=*frz*'); %up to 24
 ind=find_record(db,'mouse=172002.1.35,comment=*frz*');
% 

db = db(ind);


stim_azimuth_org = [];
stim_elevation_org = [];
stim_azimuth_corr = [];
stim_elevation_corr= [];

for i=1:length(db)
    if ~isempty(db(i).measures) && isfield(db(i).measures,'nose') && ~isempty(db(i).measures.nose)
        [stim_azimuth,stim_elevation] = ...
            wc_compute_overheadstim_angles(db(i).measures.nose,db(i).measures.arse,db(i).measures.stim);
        
        db(i).measures.stim_azimuth = stim_azimuth(find(~isnan(stim_azimuth),1));
        db(i).measures.stim_elevation = stim_elevation(find(~isnan(stim_azimuth),1));
        
        nose = [nose;db(i).measures.nose];
        arse = [arse;db(i).measures.arse];
        stim = [stim;db(i).measures.stim];
        
        
        switch db(i).stim_type(1:6)
            case 'disc_c'
                stim_azimuth_corr = [stim_azimuth_corr db(i).measures.stim_azimuth ];
                stim_elevation_corr = [stim_elevation_corr db(i).measures.stim_elevation];
            case {'disc_L','disc_R'}
                stim_azimuth_org = [stim_azimuth_org db(i).measures.stim_azimuth ];
                stim_elevation_org = [stim_elevation_org db(i).measures.stim_elevation];
        end
    end
end


figure;
r = cos(stim_elevation_org);
phi = stim_azimuth_org;
polarplot(phi,r,'or');
hold on
r = cos(stim_elevation_corr);
phi = stim_azimuth_corr;
polarplot(phi,r,'og');


figure;
plot(stim_azimuth_org,stim_elevation_org,'or');
hold on;
plot(stim_azimuth_corr,stim_elevation_corr,'og');







