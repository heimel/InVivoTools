function [moviefields] = MovieParams2MTI(ds, df)

% MOVIEPARAMS2MTI - Set up Movie fields for DisplayTiming/DisplayStimulus
%
%   This function allow our standard 'Movie' dislay type in NewStim to take
%   advantage of new features while maintaining backward-compatibility with
%   old code written before these features were available.
%
%   MOVIEFIELDS = MOVIEPARAMS2MTI(DS, DF)
%      DS is the displaystruct of the stimulus, DF is the displayprefs.
%
%   If the stim's display type is a 'Movie', then the following fields are
%   returned as a structure.  These fields either assume default values,
%   or, if the stim's display struct has a 'userfield' entry that specifies
%   variable source rectangles, rotation angles, global alphas, or clipping
%   (that is,
%   mask region) parameters, then those values are used.
%   (see "help displaystruct")
%
%   'Movie_sourcerects'    A list of source rect locations for drawing textures; is a
%                              column vector of rect locations of size [4xNxM],
%                              where N is the number of frames in df.frames,
%                              and M is the number of textures.
%                              Default is a constant source rectangle that is the
%                              same size as each offscreen buffer.
%   'Movie_destrects'      A list of destination rect locations for drawing textures; is a
%                              column vector of rect locations of size [4xNxM],
%                              where N is the number of frames in df.frames,
%                              and M is the number of textures.
%                              Default is a constant destination rectangle that is
%                              given in df.rect.
%   'Movie_angles'         A list of rotation angles for the DrawTexture command
%                              [1xNxM],where N is the number of frames in df.frames
%                              and M is the number of textures.
%                              Default value is 0.
%   'Movie_globalalphas'   A list of global alphas for the DrawTexture command
%                              [1xNxM], where N is the number of frames in df.frames,
%                              and M is the number of textures.
%                              Default value is 1.
%   'Movie_textures'       A cell list of the textures to draw on a given data frame
%                              {N}, where N is the number of frames.  The texture indexes
%                              refer to the offscreen textures in ds.offscreen.
%                              Default value is Movie_textures{i}=df.frames(i).
%   'Move_auxparameters'   A list of auxillary parameters for the DrawTexture command
%                              [DxNxM], where D is the number of parameters,
%                              N is the number of frames in df.frames,
%                              and M is the number of textures. The
%                              auxillary parameters are for instance used
%                              for CreateProceduralSineGrating.
%                              Default is [].
%


%
%   This function should only be called when stimuli are loaded (and, in PTB-3, when
%   the stimulus screen is showing).

NewStimGlobals

if ~isstruct(ds), ds = struct(ds); end;
if ~isstruct(df), df = struct(df); end;

if strcmp(ds.displayType,'Movie'),
    if isfield(ds.userfield,'Movie_sourcerects'),
        moviefields.Movie_sourcerects = ds.userfield.Movie_sourcerects;
    else
        % 		sourcerects = [];
        % 		for i=1:length(ds.offscreen),
        % 			sourcerect = Screen(ds.offscreen(1),'Rect');
        % 			sourcerects = cat(3,sourcerects,repmat(sourcerect(:),1,length(df.frames)));
        % 		end;
        sourcerects = zeros(4,length(df.frames),length(ds.offscreen));
        for i=1:length(ds.offscreen),
            sourcerect = Screen(ds.offscreen(1),'Rect');
            sourcerects(:,:,i) = repmat(sourcerect(:),1,length(df.frames));
        end;
        moviefields.Movie_sourcerects = sourcerects;
    end
    if isfield(ds.userfield,'Movie_destrects'),
        moviefields.Movie_destrects = ds.userfield.Movie_destrects;
    else
        destrect = df.rect; % make sure it is a column vector
        % 		destrects = [];
        % 		for i=1:length(ds.offscreen),
        % 			destrects = cat(3,destrects,repmat(destrect(:),1,length(df.frames)));
        % 		end;
        destrects = zeros(4,length(df.frames),length(ds.offscreen));
        for i=1:length(ds.offscreen),
            destrects(:,:,i) = repmat(destrect(:),1,length(df.frames));
        end;
        moviefields.Movie_destrects = destrects;
    end;
    
    
    if isfield(ds.userfield,'Movie_angles'),
        moviefields.Movie_angles = ds.userfield.Movie_angles;
    else
        moviefields.Movie_angles = zeros(1,length(df.frames),length(ds.offscreen));
    end
    
    if isfield(ds.userfield,'Movie_globalalphas'),
        moviefields.Movie_globalalphas = ds.userfield.Movie_globalalphas;
    else
        moviefields.Movie_globalalphas = ones(1,length(df.frames),length(ds.offscreen));
    end;
    if isfield(ds.userfield,'Movie_textures'),
        moviefields.Movie_textures = ds.userfield.Movie_textures;
    else,
        for i=1:length(df.frames), moviefields.Movie_textures{i} = df.frames(i); end;
    end;
    if isfield(ds.userfield,'Movie_auxparameters'),
        moviefields.Movie_auxparameters = ds.userfield.Movie_auxparameters;
    else
        moviefields.Movie_auxparameters = zeros(4,length(df.frames),length(ds.offscreen));
    end;

    if exist('NewStimTilt','var') && ~isempty(NewStimTilt) && NewStimTilt~=0
        moviefields.Movie_angles = moviefields.Movie_angles + NewStimTilt/2;
