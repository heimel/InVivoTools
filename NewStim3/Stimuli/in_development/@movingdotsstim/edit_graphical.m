function newmds = edit_graphical(mds)

newmds = mds;

h0=editdotsstim;

p = getparameters(mds);

set(ft(h0,'RectEdit'),'String',mat2str(p.rect));
set(ft(h0,'BGEdit'),'String',mat2str(p.BG));
set(ft(h0,'FGEdit'),'String',mat2str(p.FG));
set(ft(h0,'VelocityEdit'),'String',num2str(p.velocity));
set(ft(h0,'FpsEdit'),'String',num2str(p.fps));
set(ft(h0,'AngvelocityEdit'),'String',num2str(p.angvelocity));
set(ft(h0,'DotsizeEdit'),'String',num2str(p.dotsize));
set(ft(h0,'NumdotsEdit'),'String',num2str(p.numdots));
set(ft(h0,'DistanceEdit'),'String',num2str(p.distance));
set(ft(h0,'DirectionEdit'),'String',num2str(p.direction));
set(ft(h0,'CoherenceEdit'),'String',num2str(p.coherence));
set(ft(h0,'DurationEdit'),'String',num2str(p.duration));
set(ft(h0,'NumpatternsEdit'),'String',num2str(p.numpatterns));
set(ft(h0,'LifetimesEdit'),'String',num2str(p.lifetimes));
if eqlen(p.randState,rand('state')),
	set(ft(h0,'RandstateEdit'),'String','rand(''state'')');
else, set(ft(h0,'RandstateEdit'),'String','<use previous randomState value>');
end;
set(ft(h0,'DispPrefsEdit'),'String',wimpcell2str(p.dispprefs));

error_free = 0;
while ~error_free,
	drawnow;
	uiwait(h0);
	if get(ft(h0,'CancelBt'),'userdata')==1,
		  error_free = 1;
	else, % it was okay
		rect_str=get(ft(h0,'RectEdit'),'String');
		bg_str = get(ft(h0,'BGEdit'),'String');
		fg_str = get(ft(h0,'FGEdit'),'String');
		velocity_str = get(ft(h0,'VelocityEdit'),'String');
		fps_str = get(ft(h0,'FpsEdit'),'String');
		angvelocity_str = get(ft(h0,'AngvelocityEdit'),'String');
		dotsize_str = get(ft(h0,'DotsizeEdit'),'String');
		numdots_str = get(ft(h0,'NumdotsEdit'),'String');
		distance_str = get(ft(h0,'DistanceEdit'),'String');
		direction_str = get(ft(h0,'DirectionEdit'),'String');
		coherence_str = get(ft(h0,'CoherenceEdit'),'String');
		duration_str = get(ft(h0,'DurationEdit'),'String');
		numpatterns_str = get(ft(h0,'NumpatternsEdit'),'String');
		lifetimes_str = get(ft(h0,'LifetimesEdit'),'String');
		randstate_str = get(ft(h0,'RandstateEdit'),'String');
		dp_str = get(ft(h0,'DispprefsEdit'),'String');

		so = 1; % syntax okay, will set to 0 if not okay
		try,p.rect=eval(rect_str);
			catch,errordlg('Syntax error in rect');so=0;end;
		try,p.BG=eval(bg_str);
			catch,errordlg('Syntax error in bg');so=0;end;
		try,p.FG=eval(bg_str);
			catch,errordlg('Syntax error in fg');so=0;end;
		try,p.velocity=eval(velocity_str);
			catch,errordlg('Syntax error in velocity');so=0;end;
		try,p.fps=eval(fps_str);
			catch,errordlg('Syntax error in fps');so=0;end;
		try,p.angvelocity=eval(angvelocity_str);
			catch,errordlg('Syntax error in angular velocity');so=0;end;
		try,p.dotsize=eval(dotsize_str);
			catch,errordlg('Syntax error in dot size');so=0;end;
		try,p.numdots=eval(numdots_str);
			catch,errordlg('Syntax error in number of dots');so=0;end;
		try,p.distance=eval(distance_str);
			catch,errordlg('Syntax error in viewing distance');so=0;end;
		try,p.direction=eval(direction_str);
			catch,errordlg('Syntax error in direction');so=0;end;
		try,p.coherence=eval(coherence_str);
			catch,errordlg('Syntax error in coherence');so=0;end;
		try,p.duration=eval(duration_str);
			catch,errordlg('Syntax error in duration');so=0;end;
		try,p.numpatterns=eval(numpatterns_str);
			catch,errordlg('Syntax error in num patterns');so=0;end;
		try,p.lifetimes=eval(lifetimes_str);
			catch,errordlg('Syntax error in lifetimes');so=0;end;
		try,p.dispprefs=eval(dp_str);
			catch,errordlg('Syntax error in dispprefs');so=0;end;
		if ~strcmp(randstate_str,'<use previous randomState value>'),
			try,
				p.randState = eval(randstate_str);
			catch,errordlg('Syntax error in random state');so=0;end;
		end;

		if so,
			try,
				mds = setparameters(mds,p);
				error_free = 1;
			catch,
				errordlg(lasterr);
				set(ft(h0,'OKBt'),'userdata',0);
			end;
		end;
	end;
end;

delete(h0);
newmds = mds;

function h = ft(h1,st)  % shorthand
h = findobj(h1,'Tag',st);

function str = wimpcell2str(theCell)
%1-dim cells only, only chars and matricies
str = '{  ';
for i=1:length(theCell),
	if ischar(theCell{i})
		str = [str '''' theCell{i} ''', '];
	elseif isnumeric(theCell{i}),
		str = [str mat2str(theCell{i}) ', '];
	end;
end;
str = [str(1:end-2) '}'];

