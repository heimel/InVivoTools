function [sms] = shapemoviestim(SMSp, OLDSTIM)

%  SHAPEMOVIESTIM - Makes a shapemoviestim
%
%  THESMS = SHAPEMOVIESTIM(PARAMETERS)
%
%  Creates a shapemoviestim object.  A shapemoviestim is a collection of
%  N-frame movie stimuli, where simple shapes are drawn on each frame.  One can
%  adjust the lifetime (in number of frames) of each simple shape.
%
%  PARAMETERS can either be the string 'graphical' (which will prompt the user
%  to enter all of the parameter values), the string 'default' (which will
%  use default parameter values), or a structure.  When using 'graphical', one
%  may also use
%
%  SMS = SHAPEMOVIESTIM('graphical',OLDSMS)
%
%  where OLDSMS is a previously created shapemoviestim object.  This will
%  set the default parameter values to those of OLDSMS.
%
%  PARAMETERS describes global parameters for all of the N-frame stimuli.
%  Individual stimuli can be added/read/adjusted with the following
%  functions:
%     newSMS=addshapemovies(thesms,nframemovies)
%     shapemoves=getshapemovies(thesms)
%     newSMS=setshapemovies(thesms,nframemovies)
%
%  If passing a structure, the structure should have the following fields:
%  (dimensions of parameters are given as [M N]; fields are case-sensitive):
%
%  [1x4] rect         - Location of stimulus on screen
%                       [top_x top_y bottom_x bottom_y]
%  [1x3] BG           - Background color [r g b]
%  [1x2] scale		  - Integer scale between actual stimulus on screen and
%                       virtual pixels specified in the n-framemovies.
%  [1x1] fps          - Speed at which to show the frames, in frames per second.
%  [1x1] N            - Number of frames in each movie
%  [1x1] isi          - Interstimulus interval between movies (in seconds)
%                     -   Note that the temporal resolution for the isi is 
%                         not finer than the fps for the stimuli
% [cell] dispprefs    - Sets displayprefs fields, or use {} for default values.
%
%   Questions to vanhoosr@brandeis.edu

NewStimListAdd('shapemoviestim');

if nargin==0,
	sms = shapemoviestim('default');
	return;
end;


sms = [];
finish = 1;

if nargin==1, oldstim=[]; else, oldstim = OLDSTIM; end;

if ischar(SMSp), % if it is an instruction
	if strcmp(SMSp,'graphical'),
		finish = 0;
		sms = edit_graphical(shapemoviestim('default'));
	elseif strcmp(SMSp,'default')|strcmp(SMSp,''),
		SMSp = [];
	else,
		error('Unknown string input to shapemoviestim.');
	end;
else,  % they are parameters
end;

if finish,
	s = stimulus(5);
	sms = class(struct('SMSparams',[],'nframemovies',[],'clut',[]),'shapemoviestim',s);
	sms = setparameters(sms,SMSp);
end;
