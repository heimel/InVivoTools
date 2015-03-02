function [is] = imagestim(ISp, OLDSTIM)

%  IMAGESTIM - Makes an imagestim
%
%  THEIS = IMAGESTIM(PARAMETERS)
%
%  Creates an imagestim object.  An imagestim displays an image on the screen.
%
%  PARAMETERS can either be the string 'graphical' (which will prompt the user
%  to enter all of the parameter values), the string 'default' (which will
%  use default parameter values), or a structure.  When using 'graphical', one
%  may also use
%
%  IS = IMAGESTIM('graphical',OLDIS)
%
%  where OLDIS is a previously created imagestim object.  This will
%  set the default parameter values to those of OLDIS.
%
%  PARAMETERS describes parameters for the image stimulus.
%
%  If passing a structure, the structure should have the following fields:
%  (dimensions of parameters are given as [M N]; fields are case-sensitive):
%
%  [1x4] rect         - Location of stimulus on screen
%                       [top_x top_y bottom_x bottom_y]
%  [1x3] BG           - Background color [r g b]
%  [1x1] duration     - Time that image remains on the screen.
%  [1xn] filename     - Name of file to be displayed
%  [1xm] maskfile     - Name of mask file (optional, use '' for none)
% [cell] dispprefs    - Sets displayprefs fields, or use {} for default values.
%
%   Questions to vanhoosr@brandeis.edu

NewStimListAdd('imagestim');

if nargin==0,
	is = imagestim('default');
	return;
end;


is = [];
finish = 1;

if nargin==1, oldstim=[]; else, oldstim = OLDSTIM; end;

if ischar(ISp), % if it is an instruction
	if strcmp(ISp,'graphical'),
		finish = 0;
		sms = edit_graphical(imagestim('default'));
	elseif strcmp(ISp,'default')||strcmp(ISp,''),
		ISp = [];
	else,
		error('Unknown string input to imagestim.');
	end;
else,  % they are parameters
end;

if finish,
	s = stimulus(5);
	is = class(struct('ISparams',[]),'imagestim',s);
	is = setparameters(is,ISp);
end;
