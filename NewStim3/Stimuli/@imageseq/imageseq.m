function [is] = imageseq(ISp, OLDSTIM)

%  IMAGESEQ - Makes an imageseq
%
%  THEIS = IMAGESEQ(PARAMETERS)
%
%  Creates an imageseq object.  An imageseq displays an image sequence on
%  the screen.
%
%  PARAMETERS can either be the string 'graphical' (which will prompt the user
%  to enter all of the parameter values), the string 'default' (which will
%  use default parameter values), or a structure.  When using 'graphical', one
%  may also use
%
%  IS = IMAGESEQ('graphical',OLDIS)
%
%  where OLDIS is a previously created imageseq object.  This will
%  set the default parameter values to those of OLDIS.
%
%  PARAMETERS describes parameters for the image sequence stimulus.
%
%  If passing a structure, the structure should have the following fields:
%  (dimensions of parameters are given as [M N]; fields are case-sensitive):
%
%  [1x4] rect         - Location of stimulus on screen
%                       [top_x top_y bottom_x bottom_y]
%  [1x3] BG           - Background color [r g b]
%  [1xn] dirname      - Name of directory to search for image files
%  [1x1] fps          - Desired frames per second of display (actual rate
%                        will be closest match offered by stim refresh)
%  [1x1] number_of_images -  the number of images to show; this is provided
%                            so the stim will know how to calculate its 
%                            expected duration even if it doesn't have
%                            access to the image files it will load
% [cell] dispprefs    - Sets displayprefs fields, or use {} for default values.
%
%   Questions to vanhoosr@brandeis.edu

NewStimListAdd('imageseq');

if nargin==0,
	is = imageseq('default');
	return;
end;


is = [];
finish = 1;

if nargin==1, oldstim=[]; else, oldstim = OLDSTIM; end;

if ischar(ISp), % if it is an instruction
	if strcmp(ISp,'graphical'),
		finish = 0;
		sms = edit_graphical(imageseq('default'));
	elseif strcmp(ISp,'default')||strcmp(ISp,''),
		ISp = [];
	else,
		error('Unknown string input to imageseq.');
	end;
else,  % they are parameters
end;

if finish,
	s = stimulus(5);
	is = class(struct('ISparams',[]),'imageseq',s);
	is = setparameters(is,ISp);
end;
