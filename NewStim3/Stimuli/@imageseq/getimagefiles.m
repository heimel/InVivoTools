function filelist = getimagefiles(S)

% GETIMAGEFILES - Return a list of selected image files for imageseq
%
%
%  FILELIST = GETIMAGEFILES(IMAGESEQ_STIM)
%
%
%  Returns a list of the image files with the extensions
%   '.TIFF','.TIF','.tiff','.tif','.JPG','.JPEG','.jpg','.jpeg',
%   '.GIF', or '.gif' in the "dirname" parameter (see GETPARAMETERS).
%
%
%  See also: IMAGESEQ IMAGESEQ/GETPARAMETERS 

p = getparameters(S);

extensionlist = {'.TIFF','.TIF','.tiff','.tif',...
		'.JPG','.JPEG','.jpg','.jpeg',...
		'.GIF','.gif'};

filelist = {};
mylist = [];

for i=1:length(extensionlist),
	mynewlist = dir([p.dirname filesep '*' extensionlist{i}]);
	if ~isempty(mynewlist),
		mylist = cat(1,mylist,mynewlist(:));
	end;
end;

if ~isempty(mylist),
	filelist = setdiff(sort({mylist.name}),{'.','..'});
else, filelist = {};
end;


