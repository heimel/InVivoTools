function [moviefields] = MovieParamsAdd(varargin)

% MOVIEPARAMSADD - Add movie fields for DisplayTiming/DisplayStimulus
%
%   This function adds the MovieParam fields of more than one stim so that
%   the display occurs _sequentially_.  All MovieParam fields must be present
%   for this function to work.  To fill all of these out with default values,
%   you might call the function MOVIEFIELDS=MOVIEPARAMS2MTI(DS,DF) before
%   calling MOVIEPARAMSADD.
%
%   MOVIEFIELDS = MOVIEPARAMSADD(MOVIEFIELDS1,MOVIEFIELDS2,...)
%
%   See help MOVIEPARAMS2MTI for parameter information.
%   Compare this function with MOVIEPARAMSCAT, which concatenates MOVIEPARAMS
%   to enable simultaneous display of textures. 

if length(varargin)>2,
	moviefields=MovieParamsAdd(varargin{1:end-1},varargin{end});
	return;
end;

mf1 = varargin{1};
mf2 = varargin{2};

 % now have only 2 input arguments

frames1 = size(mf1.Movie_sourcerects,2);
textures1 = size(mf1.Movie_sourcerects,3);
if isempty(mf1.Movie_sourcerects), textures1 = 0; end;
frames2 = size(mf2.Movie_sourcerects,2);
textures2 = size(mf2.Movie_sourcerects,3);
if isempty(mf2.Movie_sourcerects), textures2 = 0; end;

moviefields.Movie_sourcerects = cat(3,mf1.Movie_sourcerects,zeros(4,frames1,textures2));
moviefields.Movie_sourcerects = cat(2,moviefields.Movie_sourcerects, cat(3,zeros(4,frames2,textures1),mf2.Movie_sourcerects));
moviefields.Movie_destrects = cat(3,mf1.Movie_destrects,zeros(4,frames1,textures2));
moviefields.Movie_destrects = cat(2,moviefields.Movie_destrects, cat(3,zeros(4,frames2,textures1),mf2.Movie_destrects));
moviefields.Movie_angles = cat(3,mf1.Movie_angles,zeros(1,frames1,textures2));
moviefields.Movie_angles = cat(2,moviefields.Movie_angles, cat(3,zeros(1,frames2,textures1),mf2.Movie_angles) );
moviefields.Movie_globalalphas = cat(3,mf1.Movie_globalalphas,zeros(1,frames1,textures2));
moviefields.Movie_globalalphas = cat(2,moviefields.Movie_globalalphas, cat(3,zeros(1,frames2,textures1),mf2.Movie_globalalphas) );
n_auxparameters = size(mf1.Movie_auxparameters,1);
moviefields.Movie_auxparameters = cat(3,mf1.Movie_auxparameters,zeros(n_auxparameters,frames1,textures2));
moviefields.Movie_auxparameters = cat(2,moviefields.auxparameters, cat(3,zeros(n_auxparameters,frames2,textures1),mf2.Movie_auxparameters));


for i=1:length(mf1.Movie_textures),
	moviefields.Movie_textures{i} =mf1.Movie_textures{i};
end;
   % add in stim2's textures for each frame, but re-number so it corresponds to the proper textures
for i=length(mf1.Movie_textures)+1:length(mf1.Movie_textures)+length(mf2.Movie_textures),
	moviefields.Movie_textures{i} = textures1+mf2.Movie_textures{i-length(mf1.Movie_textures)};
end;

