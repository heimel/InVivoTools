function editgraphical(ds, command, thefig)

% EDITGRAPHICAL - View/Edit DIRSTRUCT
%
%  EDITGRAPHICAL(MYDIRSTRUCT)
%
%   Opens a window for viewing and editing a 
%   DIRSTRUCT directory structure.
%
%   See also: DIRSTRUCT

if nargin==1, % 
	ud.ds = ds;
	command = 'NewWindow';
	fig = figure;
	set(fig,'Tag','dirstruct editor','position',[370 194 562 578]);
end;

if nargin==3,  % then is ds, command, and then fig as 3rd arg
	fig = thefig;
	ud = get(fig,'userdata');
end;

if ~isa(command,'char'), 
	% if not a string, then command is a callback object
	command = get(command,'Tag');
	fig = gcbf;

	ud = get(fig,'userdata');
end;

command,

switch command,
	case 'NewWindow',
		button.Units = 'pixels';
		button.BackgroundColor = [0.8 0.8 0.8];
		button.HorizontalAlignment = 'center';
		mycallback = 'editgraphical(getfield(get(gcbf,''userdata''),''ds''),gcbo,gcbf);';
		button.Callback = mycallback;
		txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
		txt.fontsize = 12; txt.fontweight = 'normal';
		txt.HorizontalAlignment = 'center';txt.Style='text';
		edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';
		popup = txt; popup.style = 'popupmenu';
		cb = txt; cb.Style = 'Checkbox'; cb.Callback = mycallback;
		cb.fontsize = 12;

		sh=-80;

		uicontrol(txt,'Units','pixels','position',[10 620+sh 150 25],'string','Dirstruct editor',...
			'fontweight','bold','fontsize',16);
		uicontrol(txt,'position',[10 590+sh-2 65 20],'string','Pathname:');
		uicontrol(edit,'position',[10+65+5 590+sh 400 20],'string',getpathname(ud.ds),'Tag','PathnameEdit');
		uicontrol(button,'position',[10+65+5+410 590+sh 60 20],'string','Update','Tag','UpdateBt');
		uicontrol(txt,'position',[10 520+sh 220 40],'string','Directories:','horizontalalignment','center');
		uicontrol(txt,'position',[250 520+sh 300 40],'string','References:','horizontalalignment','center');
		sh = sh + 40;
		uicontrol('Units','pixels','position',[10 100+sh 220 400],...
			'Style','list','BackgroundColor',[1 1 1],'Tag','dirlist',...
			'Callback',mycallback,'Max',2);
		uicontrol('Units','pixels','position',[250 200+sh 300 300],...
			'Style','list','BackgroundColor',[1 1 1],'Tag','reflist',...
			'Callback',mycallback);
		uicontrol(button,'position',[250 180+sh 70 20],'String','New','Tag','NewRefBt');
		uicontrol(button,'position',[250+70+5 180+sh 70 20],'String','Edit','Tag','EditRefBt');
		uicontrol(button,'position',[250+2*70+5+5 180+sh 70 20],'String','Delete','Tag','DeleteRefBt');
		uicontrol(button,'position',[250 155+sh 200 20],'String','Select directories w/ same reference',...
			'Tag','SelectRefBt');
		uicontrol(button,'position',[10 75+sh 70 20],'String','New','Tag','NewDirBt');
		uicontrol(button,'position',[10+70+5 75+sh 70 20],'String','Hide','Tag','HideDirBt');
		uicontrol(button,'position',[10+2*70+5+5 75+sh 70 20],'String','Delete','Tag','DeleteDirBt');

		set(fig,'userdata',ud);
		editgraphical(ud.ds,'UpdateBt',fig);
	case 'UpdateBt',
		pathname = get(ft(fig,'PathnameEdit'),'string');
		try, newds = dirstruct(pathname);
		catch,
			errordlg(['Error in pathname: ' lasterr '.']);
			newds = [];
		end;
		if ~isempty(newds),
			ud.ds = newds;
			set(fig,'userdata',ud);
			editgraphical(ud.ds,'UpdateDirList',fig);
		end;
	case 'NewRefBt',
		% assume enable/disable will only enable this when it is appropriate
		prompt={'Name','Reference (integer)','Type (e.g., prairietp, singleEC, singleIC, etc)'};
		name = 'Enter new reference item'; numlines = 1;
		defaultanswer = {'tp','1','prairietp'};
		answer = inputdlg(prompt,name,numlines,defaultanswer);
		v = get(ft(fig,'dirlist'),'value');
		dirs = get(ft(fig,'dirlist'),'string'); mydir = dirs{v};  % should be only one by enable/disable
		a = struct('name',answer{1},'ref',fix(str2num(answer{2})),'type',answer{3});
		g = loadStructArray([fixpath(getpathname(ud.ds)) mydir filesep 'reference.txt']);
		g(end+1) = a;
		saveStructArray([fixpath(getpathname(ud.ds)) mydir filesep 'reference.txt'],g);
		editgraphical(ud.ds,'UpdateBt',fig);
	case 'EditRefBt',
		v = get(ft(fig,'dirlist'),'value');
		dirs = get(ft(fig,'dirlist'),'string'); mydir = dirs{v};
		v_ = get(ft(fig,'reflist'),'value');
		refstrs = get(ft(fig,'reflist'),'string');
		g = loadStructArray([fixpath(getpathname(ud.ds)) mydir filesep 'reference.txt']);
		if strcmp(refstrs{v_},[g(v_).name ' | ' num2str(g(v_).ref)]), % check to make sure the same
			prompt={'Name','Reference (integer)','Type (e.g., prairietp, singleEC, singleIC, etc)'};
			name = 'Edit reference item'; numlines = 1;
			defaultanswer = {g(v_).name,num2str(g(v_).ref),g(v_).type};
			answer = inputdlg(prompt,name,numlines,defaultanswer);
			if ~isempty(answer),
				a = struct('name',answer{1},'ref',fix(str2num(answer{2})),'type',answer{3});
				g(v_) = a;
				saveStructArray([fixpath(getpathname(ud.ds)) mydir filesep 'reference.txt'],g);
				editgraphical(ud.ds,'UpdateBt',fig);
			end;
		else, errordlg(['Could not edit...information appears to have changed on disk.  Try Update first.']);
		end;
	case 'DeleteRefBt',
		buttonname = questdlg('Are you sure you want to delete the selected reference?','Are you sure?',...
                                'Yes','Cancel','Yes');
		if strcmp(buttonname,'Yes'),
			v = get(ft(fig,'dirlist'),'value');
			dirs = get(ft(fig,'dirlist'),'string'); mydir = dirs{v};
			v_ = get(ft(fig,'reflist'),'value');
			refstrs = get(ft(fig,'reflist'),'string');
			g = loadStructArray([fixpath(getpathname(ud.ds)) mydir filesep 'reference.txt']);
			if strcmp(refstrs{v_},[g(v_).name ' | ' num2str(g(v_).ref)]), % check to make sure the same
				g = g([1:v_-1 v-1:length(g)]);
				saveStructArray([fixpath(getpathname(ud.ds)) mydir filesep 'reference.txt'],g);
			else,
				errordlg(['Could not delete...information appears to have changed on disk.  Try Update first.']);
			end;
			editgraphical(ud.ds,'UpdateBt',fig);
		end;
	case 'SelectRefBt',
		v = get(ft(fig,'dirlist'),'value');
		dirs = get(ft(fig,'dirlist'),'string'); mydir = dirs{v};
		v_ = get(ft(fig,'reflist'),'value');
		refstrs = get(ft(fig,'reflist'),'string');
		g = loadStructArray([fixpath(getpathname(ud.ds)) mydir filesep 'reference.txt']);
		if strcmp(refstrs{v_},[g(v_).name ' | ' num2str(g(v_).ref)]), % check to make sure the same
			T = gettests(ud.ds,g(v_).name,g(v_).ref);
			v = [];
			for i=1:length(dirs),
				for j=1:length(T),
					if strcmp(T{j},dirs{i}), v(end+1) = i; break; end;
				end;
			end;
			set(ft(fig,'dirlist'),'value',v);
			editgraphical(ud.ds,'UpdateRefList',fig);
		else, errordlg(['Information appears to have changed on disk.  Try Update first.']);
		end;
	case 'NewDirBt',
		prompt={'New directory name: '}; name='New directory name';
		numlines=1; defaultanswer = { newtestdir(ud.ds)  };
		answer = inputdlg(prompt,name,numlines,defaultanswer);
		if ~isempty(answer),
			try,
				mkdir(getpathname(ud.ds),answer{1});
				a = struct('name','','ref','','type',''); a = a([]);
				saveStructArray([getpathname(ud.ds) filesep answer{1} filesep 'reference.txt'],a);
			catch,
				errordlg(['Could not create directory: ' lasterr '.']);
			end;
			editgraphical(ud.ds,'UpdateBt',fig);
		end;
	case 'HideDirBt',
		v = get(ft(fig,'dirlist'),'value');
		dirs = get(ft(fig,'dirlist'),'string');
		path = fixpath(getpathname(ud.ds));
		for i=1:length(v),
			movefile([path dirs{v(i)} filesep 'reference.txt'],...
				[path dirs{v(i)} filesep 'referencebkup.txt']);
		end;
		editgraphical(ud.ds,'UpdateBt',fig);
	case 'DeleteDirBt',
		v = get(ft(fig,'dirlist'),'value');
		dirs = get(ft(fig,'dirlist'),'string');
		if ~isempty(v),
			buttonname = questdlg('Are you sure you want to delete the selected directories?','Are you sure?',...
				'Yes','Cancel','Yes');
			if strcmp(buttonname,'Yes'),
				path = fixpath(getpathname(ud.ds));
				for i=1:length(v),
					try, rmdir([path dirs{v(i)}],'s'); end;
				end;
			end;
			editgraphical(ud.ds,'UpdateBt',fig);
		end;
	case 'UpdateDirList',
		T = getalltests(ud.ds);
		v = get(ft(fig,'dirlist'),'value');
		set(ft(fig,'dirlist'),'string',T);
		if max(v)>length(T), set(ft(fig,'dirlist'),'value',[]); end;
		editgraphical(ud.ds,'UpdateRefList',fig);
	case 'UpdateRefList',
		v = get(ft(fig,'dirlist'),'value');
		if length(v)==1,
			v_ = get(ft(fig,'reflist'),'value');
			str = get(ft(fig,'dirlist'),'string'); 
			dirname = str{v};
			refs = getnamerefs(ud.ds,dirname);
			refstr = {};
			for j=1:length(refs),
				refstr{j} = [refs(j).name ' | ' int2str(refs(j).ref)];
			end;
			if isempty(refstr), refstr = ''; end;
			if ~isempty(v_), if v_>length(refstr), v_ = 1; end; else, v_ = 1; end;
			set(ft(fig,'reflist'),'string',refstr,'value',v_);
		else,
			set(ft(fig,'reflist'),'string','','value',[]);
		end;
		editgraphical(ud.ds,'EnableDisable',fig);
	case 'EnableDisable',
		v = get(ft(fig,'dirlist'),'value');
		v_ = get(ft(fig,'reflist'),'value');str_ = get(ft(fig,'reflist'),'string');
		if length(v)==1&length(v_)==1&isa(str_,'cell'),
			set(ft(fig,'EditRefBt'),'enable','on');
			set(ft(fig,'SelectRefBt'),'enable','on'); set(ft(fig,'DeleteRefBt'),'enable','on');
		else,
			set(ft(fig,'EditRefBt'),'enable','off');
			set(ft(fig,'SelectRefBt'),'enable','off'); set(ft(fig,'DeleteRefBt'),'enable','off');
		end;
		if length(v)>0,
			set(ft(fig,'HideDirBt'),'enable','on');
			set(ft(fig,'DeleteDirBt'),'enable','on');
		else,
			set(ft(fig,'HideDirBt'),'enable','off');
			set(ft(fig,'DeleteDirBt'),'enable','off');
		end;
		if length(v)==1, set(ft(fig,'NewRefBt'),'enable','on'); else, set(ft(fig,'NewRefBt'),'enable','off'); end;
		set(ft(fig,'NewDirBt'),'enable','on');
	case 'dirlist',
		editgraphical(ud.ds,'UpdateRefList',fig);
	case 'reflist',
		editgraphical(ud.ds,'EnableDisable',fig);
	case 'dummy',


		v_ = get(ft(fig,'sliceList'),'value');
		strlist = {};
		for i=1:length(ud.slicelist),
			strlist{i} = ud.slicelist(i).dirname;
		end;
		set(ft(fig,'sliceList'),'string',strlist);
		if v_ > length(strlist),
			if length(strlist)>=1, v = 1;
			else, v = [];
			end;
		elseif isempty(v_), v = 1;
		else, v = v_;
		end;
		set(ft(fig,'sliceList'),'value',v);
		set(ft(fig,'AnalyzeCellsCB'),'value',ud.slicelist(v).analyzecells);
		set(ft(fig,'DrawCellsCB'),'value',ud.slicelist(v).drawcells);
		set(ft(fig,'depthEdit'),'string',num2str(ud.slicelist(v).depth));
		analyzetpstack('UpdatePreviewImage',[],fig);
		analyzetpstack('UpdateCellImage',[],fig);
	case 'UpdateCellList',
		v_ = get(ft(fig,'celllist'),'value');
		strlist = {};
		for i=1:length(ud.celllist),
			strlist{i} = [num2str(ud.celllist(i).index) ' | ' ud.celllist(i).dirname];
		end;
		set(ft(fig,'celllist'),'string',strlist);
		if v_>length(strlist),
			if length(strlist)>=1, v=1;
			else, v=[];
			end;
		elseif isempty(v_), v=1;
		else, v=v_;
		end;
		set(ft(fig,'celllist'),'value',v);
		analyzetpstack('UpdateCellImage',[],fig);
	case 'UpdatePreviewImage', % updates preview image if necessary
		v = get(ft(fig,'sliceList'),'value'),
		dirname = ud.slicelist(v).dirname;
		if ~strcmp(dirname,ud.previewdir),  % we need to update
			if ishandle(ud.previewim), delete(ud.previewim); end;
			ud.previewdir = dirname;
			axes(ft(fig,'tpaxes'));
			try, mn=str2num(get(ft(fig,'ColorMinEdit'),'string'));
			catch, errordlg(['Syntax error in colormin.']); mn=0;
			end;
			try, mx=str2num(get(ft(fig,'ColorMaxEdit'),'string'));
			catch, errordlg(['Syntax error in colormax.']); mx=0;
			end;
			ud.previewim=image(rescale((ud.previewimage{v}),[mn mx],[0 255]));
			colormap(gray(256));
			set(gca,'tag','tpaxes');
			ch = get(gca,'children');
			ind = find(ch==ud.previewim);
			if length(ch)>1,% make on bottom
				ch = cat(1,ch(1:ind-1),ch(ind+1:end),ch(ind));
				set(gca,'children',ch);
			end; 
			set(fig,'userdata',ud);
		end;
	case 'UpdateCellImage',
		cv = get(ft(fig,'celllist'),'value');
		sv = get(ft(fig,'sliceList'),'value');
		newdir = get(ft(fig,'sliceList'),'string');
		newdir = newdir{sv},
			%bg color is red, fg is blue, highlighted is yellow
		if length(ud.celldrawinfo.h)~=length(ud.celllist),
			% might need to draw cells
			% we do when we are drawing for first time
                        % or if we are adding a cell
			if 1+length(ud.celldrawinfo.h)==length(ud.celllist),
				start = length(ud.celllist);
			elseif length(ud.celldrawinfo.h)==0,
				start = 1;
			else,  % maybe we removed some cells
				start = 1;
			end;
			for i=start:length(ud.celllist),
				axes(ft(fig,'tpaxes'));
				hold on;
				xi = ud.celllist(i).xi; xi(end+1) = xi(1);
				yi = ud.celllist(i).yi; yi(end+1) = yi(1);
				ud.celldrawinfo.h(end+1) = plot(xi,yi,'linewidth',2);
				ud.celldrawinfo.t(end+1) = text(mean(xi),mean(yi),...
					int2str(ud.celllist(i).index),...
					'fontsize',12,'fontweight','bold','horizontalalignment','center');
				set(gca,'tag','tpaxes');
				if strcmp(newdir,ud.celllist(i).dirname),
					set(ud.celldrawinfo.h(end),'color',[0 0 1]);
					set(ud.celldrawinfo.t(end),'color',[0 0 1]);
				else,
					set(ud.celldrawinfo.h(end),'color',[1 0 0]);
					set(ud.celldrawinfo.t(end),'color',[1 0 0]);
				end;
			end;
		end;
		if ~strcmp(ud.celldrawinfo.dirname,newdir),
			disp(['Redrawing for new directory.']);
			slicelistlookup.test = [];
			for j=1:length(ud.slicelist),
				slicelistlookup=setfield(slicelistlookup,ud.slicelist(j).dirname,j);
			end;
			% user selected a new directory and we have to recolor
			for i=1:length(ud.celllist),
				if strcmp(ud.celllist(i).dirname,newdir),
					set(ud.celldrawinfo.h(i),'color',[0 0 1]);
					set(ud.celldrawinfo.t(i),'color',[0 0 1]);
					if getfield(ud.slicelist(getfield(slicelistlookup,...
							ud.celllist(i).dirname)),'drawcells'),
						set(ud.celldrawinfo.h(i),'visible','on');
						set(ud.celldrawinfo.t(i),'visible','on');
					else,
						set(ud.celldrawinfo.h(i),'visible','off');
						set(ud.celldrawinfo.t(i),'visible','off');
					end;
				else,
					%disp(['Setting color to red.']);
					set(ud.celldrawinfo.h(i),'color',[1 0 0]);
					set(ud.celldrawinfo.t(i),'color',[1 0 0]);
					if getfield(ud.slicelist(getfield(slicelistlookup,...
							ud.celllist(i).dirname)),'drawcells'),
						set(ud.celldrawinfo.h(i),'visible','on');
						set(ud.celldrawinfo.t(i),'visible','on');
					else,
						set(ud.celldrawinfo.h(i),'visible','off');
						set(ud.celldrawinfo.t(i),'visible','off');
					end;
				end;
			end;
			ud.celldrawinfo.dirname = newdir;
		end;
		highlighted = findobj(ft(fig,'tpaxes'),'color',[1 1 0]);
		[handles,hinds] = intersect(ud.celldrawinfo.h,highlighted);
		%hinds,cv,
		for i=1:length(hinds),
			if hinds(i) ~= cv, % if it shouldn't be highlighted
				if exist('slicelistlookup')~=1,
					slicelistlookup.test = [];
					for j=1:length(ud.slicelist),
						slicelistlookup=...
							setfield(slicelistlookup,ud.slicelist(j).dirname,j);
					end;
				end;
				if strcmp(ud.celldrawinfo.dirname,ud.celllist(hinds(i)).dirname),
					set(ud.celldrawinfo.h(hinds(i)),'color',[0 0 1],'visible','on');
					set(ud.celldrawinfo.t(hinds(i)),'color',[0 0 1],'visible','on');
				else,
					if getfield(ud.slicelist(getfield(slicelistlookup,...
							ud.celllist(hinds(i)).dirname)),'drawcells'),
						vis = 'on';
					else, vis = 'off';
					end;
					set(ud.celldrawinfo.h(hinds(i)),'color',[1 0 0],'visible',vis);
					set(ud.celldrawinfo.t(hinds(i)),'color',[1 0 0],'visible',vis);
				end;
			end;
		end;
        if ~isempty(ud.celldrawinfo.h),
    		set(ud.celldrawinfo.h(cv),'color',[1 1 0],'visible','on');
    		set(ud.celldrawinfo.t(cv),'color',[1 1 0],'visible','on');
        end;
		set(fig,'userdata',ud);
	case 'DrawCellsCB',
		sv = get(ft(fig,'sliceList'),'value');
		ud.slicelist(sv).drawcells = 1-ud.slicelist(sv).drawcells;
		ud.celldrawinfo.dirname = '';
		set(fig,'userdata',ud);
		analyzetpstack('UpdateCellImage',[],fig);
	case 'sliceList',
		analyzetpstack('UpdateSliceDisplay',[],fig);
	case 'celllist',
		analyzetpstack('UpdateCellImage',[],fig);
	case 'addsliceBt',
		ud.ds = update(ud.ds);
		dirlist = getalltests(ud.ds);
		[s,ok] = listdlg('ListString',dirlist);
		if ok==1,
			newslice = emptyslicerec;
			newslice.dirname = dirlist{s};
			numFrames = 50;
			pvimg=previewprairieview([fixpath(getpathname(ud.ds)) filesep newslice.dirname],...
				numFrames,1);
			ud.previewimage = cat(1,ud.previewimage,{pvimg});
			ud.slicelist = [ud.slicelist newslice];
		end;
		ud.slicelist,
		set(fig,'userdata',ud);
		analyzetpstack('UpdateSliceDisplay',[],fig);
	case 'RemoveSliceBt',
		v = get(ft(fig,'sliceList'),'value');
		dirname = get(ft(fig,'sliceList'),'string');
		dirname = dirname{v},
		ud.slicelist = [ud.slicelist(1:(v-1)) ud.slicelist((v+1):end)];
		ud.previewimage = [ud.previewimage(1:(v-1)) ud.previewimage((v+1):end)];
		cellinds = []; celldel = [];
		for i=1:length(ud.celllist),
			if ~strcmp(ud.celllist(i).dirname,dirname),
				cellinds(end+1) = i;
			else, celldel(end+1) = i;
			end;
		end;
		ud.celllist = ud.celllist(cellinds);
		delete(ud.celldrawinfo.h(celldel)); delete(ud.celldrawinfo.t(celldel)); 
		ud.celldrawinfo.h=ud.celldrawinfo.h(cellinds);
		ud.celldrawinfo.t=ud.celldrawinfo.t(cellinds);
		set(fig,'userdata',ud);
		analyzetpstack('UpdateSliceDisplay',[],fig);
		analyzetpstack('UpdateCellList',[],fig);
	case 'drawnewBt',
		v = get(ft(fig,'sliceList'),'value');
		dirname = ud.slicelist(v).dirname;
		figure(fig);
		axes(ft(fig,'tpaxes'));
		zoom off;
		[bw,xi,yi]=roipoly();
		newcell=emptycellrec;
		newcell.dirname = dirname;
		newcell.pixelinds = find(bw);
		newcell.xi = xi; newcell.yi = yi;
		if ~isempty(ud.celllist),
			newcell.index = max([ud.celllist.index])+1;
		else, newcell.index = 1;
		end;
		ud.celllist = [ud.celllist newcell];
		set(fig,'userdata',ud);
		analyzetpstack('UpdateCellList',[],fig);
	case 'drawnewballBt',
		v = get(ft(fig,'sliceList'),'value');
		dirname = ud.slicelist(v).dirname;
		figure(fig);
		axes(ft(fig,'tpaxes'));
		zoom off;
		sz = size(get(ud.previewim,'CData'));
		[blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));
		newballdiastr = get(ft(fig,'newballdiameterEdit'),'string');
		if ~isempty(newballdiastr),
			try, newballdia = eval(newballdiastr);
			catch, newballdia = 8;
			end;
		else, newballdia = 8;
		end;
		rad = round(newballdia/2);
		xi_ = ((-rad):1:(rad));
		yi_p = sqrt(rad^2-xi_.^2);
		yi_m = - sqrt(rad^2-xi_.^2);
		[x,y] = ginput(1);
		while ~isempty(x),
			xi = [xi_ xi_(end:-1:1)]+x;
			yi = [yi_p yi_m(end:-1:1)]+y;
			bw = inpolygon(blankprev_x,blankprev_y,xi,yi);
			%figure; image(bw*255); colormap(gray(256)); figure(fig);
			%hold on; plot(xi,yi,'r','linewidth',2);

			newcell=emptycellrec;
			newcell.dirname = dirname;
			newcell.pixelinds = find(bw);
			newcell.xi = xi; newcell.yi = yi;
			if ~isempty(ud.celllist),
				newcell.index = max([ud.celllist.index])+1;
			else, newcell.index = 1;
			end;
			ud.celllist = [ud.celllist newcell];
			set(fig,'userdata',ud);
			analyzetpstack('UpdateCellList',[],fig);
			ud=get(fig,'userdata');
			figure(fig);
			[x,y]=ginput(1);
		end;
		
	case 'deletecellBt',
		v = get(ft(fig,'celllist'),'value');
		ud.celllist = [ud.celllist(1:(v-1)) ud.celllist((v+1):end)];
		delete(ud.celldrawinfo.h(v)); delete(ud.celldrawinfo.t(v));
		ud.celldrawinfo.h= [ud.celldrawinfo.h(1:(v-1)) ud.celldrawinfo.h((v+1):end)];
		ud.celldrawinfo.t= [ud.celldrawinfo.t(1:(v-1)) ud.celldrawinfo.t((v+1):end)];
		set(fig,'userdata',ud);
		analyzetpstack('UpdateCellList',[],fig);
	case 'depthEdit',
		v = get(ft(fig,'sliceList'),'value');
		try,
			ud.slicelist(v).depth = str2num(get(ft(fig,'depthEdit'),'string'));
		catch, errordlg(['Syntax error in depth. Value not changed.']);
		end;
		set(fig,'userdata',ud);
	case {'AnalyzeParamBt','AnalyzeStimBt'},
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		if strcmp(command,'AnalyzeParamBt'), paramname = get(ft(fig,'stimparamnameEdit'),'string');
		else, paramname = []; end;
		trialsstr = get(ft(fig,'trialsEdit'),'string');
		if ~isempty(trialsstr), trialslist = eval(trialsstr); else, trialslist = []; end;
		timeintstr = get(ft(fig,'timeintEdit'),'string');
		if ~isempty(timeintstr), timeint= eval(timeintstr); else, timeint= []; end;
		sptimeintstr = get(ft(fig,'sptimeintEdit'),'string');
		if ~isempty(sptimeintstr), sptimeint= eval(sptimeintstr); else, sptimeint= []; end;
		blankIDstr = get(ft(fig,'BlankIDEdit'),'string');
		if ~isempty(blankIDstr), blankID = eval(blankIDstr); else, blankID = []; end;
		[listofcells,listofcellnames]=getcurrentcells(ud,refdirname);
		fname = stackname; scratchname = fixpath(getscratchdirectory(ud.ds,1));
		needtorun = 1;
		rawfilename = [scratchname fname '_' dirname '_raw'];
		if exist(rawfilename)==2,
			g = load(rawfilename,'-mat');
			needtorun = ~(g.listofcellnames==listofcellnames);
		end;
		if needtorun,
			[data,t] = readprairieviewdata(fulldirname,[-Inf Inf],listofcells,1);
			save(rawfilename,'data','t','listofcells','listofcellnames','-mat');
			pixelarg = listofcells;
		else,
			pixelarg = load(rawfilename,'-mat');
		end;
		fprintf('Analyzing...will take several seconds...\n');
		paramname,
		resps=prairieviewtuningcurve(fulldirname,paramname,pixelarg,1,listofcellnames,trialslist,timeint,sptimeint,blankID,~isempty(blankID));
		save([scratchname fname '_' dirname],'resps','listofcells','listofcellnames',...
			'dirname','refdirname','paramname','-mat');
	case 'checkDriftBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		trialsstr = get(ft(fig,'trialsEdit'),'string');
		if ~isempty(trialsstr), trialslist = eval(trialsstr); else, trialslist = []; end;
		timeintstr = get(ft(fig,'timeintEdit'),'string');
		if ~isempty(timeintstr), timeint= eval(timeintstr); else, timeint= []; end;
		sptimeintstr = get(ft(fig,'sptimeintEdit'),'string');
		if ~isempty(sptimeintstr), sptimeint= eval(sptimeintstr); else, sptimeint= []; end;
		val = get(ft(fig,'celllist'),'value');
		if strcmp(ud.celllist(val).dirname,refdirname),
			centerloc = [mean(ud.celllist(val).xi)  mean(ud.celllist(val).yi)];
			roirect = round([ -20 -20 20 20] + [centerloc centerloc]);
			roiname=['cell ' int2str(ud.celllist(val).index) ' ref ' ud.celllist(val).dirname];
			myim=prairieviewcheckroidrift(fulldirname,roirect,ud.celllist(val).pixelinds,ud.celllist(val).xi-centerloc(1),...
				ud.celllist(val).yi-centerloc(2),roiname,1);
		else, errordlg(['Selected cell was not recorded in directory ' dirname '.']);
		end;
	case 'movieBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		trialsstr = get(ft(fig,'trialsEdit'),'string');
		if ~isempty(trialsstr), trialslist = eval(trialsstr); else, trialslist = []; end;
		stimstr = get(ft(fig,'movieStimsEdit'),'string');
		if ~isempty(stimstr), stimlist = eval(stimstr); else, stimlist = []; end;
		dF = get(ft(fig,'moviedFCB'),'value'); sorted=get(ft(fig,'movieSortCB'),'value');
		movfname = get(ft(fig,'movieFileEdit'),'string');
		fprintf('Preparing movie...will take several seconds...\n');
		M=prairieviewmovie(fulldirname,trialslist,stimlist,dF,sorted,8,[fixpath(getpathname(ud.ds)) movfname]);
	case 'QuickMapBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		fname = stackname;
		scratchname = fixpath(getscratchdirectory(ud.ds,1));
		try,
			g=load([scratchname fname '_' dirname],'resps','listofcells','listofcellnames',...
			'dirname','refdirname','-mat');
		catch, 
			errordlg(['Can''t open analysis file.  Please analyze data first.']);
			error(['Can''t open analysis file.  Please analyze data first.']);
		end;
		try, thresh = str2num(get(ft(fig,'mapthreshEdit'),'string'));
		catch, errordlg(['Syntax error in map threshold: ' get(ft(fig,'mapthreshEdit'),'string') '.']);
			error(['Syntax error in map threshold: ' get(ft(fig,'mapthreshEdit'),'string') '.']);
		end;
		im=prairieviewquickmap(fulldirname,g.resps,g.listofcells,1,'threshold',thresh);
	case 'QuickPSTHBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		[listofcells,listofcellnames]=getcurrentcells(ud,refdirname);
		fname = stackname; scratchname = fixpath(getscratchdirectory(ud.ds,1));
		needtorun = 1;
		rawfilename = [scratchname fname '_' dirname '_raw'];
		if exist(rawfilename)==2,
			g = load(rawfilename,'-mat');
			needtorun = ~(g.listofcellnames==listofcellnames);
		end;
		if needtorun,
			[data,t] = readprairieviewdata(fulldirname,[-Inf Inf],listofcells,1);
			save(rawfilename,'data','t','listofcells','listofcellnames','-mat');
			pixelarg = listofcells;
		else,
			pixelarg = load(rawfilename,'-mat');
		end;
		binsize = eval(get(ft(fig,'QuickPSTHEdit'),'string'));
		plotit = 1 + get(ft(fig,'QuickPSTHCB'),'value');
		fprintf('Analyzing...will take a few seconds...\n');
		global mydata myt myavg mybins;
		[mydata,myt,myavg,mybins]=prairieviewquickpsth(fulldirname,[],pixelarg,plotit,listofcellnames,binsize);
	case 'baselineBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		[listofcells,listofcellnames]=getcurrentcells(ud,refdirname);
		tpfile = load([fulldirname filesep 'twophotontimes.txt'],'-ascii'),
		fprintf('Analyzing...will take a few seconds...\n');
		[d,t]=readprairieviewdata(fulldirname,[tpfile(2)+5 tpfile(end)-5],listofcells,1);
		figure;
		colors=[ 1 0 0;0 1 0;0 0 1;1 1 0;0 1 1;1 1 1;0.5 0 0;0 0.5 0;0 0 0.5;0.5 0.5 0;0.5 0.5 0.5];
		for i=1:length(ud.celllist),
			hold on;
			ind=mod(i,length(colors)); if ind==0,ind=length(colors); end;
			plot(t{i},d{i},'color',colors(ind,:));
		end;
		legend(listofcellnames);
		ylabel('Raw signal'); xlabel('Time (s)');
	case 'correctDriftBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		fullrefdirname = [fixpath(getpathname(ud.ds)) refdirname];
		[dr,t]=prairieviewdriftcheck(fulldirname,[-6:2:6],[-6:2:6],fullrefdirname,[-100:10:100],[-100:10:100],10,5,1,1);
	case 'ImageMathBt',
		str = get(ft(fig,'ImageMathEdit'),'string');
		op_minus = find(str=='-'); op_plus = find(str=='+');
		op_mult = find(str=='*'); op_divide = find(str=='/');
		op_loc = [ op_minus op_plus op_mult op_divide];
		op = str(op_loc);
		stim1 = str2num(str(1:op_loc-1)); stim2 = str2num(str(op_loc+1:end));
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		fprintf('Analyzing...will take a few seconds...\n');
		[r,im1,im2]=prairieviewimagemath(fulldirname,stim1,stim2,op,1,[dirname ' | ' str]);
        	imagedisplay(im1,'Title',int2str(stim1)); imagedisplay(im2,'Title',int2str(stim2));
	case 'singleCondBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		trialsstr = get(ft(fig,'trialsEdit'),'string');
		if ~isempty(trialsstr), trialslist = eval(trialsstr); else, trialslist = []; end;
		timeintstr = get(ft(fig,'timeintEdit'),'string');
		if ~isempty(timeintstr), timeint= eval(timeintstr); else, timeint= []; end;
		sptimeintstr = get(ft(fig,'sptimeintEdit'),'string');
		if ~isempty(sptimeintstr), sptimeint= eval(sptimeintstr); else, sptimeint= []; end;
		fprintf('Analyzing...will take a few seconds...\n');
		[r,indimages]=prairieviewsinglecondition(fulldirname,trialslist,timeint,sptimeint,1,dirname);
	case 'AddDBBt',
		sv = get(ft(fig,'sliceList'),'value');
		dirname = ud.slicelist(sv).dirname;
		[listofcells,listofcellnames,cellstructs]=getcurrentcells(ud,dirname);
		refs = getnamerefs(ud.ds,dirname);
		foundIt=0;
		for i=1:length(refs), if strcmp(refs(i).name,'tp'), foundIt = i; break; end; end;
		if foundIt>0,
			addtotpdatabase(ud.ds,refs(foundIt),cellstructs,listofcellnames,'analyzetpstack name',stackname);
		else,
			errordlg(['Could not find two-photon reference for directory ' dirname '.']);
		end;
	case 'saveBt',
		fname = stackname;
		scratchname = fixpath(getscratchdirectory(ud.ds,1));
		celllist = ud.celllist; slicelist = ud.slicelist; previewimage = ud.previewimage;
		if exist([scratchname fname '.stack']),
			answer = questdlg('File exists...overwrite?',...
				'File exists...overwrite?','OK','Cancel','Cancel');
			if strcmp(answer,'OK'),
				save([scratchname fname '.stack'],'celllist','slicelist',...
						'previewimage','-mat');
			end;
		else,
			save([scratchname fname '.stack'],'celllist','slicelist','previewimage','-mat');
		end;
	case 'loadBt',
		fname = stackname;
		scratchname = fixpath(getscratchdirectory(ud.ds,1));
		if exist([scratchname fname '.stack']),
			figure(fig);
			clf;
			analyzetpstack('NewWindow',[],fig);
			set(ft(fig,'stacknameEdit'),'string',fname);
			ud = get(fig,'userdata');
			g = load([scratchname fname '.stack'],'-mat');
			ud.celllist=g.celllist;ud.slicelist=g.slicelist;ud.previewimage=g.previewimage;
			set(fig,'userdata',ud);
			analyzetpstack('UpdateSliceDisplay',[],fig);	
		else, errordlg(['File ' scratchname fname '.stack does not exist.']);
		end;
		analyzetpstack('UpdateCellList',[],fig);
		analyzetpstack('UpdateSliceDisplay',[],fig);
	case 'ColorMaxEdit',
		ud.previewdir = '';
		set(fig,'userdata',ud);
		analyzetpstack('UpdatePreviewImage',[],fig);
	case 'ColorMinEdit',
		analyzetpstack('ColorMaxEdit',[],fig);
	otherwise,
		disp(['Unhandled command: ' command '.']);
