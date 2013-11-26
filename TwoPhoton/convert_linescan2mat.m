function convert_linescan2mat( tifname, original_linescan_period, compression )
if nargin < 3
    compression = 10;
end


% read linescan image
[datapath,basename] = fileparts( tifname );
basename = fullfile(datapath,basename);

matname = [basename '_compressed_' num2str(compression) 'x.mat'];
tinf = tiffinfo(tifname);
n_frames = tinf.NumberOfFrames;
width = tinf.Width;
height = tinf.Height;



disp(['original linescan: n_frames = ' num2str(n_frames) ...
    ', width = ' num2str(width) ', height = ' num2str(height)]);

compressed_height = height / compression;
if compressed_height ~= round(compressed_height)
    error('compression factor does not divide frame height');
end
fullheight =  compressed_height *n_frames;


full_image = zeros( fullheight, width);
compressed_frame  = zeros( compressed_height, width);

for f = 1:n_frames
    frame = imread(tifname,f);
    imagesc(frame);
    for r = 1:compressed_height
        compressed_frame(r,:) = mean( frame(compression * (r-1) +(1:compression),:),1);
    end
    imagesc(compressed_frame);
    full_image( compressed_height*(f-1) + (1:compressed_height),:) = compressed_frame;
end



compressed_linescan_period = original_linescan_period * compression;

save(matname,'full_image','compressed_linescan_period','original_linescan_period','-mat');
imwrite(full_image / max(full_image(:)),[basename '_compressed_' num2str(compression) 'x.png'],'png');





