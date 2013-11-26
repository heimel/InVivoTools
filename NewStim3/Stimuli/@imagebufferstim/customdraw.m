function [done,stamp,infoO] = customdraw(stim,info,MTI)

% CUSTOMDRAW - Custom draw routine for imagebufferstim
%
%  [DONE,STAMP,INFO] = CUSTOMDRAW(THEPERIODICSTIM, INFO, STIMWINDOW,...
%                    MTI)
%
%  This custom draw routine is used for display "plaid" sums of gratings.
%
%  

StimWindowGlobals;

done = 0;
stamp = 1; % always stamp unless we're on the last frame, see below

dS = struct(getdisplaystruct(stim));

if isempty(info),
	infoO = struct('frameNum',1,'vbl',0,'first',1, 'remainingframes', ...
            dS.userfield.remainingframes, 'randlog', dS.userfield.randlog, ...
            'texid', dS.userfield.texid, 'blank', 0);
else,
	infoO = info;
    infoO.first = 0;
end;

randframes = dS.userfield.randframes;
randfileind = dS.userfield.randfileind;
randimgind = dS.userfield.randimgind;
filedir = dS.userfield.filedir;
filenames = dS.userfield.filenames;
blankpause = dS.userfield.blankpause;

frameNum = infoO.frameNum;

if infoO.first % first frame
	screen('LoadNormalizedGammaTable',StimWindow,StimWindowPreviousCLUT);
	screen('FillRect',StimWindow,round(255*MTI.ds.clut(1,:,:)));
	textures = find(MTI.MovieParams.Movie_textures{1});
	screen('DrawTextures',StimWindow,MTI.ds.offscreen(textures),squeeze(MTI.MovieParams.Movie_sourcerects(:,frameNum,textures)),squeeze(MTI.MovieParams.Movie_destrects(:,frameNum,textures)),...
		squeeze(MTI.MovieParams.Movie_angles(:,frameNum,textures)),1,squeeze(MTI.MovieParams.Movie_globalalphas(:,frameNum,textures)));
	if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
	infoO.vbl = screen('Flip',StimWindow,0);
    infoO.blank = 1;
    infoO.frameNum = infoO.frameNum + 1;
elseif infoO.blank
    % Blank Screen
    screen('Flip', StimWindow, infoO.vbl+(MTI.pauseRefresh(1)/StimWindowRefresh));
    screen('FillRect',StimWindow,round(255*MTI.ds.clut_bg(1,:,:)));
    infoO.blank = 0;
else
    % Load Next Image
    if ismac A = imread([filedir '/' filenames(randfileind(frameNum),:)], randimgind(frameNum));
    else A = imread([filedir '\' filenames(randfileind(frameNum),:)], randimgind(frameNum)); end;
    Screen('Close', infoO.texid);
    infoO.imgtex = Screen('MakeTexture', StimWindow, A);
    infoO.randlog(frameNum) = randframes(frameNum);
    MTI.ds.offscreen = infoO.imgtex;
    infoO.remainingframes = infoO.remainingframes - 1;
    % Display Image
	textures = find(MTI.MovieParams.Movie_textures{1});
	screen('DrawTextures',StimWindow,MTI.ds.offscreen(textures),squeeze(MTI.MovieParams.Movie_sourcerects(:,1,textures)),squeeze(MTI.MovieParams.Movie_destrects(:,1,textures)),...
		squeeze(MTI.MovieParams.Movie_angles(:,1,textures)),1,squeeze(MTI.MovieParams.Movie_globalalphas(:,1,textures)));
	if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
    infoO.vbl=screen('Flip',StimWindow,infoO.vbl+(MTI.pauseRefresh(1)/StimWindowRefresh)+blankpause/1000);
    infoO.blank = 1;
    infoO.frameNum = infoO.frameNum + 1;
end;

if infoO.remainingframes <= 0
    % Blank Screen
    screen('Flip', StimWindow, infoO.vbl+(MTI.pauseRefresh(1)/StimWindowRefresh));
    screen('FillRect',StimWindow,round(255*MTI.ds.clut_bg(1,:,:)));
	if StimWindowUseCLUTMapping, Screen('LoadNormalizedGammaTable',StimWindow,linspace(0,1,256)' * ones(1,3),1); end;
	screen('Flip',StimWindow,infoO.vbl+(MTI.pauseRefresh(1)/StimWindowRefresh)+blankpause/1000);
	stamp = 0; % not a new data frame, just waiting for the old one to play out
	done = 1;
    infoO.randlog
end;