function show_movie(window, w,rect,time,background,waitframes,continuous )
%SHOW_MOVIE uses RUSH to show psychtoolbox movie
%
%  2004, Alexander Heimel

global monitorframerate 

if nargin<6
    waitframes=1; %#ok<NASGU>
end
if nargin<7
    continuous=0;
end

frames=length(w); %#ok<NASGU>
r=Screen(w(1),'Rect');
%rr=CenterRect(r,screen(window,'Rect'))
rr=rect; %#ok<NASGU>
Screen('Screens');	% Make sure all Rushed functions are in memory.
%Screen(window,'FillRect',gray);
i=0;				% Allocate all Rushed variables.
n=round(time*monitorframerate); 
if waitframes == 1
    loop=[ 'for i=0:n-1;'  ...
        'Screen(''CopyWindow'',w(1+mod(i,frames)),window,r,rr);' ...
        'Screen(window,''Flip'');' ...
        'end;' ];
else
    
    loop=[ 'for i=0:n-1;'  ...
        'Screen(''CopyWindow'',w(1+mod(i,frames)),window,r,rr);' ...
        'Screen(window,''Flip'');' ...
        'Screen(window,''WaitBlanking'',waitframes-1);' ...
        'end;' ];
end

priorityLevel=MaxPriority(window,'WaitBlanking');
hidecursor;
if ~continuous
    Screen(window,'FillRect',background);
    Screen(window,'Flip');
end

%disp('SHOW_MOVIE: in debug mode, i.e. priorityLevel = 0');
%priorityLevel = 0; 
Rush(loop,priorityLevel); % show movie

if ~continuous
    Screen(window,'FillRect',background);
    Screen(window,'Flip');
end