end;

 % speciality functions

function sr = emptyslicerec
sr = struct('dirname','','depth',0,'drawcells',1,'analyzecells',1);

function cr = emptycellrec
cr = struct('dirname','','pixelinds','','xi','','yi','','index',[]);

function obj = ft(fig, name)
obj = findobj(fig,'Tag',name);

function refdirname = getrefdirname(ud,dirname)
namerefs = getnamerefs(ud.ds,dirname);
match = 0;
for i=1:length(ud.slicelist),
	nr = getnamerefs(ud.ds,ud.slicelist(i).dirname);
	mtch = 1;
	for j=1:length(nr),
		for k=1:length(namerefs),
			mtch=mtch*double((strcmp(nr(j).name,namerefs(k).name)&(nr(j).ref==namerefs(k).ref)));
		end;
	end;
	if mtch==1, match = i; end;
end;
if match~=0, refdirname = ud.slicelist(match).dirname;
else, refdirname ='';
end;

function [listofcells,listofcellnames,cellstructs] = getcurrentcells(ud,refdirname)
listofcells = {}; listofcellnames = {};
cellstructs = emptycellrec; cellstructs = cellstructs([]);
for i=1:length(ud.celllist),
	if strcmp(ud.celllist(i).dirname,refdirname),
		listofcells{end+1} = ud.celllist(i).pixelinds;
		listofcellnames{end+1}=['cell ' int2str(ud.celllist(i).index) ' ref ' ud.celllist(i).dirname];
		cellstructs = [cellstructs ud.celllist(i)];
	end;
end;
