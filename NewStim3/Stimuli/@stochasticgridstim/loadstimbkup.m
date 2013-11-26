function [outstim] = loadstim(SGSstim)

NewStimGlobals;
StimWindowGlobals;

% no error handling yet

SGSstim = unloadstim(SGSstim);  % unload old version before loading
 
SGSparams = SGSstim.SGSparams;

if isfield(SGSparams,'angle'),
	rotationangle = SGSparams.angle;
else,
	rotationangle = 0;
end;

width  = SGSparams.rect(3) - SGSparams.rect(1);
height = SGSparams.rect(4) - SGSparams.rect(2);

% set up grid
if (SGSparams.pixSize(1)>=1),
	X = SGSparams.pixSize(1);
	else, X = (width*SGSparams.pixSize(1)); 
end;

if (SGSparams.pixSize(2)>=1),
	Y = SGSparams.pixSize(2);
else, Y = (height*SGSparams.pixSize(2)); 
end;

i = 1:width;
x = fix((i-1)/X)+1;
i = 1:height;
y = fix((i-1)/Y)+1;
XY = x(end)*y(end);

grid = ([(x-1)*y(end)]'*ones(1,length(y))+ones(1,length(x))'*y)';
g = reshape(1:width*height,height,width);
corner = zeros(Y,X); corner(1) = 1;
cc=reshape(repmat(corner,height/Y,width/X).*g,width*height,1);
corners = cc(find(cc))';
footprint = reshape(g(1:Y,1:X),X*Y,1)-1;
inds=ones(1,X*Y)'*corners+footprint*ones(1,XY);



z = 1:XY;
  
clut_bg = repmat(SGSparams.BG,256,1);  
depth = 8;
l = length(SGSparams.dist);
clut_usage = [ 1 ones(1,l) zeros(1,255-l) ]';

probs = cumsum(SGSparams.dist(1:end))'; probs = probs ./ probs(end);
phs = ones(XY,1) * probs;
pls = [ zeros(XY,1) phs(:,1:end-1)];
l = length(SGSparams.dist);  

rand('state',SGSparams.randState);
  
dP = getdisplayprefs(SGSstim.stimulus);
dPs = struct(dP);
if ((XY<253)&(~dPs.forceMovie)), % use one image and array of CLUTs, one frame per column
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
	else,
		if rotationangle~=0,
			grid = imrotate(grid,rotationangle,'nearest','crop');
		end;
		offscreen = screen('MakeTexture',StimWindow,grid);
	end;
else, % use one CLUT and many images
	displayType = 'Movie';
	displayProc = 'standard';
	clut = ([ SGSparams.BG; SGSparams.values(1:l,:); repmat(SGSparams.BG,255-l,1);]);
	offscreen = zeros(1,SGSparams.N);
	Je = ones(1,size(inds,1));
	I = 1:XY;
	for i=1:SGSparams.N,
		f = rand(XY,1) * ones(1,length(SGSparams.dist));
		[I,J] = find(f>pls & f<=phs);
		[y,is] = sort(I);
		image = repmat(uint8(1),size(grid));
		image(inds(:,I)) = (J(is) * Je)';
		if NS_PTBv < 3,
			if rotationangle~=0,
				warning(['Rotating images not supported under OS 9 ' ...
					 'due to programmer laziness']);
			end;
			offscreen(i) = screen(-1,'OpenOffscreenWindow',255,[0 0 width height]);
			screen(offscreen(i),'PutImage',image,[0 0 width height]);
		else,
			if rotationangle~=0,
				image = imrotate(image, rotationangle,'nearest','crop');
			end;
			offscreen(i) = screen('MakeTexture',StimWindow,image);
		end;
	 end;
end;
 
dS = {'displayType', displayType, 'displayProc', displayProc, ...
              'offscreen', offscreen, 'frames', SGSparams.N, 'depth', 8, ...
			  'clut_usage', clut_usage, 'clut_bg', clut_bg, 'clut', clut};
  
outstim = SGSstim;
outstim.stimulus = setdisplaystruct(outstim.stimulus,displaystruct(dS));
outstim.stimulus = loadstim(outstim.stimulus);
 
