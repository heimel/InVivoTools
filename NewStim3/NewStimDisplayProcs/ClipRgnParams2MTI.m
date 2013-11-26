function [cliprgnfields] = ClipRgnParams2MTI(ds, df)

% CLIPRGNPARAMS2MTI - Set up ClipRgn fields for DisplayTiming/DisplayStimulus
%
%   This function allow our standard ClipRgn in NewStim to take
%   advantage of new features while maintaining backward-compatibility with
%   old code written before these features were available.
%
%   CLIPRGNFIELDS = CLIPRGNPARAMS2MTI(DS, DF)
%      DS is the displaystruct of the stimulus, DF is the displayprefs.
%   
%   The following fields are returned as a structure.  These fields either
%   assume default values, or, if the stim's display struct has a 'userfield'
%   entry that specifies variable source rectangles, rotation angles, global
%   alphas, for the clipping (that is, mask region) parameters, then those
%   values are used.
%   (see "help displaystruct")
%
%   'ClipRgn_sourcerects'  A list of source rects for the clipping region mask
%                              In coordinates of the masktexture
%                              [Nx4], where N is the number of frames in df.frames
%                              Default value is a source rectangle the same size as
%                              the texture in ds.clipRect
%   'ClipRgn_destrects'    A list of destination rects for the clipping region mask,
%                              in global screen coordinates
%                              [Nx4], where N is the number of frames in df.frames
%                              Default value is the same location as df.rect.
%   'ClipRgn_angles'       A list of rotation angles for the clipping DrawTexture
%                              command; [Nx4], where N is the number of frames in
%                              df.frames.  Default value is 0.
%
%   This function should only be called when stimuli are loaded (and, in PTB-3, when
%   the stimulus screen is showing).

if ~isstruct(ds), ds = struct(ds); end;
if ~isstruct(df), df = struct(df); end;

if isfield(ds.userfield,'ClipRgn_sourcerects'),
	cliprgnfields.ClipRgn_sourcerects = ds.userfield.ClipRgn_sourcerects;
else,
	if ds.makeClip==4, % source rect is the size of the full screen
		StimWindowGlobals;
		sourcerect = Screen(StimWindow,'Rect');
		cliprgnfields.ClipRgn_sourcerects = repmat(sourcerect,length(df.frames),1);
	elseif ds.makeClip==5, % assume it is the window
		sourcerect = Screen(ds.clipRect,'Rect');
		cliprgnfields.ClipRgn_sourcerects = repmat(sourcerect,length(df.frames),1);
	end;
end;
if isfield(ds.userfield,'ClipRgn_destrects'),
	cliprgnfields.ClipRgn_destrects = ds.userfield.ClipRgn_destrects;
else,
	if ds.makeClip==4, % destination rect is the full screen
		StimWindowGlobals;
		destrect = Screen(StimWindow,'Rect');
		cliprgnfields.ClipRgn_destrects = repmat(destrect,length(df.frames),1);
	elseif ds.makeClip==5, % assume it is the stimulus size
		destrect = df.rect;
		cliprgnfields.ClipRgn_destrects = repmat(destrect,length(df.frames),1);
	end;
end;
if isfield(ds.userfield,'ClipRgn_angles'),
	cliprgnfields.ClipRgn_angles = ds.userfield.ClipRgn_angles;
else,
	cliprgnfields.ClipRgn_angles = zeros(1,length(df.frames));
end;
