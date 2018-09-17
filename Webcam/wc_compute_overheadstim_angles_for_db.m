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

%my_colours;

figure;
axx1 = subplot(1,3,1);
plot(axx1, stim_azimuth,stim_elevation,'v', 'MarkerSize', 5, 'MarkerEdgeColor', saddle_brown);
xlabel('Azimuth (radii)', 'FontSize', 18);
ylabel('Elevation (radii)', 'FontSize', 18);
axis([-pi pi 0 pi/2]);
box(axx1, 'off')
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',18);

axx2 = subplot(1,3,2);
histogram(axx2, stim_azimuth,'binlimits',[-pi pi], 'FaceColor',light_salmon);
xlabel('Azimuth (radii)', 'FontSize', 18);
ylabel('Number of trials', 'FontSize', 18);
box(axx2, 'off')
aa = get(gca,'XTickLabel');
set(gca,'XTickLabel',aa,'fontsize',18);

axx3 = subplot(1,3,3);
histogram(axx3,stim_elevation,'binlimits',[0 pi/2], 'FaceColor',my_pink);
xlabel('Elevation (radii)', 'FontSize', 18);
ylabel('Number of trials', 'FontSize', 18);
box(axx3, 'off')
aaa = get(gca,'XTickLabel');
set(gca,'XTickLabel',aaa,'fontsize',18)
