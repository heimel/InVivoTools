%compute_overheadstim_angles_for_db
%
% script to recompute all overhead stimulus elevation and azimuths
%
% 2018, Alexander Heimel

experiment('14.13');
host('tinyhat');

db = load_testdb('wc');

nose = [];
arse = [];
stim = [];

for i=1:length(db)
    if ~isempty(db(i).measures) && isfield(db(i).measures,'nose') && ~isempty(db(i).measures.nose)
        [stim_azimuth,stim_elevation] = ...
                        wc_compute_overheadstim_angles(db(i).measures.nose,db(i).measures.arse,db(i).measures.stim);
        
        db(i).measures.stim_azimuth = stim_azimuth(find(~isnan(stim_azimuth),1));
        db(i).measures.stim_elevation = stim_elevation(find(~isnan(stim_azimuth),1));
        
        nose = [nose;db(i).measures.nose];
        arse = [arse;db(i).measures.arse];
        stim = [stim;db(i).measures.stim];
    end
end



ind = find_record(db,'comment=*frz*,date>2016-00-00');
fdb = db(ind);

stim_azimuth = [];
stim_elevation = [];

for i=1:length(fdb)
    if isfield(fdb(i).measures,'stim_azimuth')
        stim_azimuth = [stim_azimuth fdb(i).measures.stim_azimuth ];
        stim_elevation = [stim_elevation fdb(i).measures.stim_elevation];
    end
end

figure;
subplot(2,2,1);
plot(stim_azimuth,stim_elevation,'.');
xlabel('Azimuth (radii)');
ylabel('Elevation (radii)');
axis([-pi pi 0 pi/2]);
subplot(2,2,3);
histogram(stim_azimuth,'binlimits',[-pi pi]);
xlabel('Azimuth (radii)');
ylabel('Count');
subplot(2,2,4);
histogram(stim_elevation,'binlimits',[0 pi/2]);
xlabel('Elevation (radii)');
ylabel('Count');

