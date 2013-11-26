function [startStopTimes,frameTimes] = DisplayStimulus(MTI)

% DISPLAYSTIMULUS
%
%   [startStopTimes,frameTimes] = DISPLAYSTIMULUS(MTI)
%
%  Displays a stimulus using data in the Measured Timing Index variable MTI.  Returns
%  timestamp entries startStopTimes and frameTimes.

StimWindowGlobals;
NewStimGlobals;

 % fill variables for speed, if it matters
startStopTimes = MTI.startStopTimes;
frameTimes = MTI.frameTimes;

if NS_PTBv<3,
	screen(StimWindow,'FillRect',0);
else,
	screen('LoadNormalizedGammaTable', StimWindow, MTI.ds.clut_bg); % set background colors 
	screen('Flip',StimWindow,0,0,2); % clear first buffer immediately
	screen('Flip',StimWindow,0,0,2); % clear 2nd buffer on next refresh
	WaitSecs(0.02);
end;

DisplayStimulus_created_masktexture = 0;

if MTI.ds.makeClip, % make a clipping region
	if NS_PTBv<3,  %use clipping region, can call routine directly
		screen(StimWindow,'SetDrawingRegion',MTI.ds.clipRect,MTI.ds.makeClip-1);
	else, % make a clipping region or use the one provided
	        if MTI.ds.makeClip>0&MTI.ds.makeClip<4,
			masktexture = ClipRgn2Texture(StimWindow,MTI.ds.makeClip,MTI.ds.clipRect,0.5*MTI.ds.clut{1}(1,:));
			DisplayStimulus_created_masktexture = 1;
	        elseif MTI.ds.makeClip==4, 
			masktexture = MTI.ds.clipRect;
	        end;
	end;
end;

if strcmp(MTI.ds.displayType,'Sound'), Snd('Open'); end;

if MTI.preBGframes>0,
	if NS_PTBv<3,
		screen(StimWindow,'SetClut',MTI.ds.clut_bg); % also does waitblanking
		startStopTimes(1) = StimTriggerAct('Stim_BGpre_trigger',MTI.stimid);
		screen(StimWindow,'WaitBlanking',MTI.preBGframes);
	else,
       	screen('LoadNormalizedGammaTable', StimWindow, MTI.ds.clut_bg,1);
		vbl = screen('Flip', StimWindow, 0, 0);
		startStopTimes(1) = StimTriggerAct('Stim_BGpre_trigger',MTI.stimid);
		screen(StimWindow,'FillRect',0); % make sure background is in 2nd buffer
		screen('Flip', StimWindow, vbl + (MTI.preBGframes-0.5)/StimWindowRefresh);
	end;
else,
	startStopTimes(1) = StimTriggerAct('Stim_BGpre_trigger',MTI.stimid);
end;

if strcmp(MTI.ds.displayType,'CLUTanim'),
    s0 = GetSecs();
	startStopTimes(2) = StimTriggerAct('Stim_ONSET_trigger',MTI.stimid);
	rect = screen(MTI.ds.offscreen(1),'Rect');
	if NS_PTBv<3,
		screen('CopyWindow',MTI.ds.offscreen(1),StimWindow,rect,MTI.df.rect,'srcCopy');
		screen(StimWindow, 'SetClut', MTI.ds.clut{MTI.df.frames(1)}); % does waitblanking
		frameTimes(1) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,1);
		for frameNum=2:length(MTI.df.frames),
			screen(StimWindow,'WaitBlanking',MTI.pauseRefresh(frameNum-1));
			StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,frameNum);
			screen(StimWindow,'SetClut',MTI.ds.clut{MTI.df.frames(frameNum)});
			frameTimes(frameNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,frameNum);
		end;
		screen(StimWindow,'WaitBlanking',MTI.pauseRefresh(end));
	else,
		screen('DrawTexture',StimWindow,MTI.ds.offscreen(1),rect,MTI.df.rect);
        if MTI.ds.makeClip&0,
            if DisplayStimulus_created_masktexture,
           		screen('DrawTexture',StimWindow,masktexture);
            else,
                screen('DrawTexture',StimWindow,masktexture,[],MTI.df.rect);
            end;
        end;
        screen('LoadNormalizedGammaTable',StimWindow, MTI.ds.clut{MTI.df.frames(1)},1);
		vbl=screen('Flip',StimWindow,0,2); % waits for waitblanking, does not clear buffer
		frameTimes(1) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,1);
		screen(StimWindow,'FillRect',0); % paint background color in the 2nd buffer
		screen('DrawTexture',StimWindow,MTI.ds.offscreen(1),rect,MTI.df.rect); % draw in the 2nd buffer
        if MTI.ds.makeClip&0,
            if DisplayStimulus_created_masktexture,
           		screen('DrawTexture',StimWindow,masktexture);
            else,
                screen('DrawTexture',StimWindow,masktexture,[],MTI.df.rect);
            end;
        end;
		StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,1);
		for frameNum=2:length(MTI.df.frames),
			% this should really be measured from each interval for most
            % accurate "local" display
			screen('LoadNormalizedGammaTable',StimWindow, MTI.ds.clut{MTI.df.frames(frameNum)},1);			
			vbl=screen('Flip',StimWindow,vbl+(MTI.pauseRefresh(frameNum-1)+0.5)/StimWindowRefresh,2);            
			%screen('Flip',StimWindow,vbl+(sum(1+MTI.pauseRefresh(1:frameNum-1))-0.5)/StimWindowRefresh,2);
			frameTimes(frameNum)=StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,frameNum);
			StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,frameNum);
		end;
		screen('Flip',StimWindow,(MTI.pauseRefresh(frameNum)+0.5)/StimWindowRefresh); % the +0.5 is here because these pause times for CLUTanims can range from -1 due to backward compatibility
    end;

