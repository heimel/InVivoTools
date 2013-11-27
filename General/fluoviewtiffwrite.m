function fluoviewtiffwrite(images,fname,inf)
%FLUOVIEWTIFFWRITE
%
% incomplete setting of tiff header
%
% 2011, Alexander Heimel
%

% automatically set tif as extension
[pathstr,name,ext] = fileparts(fname);
fname = fullfile( pathstr,[name '.tif']);

if isfield(inf,'ImageDescription')
    description = inf.ImageDescription;
else 
    description = 'empty'; % probably needs to be filled in still
end


imwrite(images(:,:,1,1),fname,'tiff','Description',description,'Compression','none');
for ch=1:size(images,4)
    for fr=1:size(images,3)
        if ch==1 && fr==1
            continue
        end
        imwrite(images(:,:,fr,ch),fname,'tiff','WriteMode','append','Compression','none');
    end
end