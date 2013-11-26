function colors=drawhorizontalretinopy(numstims)

% DRAWHORIZONTALRETINOPY - Draws a picture of horizontal retinopy stimulus
%
% COLORS=DRAWHORIZONTALRETINOPY(NUMSTIMS)
%
%  Draws a picture of a horizontal retinopy stimulus with number of stimuli
%  NUMSTIMS in the current axes.  The colors used are returned in COLORS.

inbox = drawcomputerscreen;

szx = inbox(3)-inbox(1);
szy = inbox(4)-inbox(2);

wd = szx; ht = szy/numstims;

cols = hsv(numstims);
purple=[0.625 0.125 0.54];
green=[0 0.7 0];
if numstims==8,
	cols(4,:) = green; cols(7,:)=purple;
	cols(1,:) = [0.7 0.3 0]; % dark red
	cols(6,:) = [0.2 0.2 0.7];
	cols(3,:) = [0.75 0.5 0.0];
end;

for i=1:numstims,
	patch_x = [inbox(1) inbox(3) inbox(3) inbox(1) inbox(1)];
	patch_y = [inbox(2)+(i-1)*ht inbox(2)+(i-1)*ht ...
	           inbox(2)+(i)*ht   inbox(2)+(i)*ht ...
			   inbox(2)+(i-1)*ht];
	fill(patch_x,patch_y,cols(i,:));
end;
