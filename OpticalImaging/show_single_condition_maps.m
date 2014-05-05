function h=show_single_condition_maps(record,fname,condnames,fileinfo,roi,ror,tit)
%SHOWS_SINGLE_CONDITION_MAPS
%
% 2008, Alexander Heimel
%

h.figure=figure('Name',tit,'NumberTitle','off');
set(h.figure,'PaperType','a4');
pos=get(h.figure,'position');
h_ed=get_fighandle('OI database*');
if ~isempty(h_ed)
	pos_ed=get(h_ed,'Position');
	pos(2)=pos_ed(2)-pos(4)-100;
end
set(h.figure,'position',pos);

colormap gray

% show single condition maps
maps=dir([fname{1} 'single*']);
if ~isempty(maps)
	maps=sort_db(maps);
	showing_online_maps=0;
else
	maps=dir([fname{1} '_map*']);

	
	if ~isempty(maps)
		maps=sort_db(maps);
	end
	showing_online_maps=1;
	disp('PLOTTING ONLINE MAPS');
end
filedir=fileparts(fname{1});
n_maps=length(maps);
if n_maps==0
	disp('COULD NOT FIND ANY MAPS');
	close(h.figure)
	return
end

switch record.stim_type
	case {'retinotopy','rt_response'}
		nx=record.stim_parameters(1);
		ny=record.stim_parameters(2);
 case {'sf_contrast','contrast_sf'}
      nx=length(record.stim_sf);
      ny=length(record.stim_contrast);
 otherwise
		nx=n_maps;
		ny=1;
end

if isempty(condnames)
	condnames=char(ones(n_maps,2));
	for i=1:n_maps
		condnames(i,:)=num2str(i,'%02d');
	end
end


pos([2 3 4])=[pos(2)-ny*300+pos(4)  nx*300 ny*300];

set(h.figure,'position',pos);

% load maps
% immap(:,:) = imread(fullfile(filedir,maps(i).name));
% immap = zeros(size(immap,1),size(immap,2),n_maps);
% for i=1:n_maps
%     immap(:,:,i)=imread(fullfile(filedir,maps(i).name));
% end


uniform_scaling =  true;
scaling = false;
if uniform_scaling && scaling
    immax = 0;
    immin = inf;
    for i=1:n_maps
        [immap,cmap]=imread(fullfile(filedir,maps(i).name));
        disp(['SHOW_SINGLE_CONDITION_MAPS: Loading ' fullfile(filedir,maps(i).name)]);
        tmax = max(immap(:));
        if tmax>immax
            immax = tmax;
        end
        tmin = min(immap(:));
        if tmin<immin
            immin = tmin;
        end
    end
end
if ~scaling
    immax = 255;
    immin = 0;
end

for i=1:n_maps
	h.single_condition(i)=subplot(ny,nx,i);
	[immap,cmap]=imread(fullfile(filedir,maps(i).name));
    
    if ~uniform_scaling
        immax = max(immap(:));
        immin = min(immap(:));
    end
	%draw roi
	immap(image_outline(roi)>0.08)=immax; 
	% draw ror
	immap(image_outline(ror)>0.08)=immin; 
	
    if scaling
        imagesc(double(immap));
    else
        image(immap); colormap gray(255);
    end
    disp(['SHOW_SINGLE_CONDITIONS_MAPS: min = ' num2str(min(immap(:))) ', mean = ' num2str(mean(immap(:))) ...
        ', max = ' num2str(max(immap(:)))]);
	
	if i==n_maps
		draw_scalebar(record.scale*fileinfo.xbin);
	end
	
	if showing_online_maps
		xlabel('O-L MAP');
		set(gca,'xcolor',[1 0 0]);
		set(gca,'ycolor',[1 0 0]);
	else
		if strcmp(record.stim_type,'sf')==0
			xlabel(trim(condnames(i,:)));
		else
			xlabel([trim(condnames(i,:)) ' cpd']);
		end			
	end
	set(gca,'Xtick',[]);
	set(gca,'ytick',[]);
	axis image;
	box on;
end


axes(h.single_condition(1));
htitle=title(tit);
set(htitle,'FontSize',8);
pos=get(htitle,'Position');
set(htitle,'Position',pos);
set(htitle,'HorizontalAlignment','left');
bigger_linewidth(3);
smaller_font(-12);


