function [outstim] = loadstim(ISstim)

ISstim = unloadstim(ISstim);
outstim = ISstim;

StimWindowGlobals;

if haspsychtbox,

   ISparams = getparameters(ISstim);

   x1 = ISparams.rect(1); x2 = ISparams.rect(3); y1 = ISparams.rect(2); y2 = ISparams.rect(4);
   dfs = struct(getdisplayprefs(ISstim));

   % read the sequence of images, assume all have the same color table
   filelist = getimagefiles(ISstim),
   

   offscreen = []; map = [];
   numframes = 0;
   for i=1:length(filelist),
       i,
	goodframe = 0;
	gs = 0;
	try,
		[im,immap] = imread([ISparams.dirname filesep filelist{i}]);
		% if there is no map, assume grayscale
		if isempty(immap), % assume grayscale
			gs = 1;
			if numframes==0, 
				graymax = double(max(im(:)));
			end;
			im = 1+255*double(im)/graymax;
			immap = gray(255);
		end;
		numframes = numframes + 1;
		goodframe = 1;
	catch,
		warning(['Excluding file ' ISparams.dirname filesep filelist{i} ' because IMREAD failed.']);
	end;
	
	if goodframe,
		sz = size(im);
		[t,d] = size(sz);

		if numframes == 1, % use the first image to set the color map
			% do we have an indexed or RGB image?
			if d==2, % indexed
				map = immap;
			else,
				[imnew,map] = rgb2ind(im,255);
			end;
   			%downsample the map if need be
			if size(map,1)>255, [im,map] = imapprox(im,map,255); end;
			map(end+1,:) = map(end,:);
			map(2:end,:) = map(1:end-1,:);
			map(1,:) = ISparams.BG/255;
		end; % pick the first map

		% now convert to indexed mode if necessary, or downsample to the current color map
		if d>2,
			im = rgb2ind(im,map);
		elseif ~gs, % if not grayscale, convert from image index map to the first image's index map
			im = imapprox(im,immap,map);
		end;

		% create a new offscreen window or texture
		if haspsychtbox<3,
			offscreen(numframes) = Screen(-1,'OpenOffscreenWindow',255,[0 0 x2-x1 y2-y1]);
   			Screen(offscreen(numframes),'PutImage',im);
		else,
		   offscreen(numframes) = Screen('MakeTexture',StimWindow,double(im));
		end;
	end;
   end;

   if numframes>=1,  % if we have at least one good frame, we can finish
	rect = [ISparams.rect];
	dP = cat(2,{'fps',ISparams.fps,'rect',dfs.rect,'frames',1:numframes},ISparams.dispprefs);
	dS = { 'displayType', 'Movie', 'displayProc', 'standard', ...
         'offscreen', offscreen, 'frames', numframes, ...
		 'clut_usage', repmat(1,256), 'depth', 8, ...
		 'clut_bg', repmat(ISparams.BG,256,1), 'clut', map*255, 'clipRect', [], ...
		 'makeClip', 0,'userfield',[] }; 
		 
	outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
	outstim.stimulus = setdisplayprefs(outstim.stimulus,displayprefs(dP));
   end;
end;

outstim.stimulus = loadstim(outstim.stimulus);
