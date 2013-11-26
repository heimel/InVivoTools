function newsms = edit_graphical(sms)

newsms = sms;

h0=editfig;

p = getparameters(sms);

set(ft(h0,'RectEdit'),'String',mat2str(p.rect));
set(ft(h0,'BGEdit'),'String',mat2str(p.BG));
set(ft(h0,'NEdit'),'String',num2str(p.N));
set(ft(h0,'FPSEdit'),'String',num2str(p.fps));
set(ft(h0,'ScaleEdit'),'String',num2str(p.scale));
set(ft(h0,'ISIEdit'),'String',num2str(p.isi));
set(ft(h0,'DispPrefsEdit'),'String',wimpcell2str(p.dispprefs));

error_free = 0;
while ~error_free,
	drawnow;
	uiwait(h0);
	if get(ft(h0,'CanButt'),'userdata')==1,
		  error_free = 1;
	else, % it was okay
		rect_str=get(ft(h0,'RectEdit'),'String');
		bg_str = get(ft(h0,'BGEdit'),'String');
		n_str = get(ft(h0,'NEdit'),'String');
		fps_str = get(ft(h0,'FPSEdit'),'String');
		scale_str = get(ft(h0,'ScaleEdit'),'String');
		isi_str = get(ft(h0,'ISIEdit'),'String');
		dp_str = get(ft(h0,'DispPrefsEdit'),'String');

		so = 1; % syntax okay
		try,p.rect=eval(rect_str);
			catch,errordlg('Syntax error in rect');so=0;end;
		try,p.N=eval(n_str);
			catch,errordlg('Syntax error in N');so=0;end;
		try,p.BG=eval(bg_str);
			catch,errordlg('Syntax error in bg');so=0;end;
		try,p.fps=eval(fps_str);
			catch,errordlg('Syntax error in fps');so=0;end;
		try,p.scale=eval(scale_str);
			catch,errordlg('Syntax error in scale');so=0;end;
		try,p.isi=eval(isi_str);
			catch,errordlg('Syntax error in isi');so=0;end;
		try,p.dispprefs=eval(dp_str);
			catch,errordlg('Syntax error in dispprefs');so=0;end;
		if so,
			try,
				sms = setparameters(sms,p);
				error_free = 1;
			catch,
				errordlg(lasterr);
				set(ft(h0,'OKButt'),'userdata',0);
			end;
		end;
	end;
end;

delete(h0);
newsms = sms;

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

