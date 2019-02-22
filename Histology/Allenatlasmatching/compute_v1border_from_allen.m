function compute_v1border_from_allen
%COMPUTE_V1BORDER_FROM_ALLEN shows injection and recording site on topview of brain
%
% used to calculate V1 border distance 
%
% 2018, Alexander Heimel

persistent ANO

% 25 micron volume size
size_ml = 456;
size_rc = 528;
size_dv = 320;

siz = [528 320 456];
% VOL = 3-D matrix of atlas Nissl volume
% fid = fopen('Atlas/atlasVolume.raw', 'r', 'l' );
% VOL = fread( fid, prod(siz), 'uint8' );
% fclose( fid );
% VOL = reshape(VOL,siz);
% ANO = 3-D matrix of annotation labels
if isempty(ANO)
    fid = fopen('Atlas/annotation.raw', 'r', 'l' );
    ANO = fread( fid, prod(siz), 'uint32' );
    fclose( fid );
    ANO = reshape(ANO,siz);
end

TOPANO = NaN([528 456]);
for rc = 1:size_rc
    for ml = 1:size_ml
        ind = find(ANO(rc,:,ml)>0,1,'first');
        if ~isempty(ind)
            TOPANO(rc,ml) = ANO(rc,ind,ml);
            
        end
    end
end

v = unique(TOPANO(~isnan(TOPANO)));
topano = zeros(size(TOPANO));
for rc = 1:size_rc
    for ml = 1:size_ml
        if ~isnan(TOPANO(rc,ml))
            topano(rc,ml) = find(v==TOPANO(rc,ml));
        end
    end
end


ftopano = medfilt2(topano,[9 9]);

% figure;
% imagesc(ftopano);colormap(prism);axis image

edges = edge(ftopano,'canny');
figure
imagesc(edges);
colormap gray
axis image
hold on

% imshowpair(ftopano,edges)
% 1 pixel is 0.025 mm

zero_ml = size_ml/2;
zero_rc = 390;

xticklab = -5:1:5; %mm
xticks = mm2ind(xticklab,zero_ml);
set(gca,'XTick',xticks,'XTickLabel',xticklab);

yticklab = 8:-1:-8; %mm
yticks = mm2ind(-yticklab,zero_rc);
set(gca,'YTick',yticks,'YTickLabel',yticklab);
set(gca,'YDir','normal');

lambda_mm = [0 0];


% injection coordinate
injection_mm = [4.1 -1.4];
injection_ind = [mm2ind(injection_mm(1),zero_ml) mm2ind(injection_mm(2),zero_rc)];
plot(injection_ind(1),injection_ind(2),'xg'); 

v1recording_mm = [2.9 -0.4];
v1recording_ind = [mm2ind(v1recording_mm(1),zero_ml) mm2ind(v1recording_mm(2),zero_rc)];
plot(v1recording_ind(1),v1recording_ind(2),'xr'); 

b_mm = [3.6 -1];
b_ind = [mm2ind(b_mm(1),zero_ml) mm2ind(b_mm(2),zero_rc)];
plot(b_ind(1),b_ind(2),'xb'); 

distinjection2b_norm = norm([injection_mm - b_mm]) / norm([injection_mm - v1recording_mm]);

disp(['From injection site to V1 main recording, borders lies on '  num2str(distinjection2b_norm,2) ]);

keyboard


function pos_ind = mm2ind(pos_mm,zer)

pos_ind = pos_mm / 0.025;
pos_ind = round(pos_ind + zer);