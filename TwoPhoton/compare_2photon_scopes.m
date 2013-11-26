function compare_2photon_scopes

% make figure of comparison of two-photon data DeZeeuw and Levelt scopes
%
% 2011, Alexander Heimel
%

tycho = [6 mean([960 440 1181]);7 mean([380 400]);9 mean([511 360]);12 340];
tycho(:,1) = tycho(:,1)*2.5*10; % to get microns

tycho(:,2) = tycho(:,2)/max(tycho(:,2));

% zoom_5_slow_scan
% max_dendrite: 
daan_max_dendrite = [0 1054;1 1204; 2 1169; 3 1139; 6 1334; 7 1668; 8 1749;];
daan_max_dendrite(:,1) = daan_max_dendrite(:,1) - 726;
daan_max_frame = [9 1833; 10 1707; 11 2943; 12 2807;13 3733;14 2836];

dezeeuw{1} = getdezeeuwdata( '/home/data/InVivo/Twophoton/Calibration/IWO2P_test_12082011/110812_disc_iwo2p_11-18-23/disc_iwo2p_11-18-23_PMT - PMT [595-40] _C0_xyz-Table ',15);
levelt{1} = getleveltdata( '/home/data/InVivo/Twophoton/Calibration/2011-08-12/zoom_5_slow_scan.tif',2);
levelt{2} = getleveltdata( '/home/data/InVivo/Twophoton/Calibration/2011-08-12/large_field_of_view.tif',2);

% cells
daan = [ 11 1050;12 1210;13 1290;15 830;20 380;21 mean([240 280])];
daan(:,2) = daan(:,2)/max(daan(:,2));
daan(:,1) = daan(:,1)*10;


daanlargefov = [13 mean([1700 1690 1750]);16 mean([1870 2100]);...
    18 mean([1540 1250]);20 mean([770 1030]);23 650;25 350];
daanlargefov(:,2) = daanlargefov(:,2)/max(daanlargefov(:,2));
daanlargefov(:,1) = daanlargefov(:,1)*10;

hold off
%plot(tycho(:,1),tycho(:,2),'ko-');
hold on;
plot(dezeeuw{1}.depth,dezeeuw{1}.max_norm,'ko-')
plot(dezeeuw{1}.depth,dezeeuw{1}.mean_norm,'ko--')
%plot(daan(:,1),daan(:,2),'ro-')
plot(levelt{1}.depth,levelt{1}.max_norm,'ro-')
plot(levelt{1}.depth,levelt{1}.mean_norm,'ro--')
%plot(daanlargefov(:,1),daanlargefov(:,2),'bo-')
%plot(levelt{2}.depth,levelt{2}.max_norm,'bo-')
%plot(levelt{2}.depth,levelt{2}.mean_norm,'bo--')
ylim([0 1.2]);
xlim([0 320]);
ylabel('Normalized intensity');
xlabel('Depth (micron)');
legend('DeZeeuw max','DeZeeuw mean','Levelt max','Levelt mean');
savefig('scope_comparison.png',gcf,'png');


return

function data = getdezeeuwdata( basename, n_frames)

f = 0;
filename = [basename 'Z' num2str(f,'%02d') '.ome.tif'];

data.max = [];
for f = 1:(n_frames-1)
    filename = [basename 'Z' num2str(f,'%02d') '.ome.tif'];
    ima = imread(filename);
    ima = double(ima(:));
    data.mode(f) = mode(ima);
    data.max(f) = max(ima)-data.mode(f);
    st = std( ima( ima<data.mode(f)));
    data.mean(f) = mean( ima( ima>(data.mode(f)+3*st)))-data.mode(f);
    data.depth(f) = (f-1)*25; % 25 micron per slice
end
data.mean_norm = data.mean / max(data.mean);
data.max_norm = data.max / max(data.max);



function data = getleveltdata( filename, channel )

ti = tiffinfo(filename);
data.max = [];
for f = 1:ti.NumberOfFrames
    ima = imread(filename,f+(channel-1)*ti.NumberOfFrames);
    ima = double(ima(:));
    data.mode(f) = mode(ima);
    data.max(f) = max(ima)-data.mode(f);
    st = std( ima( ima<data.mode(f)));
    data.mean(f) = mean( ima( ima>(data.mode(f)+3*st)))-data.mode(f);
    data.depth(f) = (f-1)*10; % 10 micron per slice
end
data.mean_norm = data.mean / max(data.mean);
data.max_norm = data.max / max(data.max);





