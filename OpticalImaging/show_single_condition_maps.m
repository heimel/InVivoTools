function h=show_single_condition_maps(record,fname,condnames,fileinfo,roi,ror,tit,lims)
%SHOWS_SINGLE_CONDITION_MAPS
%
% 2008-2015, Alexander Heimel
%

if nargin<8
    lims = [];
end
if nargin<7
    tit = '';
end
if nargin<6
    ror = [];
end
if nargin<5
    roi = [];
end
if nargin<4
    fileinfo = [];
end
if nargin<3
    condnames = [];
end
if nargin<2
    fname = '';
end

params = oiprocessparams(record);

if isempty(fname)
    tests=convert_cst2cell(record.test);
    fname = {fullfile(experimentpath(record),tests{1})};
end
if isempty(fileinfo)
    fileinfo=imagefile_info( fullfile(experimentpath(record),...
        [ tests{1} 'B0.BLK']));
end


h.figure=figure('Name',tit,'NumberTitle','off','WindowStyle','normal');
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
maps=dir([fname{1} 'single*.png']);
if ~isempty(maps)
    maps=sort_db(maps);
    showing_online_maps=0;
else
    maps=dir([fname{1} '_map*']);
    if ~isempty(maps)
        maps=sort_db(maps);
    end
    showing_online_maps=1;
    logmsg('Plotting online maps');
end
filedir=fileparts(fname{1});
n_maps=length(maps);
if n_maps==0
    logmsg('Could not find any maps');
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

pos([2 3 4]) = [pos(2)-ny*300+pos(4)  nx*300 ny*300];
set(h.figure,'position',pos);

scaling = false;
if ~scaling
    immax = 255;
    immin = 0;
end

if ny*nx < n_maps
    errormsg(['Loaded more single conditions maps than expected. Only showing ' num2str(ny*nx) '. Delete all single conditions maps from folder']);
    n_maps = ny * nx;
end
    
for i = 1:n_maps
    h.single_condition(i) = subplot(ny,nx,i);
    immap = imread(fullfile(filedir,maps(i).name));
    
    if params.single_condition_show_roi && ~isempty(roi)
        %draw roi
        immap(image_outline(roi)>0.08) = immax;
    end
    if params.single_condition_show_ror  && ~isempty(ror)
        % draw ror
        immap(image_outline(ror)>0.08) = immin;
    end
    
    if scaling
        imagesc(double(immap)); %#ok<UNRCH>
    else
        image(immap); 
        colormap gray(255);
    end
    
    if isfield(fileinfo,'xbin') && ~isempty(fileinfo.xbin)
        if i==n_maps
            draw_scalebar(record.scale*fileinfo.xbin);
        end
    end
    
    if showing_online_maps
        xlabel('O-L MAP');
        set(gca,'xcolor',[1 0 0]);
        set(gca,'ycolor',[1 0 0]);
    else
        if strcmp(record.stim_type,'sf')==0
            %	xlabel(strtrim(condnames(i,:)));
        else
            xlabel([strtrim(condnames(i,:)) ' cpd']);
        end
    end
    set(gca,'Xtick',[]);
    set(gca,'ytick',[]);
    axis image;
    box on;
    
    p = get(h.single_condition(i),'pos');
    p(3) = p(3)+0.02;
    p(4) = p(4)+0.02;
    set(h.single_condition(i),'pos',p);
    
    if ~isempty(lims)
        if length(lims)==1
            zoom(lims);
        else
            axis(lims);
        end
    end
    
    if params.single_condition_show_monitor_center  && ...
            length(record.response)==2 && ...
            strcmpi(record.stim_type,'retinotopy')
        
        % lambda is in unbinned coordinates
        [lambda_x,lambda_y]=get_bregma(record);
        
        % show monitor center
        if params.wta_show_monitor_center
            oi_plot_monitorcenter(record,h.single_condition(i),fileinfo,lambda_x,lambda_y);
        end
    end

end

% intensity bar
filename = [fname{1} 'single_cond_range.asc'];
if exist(filename,'file')
    rang = load(filename,'-ascii'); % loading range for intensity bar
    p = get(gca,'position');
    subplot('position',[p(1)+p(3)+0.03 p(2) 0.98-(p(1)+p(3)+0.03) p(4) ]);
    imagesc((255:-1:0)');
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    %set(gca,'ytick',[1 255]);
    %set(gca,'yticklabel',{num2str(rang(2),2), num2str(rang(1),2)})
    xlabel([num2str(rang(1)*100,2) ' %'])
    title([num2str(rang(2)*100,2) ' %'])
    line([0.5 0.8],[128 128],'color',[0 0 0])
    line([1.2 1.5],[128 128],'color',[0 0 0])
end


axes(h.single_condition(1));
htitle=title(tit);
set(htitle,'FontSize',8);
pos=get(htitle,'Position');
set(htitle,'Position',pos);
set(htitle,'HorizontalAlignment','left');
%bigger_linewidth(3);
smaller_font(-12);

set(gcf,'userdata',h);
