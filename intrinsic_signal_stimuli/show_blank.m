function show_blank(window,time,background )
%SHOW_BLANK shows blank screen for specified time
%
%  SHOW_BLANK(WINDOW,TIME,BACKGROUND)
%     TIME = time (s) to show blank
%  2004, Alexander Heimel

Screen(window,'FillRect',background);
pause(time)