elseif strcmp(MTI.ds.displayType,'Movie'),
    rect_sequence = ones(size(MTI.df.frames));
    if isfield(MTI.ds.userfield,'rect'),
        rect = MTI.ds.userfield.rect;
        if isfield(MTI.ds.userfield,'rectsequence'),
            rect_sequence = MTI.ds.userfield.rectsequence;
        end;
    else,
        rect = screen(MTI.ds.offscreen(1),'Rect');
    end;
	startStopTimes(2) = StimTriggerAct('Stim_ONSET_trigger',MTI.stimid);
    if NS_PTBv<3,
		screen(StimWindow,'SetClut',MTI.ds.clut); % does waitblanking
		screen('CopyWindow',MTI.ds.offscreen(MTI.df.frames(1)),StimWindow,rect(rect_sequence(1),:), MTI.df.rect,'srcCopyQuickly');
		frameTimes(1) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,1);
		for frameNum=2:length(MTI.df.frames);
			screen(StimWindow,'WaitBlanking',MTI.pauseRefresh(frameNum-1));
			StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,frameNum);
            rectnum = 1+mod(MTI.df.frames(frameNum),length(MTI.ds.offscreen));
			screen('CopyWindow',MTI.ds.offscreen(MTI.df.frames(frameNum)),StimWindow,rect(rect_sequence(frameNum),:), MTI.df.rect,'srcCopyQuickly');
			frameTimes(frameNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,frameNum);
		end;
		screen(StimWindow,'WaitBlanking',MTI.pauseRefresh(end));
	else,
		screen('LoadNormalizedGammaTable',StimWindow,MTI.ds.clut);
		screen('DrawTexture',StimWindow,MTI.ds.offscreen(MTI.df.frames(1)),rect(rect_sequence(1),:),MTI.df.rect,[],0);
        if MTI.ds.makeClip,
            if DisplayStimulus_created_masktexture,
           		screen('DrawTexture',StimWindow,masktexture);
            else,
                screen('DrawTexture',StimWindow,masktexture,[],MTI.df.rect);
            end;
        end;
		vbl = screen('Flip',StimWindow,0);
		frameTimes(1) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,1);
		screen(StimWindow,'FillRect',0); % fill the other buffer with background
		StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,1);
		for frameNum=2:length(MTI.df.frames);
			screen('DrawTexture',StimWindow,MTI.ds.offscreen(MTI.df.frames(frameNum)),rect(rect_sequence(frameNum),:),MTI.df.rect,[],0);
            if MTI.ds.makeClip,
                if DisplayStimulus_created_masktexture,
                    screen('DrawTexture',StimWindow,masktexture);
                else,
                    screen('DrawTexture',StimWindow,masktexture,[],MTI.df.rect);
                end;
            end;
			vbl=screen('Flip',StimWindow,vbl+(MTI.pauseRefresh(frameNum-1)-0.5)/StimWindowRefresh);
			frameTimes(frameNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,frameNum);
			WaitSecs(1/10000);
			StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,frameNum);
		end;
		if frameNum==1,
            screen('DrawTexture',StimWindow,MTI.ds.offscreen(MTI.df.frames(1)),rect(rect_sequence(frameNum),:),MTI.df.rect,[],0);
            if MTI.ds.makeClip,
                if DisplayStimulus_created_masktexture,
                    screen('DrawTexture',StimWindow,masktexture);
                else,
                    screen('DrawTexture',StimWindow,masktexture,[],MTI.df.rect);
                end;
            end;
        end;
		screen('Flip',StimWindow,vbl+(MTI.pauseRefresh(end)-0.5)/StimWindowRefresh);
	end;
