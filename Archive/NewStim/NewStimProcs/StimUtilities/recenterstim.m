function S = recenterstim(stim, varargs)

%  Part of the NewStim package
%  NEWSTIM = RECENTERSTIM(STIM,{'rect',[TOPX TOPY BOTX BOTY], ...
%	'screenrect',[SCREENTOPX,SCREENTOPY,SCREENBOTX,SCREENBOTY], ...
%	'params',PARAMS});
%
%  This function recenters STIM so it is presented at the center of the
%  rectangle RECT.  The SCREENRECT of the display screen must be provided to
%  ensure that the stimulus does not run off the screen; if it would run off
%  the screen, then it is adjusted so it is as close to the new location as
%  possible.  If PARAMS is 1, then the stimulus' parameters are changed to
%  reflect the new changes; otherwise, only the image data structures are
%  edited.  It is recommended that one use PARAMS=1 unless one is editing a
%  stimulus that takes a long time to load and one doesn't want to wait for
%  reloading (a stimulus is initialized and unloaded when parameters are
%  changed).
%
%  If the change cannot be made, empty is returned.
%  
%
%  Note:  This function looks for a 'rect' field in the parameters of the
%  stimulus object, so this function will only work for stimulus objects which
%  have this field.
%
%  See also:  CELLSTR, STIMWINDOW, STIMULUS, FOREACHSTIMDO
%rect,
 % check args
if ~(strcmp(varargs{1},'rect')&strcmp(varargs{3},'screenrect')&...
   strcmp(varargs{5},'params')),
	error('Input arguments not correct; see help');
end;
rect = varargs{2}; screenrect = varargs{4}; params = varargs{6};

xmins = min(screenrect([1 3])); xmaxs = max(screenrect([1 3]));
ymins = min(screenrect([2 4])); ymaxs = max(screenrect([2 4]));
xCtr = (0.5 * [ rect(3)+rect(1) ]);
yCtr = (0.5 * [ rect(4)+rect(2) ]);
p = getparameters(stim);
if isfield(p,'rect'),
	r = p.rect;  % gotta be a briefer way than below, but ...
	xmino = min(r([1 3])); xmaxo = max(r([1 3]));
	ymino = min(r([2 4])); ymaxo = max(r([2 4]));
	dx = fix(xCtr - 0.5*(xmaxo+xmino));
	dy = fix(yCtr - 0.5*(ymaxo+ymino));
	w = xmaxo-xmino; h = ymaxo-ymino;
	if dx<0,
		xmino=max(xmino+dx,xmins);
		xmaxo=max(xmaxo+dx,xmins+w);
	else, % dx>=0
		xmino=min(xmino+dx,xmaxs-w);
		xmaxo=min(xmaxo+dx,xmaxs);
	end;
	if dy<0,
		ymino=max(ymino+dy,ymins);
		ymaxo=max(ymaxo+dy,ymins+h);
	else, % dy>=0
		ymino=min(ymino+dy,ymaxs-h);
		ymaxo=min(ymaxo+dy,ymaxs);
	end;
	newrect = [xmino ymino xmaxo ymaxo];
	if params,
		p.rect = newrect;
		cl = class(stim);
		try,
			eval(['ns = ' cl '(p);']);
			S = ns;
		catch,
			% didn't work, so don't update stim
			S = [];
		end;
	else,  % edit displayPrefs
		try,
			dp = getdisplayprefs(stim);
			dp = setvalues(dp,{'rect',newrect});
			S = setdisplayprefs(stim,dp);
		catch,
			S = [];
		end;
	end;
else,   % can't update
	S = [];
end;
