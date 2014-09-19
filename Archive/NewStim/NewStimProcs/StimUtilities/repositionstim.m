function S = repositionstim(stim, varargs)

%  Part of the NewStim package
%  NEWSTIM = REPOSITIONSTIM(STIM,{'rect',[TOPX TOPY BOTX BOTY], ...
%	'params',PARAMS});
%
%  This function repositions STIM so it is presented at the rectangle RECT.
%  If PARAMS is 1, then the stimulus' parameters are changed to reflect the new
%  changes; otherwise, only the image data structures are edited.  It is
%  recommended that one use PARAMS=1 unless one is editing a stimulus that
%  takes a long time to load and one doesn't want to wait for reloading (a
%  stimulus is initialized and unloaded when parameters are changed).
%
%  If the change cannot be made, empty is returned.
%  
%
%  Note:  This function looks for a 'rect' field in the parameters of the
%  stimulus object, so this function will only work for stimulus objects which
%  have this field.  In addition, some stimuli classes have requirements about
%  their display sizes which are determined by their other parameters.  This
%  function knows the requirements for stochasticgridstim and blinkingstim, but
%  other classes with requirements may not be adjustable.  In this case, the
%  new rectangle is adjusted so it is smaller than the one given above.
%
%  See also:  CELLSTR, STIMWINDOW, STIMULUS, FOREACHSTIMDO
%rect,
 % check args
if ~(strcmp(varargs{1},'rect')&strcmp(varargs{3},'params')),
	error('Input arguments not correct; see help');
end;
rect = varargs{2}; params = varargs{4};

p = getparameters(stim);
if isfield(p,'rect'),
	r = p.rect;
	proceed = 1;
	switch(class(stim)),
		case {'stochasticgridstim','blinkingstim'},
			xmino = min(rect([1 3])); xmaxo = max(rect([1 3]));
			ymino = min(rect([2 4])); ymaxo = max(rect([2 4]));
			w = xmaxo-xmino; h = ymaxo-ymino;
			px = p.pixSize(1); py = p.pixSize(2);
			if (floor(w./px)<1)|(floor(h./py)<1), proceed = 0;
			else,
				% reduce w, h by mod amount
				w_lr=fix(mod(w,px)/2); h_ur=fix(mod(h,px)/2);
				w_rr = mod(w,px)-w_lr; h_lr = mod(h,px)-h_ur;
				newrect=[xmino+w_lr ymino+h_ur ...
					 xmaxo-w_rr ymaxo-h_lr];
			end;
		otherwise,
			newrect = rect;
	end;
	if proceed,
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
	else, S = []; end; % if proceed
else,   % can't update
	S = [];
end;