%         moviefields.Movie_angles(1,:) = moviefields.Movie_angles(1,:) + NewStimTilt/2;
%         moviefields.Movie_angles(2,:) = moviefields.Movie_angles(2,:) + NewStimTilt/2;
%         cent_scr=[df.rect(1)+df.rect(3)/2,df.rect(2)+df.rect(4)/2];
%         disp('MOVIEPARAMS2MTI: NewStimTilt center of rect rotation around screen center is not yet implemented.');
        % next line not finished. Should be rotated around screen center
%         moviefields.Movie_destrects=moviefields.Movie_destrects-moviefields.Movie_sourcerects
%         moviefields.Movie_destrects = moviefields.Movie_destrects + mean(moviefields.Movie_sourcerects(:,1,1),1) - mean(moviefields.Movie_destrects(:,1,1),1);
%         moviefields.Movie_destrects(:,:,2) = moviefields.Movie_destrects(:,:,2) + mean(moviefields.Movie_sourcerects(:,1,2),1) - mean(moviefields.Movie_destrects(:,1,2),1);
% xx1=mean(moviefields.Movie_sourcerects(:,1,1),1) - mean(moviefields.Movie_destrects(:,1,1),1);
% xx2=mean(moviefields.Movie_sourcerects(:,1,2),1) - mean(moviefields.Movie_destrects(:,1,2),1);
% center_source=(moviefields.Movie_sourcerects(:,1)+moviefields.Movie_sourcerects(:,end))/2;
% % shift_center=center_source-moviefields.Movie_destrects(:,1);
% df.rect
% shift_center=[10;10;10;10];
% moviefields.Movie_destrects=moviefields.Movie_destrects+repmat(shift_center,1,length(moviefields.Movie_destrects));
% moviefields.Movie_destrects(1,:)=moviefields.Movie_destrects(1,:)+0;
% moviefields.Movie_destrects(2,:)=moviefields.Movie_destrects(2,:)+0;
% moviefields.Movie_destrects(3,:)=moviefields.Movie_destrects(3,:)+0;
% moviefields.Movie_destrects(4,:)=moviefields.Movie_destrects(4,:)+0;
% CenterRectOnPointd(moviefields.Movie_destrects(1:4),400,400);
moviefields.Movie_destrects=moviefields.Movie_destrects+0;
% moviefields.Movie_destrects(1,:)=moviefields.Movie_destrects(1,:)-df.rect(1)+960;
% moviefields.Movie_destrects(2,:)=moviefields.Movie_destrects(2,:)-df.rect(2)+540;
% df.rect
% moviefields.Movie_destrects(3,:)=moviefields.Movie_destrects(3,:)-df.rect(3);
% moviefields.Movie_destrects(4,:)=moviefields.Movie_destrects(4,:)-df.rect(4);
    end
else
    moviefields = [];
end;

