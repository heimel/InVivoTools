function [done,stamp,infoO] = customdraw(rcgs, info, MTI)

% CUSTOMDRAW - Custom draw routine for rcgstim
%
%  [DONE,STAMP,INFO] = CUSTOMDRAW(SGS, INFO, STIMWINDOW,...
%                    MTI)
%
%  This custom draw routine is used for display of rcgratingstim
%
%  

StimWindowGlobals;
NewStimGlobals;

done = 0;
stamp = 1; % always stamp unless we're on the last frame, see below

if isempty(info),
	infoO = struct('frameNum',1,'vbl',0);
	screen('LoadNormalizedGammaTable',StimWindow,StimWindowPreviousCLUT);
	screen('FillRect',StimWindow,round(255*MTI.ds.clut(1,:,:)));
else,
	infoO = info;
end;

frameNum = infoO.frameNum;

if frameNum<=length(MTI.ds.userfield.frames),
	n = MTI.ds.userfield.frames(frameNum);
	screen('DrawTextures',...
		StimWindow,...
		[MTI.ds.offscreen(MTI.ds.userfield.Movie_textures{n}) MTI.ds.userfield.clip_tex ],...
		[squeeze(MTI.ds.userfield.Movie_sourcerects(:,n,1))  MTI.ds.userfield.clip_source'],... 
		[squeeze(MTI.ds.userfield.Movie_destrects(:,n,1))  MTI.ds.userfield.clip_dest'],...
		[MTI.ds.userfield.Movie_angles(n) MTI.ds.userfield.clip_angle(1) ], ...
		0, ...
		[MTI.ds.userfield.Movie_globalalphas(:,n) MTI.ds.userfield.clip_globalalpha(1) ]   );
	if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
	if infoO.vbl==0,
		infoO.vbl=screen('Flip',StimWindow,0);
	else,
		infoO.vbl=screen('Flip',StimWindow, infoO.vbl+(MTI.ds.userfield.pauseRefresh(frameNum-1)-0.5)/StimWindowRefresh);
	end;
end;

if frameNum>length(MTI.ds.userfield.frames),
	if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
	screen('Flip',StimWindow,infoO.vbl+(MTI.ds.userfield.pauseRefresh(end)-0.5)/StimWindowRefresh);
	stamp = 0; % not a new data frame, just waiting for the old one to play out
	done = 1;
end;

infoO.frameNum = infoO.frameNum + 1;