elseif strcmp(MTI.ds.displayType,'custom'),
	done=0; stamp=0; info=[]; stampNum=1;
	startStopTimes(2) = StimTriggerAct('Stim_ONSET_trigger',MTI.stimid);
	while(done==0),
		eval(['[done,stamp,info]=' MTI.ds.displayProc '(info,StimWindow,MTI.ds,MTI.df);']);
		if stamp==1, % make a time stamp
			frameTimes(stampNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,stampNum);
			stampNum = stampNum + 1;
			StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,stampNum);
		end;
	end;
elseif strcmpi(MTI.ds.displayType,'QUICKTIME'),   % note, quicktime play only supported in PTB-3
    Screen('LoadNormalizedGammaTable',StimWindow,StimWindowPreviousCLUT);
    Screen('SetMovieTimeIndex', MTI.ds.userfield.movie, 0); % play from beginning, regardless of where we played last time
	done = 0; frameNum = 0;
	startStopTimes(2) = StimTriggerAct('Stim_ONSET_trigger',MTI.stimid);
	Screen('PlayMovie',MTI.ds.userfield.movie,1);
	while ~done,
		if frameNum>0, StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,frameNum); end;
		tex = Screen('GetMovieImage',StimWindow,MTI.ds.userfield.movie);
		if tex<=0, done = 1; break; % detect hitting the end of the movie
		else,
			frameNum = frameNum + 1;
			Screen('DrawTexture',StimWindow,tex,[],MTI.df.rect);
			Screen('Flip',StimWindow);
			frameTimes(frameNum) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,frameNum);
			Screen('Close',tex);
		end;
	end;
	Screen('PlayMovie',MTI.ds.userfield.movie,0); % stop the movie from playing

elseif strcmp(MTI.ds.displayType,'Sound'),
	startStopTimes(2) = StimTriggerAct('Stim_ONSET_trigger',MTI.stimid);
	Snd('Play',MTI.ds.userfield.sound,MTI.ds.userfield.rate);
	StimTriggerAct('Stim_beforeframe_trigger',MTI.stimid,1);
	Snd('Wait');
	frameTimes(1) = StimTriggerAct('Stim_afterframe_trigger',MTI.stimid,1);
end;

if MTI.postBGframes>0,
	if NS_PTBv<3,
		screen(StimWindow,'SetClut',MTI.ds.clut_bg);
		startStopTimes(3) = StimTriggerAct('Stim_OFFSET_trigger',MTI.stimid);
		screen(StimWindow,'WaitBlanking',MTI.postBGframes);
	else,
		screen(StimWindow,'FillRect',0); % make sure background is in 2nd buffer
        vbl = screen('Flip', StimWindow, 0); % wait for blanking
		screen(StimWindow,'FillRect',0); % make sure background is in 2nd buffer
        WaitSecs(0.2);
        screen('LoadNormalizedGammaTable', StimWindow, MTI.ds.clut_bg,1);
        startStopTimes(3) = StimTriggerAct('Stim_OFFSET_trigger',MTI.stimid);
        screen('Flip', StimWindow, vbl + (MTI.postBGframes+0.5)/StimWindowRefresh);
        WaitSecs(0.2);
	end;
else,
	startStopTimes(3) = StimTriggerAct('Stim_OFFSET_trigger',MTI.stimid);
end;

screen('LoadNormalizedGammaTable', StimWindow, MTI.ds.clut_bg,1);
screen('Flip',StimWindow,0,0,1);screen('Flip',StimWindow,0,0,1);


startStopTimes(4) = StimTriggerAct('Stim_BGpost_trigger',MTI.stimid);

if strcmp(MTI.ds.displayType,'Sound'), Snd('Close'); end;


if MTI.ds.makeClip&NS_PTBv<3, % clear the clipping region
	screen(StimWindow,'SetDrawingRegion',StimWindowRect);
end;

if DisplayStimulus_created_masktexture, Screen('Close',masktexture); end;
