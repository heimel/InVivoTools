function show_movie(window, w,rect,time,background,waitframes,continuous )
%SHOW_MOVIE uses RUSH to show psychtoolbox movie
%
%  2004, Alexander Heimel

global whichScreen monitorframerate 

if nargin<6
    waitframes=1;
end
if nargin<7
    continuous=0;
end

frames=length(w);
r=Screen(w(1),'Rect')
%rr=CenterRect(r,screen(window,'Rect'))
rr=rect;
Screen('Screens');	% Make sure all Rushed functions are in memory.
%Screen(window,'FillRect',gray);
i=0;				% Allocate all Rushed variables.
n=round(time*monitorframerate); 

loop={
	'for i=0:n-1;'
		'Screen(window,''WaitBlanking'',waitframes);'
		'Screen(''CopyWindow'',w(1+mod(i,frames)),window,r,rr);'
	'end;'
}
priorityLevel=MaxPriority(window,'WaitBlanking');
hidecursor;
if ~continuous
    Screen(window,'FillRect',background);
end
Rush(loop,priorityLevel);
if ~continuous
    Screen(window,'FillRect',background);
end