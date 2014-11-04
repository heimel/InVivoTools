function [outstim] = loadstim(ISstim)

ISstim = unloadstim(ISstim);
outstim = ISstim;

if haspsychtbox,

   StimWindowGlobals;

   ISparams = ISstim.ISparams;

   x1 = ISparams.rect(1);
   x2 = ISparams.rect(3);
   y1 = ISparams.rect(2);
   y2 = ISparams.rect(4);

   dfs = struct(getdisplayprefs(ISstim));
   tRes = (1/StimWindowRefresh);
   fps = StimWindowRefresh;
   [im,map] = imread(ISparams.filename);
   sz = size(im);
   offscreen = Screen(-1,'OpenOffscreenWindow',255,[0 0 x2-x1 y2-y1]);
   
   %Added by jbednar@inf.ed.ac.uk: expand grayscale images to RGB
   [t d]=size(sz);
   if d==2, 
	  	im=cat(3,im,im,im);
   end;
   
   [im,map] = rgb2ind(im,255);
   map(256,:) = ISparams.BG;
   if ~isempty(ISparams.maskfile),
   	[mask] = imread(ISparams.maskfile);
   	maskind = find(mask ~= 0);
   	im(maskind) = 255;
   end;

   frames = 1;

   plotrect = [(x1 + x2 - sz(2))/2 (y1 + y2 - sz(1))/2 (x1 + x2 + sz(2))/2 (y1 + y2 + sz(1))/2];
   Screen(offscreen,'PutImage',im,plotrect);
   rect = [ISparams.rect];
   dP = cat(2,{'fps',fps,'rect',dfs.rect,'frames',frames},ISparams.dispprefs);
   dS = { 'displayType', 'CLUTanim', 'displayProc', 'standard', ...
         'offscreen', offscreen, 'frames', frames, ...
		 'clut_usage', repmat(1,256), 'depth', 8, ...
		 'clut_bg', repmat(ISparams.BG,256,1), 'clut', map, 'clipRect', [], ...
		 'makeClip', 0,'userfield',[] }; 
		 
  outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
  outstim.stimulus = setdisplayprefs(outstim.stimulus,displayprefs(dP));
end;

outstim.stimulus = loadstim(outstim.stimulus);
