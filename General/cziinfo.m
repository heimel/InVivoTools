function [info,imlabel,immacro] = cziinfo(filename)
%CZIREAD returns info in czi image
%
%  [INFO,IMLABEL,IMMACRO] = CZIINFO(FILENAME)
%
%    INFO is a struct array with an entry for each scene
%      INFO.scene, starts at 0
%      INFO.sizex
%      INFO.positionx
%      INFO.positiony
%      INFO.scale, 1 is largest
%      INFO.imagename
%      INFO.channelcount
%      INFO.channelname = cell list of strings
%      INFO.voxelSizeX_um x-size of pixel in um
%
%  IMLABEL is the image of the label
%  IMMACRO is the macro image
%
% 2021, Alexander Heimel

if nargin<1 || isempty(filename)
    filename = '\\vs01\CSF_DATA\Shared\InVivo\Experiments\TAC1_Cfos_images\Jump_TMT\58172\Jacqueline_2021_03_26_0037_4-3.czi';
end


reader = bfGetReader(filename);
omeMeta = reader.getMetadataStore();

n_images = getImageCount(omeMeta);  % number of images is czi file
n_images = n_images - 2;

info = [];
for i = 1:n_images
    width = eval(getPixelsSizeX(omeMeta,i-1));
    info(i).sizex = width; %#ok<*AGROW>
    setSeries(reader,i-1);
    metadata = char(getSeriesMetadata(reader));
    p = find(metadata=='=');
    scenestr = metadata(p+1:end-1);
    info(i).scene = eval(scenestr);
    info(i).positionx = double(getPlanePositionX(omeMeta,i-1,1).value(ome.units.UNITS.MICROMETER));
    info(i).positiony = double(getPlanePositionY(omeMeta,i-1,1).value(ome.units.UNITS.MICROMETER));
    
    info(i).imagename = char(getImageName(omeMeta,i-1));  % e.g. Jacqueline_2021_03_26_0037_4-3.czi #04

    info(i).channelcount = getChannelCount(omeMeta,i-1);
    for c = 1:info(i).channelcount
        info(i).channelname{c} = char(getChannelName(omeMeta,i-1,c-1));
    end
    info(i).voxelSizeX_um = double(omeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROMETER));

end
n_scenes = max([info(:).scene]);

% set info.scales
for s = 0:n_scenes
    ind = find([info(:).scene] == s);
    [~,inds] = sort([info(ind).sizex],'descend');
    for i = 1:length(ind)
        info(ind(i)).scale = inds(i);
    end
end

if nargout>1
    %% Show label image
    
    reader.setSeries( n_images);
    width = getSizeX(reader);
    height = getSizeY(reader);
    imlabel = zeros(height,width,3);
    
    for c = 1:3
        im = bfGetPlane(reader, c);
        %   im = im - mode(im(:));
        im = double(im);
        im = im / prctile(im(:),75) ;
        imlabel(:,:,c) = im;
    end
    imlabel = imrotate(imlabel,-90);
    axes('position',[0 0.8 0.2 0.2]);
    image(imlabel)
    axis image off
    
    
    %% Show macro image
    reader.setSeries( n_images+1);
    width = getSizeX(reader);
    height = getSizeY(reader);
    immacro = zeros(height,width,3);
    
    for c = 1:3
        im = bfGetPlane(reader, c);
        im = im - prctile(im(:),10);
        im = double(im);
        im = im / prctile(im(:),90) ;
        immacro(:,:,c) = im;
    end
    axes('position',[0.8 0.8 0.2 0.2]);
    image(immacro)
    axis image off
    
    
end

