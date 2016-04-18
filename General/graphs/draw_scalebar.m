function width_scalebar_in_um=draw_scalebar( umperpixel,varargin)
%DRAW_SCALEBAR draws scale bar in image
%

handle=[];

color=[];

% possible varargins with default values
pos_args={...
	'handle',[],...
	'location','SouthEastInside',...
	'color',[0 0 0],...
	};

assign(pos_args{:});

%parse varargins
nvarargin=length(varargin);
if nvarargin>0
	if rem(nvarargin,2)==1
		warning('DRAW_SCALEBAR:WRONGVARARG','odd number of varguments');
		return
	end
	for i=1:2:nvarargin
		found_arg=0;
		for j=1:2:length(pos_args)
			if strcmp(varargin{i},pos_args{j})==1
				found_arg=1;
				if ~isempty(varargin{i+1})
					assign(pos_args{j}, varargin{i+1});
				end
			end
		end
		if ~found_arg
			warning('DRAW_SCALEBAR:WRONGVARARG',['could not parse argument ' varargin{i}]);
			return
		end
	end
end


if isempty(handle)
	handle=gca;
end

xlim=get(gca,'XLim');
ylim=get(gca,'YLim');
width_figure_in_pixels=xlim(2)-xlim(1);
height_figure_in_pixels=ylim(2)-ylim(1);
width_figure_in_um=width_figure_in_pixels*umperpixel;
width_scalebar_in_um= 10^floor(log10(width_figure_in_um/2));
width_scalebar_in_pixels=width_scalebar_in_um/umperpixel;
if width_scalebar_in_pixels< width_figure_in_pixels/6 %5.2
	width_scalebar_in_um=width_scalebar_in_um*5;
	width_scalebar_in_pixels=width_scalebar_in_pixels*5;
end

height_scalebar_in_pixels=width_scalebar_in_pixels/4;

switch lower(location)
	case 'southeastinside'
		xr=xlim(2)-width_figure_in_pixels/10;
		xl=xr-width_scalebar_in_pixels;
		yb=ylim(2)-width_figure_in_pixels/10;
		yt=yb-height_scalebar_in_pixels;
	otherwise
		warning('DRAW_SCALEBAR:UNKNOWNLOCATION',['unknown location: ' location]);
		% defaulting to southeastinside
		xr=xlim(2)-width_figure_in_pixels/10;
		xl=xr-width_scalebar_in_pixels;
		yb=ylim(2)-width_figure_in_pixels/10;
		yt=yb-height_scalebar_in_pixels;
end

axes(handle);
patch([xl xr xr xl],[yb yb yt yt],color);
%disp(['scale bar = ' num2str(width_scalebar_in_um) ' um']); 
hxlab = get(gca,'xlabel');
if ~isempty(hxlab)
    xlab = get(hxlab,'String');
    if isempty(xlab)
        xlabel([num2str(width_scalebar_in_um) ' um']);
    end
end

return


