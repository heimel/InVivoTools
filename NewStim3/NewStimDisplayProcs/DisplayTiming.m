function [MTI] = DisplayTiming(stimScript)
%  DISPLAYTIMING - Precompute display information for DisplayStimScript
%
%  MTI = DISPLAYTIMING(stimScript);
%
%  DISPLAYTIMING creates blank arrays that will be used to store stimulus
%  timing information in the DisplayStimScript function for the NewStim
%  package.  Calling DISPLAYTIMING before calling DISPLAYSTIMSCRIPT can
%  speed up DISPLAYSTIMSCRIPTS execution, as DISPLAYSTIMSCRIPT will call
%  DISPLAYTIMING if the blank timing structure MTI has not already been
%  created.
%
%  MTI is a cell list of information about each stimulus presentation.
%  Each MTI{i} is a struct with the following entries:
%   'frameTimes'          Time of each frame in the stimulus with respect to
%                                stimulus clock
%   (Note: the remaining entries are technical calculations for DisplayStimScript
%    that will not be interesting to most users)
%   'preBGframes'          # of monitor frame refreshes to show background
%                                before stim comes on
%   'postBGframes;         # of monitor frame refreshes to show background
%                                after stim goes off
%   'pauseRefresh'         # of monitor frame refreshes to wait between each
%                                frame, pauseRefresh, 'frameTimes', frameTimes, ...
%   'startStopTimes'
%   'ds'                   the displaystruct object associated with the stimulus
%                                as a struct
%   'df'                   the displayprefs object associated with the stimulus
%                                as a struct
%   'stimid'               the stimulus number in the script
%   'GammaCorrectionTable' the GammaCorrectionTable used, if any
%
%   If the stim's display type is a 'Movie', then the following fields are also
%   returned.  These fields either assume default values, or, if the stim's
%   display struct has a 'userfield' entry that specifies variable
%   source rectangles, rotation angles, global alphas, or clipping (that is,
%   mask region) parameters, then those values are used.
%   (see "help displaystruct")
%
%   'Movie_sourcerects'    A list of source rect locations for drawing textures; is
%                              [Nx4], where N is the number of frames in df.frames
%                              Default is a constant source rectangle that is the
%                              same size as the offscreen buffer.
%   'Movie_angle'          A list of rotation angles for the DrawTexture command
%                              [Nx1],where N is the number of frames in df.frames
%                              Default value is 0.
%   'Movie_globalalpha'    A list of global alphas for the DrawTexture command
%                              [Nx1], where N is the number of frames in df.frames
%                              Default value is 1.
%   'ClipRgn_sourcerects'  A list of source rects for the clipping region mask
%                              In coordinates of the masktexture
%                              [Nx4], where N is the number of frames in df.frames
%                              Default value is a source rectangle the same size as
%                              the texture in ds.clipRect
%   'ClipRgn_destrects'    A list of destination rects for the clipping region mask,
%                              in global screen coordinates
%                              [Nx4], where N is the number of frames in df.frames
%                              Default value is the same location as df.rect.
%
%  If gamma correction is enabled (see GammaCorrectionTableGlobals)
%  DISPLAYTIMING applies gamma correction to all color look up tables in
%  each stimulus's displaystruct object.
%
% 200X, Steve Van Hooser
% 200X-2021, Alexander Heimel

if ~isloaded(stimScript)
    error('DisplayTiming error: stimScript not loaded.');
end

MTI = cell(0);

StimWindowGlobals;
NewStimGlobals;
GammaCorrectionTableGlobals;

currLut = Screen('ReadNormalizedGammaTable', StimWindow);

dispOrder = getDisplayOrder(stimScript);

thedfs = cell(numStims(stimScript),1);
thedss = cell(numStims(stimScript),1);
for i=1:numStims(stimScript)
    thedfs{i} = struct(getdisplayprefs(get(stimScript,i)));
    thedss{i} = struct(getdisplaystruct(get(stimScript,i)));
    
    thedss{i}.bg_gammauncorrected = thedss{i}.clut_bg(1,:);
    thedss{i}.bg_gammacorrected = thedss{i}.clut_bg(1,:);
    
    if GammaCorrectionEnable  % apply gamma correction
        % thedss{i}.clut_bg = ApplyGammaCorrection(thedss{i}.clut_bg);
        % Commented by Alexander: not applying gamma correction to clut_bg
        % table. Only the clut_bg value is used to set the background in the thedss{i}.clut
        thedss{i}.bg_gammacorrected = ApplyGammaCorrection(thedss{i}.clut_bg(1,:));
        
        if iscell(thedss{i}.clut)
            for j=1:length(thedss{i}.clut)
                thedss{i}.clut{j} = ApplyGammaCorrection(thedss{i}.clut{j});
            end
        else
            thedss{i}.clut = ApplyGammaCorrection(thedss{i}.clut);
        end
    end
    thedss{i}.clut_bg = mergeluts(currLut,thedss{i}.clut_bg);
    if iscell(thedss{i}.clut)
        for j=1:length(thedss{i}.clut)
            thedss{i}.clut{j} = mergeluts(currLut,thedss{i}.clut{j}/255); 
        end
    else
        thedss{i}.clut = mergeluts(currLut,thedss{i}.clut/255);
        
        % on OS/X and some NVidia card the currlut may be larger than 256 rows
        % but the rest of the software assumes 256 entries only.
        thedss{i}.clut = thedss{i}.clut(1:256,:);
    end
end

for i=1:length(dispOrder)
    df = thedfs{dispOrder(i)};
    ds = thedss{dispOrder(i)};
    if (strcmp(ds.displayType,'CLUTanim'))||(strcmp(ds.displayType,'Movie'))
        if max(df.frames) > ds.frames
            error(['Error: frames to display in ' ...
                'displaypref greater than actual number of frames in displaystruct.']); 
        end
        if min(df.frames) < 1
            error(['Error: frames to display in ' ...
                'displaypref out of bounds (less than first frame).']);
        end
        % the following line is necessary because SetClut takes 1 refresh
        if strcmp(ds.displayType,'CLUTanim')
            sft=1;
        else
            sft=0;
        end
        pauseRefresh = zeros(1,length(df.frames));
        if df.roundFrames
            pauseRefresh(:) = round(StimWindowRefresh / df.fps)-sft;
        else
            pauseRefresh = diff(fix((1:(length(df.frames)+1)) * StimWindowRefresh / df.fps))-sft;
        end
        frameTimes = zeros(size(pauseRefresh));
    else
        if (strcmp(ds.displayType,'custom'))
            eval([ds.displayProc '(-1,[],ds,df);']); % get proc in memory
        end
        frameTimes = [];
        pauseRefresh = [];
    end
    startStopTimes = [ 0 0 0 0];
    if isfield(df,'BGpretime')
        preBGframes = fix(df.BGpretime * StimWindowRefresh);
    else
        preBGframes = [];
    end
    if isfield(df,'BGposttime')
        postBGframes = fix(df.BGposttime * StimWindowRefresh);
    else
        postBGframes = [];
    end
    MTI{i} = struct('preBGframes', preBGframes,...
        'postBGframes', postBGframes, ...
        'pauseRefresh', pauseRefresh, 'frameTimes', frameTimes, ...
        'startStopTimes', startStopTimes, 'ds', ds, ...
        'df', df,'stimid',dispOrder(i),...
        'GammaCorrectionTable',GammaCorrectionTable);
    MTI{i}.MovieParams = MovieParams2MTI(ds, df);
    MTI{i}.ClipRgnParams = ClipRgnParams2MTI(ds,df);
end
