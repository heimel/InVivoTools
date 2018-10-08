function FinalImage = fasttifread( FileTif, InfoImage )
%FASTTIFREAD reads in entire tif stack fast
%
% IM = FASTTIFREAD( FILENAME, [INFOIMAGE] )
%     fragile code, makes assumptions on data, use with caution
%
% Code adapted from: http://www.matlabtips.com/how-to-load-tiff-stacks-fast-really-fast/
%
% Note: uses tifflib mexfiles in private folder
%
% 2015, Alexander Heimel


warning('off');

if nargin<2
    InfoImage=imfinfo(FileTif);
end
    
mImage = InfoImage(1).Width;
nImage = InfoImage(1).Height;
if isfield(InfoImage,'NumberOfFrames')
   NumberOfFrames = InfoImage(1).NumberOfFrames;
else
   NumberOfFrames = length(InfoImage); 
end
    
if isfield(InfoImage,'NumberOfChannels')
    NumberOfChannels = InfoImage(1).NumberOfChannels;
else
    NumberOfChannels = 1;
end
NumberImages = NumberOfChannels * NumberOfFrames;

FinalImage = zeros(nImage,mImage,NumberImages,'uint16');

%tic
FileID = tifflib('open',FileTif,'r');
rps = tifflib('getField',FileID,Tiff.TagID.RowsPerStrip);

for i=1:NumberImages
    %   tifflib('setDirectory',FileID,i-1);
    rps = min(rps,nImage);
    for r = 1:rps:nImage
        row_inds = r:min(nImage,r+rps-1);
        %     stripNum = tifflib('computeStrip',FileID,r)
        stripNum = floor(r/rps)+1;
        FinalImage(row_inds,:,i) = tifflib('readEncodedStrip',FileID,stripNum-1);
    end
    if i<NumberImages
        tifflib('readDirectory',FileID);
    end
end
tifflib('close',FileID);
%toc
warning('on')

if NumberOfChannels>1
    FinalImage = reshape(FinalImage,size(FinalImage,1),size(FinalImage,2),NumberOfFrames,NumberOfChannels);
end


%tic;for i=1:NumberImages;FinalImage(:,:,i)=imread(FileTif,i);end;toc;