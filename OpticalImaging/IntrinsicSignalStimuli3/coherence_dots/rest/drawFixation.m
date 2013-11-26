function   display = drawFixation(display)
%display = drawFixation(display)
%
%Inserts a fixation point (smaller square inside a larger square) in the
%center of the screen and calls Screen's 'Flip' function.  
%
%Can use the field 'fixation' in the display structure, or uses the
%following default values:
%
%   display.fixation.size       Size of fixation square
%                                 default is 0.5 degrees
%   display.fixation.mask       Size of circular 'mask' that surrounds the fixation
%                                 default is 2 degrees
%   display.fixation.color      Cell array for two outer and inner colors
%                                 default is {[255,255,255],[0,0,0]}
%   display.fixation.flip       Flag for whether or not to call Screen's
%                                 'Flip function at the end.  Default is 1                          

%3/26/09 Written by G.M. Boynton at the University of Washington

%Deal with default values
if ~isfield(display,'fixation')
    display.fixation = [];
end

%Size
if ~isfield(display.fixation,'size')
    display.fixation.size = .5; %degrees
end

%Mask
if ~isfield(display.fixation,'mask')
    display.fixation.mask = 2;  %degrees
end

%Color
if ~isfield(display.fixation,'color')
    display.fixation.color = {[255,255,255],[0,0,0]};
end

%Flip
if ~isfield(display.fixation,'flip')
    display.fixation.flip = 1;  %flip by default
end

center = display.resolution/2;

%Calculate size of boxes in screen-coordinates
sz(1) = angle2pix(display,display.fixation.size/2);
sz(2) = angle2pix(display,display.fixation.size/4);
sz(3) = angle2pix(display,display.fixation.mask/2);

%Calculate the rectangles in screen-coordinates [l,t,r,b]
for i=1:3
    rect{i}= [-sz(i)+center(1),-sz(i)+center(2),sz(i)+center(1),sz(i)+center(2)];
end

%Mask (background color)
Screen('FillOval', display.windowPtr, display.bkColor,rect{3});
%Outer rectangle (default is white)
Screen('FillRect', display.windowPtr, display.fixation.color{1},rect{1});
%Inner rectangle (default is black)
Screen('FillRect', display.windowPtr, display.fixation.color{2},rect{2});

if display.fixation.flip
     Screen('Flip',display.windowPtr);
end
