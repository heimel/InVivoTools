function [done,stamp,infoO]=blinktim(info,StimScreen,dispstruct,dispprefs);
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

  done = 0; stamp = 0; 

  if ~isstruct(info)&~isempty(info),
        dispstruct.userfield; % make sure we're in memory
  elseif isempty(info),
	screen(StimScreen,'SetClut',dispstruct.clut);
	rectshift = [dispprefs.rect(1) dispprefs.rect(2) ...
				dispprefs.rect(1) dispprefs.rect(2)];
	frameLength = dispstruct.userfield.frameLength - 1;
	if (frameLength<1), frameLength = 1; end;
	info=struct('frame',0,'bgcount',0,'rectshift',rectshift, ...
		'frameLength',frameLength);
	done=0; stamp=0;
  else, % info has our info
	% clean up the mess from the last frame
	if info.frame>0&info.frame~=dispstruct.userfield.N,
		screen(StimScreen,'WaitBlanking',dispstruct.userfield.frameLength);
		screen('CopyWindow',dispstruct.offscreen(2),StimScreen, ...
                   dispstruct.userfield.rects(1,:), ...
                   info.rectshift+dispstruct.userfield.rects( ...
                            dispstruct.userfield.blinkList(info.frame),:), ...
							'srcCopyQuickly');
	end;
	if info.frame==dispstruct.userfield.N,
		done = 1; stamp=0;
	else,
	   if info.bgcount==0, % draw the frame
		stamp = 1;
		screen('CopyWindow',dispstruct.offscreen(1),StimScreen, ...
		    dispstruct.userfield.rects(1,:), ...
                    info.rectshift+dispstruct.userfield.rects( ...
                        dispstruct.userfield.blinkList(info.frame+1),:), ...
						'srcCopyQuickly');
		info.bgcount = dispstruct.userfield.bgpause;
		info.frame = info.frame + 1;
		else, info.bgcount = info.bgcount - 1;
	   end;
	end;
  end;

infoO = info;

