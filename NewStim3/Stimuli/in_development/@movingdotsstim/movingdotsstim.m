function [mds] = movingdotsstim(MDSp, OLDSTIM)

%  MOVINGDOTSSTIM- Makes a movingdotsstim
%
%  THEMDS = MOVINGDOTSSTIM(PARAMETERS)
%
%  Creates a movingdotsstim object.  A movingdotsstim is a collection of
%  random dots, some fraction of which move in a coherent direction while the
%  rest appear and disappear randomly.
%
%  PARAMETERS can either be the string 'graphical' (which will prompt the user
%  to enter all of the parameter values), the string 'default' (which will
%  use default parameter values), or a structure.  When using 'graphical', one
%  may also use
%
%  MDS = MOVINGDOTSSTIM('graphical',OLDMDS)
%
%  where OLDMDS is a previously created movingdotsstim object.  This will
%  set the default parameter values to those of OLDMDS.
%
%  PARAMETERS describes parameters the stimulus.
%
%  If passing a structure, the structure should have the following fields:
%  (dimensions of parameters are given as [M N]; fields are case-sensitive):
%
%  [1x4] rect         - Location of stimulus on screen
%                       [top_x top_y bottom_x bottom_y]
%                           (default [0 0 200 200])
%  [1x3] BG           - Background color [r g b] (default black)
%  [1x3] FG           - Foreground color of the dots [r g b] (default white)
%  [1x1] motiontype   - 'planar' for planar motion, 'radial' for radial motion
%                       (default 'planar')
%  [1x1] velocity     - Velocity of dots, in degrees of visual angle per second;
%                         actual stimulus will come as close to the desired
%                         velocity as possible given the frames per second.
%                         (default 10 deg/sec)
%  [1x1] angvelocity  - Angular velocity in degrees angle/sec; only used
%                         for radial stimuli (default 0 angle/sec).
%  [1x1] direction    - Direction in degrees.  For planar stimuli, this is the
%                         direction in which dots will move (0 is up).  For
%                         radial stimuli, cos(direction) * angvelocity is the 
%                         angular velocity in degrees of angle per second and
%                         sin(direction)*velocity is radial velocity in 
%                         degrees of visual angle per second.  (Default 0.)
%  [1x1] coherence    - Fraction of dots that move as above (0..1); other dots
%                         move randomly (default 1).
%  [1x1] dotsize      - Size of dots, in degrees, default 1.5
%  [1x1] numdots      - Number of dots, default 20
%  [1x1] distance     - Viewing distance in cm, default 57
%  [1x1] fps          - Presentation frames per second, default 120.
%  [1x1] duration     - Duration of stimulus in seconds, default 4.
%  [1x1] numpatterns  - Number of random patterns generated; default is 1.
%  [1x1] lifetimes    - Length of each dot's life (seconds)  Default is Inf.
% [35x1] randState    - Matlab random seed variable (default: rand('state'))
% [cell] dispprefs    - Sets displayprefs fields, or use {} for default values.
% 
%  Note:This stimulus type is drawn 'live'; i.e., the frames are not precomputed
%  and copied to the screen from memory.  Thus, by specifying a large dot
%  size and many dots, it is possible that drawing can take more time than one
%  video frame.  The user should test this stimulus with their own computer and
%  video hardware to see the maximum capabilities of their system.
%
%   Questions to vanhoosr@brandeis.edu

NewStimListAdd('movingdotstim');

if nargin==0,
	mds = movingdotstim('default');
	return;
end;


mds = [];
finish = 1;

if nargin==1, oldstim=[]; else, oldstim = OLDSTIM; end;

if ischar(MDSp), % if it is an instruction
	if strcmp(MDSp,'graphical'),
		finish = 0;
		mds = edit_graphical(movingdotsstim('default'));
	elseif strcmp(MDSp,'default')|strcmp(MDSp,''),
		MDSp = [];
	else,
		error('Unknown string input to movingdotsstim.');
	end;
else,  % they are parameters
end;

if finish,
	s = stimulus(5);
	mds = class(struct('MDSparams',[]),'movingdotsstim',s);
	mds = setparameters(mds,MDSp);
end;
