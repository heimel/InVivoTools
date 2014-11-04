function [done,stamp,infoO]=blinkstim(info,StimScreen,dispstruct,dispprefs);
%
%  What you get:
%
%     Background is drawn, the appropriate number of background frames are
%     shown, the color table is not installed.
%
%  output:
%
%    done -       0/1 is the stimulus done
%    stamp -      0/1 should we record the time?
%    info -       whatever, it is passed again
%
%  input - 
%      if info not a structure, then it is just loading in memory
%      if info = [], then it is the first frame
%      else, just show the next frame

NewStimGlobals;
StimWindowGlobals;

  done = 0; stamp = 0; 

  if ~isstruct(info)&~isempty(info),
        dispstruct.userfield; % make sure we're in memory
  elseif isempty(info),
	if NS_PTBv<3, Screen(StimScreen,'SetClut',dispstruct.clut);
	else, Screen('LoadNormalizedGammaTable',StimScreen,dispstruct.clut);
	end;
	Screen(StimScreen,'FillRect',0);
	rectshift = [dispprefs.rect(1) dispprefs.rect(2) ...
				dispprefs.rect(1) dispprefs.rect(2)];
	frameLength = dispstruct.userfield.frameLength - 1;
	if (frameLength<1), frameLength = 1; end;
	info=struct('frame',0,'bgcount',0,'rectshift',rectshift, ...
		'frameLength',frameLength,'lastvbl',Screen('Flip',StimScreen));
	done=0; stamp=0;
  else, % info has our info
	% clean up the mess from the last frame
	% if PTB2, wait until waitblanking, do our drawing
	% if PTB3, do our drawing, flip the page at waitblanking
	if info.frame>0&info.frame~=dispstruct.userfield.N,
		if NS_PTBv<3, % not necessary in PTB3
			Screen(StimScreen,'WaitBlanking',dispstruct.userfield.frameLength);
			Screen('CopyWindow',dispstruct.offscreen(2),StimScreen, ...
       		            dispstruct.userfield.rects(1,:), ...
       		            info.rectshift+dispstruct.userfield.rects( ...
       		                     dispstruct.userfield.blinkList(info.frame),:), ...
							'srcCopyQuickly');
		end;
	end;
	if info.frame>dispstruct.userfield.N,
		done = 1; stamp=0;
	else,
	   if info.bgcount==0|NS_PTBv==3, % draw the frame
		stamp = 1;
		if NS_PTBv<3,
			Screen('CopyWindow',dispstruct.offscreen(1),StimScreen, ...
			    dispstruct.userfield.rects(1,:), ...
       		             info.rectshift+dispstruct.userfield.rects( ...
       		                 dispstruct.userfield.blinkList(info.frame+1),:), ...
							'srcCopyQuickly');
		else,
			if dispstruct.userfield.bgpause~=0,
				info.lastvbl = Screen('Flip',StimScreen,info.lastvbl+(dispstruct.userfield.frameLength-0.5)/StimWindowRefresh);
			end;
			if info.frame~=dispstruct.userfield.N, % draw next frame for all but last frame
                Screen('DrawTexture',StimScreen,dispstruct.offscreen(1),dispstruct.userfield.rects(1,:),info.rectshift+dispstruct.userfield.rects(...
				dispstruct.userfield.blinkList(info.frame+1),:));
            else,
                done = 1; stamp=0;
            end;
            info.lastvbl = Screen('Flip',StimScreen,info.lastvbl+(dispstruct.userfield.frameLength*(1+dispstruct.userfield.bgpause)-0.5)/StimWindowRefresh);
            if info.frame==dispstruct.userfield.N-1, 
                    %info.lastvbl = Screen('Flip',StimScreen,info.lastvbl+(dispstruct.userfield.frameLength-0.5)/StimWindowRefresh);
                    %info.lastvbl = Screen('Flip',StimScreen,info.lastvbl+(dispstruct.userfield.frameLength*(1+dispstruct.userfield.bgpause)-0.5)/StimWindowRefresh);
            end;
		end;
		info.bgcount = dispstruct.userfield.bgpause;
		info.frame = info.frame + 1;
		%dispstruct.userfield, % displaying for debugging purposes
		%info,
	   else,
		info.bgcount = info.bgcount - 1;
	   end;
	end;
  end;

infoO = info;

