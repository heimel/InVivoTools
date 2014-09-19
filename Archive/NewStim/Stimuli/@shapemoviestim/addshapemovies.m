function newSMS = addshapemovies(thesms,nframemovies, errorcheck)

%  ADDSHAPEMOVIES - Add shape movies to a shapemoviestim object
%
%    newSMS = ADDSHAPEMOVIESS(THESMS, NFRAMEMOVIES, [ERRORCHECK])
%
%  Adds NFRAMEMOVIES to the SHAPEMOVIESTIM object THESMS, with the new object
%  being returned in newSMS.  If ERRORCHECK is 0, then no errorchecking is done
%  on the parameters, which saves a little time but may allow errors on loading.
%  ERRORCHECK is an optional argument with default value 1.
%
%  Each n-frame movie is a cell, so the variable NFRAMEMOVIES is a cell list.
%  Each cell item contains an m-length structure array describing a movie with M
%  shapes.  Each struct contains an element describing one shape with the
%  following fields:
%
%  'type'        |  1=>disk, 2=> gaussian*, 3=>oval*
%  'position'    |  struct w/ elements 'x', and 'y'; the position on the
%                |    screen
%  'onset'       |  the onset time (in frame numbers, starting with 1)
%  'duration'    |  the duration (in number of frames, starting with 1)
%  'size'        |  size (radius for disks, gaussians, ovals)
%  'color'       |  struct w/ elements 'r','g','b' in [0..255] describing color
%  'contrast'    |  Fraction of difference between 'color' and 'BG' that should
%                |    actually be used in drawing the shape
%  'speed'       |  struct w/ elements 'x','y',velocity in pixels/frame
%  'orientation' |  orientation of shape *
%  'eccentricity'|  eccentricity of shape *
%
%  * indicates feature not yet implemented

newSMS = [];
if nargin==3, ec = errorcheck; else, ec = 1; end;

p = getparameters(thesms); clut = p.BG; lastclut = 1;

b = 1;

if ec,
	for i=1:length(nframemovies),
		shapes = nframemovies{i};
		for j=1:length(shapes),
			[b,err]=verifyshape(shapes(j)); if ~b, break; end;
			col=[shapes(j).color.r shapes(j).color.g shapes(j).color.b];
			rcol = p.BG + (col-p.BG)*shapes(j).contrast;
			[a,ai] = intersect(clut,rcol,'rows');
			if isempty(a), % add it
				if lastclut==256,
					b = 0; err = 'Color table cannot have more than 256 entries'; break; end;
				lastclut = lastclut + 1;
				clut(lastclut,:) = rcol;
			end;
		end;
		if ~b, break; end;
	end;
end;

clut = [clut ; zeros(256-lastclut,3)];

if ~b, error(['Could not install movies: ' err]);
else, 
	thesms.nframemovies = nframemovies;
	thesms.clut = clut;
	newSMS = thesms;
end;
