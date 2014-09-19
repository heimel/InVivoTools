function [done,stamp,infoO]=dotsstim(info,StimScreen,dispstruct,dispprefs);
%  DOTSSTIM - Custom display procedure for moving dots stimulus
%         (Not a function that should be called directly by the user)
%    [DONE,STAMP,NEWINFO]=DOTSSTIM(INFO,STIMSCREEN,DISPSTRUCT,DISPPREFS)
%
%  What you get:
%
%     Background is drawn, the appropriate number of background frames are
%     shown, the stimulus color table is not installed.
%
%  output:
%
%    done -       0/1 is the stimulus done
%    stamp -      0/1 should we record the time?
%    info -       whatever, it is passed again
%   userfield -   Will be added to displaystruct when done==1
%
%  input - 
%      if info not a structure, then it is just loading in memory
%      if info = [], then it is the first frame
%      else, just show the next frame

  done = 0;

  global movingdotsstimrecord
  
  if ~isstruct(info)&~isempty(info), % warm up call
        dispstruct.userfield; % make sure we're in memory
		stamp = 0;
		% look for movingdotstimrecord, install it if doesn't exist
		foundRec = 0;
		mdstruct = struct('parameters',dispstruct.userfield.parameters,...
			'patternnumber',1,'numpatterns',dispstruct.userfield.numpatterns);
		if ~isempty(movingdotsstimrecord),
		   for i=1:length(movingdotsstimrecord),
			  if movingdotsstimrecord(i).parameters==dispstruct.userfield.parameters,
				  foundRec = i; break;
			  end;
	       end;
	    else,
		   movingdotsstimrecord = mdstruct; foundRec = 1;
	    end;
	    if foundRec==0, movingdotsstimrecord(end+1)=mdstruct;
	    else, movingdotsstimrecord(foundRec).patternnumber=1;
		end;
  elseif isempty(info), % first frame
	foundRec = 0;
	if ~isempty(movingdotsstimrecord),
		for i=1:length(movingdotsstimrecord),
			if movingdotsstimrecord(i).parameters==dispstruct.userfield.parameters,
				foundRec = i; break;
			end;
	    end;
	end;
	if foundRec~=0, pattern = movingdotsstimrecord(foundRec).patternnumber;
    else, pattern = 1; end;
	screen(StimScreen,'SetClut',dispstruct.clut);
	frameLength = dispstruct.userfield.frameLength;
	if (frameLength<1), frameLength = 1; end;
	info=struct('frame',0,'frameLength',frameLength,'patternnum',pattern);
	done=0; stamp=0;
  else, % info has our info
	if info.frame==0,
		stamp = 1;
		screen(StimScreen,'WaitBlanking',dispstruct.userfield.frameLength);
		dots(StimScreen,'CopyDots',dispstruct.userfield.firstdots(:,:,info.patternnum),[0 0],0);
		info.frame = info.frame+1;
	elseif info.frame<dispstruct.userfield.numFrames,
		stamp = 1;
		screen(StimScreen,'WaitBlanking',dispstruct.userfield.frameLength);
		dots(StimScreen,'CopyDots',...
			dispstruct.userfield.middledots(:,:,info.frame,info.patternnum),[0 0],0);
		info.frame = info.frame + 1;
	else, % we've run all our frames
		done = 1; stamp=0;
	    screen(StimScreen,'SetClut',dispstruct.clut_bg); % set to bg so dots disappear
		foundRec = 0;
	    if ~isempty(movingdotsstimrecord),
		   for i=1:length(movingdotsstimrecord),
			  if movingdotsstimrecord(i).parameters==dispstruct.userfield.parameters,
				foundRec = i; break;
			  end;
	       end;
	    end;
	    if foundRec~=0,
			movingdotsstimrecord(foundRec).patternnumber = movingdotsstimrecord(foundRec).patternnumber+1;
			if movingdotsstimrecord(foundRec).patternnumber>movingdotsstimrecord(foundRec).numpatterns,
				movingdotsstimrecord(foundRec).patternnumber=1;
			end;
		end;
	end;
  end;

infoO = info;
