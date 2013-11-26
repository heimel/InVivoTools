function [outstim] = loadstim(SGSstim)

NewStimGlobals;
StimWindowGlobals;

use_customdraw = 1;
conserve_mem_custom = 1;

% no error handling yet

SGSstim = unloadstim(SGSstim);  % unload old version before loading
 
SGSparams = SGSstim.SGSparams;

if isfield(SGSparams,'angle'),
	rotationangle = SGSparams.angle;
else
	rotationangle = 0;
end;

[Xo,Yo,rect,width,height,inds,grid] = getgrid(SGSstim);
XY = Xo * Yo;
z = 1:XY;

clut_bg = repmat(SGSparams.BG,256,1);  
l = length(SGSparams.dist);
clut_usage = [ 1 ones(1,l) zeros(1,255-l) ]';

probs = cumsum(SGSparams.dist(1:end))'; probs = probs ./ probs(end);
phs = ones(XY,1) * probs;
pls = [ zeros(XY,1) phs(:,1:end-1)];
l = length(SGSparams.dist);  

rand('state',SGSparams.randState); %#ok<RAND>
  
dP = getdisplayprefs(SGSstim.stimulus);
dPs = struct(dP);
if ((XY<253)&(~dPs.forceMovie))&~use_customdraw, % use one image and array of CLUTs, one frame per column
	displayType = 'CLUTanim';
	displayProc = 'standard';
	clut = cell(SGSparams.N,1);
	for i=1:SGSparams.N,
		f = rand(XY,1) * ones(1,length(SGSparams.dist));
		[I,J] = find(f>pls & f<=phs);
		[y,is] = sort(I);
		clut{i} = ([ SGSparams.BG ; SGSparams.values(J(is),:); repmat(SGSparams.BG,255-XY,1);]);
	end;
	if NS_PTBv < 3,
		if rotationangle~=0,
			warning(['Rotating images not supported under OS 9 ' ...
				 'due to programmer laziness']);
		end;
		offscreen = screen(-1,'OpenOffscreenWindow',255,[0 0 width height]);
		screen(offscreen,'PutImage',grid,[0 0 width height]);
    else  % this is out of date, better to use movie feature
		if rotationangle~=0,
			grid = imrotate(grid,rotationangle,'nearest','crop');
		end;
		offscreen = screen('MakeTexture',StimWindow,grid);
	end;
else % use 'Movie' mode, one CLUT and many images
	displayType = 'Movie';
	displayProc = 'standard';
	clut = ([ SGSparams.BG; SGSparams.values(1:l,:); repmat(SGSparams.BG,255-l,1);]);
    if ~conserve_mem_custom
        offscreen = zeros(1,SGSparams.N);
    end
	Je = ones(1,size(inds,1));
	I = 1:XY;
	for i=1:SGSparams.N,
		if i==1|~conserve_mem_custom,
			f = rand(XY,1) * ones(1,length(SGSparams.dist));
			[I,J] = find(f>pls & f<=phs);
			[y,is] = sort(I);
			image = repmat(uint8(1),size(grid));
			image(inds(:,I)) = (J(is) * Je)';
		end;
		if NS_PTBv < 3,
			if rotationangle~=0,
				warning(['Rotating images not supported under OS 9 ' ...
					 'due to programmer laziness']);
			end;
			offscreen(i) = screen(-1,'OpenOffscreenWindow',255,[0 0 width height]);
			screen(offscreen(i),'PutImage',image,[0 0 width height]);
        else
			if rotationangle~=0&~use_customdraw,
				image = imrotate(image, rotationangle,'nearest','crop');
			end;
			if ~conserve_mem_custom|i==1,
				rgb = ind2rgb(image,clut);
				offscreen(i) = screen('MakeTexture',StimWindow,rgb);
			end;
		end;
	 end;
	if use_customdraw, displayProc = 'customdraw'; end;
end
 
dS = {'displayType', displayType, 'displayProc', displayProc, ...
              'offscreen', offscreen, 'frames', SGSparams.N, 'depth', 8, ...
			  'clut_usage', clut_usage, 'clut_bg', clut_bg, 'clut', clut};
  
outstim = SGSstim;
outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
outstim.stimulus = loadstim(outstim.stimulus);
 
