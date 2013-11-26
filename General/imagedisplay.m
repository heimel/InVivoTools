function h = imagedisplay(im, varargin)

%  IMAGEDISPLAY - Display an image and allow user to adjust 
%
%  H = IMAGEDISPLAY(IMAGE, [...] )
%
%  Displays the image IMAGE in the current figure.  There are
%  buttons provided for adjusting the image scale, including
%  an autoscale button.
%
%  One may also provide additional arguments in name/value
%  pairs (e.g., 'InitialScale', [0 255]):
%
%  'InitialScale'   [low high]  the high and low bounds for scaling
%                               (initially [0 255])
%  'AutoScale',     0/1         should autoscale button be visible?
%                               (initially 1)
%  'Units',                     Units of position (e.g., 'pixels'
%                                or 'normalized'; default 'normalized')
%  'Position',                  position of image in figure
%                               (initially [0.1 0.1 0.8 0.8])
%  'ScaleEdits'   0/1          should scale edit boxes be visible?
%                               (initially 1)
%  'Title'                      A title string
%  'fig'                        The figure (new is created by default)


if (size(im,1)==size(im,2))&size(im,1)==1, % then we have a callback object
	command = get(im,'tag');
	refnum = get(im,'userdata');
	fig = get(im,'parent');
elseif isa(im,'char'),
	command = im;
	assign(varargin{:});  % refnum AND fig MUST BE GIVEN AS ARGUMENT HERE
else,
	command = 'NewWindow';
	InitialScale = [ min(min(im)) max(max(im))];
	AutoScale = 1;
	Units = 'normalized';
	Position=[0.1 0.1 0.8 0.8];
	ScaleEdits = 1;
	Title = '';
	fig = 0;
	assign(varargin{:});
	if fig==0, fig = figure; end;
end;

switch command,
	case 'NewWindow',
		frame = uicontrol('Style','frame','units',Units,'position',Position,'visible','off');
		if ScaleEdits,
			axPos = [Position(1) Position(2)+Position(4)*0.2 Position(3) Position(4)*0.8];
		else,
			axPos = Position;
		end;
		button.fontsize = 10; button.fontweight = 'normal';
		button.units = Units; button.BackgroundColor = [ 0.8 0.8 0.8];
		txt = button; txt.Style = 'text';
		button.callback = 'imagedisplay(gcbo);';
		edit = button; edit.horizontalalignment='center'; edit.backgroundColor=[1 1 1];
		edit.style = 'Edit';
		btwid = Position(3)*0.2;
		if strcmp(Units,'pixels'), btheight = 20; else, btheight = 0.15*Position(4); end;
		AutoScalePos = [ Position(1) Position(2) btwid btheight];
		ScaleMinPos = [Position(1)+btwid+0.05*btwid Position(2) btwid btheight];
		ScaleMinEditPos = [Position(1)+2*(btwid+0.05*btwid) Position(2) btwid btheight];
		ScaleMaxPos = [Position(1)+3*(btwid+0.05*btwid) Position(2) btwid btheight];
		ScaleMaxEditPos = [Position(1)+4*(btwid+0.05*btwid) Position(2) btwid btheight];

		refnum = fix(rand*100000);
		if ScaleEdits, vis = 'on'; else, vis = 'off'; end;
		if AutoScale, asvis = 'on'; else, asvis = 'off'; end;
		uicontrol(button,'String','Auto','Position',AutoScalePos,'Tag','AutoScaleBt',...
				'userdata',refnum,'visible',asvis);
		uicontrol(txt,'String','Min:','Position',ScaleMinPos,'userdata',refnum,'visible',vis);
		uicontrol(txt,'String','Max:','Position',ScaleMaxPos,'userdata',refnum,'visible',vis);
		uicontrol(edit,'String',num2str(InitialScale(1)),'Position',ScaleMinEditPos,...
				'userdata',refnum,'Tag','MinEdit','visible',vis);
		uicontrol(edit,'String',num2str(InitialScale(2)),'Position',ScaleMaxEditPos,...
				'userdata',refnum,'Tag','MaxEdit','visible',vis);
		ax = axes('Units',Units,'Position',axPos,'userdata',refnum,'tag','ImageDisplayAxes');
		h=image(im); set(h,'userdata',im);
		title(Title);
		set(ax,'userdata',refnum,'tag','ImageDisplayAxes');
		imagedisplay('DisplayImage','refnum',refnum,'fig',gcf);
	case 'DisplayImage',
		ax = ft(fig,'ImageDisplayAxes',refnum);
		mn = str2num(get(ft(fig,'MinEdit',refnum),'string'));
		mx = str2num(get(ft(fig,'MaxEdit',refnum),'string'));
		if ~isempty(ax),
			titlestr = get(get(gca,'title'),'string');
			rawdata = [];
			ch = get(ax,'children');
			for i=1:length(ch),
				if strcmp(get(ch(i),'Type'),'image')
					rawdata = get(ch(i),'userdata');
					break;
				end;
			end;
			if ~isempty(rawdata),  % if we got it
				delete(ch(i));
				h=image(rescale(rawdata,[mn mx],[0 255]));
				axis equal;
				set(h,'userdata',rawdata);
				set(ax,'userdata',refnum,'tag','ImageDisplayAxes');
				title(titlestr);
			else, % we've got nothing to draw
				warning('no data to draw.');
			end;
			colormap(gray(256));
		end;
	case 'MinEdit',
		imagedisplay('DisplayImage','refnum',refnum,'fig',gcbf);
	case 'MaxEdit',
		imagedisplay('DisplayImage','refnum',refnum,'fig',gcbf);
	case 'AutoScaleBt',
		ax = ft(fig,'ImageDisplayAxes',refnum);
		if ~isempty(ax),
			rawdata = [];
			ch = get(ax,'children');
			for i=1:length(ch),
				if strcmp(get(ch(i),'Type'),'image')
					rawdata = get(ch(i),'userdata');
					break;
				end;
			end;
			if ~isempty(rawdata),  % if we got it
				mn = min(min(rawdata)); mx=max(max(rawdata));
				set(ft(fig,'MinEdit',refnum),'string',num2str(mn));
				set(ft(fig,'MaxEdit',refnum),'string',num2str(mx));
			else, % we've got nothing to draw
				warning('no data.');
			end;
			colormap(gray(256));
		end;
		imagedisplay('DisplayImage','refnum',refnum,'fig',gcbf);
end;

function h=ft(fig,name,ref)
h=findobj(fig,'tag',name,'userdata',ref);
