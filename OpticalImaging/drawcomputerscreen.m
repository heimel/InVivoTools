function inbox = drawcomputerscreen

% DRAWCOMPUTERSCREEN Draws a picture of a computer screen in current axes
%
%  INBOX=DRAWCOMPUTERSCREEN
%
% Draws a computer screen with gray borders.  Returns in INBOX the
% bounding rectangle of the "inside" of the monitor [left top right bottom].

 %cmap=[0 0 0; 1 1 1; 0.7 0.7 0.7; 1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 1 0; 1 0 1];
 %colormap(cmap);

hold on;
patch1x= [0.15 0.21 0.21 0.15 0.15]-0.15;
patch1y= [0.0 0.06 0.94 1.0 0.0];
fill(patch1x,patch1y,[0.7 0.7 0.7],'linewidth',2);
patch2x= patch1x+1.3-0.06;
patch2y= [0.06 0.0 1.0 0.94 0.06];
fill(patch2x,patch2y,[0.7 0.7 0.7],'linewidth',2);
patch3x= [0 1.3 1.3-0.06 0.06 0];
patch3y= [1 1    0.94      0.94 1];
fill(patch3x,patch3y,[0.7 0.7 0.7],'linewidth',2);
patch4x= [0 1.3 1.3-0.06 0.06 0];
patch4y= [0 0    0.06      0.06 0];
fill(patch4x,patch4y,[0.7 0.7 0.7],'linewidth',2);
axis([0 1.3 0 1.0]);
inbox = [0.06 0.94 1.3-0.06 0.06];
axis equal;
axis off;
