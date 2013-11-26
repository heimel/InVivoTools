% displayStruct

% displayType
%   ... structs relevent to displayType
%       for Movie, this is an Nx3 color table and 'offscreen'(1:M)
%       for CLUTanim, this is 1 'offscreen' and Nx3{1:M} clut
% displayProc = 'standard' or name of another procedure
% displayPrefs
%    (* indicates default value required)
%    *fps  - fames per second to display
%    *rect - target on screen (possibly not applicable to all stimuli)
%    roundframes - 0/1 should # refreshes between frames be constant or
%          rounded so that fps is more accurate?
%    absStartTime - the absolute time when we should start to play the movie
%                          (use <0 for immediately)
%    BGpretime - amount of time background should be present before playing
%                stim
%    BGposttime - amount of time background should be present after playing stim
%    lastframetime - amount of time last frame should be shown before reverting
%              to background
%    

