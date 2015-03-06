function [done,stamp,infoO] = customdraw(sgs, info, MTI)

% CUSTOMDRAW - Custom draw routine for stochasticgridstim
%
%  [DONE,STAMP,INFO] = CUSTOMDRAW(SGS, INFO, STIMWINDOW,...
%                    MTI)
%
%  This custom draw routine is used for display stochasticgrid stimuli.
%
%  

StimWindowGlobals;
NewStimGlobals;

usenewtexturemethod = 0;

done = 0;
stamp = 1; % always stamp unless we're on the last frame, see below

if isempty(info),
	SGSparams = getparameters(sgs);
	[X,Y] = getgrid(sgs);
	V = getgridvalues(sgs);
	colorvalues = SGSparams.values;
	if isfield(SGSparams,'angle'),
		rotationangle = SGSparams.angle;
	else,
		rotationangle = 0;
	end;
	gridrects = [];
	for i=1:X, % could do this without for loops, save for later
		for j=1:Y,
			gridrects(:,end+1) = [0*1+(i-1)*SGSparams.pixSize(1) 0*1+(j-1)*SGSparams.pixSize(2) i*SGSparams.pixSize(1) j*SGSparams.pixSize(2) ]';
		end;
	end;
	infoO = struct('frameNum',1,'vbl',0,'rotationangle',rotationangle,'gridvalues',V,'colorvalues',colorvalues,'X',X,'Y',Y, 'gridrects',gridrects);
	Screen('LoadNormalizedGammaTable',StimWindow,StimWindowPreviousCLUT);
	Screen('FillRect',StimWindow,round(255*MTI.ds.clut(1,:,:)));
else,
	infoO = info;
end;

frameNum = infoO.frameNum;

if frameNum==1&0, % first frame, display the one we loaded earlier
	textures = find(MTI.MovieParams.Movie_textures{frameNum});
	Screen('DrawTextures',StimWindow,MTI.ds.offscreen(textures),...
		squeeze(MTI.MovieParams.Movie_sourcerects(:,frameNum,textures)),...
		squeeze(MTI.MovieParams.Movie_destrects(:,frameNum,textures)),...
		infoO.rotationangle,...
		0,...
		squeeze(MTI.MovieParams.Movie_globalalphas(:,frameNum,textures)));
	if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
	infoO.vbl = Screen('Flip',StimWindow,0);
elseif frameNum<=length(MTI.df.frames),
	% Image Loading Routines
	if usenewtexturemethod,
		image = reshape(infoO.colorvalues(infoO.gridvalues(:,frameNum),[1 2 3]),infoO.X,infoO.Y,3);
	    	offscreen = Screen('MakeTexture',StimWindow,image);
	else,
		offscreen = MTI.ds.offscreen(1);
		Screen('FillRect',offscreen, infoO.colorvalues(infoO.gridvalues(:,frameNum),:)', infoO.gridrects);
	end;
	textures = find(MTI.MovieParams.Movie_textures{1});
	Screen('DrawTextures',StimWindow,offscreen,[],... % use default source rect size
		squeeze(MTI.MovieParams.Movie_destrects(:,frameNum,textures)),...
		infoO.rotationangle,0,squeeze(MTI.MovieParams.Movie_globalalphas(:,frameNum,textures)));
	if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
	if infoO.vbl==0,
		infoO.vbl=Screen('Flip',StimWindow,0);
	else,
		infoO.vbl=Screen('Flip',StimWindow, infoO.vbl+(MTI.pauseRefresh(frameNum)-0.5)/StimWindowRefresh);
	end;
	if usenewtexturemethod, Screen('close',offscreen); end;
end;

if frameNum>length(MTI.df.frames),
	if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
	Screen('Flip',StimWindow,infoO.vbl+(MTI.pauseRefresh(end)-0.5)/StimWindowRefresh);
	stamp = 0; % not a new data frame, just waiting for the old one to play out
	done = 1;
end;

infoO.frameNum = infoO.frameNum + 1;
