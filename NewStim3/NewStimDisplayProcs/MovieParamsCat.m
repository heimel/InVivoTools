function [moviefields] = MovieParamsCat(varargin)

% MOVIEPARAMSCAT - Concatonate movie fields for DisplayTiming/DisplayStimulus
%
%   This function concatonates the MovieParam fields.  All MovieParam fields
%   must be present for this feature to work.  To fill all of these out with
%   default values, you might call the function
%        MOVIEFIELDS=MOVIEPARAMS2MTI(DS,DF) before calling MOVIEPARAMSCAT.
%
%   MOVIEFIELDS = MOVIEPARAMSCAT(MOVIEFIELDS1,MOVIEFIELDS2,...)
%
%   See help MOVIEPARAMS2MTI for parameter information.

if length(varargin)>2,
	moviefields=MovieParamsCat(varargin{1:end-1},varargin{end});
	return;
end;

mf1 = varargin{1};
mf2 = varargin{2};

 % now have only 2 input arguments
moviefields.Movie_sourcerects = cat(3,mf1.Movie_sourcerects,mf2.Movie_sourcerects);
moviefields.Movie_destrects = cat(3,mf1.Movie_destrects,mf2.Movie_destrects);
moviefields.Movie_angles = cat(3,mf1.Movie_angles,mf2.Movie_angles);
moviefields.Movie_globalalphas = cat(3,mf1.Movie_globalalphas,mf2.Movie_globalalphas);
moviefields.Movie_auxparameters = cat(3,mf1.Movie_auxparameters,mf2.Movie_auxparameters);

for i=1:length(mf1.Movie_textures),
	moviefields.Movie_textures{i} = cat(2,mf1.Movie_textures{i},size(mf1.Movie_sourcerects,3)+mf2.Movie_textures{i}); % changed cat(1 to cat(2
end;


