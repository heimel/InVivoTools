function czi2tif(filename,outputpath, scalenr,verbose,for_amasine)
%CZI2TIF Opens czi file as saves all scenes to tiff files
%
%  CZI2TIF(FILENAME,OUTPUTPATH,SCALENR=1,VERBOSE=FALSE,FOR_AMASINE=FALSE)
%
%      SCALENR starts at 1, largest scale first
%
% 2021, Alexander Heimel


if nargin<1 || isempty(filename)
    filename = '\\vs01\CSF_DATA\Shared\InVivo\Experiments\TAC1_Cfos_images\Jump_TMT\58172\Jacqueline_2021_03_26_0037_4-3.czi';
end
if nargin<2 || isempty(outputpath)
    outputpath = fileparts(filename);
end
if nargin<3 || isempty(scalenr)
    scalenr = 1;
end
if nargin<4 || isempty(verbose)
    verbose = true;
end
if nargin<5 || isempty(for_amasine)
    for_amasine = true;
end

info = cziinfo(filename);
scenes = unique([info(:).scene]);
for s = scenes
    ind = find([info(:).scene]==s & [info(:).scale] == scalenr,1);
    n_channels = info(ind).channelcount;
    for c=1:n_channels
        if verbose
            disp(['Loading ' filename ' scene #' num2str(s) ', scale #' num2str(scalenr) ', channel #' num2str(c)]);
        end
        img = cziread(filename,s,scalenr,c);
        
        [~,rootname] = fileparts(filename); 
        outputfilename = fullfile(outputpath,[rootname '_S' num2str(s) '_C' num2str(c) '.tif']);
        
        if for_amasine
            outputfilename(outputfilename=='-') = '';
        end
        if verbose
            disp(['Writing to ' outputfilename ]);
        end
        imwrite(img,outputfilename,'tiff');
    end
end
