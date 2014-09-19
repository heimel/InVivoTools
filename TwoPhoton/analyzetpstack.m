function fig = analyzetpstack(command, record, thefig, analysis_parameters)
% ANALYZETPSTACK - Analyze two-photon stack
%
%  FIG = ANALYZETPSTACK(COMMAND, RECORD, THEFIG, ANALYSIS_PARAMETERS)
%
%   Opens a window for analyzing a stack of two-photon
%   time series.
%
%   check HELP TP_ORGANIZATION for organization of data
%
% 2007 - 2008, Steve Van Hooser
% 2008 - 2013, Alexander Heimel
%

global shift_state control_state % for short-cut key detection
global savedscript % for sharing visual stimulus with base workspace
%global psth

NUMPREVIEWFRAMES = 300;


drift=[]; %#ok<NASGU>  to mask toolbox function drift

if nargin<4
    analysis_parameters = [];
end

if nargin>2,  % then is command w/ fig as 3rd arg
    fig = thefig;
    if ~isempty(fig)
        ud = get(fig,'userdata');
    end
end


if ~isa(command,'char'),
    % if not a string, then command is a callback object
    command = get(command,'Tag');
    fig = gcbf;
    ud = get(fig,'userdata');
end;


if exist('ud','var') && isfield(ud,'channel')
    if ~isempty(ft(gcf,'stimChannelEdit'))
        %        disp('ANALYZETPSTACK: QUICK AND DIRTY SOLUTION FOR RATIOMETRIC ANALYSIS')
        ud.channel = fix(str2num(get(ft(gcf,'stimChannelEdit'),'string')));  %#ok<ST2NM>
        set(gcf,'userdata',ud);
    end
end


if exist('ud','var') && isfield(ud,'verbose') && ud.verbose
    if exist('fig','var')
        disp(['ANALYZETPSTACK: Command = ' command ', Fig = ' num2str(fig)]);
    else
        disp(['ANALYZETPSTACK: Command = ' command]);
    end
    
end

switch command,
    case 'NewWindow',
        if ~isfield(record,'ROIs')
            record.ROIs = [];
        end
        if ~isfield(record.ROIs,'new_cell_index')
            record.ROIs.new_cell_index = 1;
        end
        
        
        tpsetup(record);
        
        [fig,ud] = draw_analyzetpstack( record, analysis_parameters, tpprocessparams(record) );
        if isempty(fig)
            return
        end
        
        enable_editclick_notification(fig); % to prevent keycapture of edit fields. see http://www.mathworks.com/matlabcentral/fileexchange/34060
        
        % set key capture
        set(fig,'WindowKeyPressFcn',@figure_keypress);
        set(fig,'WindowScrollWheelFcn',@figure_keypress);
        set(fig,'WindowKeyReleaseFcn',@figure_keyrelease);
        set(fig,'WindowButtonDownFcn',@figure_buttondown);
        
        
        ud.verbose = get(ft(fig,'verboseCB'),'value');
        ud.ref_record = tp_get_refrecord(ud.record);
        ud.image_processing.unmixing = get(ft(fig,'unmixingBt'),'value');
        ud.image_processing.spatial_filter = get(ft(fig,'spatialFilterBt'),'value');
        % now make data structures
        slicelist = emptyslicerec;
        ud.slicelist = slicelist([]);
        if ~isfield(record.ROIs,'celllist') || isempty(record.ROIs.celllist)
            celllist = tp_emptyroirec;
            ud.celllist = celllist([]);
        else
            tcelllist = structconvert(record.ROIs.celllist,tp_emptyroirec);
            for i=1:length(tcelllist)
                if ~isempty(tcelllist(i).xi)
                    if isfield(ud,'celllist')
                        ud.celllist(end+1) =tcelllist(i);
                    else
                        ud.celllist =tcelllist(i);
                    end
                end
            end
        end
        control_state = false;
        shift_state = false;
        ud.previewimage = {};
        ud.previewdir = [];
        ud.previewim = [];
        ud.previewchannel = 1;
        ud.recompute_preview = true;
        ud.ztproject = true;
        ud.celldrawinfo.dirname = [];
        ud.celldrawinfo.h = [];
        ud.celldrawinfo.t = [];
        ud.zoom_object = [];
        set(fig,'userdata',ud);
        set(ft(fig,'newcellindexEdit'),'String',num2str(ud.record.ROIs.new_cell_index));
        parse_analysis_parameters( analysis_parameters,fig);
        analyzetpstack('driftcheckmethodPopup',[],fig);
        analyzetpstack('addsliceBt',[],fig);
        analyzetpstack('UpdateSliceDisplay',[],fig);
        analyzetpstack('UpdateCellList',[],fig);
        %        analyzetpstack('loadBt',[],fig);
        set(fig,'ResizeFcn',@figure_resize);
    case 'UpdateSliceDisplay',
        v_ = get(ft(fig,'sliceList'),'value');
        currstr_ = get(ft(fig,'sliceList'),'string');
        if iscell(currstr_) && ~isempty(currstr_)
            selDir = trimws(currstr_{v_});  % currently selected
        else
            selDir = {};
        end;
        inds = [];
        newlist = {};
        currInds = 1:length(ud.slicelist);
        while ~isempty(currInds),
            %parentdir = getrefdirname(ud,ud.slicelist(currInds(1)).dirname);
            parentdir = '.';%getrefdirname(ud,ud.slicelist(currInds(1)).dirname);
            if strcmp(parentdir,ud.slicelist(currInds(1)).dirname),  % if it is a parent directory, find all its kids
                newlist{end+1} = parentdir;
                inds(end+1) = currInds(1);
                currInds = setdiff(currInds,currInds(1));  % we will include this as a parent
                kids = [];
                for j=currInds,
                    myparent = '.';%getrefdirname(ud,ud.slicelist(j).dirname);
                    if strcmp(parentdir,myparent)
                        kids(end+1) = j;
                        newlist{end+1} = ['    ' ud.slicelist(j).dirname];
                        inds(end+1) = j;
                    end;
                end;
                currInds = setdiff(currInds,kids);
            end;
        end;
        littlelist = {};
        for i=1:length(newlist), littlelist{i} = trimws(newlist{i}); end;
        [c,ia]=intersect(littlelist,selDir);
        if ~isempty(c), v = ia(1); else v = 1; end;
        % now to reshuffle the slicelists
        ud.slicelist = ud.slicelist(inds);
        % ud.previewimage = ud.previewimage{inds};
        set(fig,'userdata',ud);
        set(ft(fig,'sliceList'),'string',newlist,'value',v);
        if ~isempty(ud.slicelist)
            set(ft(fig,'DrawROIsCB'),'value',ud.slicelist(v).drawcells);
            if ~isfield(ud.slicelist(v),'drawroinos')
                ud.slicelist(v).drawroinos = 0;
            end
            set(ft(fig,'DrawROINosCB'),'value',ud.slicelist(v).drawroinos);
            set(ft(fig,'sliceOffsetEdit'),'string',['[' num2str(ud.slicelist(v).xyoffset) ']']);
            parentdir = '.';%getrefdirname(ud,trimws(ud.slicelist(v).dirname));
            if ~strcmp(parentdir,trimws(ud.slicelist(v).dirname)),
                set(ft(fig,'sliceOffsetEdit'),'visible','off');
                set(ft(fig,'sliceOffsetText'),'visible','off');
            else
                set(ft(fig,'sliceOffsetEdit'),'visible','on');
                set(ft(fig,'sliceOffsetText'),'visible','on');
            end;
        end;
        analyzetpstack('UpdatePreviewImage',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
        analyzetpstack('UpdateCellLabels',[],fig);
    case 'UpdateCellList',
        v_ = get(ft(fig,'celllist'),'value');
        strlist = {};
        for i=1:length(ud.celllist)
            if ud.celllist(i).present
                present = '+';
            else
                present = '-';
            end
            if isfield(ud.celllist(i),'neurite') && ~isempty(ud.celllist(i).neurite)
                neurite = num2str(ud.celllist(i).neurite(1),'%3d');
            else
                neurite = '   ';
            end
            
            strlist{i} = ...
                [ sprintf('%3s',num2str(ud.celllist(i).index,'%4d')) ' ' ...
                present ' ' ...
                strjust(sprintf('%5s',ud.celllist(i).type(1:min(5,end))),'left') ' ' ...
                neurite ' ' ...
                cell2str(ud.celllist(i).labels,false,false) ' ' ...
                num2str(fix(ud.celllist(i).intensity_mean),' %04d') ' ' ...
                ];
        end;
        set(ft(fig,'celllist'),'string',strlist);
        if isempty(v_)
            v_ = 1;
        end
        v_((v_>length(strlist)))=[];
        v = v_;
        set(ft(fig,'celllist'),'value',v);
        analyzetpstack('UpdateCellLabels',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
        
        
    case {'channel1Tg','channel2Tg','channel3Tg','channel4Tg',...
            'channel5Tg','channel6Tg','channel7Tg','channel8Tg',...
            'channel9Tg',}
        % make sure that there is always a channel on
        channels_on = [];
        for c = 1:9
            channels_on = [channels_on get(ft(fig,['channel' num2str(c) 'Tg']),'value')];
        end
        if ~any(channels_on) % then turn channel 1 on
            set(ft(fig,'channel1Tg'),'value',1)
        end
        
        for c = 1:9
            channel = get(ft(fig,['channel' num2str(c) 'Tg']),'value');
            col = get(ft(fig,['channel' num2str(c) 'Tg']),'backgroundcolor');
            set(ft(fig,['channel' num2str(c) 'Tg']),'backgroundcolor', sign(col) * (channel/2+1/2))
        end
        analyzetpstack('UpdatePreviewImage',[],fig);
    case {'LastFrameEdit','FirstFrameEdit'}
        analyzetpstack('UpdatePreviewImage',[],fig);
        
    case {'UpdatePreviewImage','FrameSlid'} % updates preview image if necessary
        %  axes(ft(fig,'tpaxes')); %#ok<MAXES>
        %  get_zoom_factor(gca);
        get_zoom_factor(ft(fig,'tpaxes'));
        
        ax = axis;
        channels = [];
        for ch=1:9
            
            if get(ft(fig,['channel' num2str(ch) 'Tg']),'value')
                channels = [channels ch];
            end
        end
        for ch = channels
            % read viewing parameters from gui
            mn(ch) = str2double(get(ft(fig,['ColorMin' num2str(ch) 'Edit']),'string'));
            mx(ch) = str2double(get(ft(fig,['ColorMax' num2str(ch) 'Edit']),'string'));
            gamma(ch) = str2double(get(ft(fig,['ColorGamma' num2str(ch) 'Edit']),'string'));
        end
        
        shift_channels = [];
        if isfield(ud.record,'comment') && ~isempty(findstr(lower(ud.record.comment),'pixelshift'))
            ind = findstr(lower(ud.record.comment),'[');
            if isempty(ind)
                iminf = tpreadconfig(ud.record);
                shift_channels = iminf.NumberOfChannels;
            else
                ind2 = findstr(lower(ud.record.comment),']');
                if isempty(ind2)
                    errormsg('Missing closing ] after pixelshift.');
                    return
                end
                shift_channels = str2num(ud.record.comment(ind:ind2)); %#ok<ST2NM>
            end
            compute_pixelshift = true;
        else
            compute_pixelshift = false;
        end
        
        switch ud.ztproject
            case true % z-projection
                if  ud.recompute_preview  % we need to update
                    % ud.previewdir = '.';
                    % compute preview image
                    
                    first = str2double(get(ft(fig,'FirstFrameEdit'),'String'));
                    last = str2double(get(ft(fig,'LastFrameEdit'),'String'));
                    pvimg = tppreview(ud.record,[first last],1,channels,ud.image_processing);
                    pvfilename = tpscratchfilename( ud.record, 1, 'preview');
                    save(pvfilename,'pvimg');
                    im = pvimg;
                    ud.previewimage{1} = im;
                else
                    im = ud.previewimage{1};
                    compute_pixelshift = false;
                end;
            case false % no zt-project, i.e. single slice
                frame = round(get(ft(fig,'FrameSlid'),'value'));
                set(ft(fig,'frameTxt'),'String',num2str(frame));
                % read frame
                for ch = channels
                    im(:,:,ch) = double(squeeze(tpreadframe(ud.record,ch,frame,ud.image_processing)));
                end
        end
        
        %check if need to shift channels
        processparams = tpprocessparams( ud.record );

        iminf = tpreadconfig(ud.record);
        if isfield(processparams,'pixelshift_um') && ~isempty(processparams.pixelshift_um)
            pixelshift = ceil(processparams.pixelshift_um / iminf.x_step);
        else
            pixelshift = processparams.pixelshift_pixel;
        end
            
        
        if compute_pixelshift
            logmsg(['Shifting channel(s) ' mat2str(shift_channels(shift_channels>0)) ' up by ' num2str(pixelshift) ' pixels'])
            for ch=intersect(shift_channels(shift_channels>0),channels)
                temp = im(:,:,ch);
                im(:,:,ch) = reshape(temp([pixelshift+1:end 1:pixelshift]),size(im,1),size(im,2));
            end
            if any(shift_channels<1)
                logmsg(['Shifting channel(s) ' mat2str(-shift_channels(shift_channels<1)) ' left by ' num2str(pixelshift) ' pixels'])
            for ch=intersect(-shift_channels(shift_channels<1),channels)
                temp = im(:,:,ch)';
                im(:,:,ch) = reshape(temp([pixelshift+1:end 1:pixelshift]),size(im,2),size(im,1))';
            end
            end
        end
        
        
        
        if ishandle(ud.previewim)
            delete(ud.previewim);
        end
        ch = get(ft(fig,'tpaxes'),'children');
        for c=ch(:)'
            if strcmp(get(c,'tag'),'preview')
                delete(c);
            end
        end
        
        % make image
        [ud.previewim,mx,mn,gamma] = tp_image(im,channels,mx,mn,gamma,tp_channel2rgb(ud.record),ft(fig,'tpaxes'));
        % set(get(ud.previewim,'parent'),'tag','tpaxes');
        set(ud.previewim,'Tag','preview');
        set(fig,'userdata',ud);
        
        
        %        axes(get(ud.previewim,'parent')); % this here is very slow
        %      axis image
        if sum(ax)~=2 % no preview image yet before call
            axis(ax); % to keep zoom
        end
        
        set(ud.previewim,'ButtonDownFcn',@buttondownfcn_preview)
        
        for ch = channels
            set(ft(fig,['ColorMax' num2str(ch) 'Edit']),'string',num2str(fix(mx(ch))));
            set(ft(fig,['ColorMin' num2str(ch) 'Edit']),'string',num2str(fix(mn(ch))));
            set(ft(fig,['ColorGamma' num2str(ch) 'Edit']),'string',num2str(gamma(ch),2));
        end
        
        
        % drift correction
        xyoffset = getxyoffset(ud);
        set(ud.previewim,...
            'xdata',get(ud.previewim,'xdata')-xyoffset(1),...
            'ydata',get(ud.previewim,'ydata')-xyoffset(2));
        ud.previewchannel = channels;
        set(fig,'userdata',ud);
        
        
        % put children first to show labels and ROIs
        set(gca,'tag','tpaxes');
        ch = get(gca,'children');
        ind = find(ch==ud.previewim);
        if length(ch)>1 && ~isempty(ind),% make on bottom
            ch = cat(1,ch(1:ind-1),ch(ind+1:end),ch(ind));
            set(gca,'children',ch);
            
            % color ROIs
            color_rois( ud.celllist, ud.celldrawinfo,fig);
        end;
        
        zoom_callback( fig,gca)
    case 'UpdateCellImage',
        %cv = get(ft(fig,'celllist'),'value');
        %sv = get(ft(fig,'sliceList'),'value');
        %newdir = get(ft(fig,'sliceList'),'string');
        %newdir = trimws(newdir{sv});
        %parentdir=getrefdirname(ud,newdir);  % is there a parent directory?
        %ancestors=getallparents(ud,newdir);  % is there a parent directory?
        %bg color is red, fg is blue, highlighted is yellow
        if isfield(ud,'cell_indices_changed') && ud.cell_indices_changed == true
            % clear all previous rois and labels
            for i = 1:length(ud.celldrawinfo.h)
                if ishandle(ud.celldrawinfo.h)
                    delete(ud.celldrawinfo.h);
                end;
                if ishandle(ud.celldrawinfo.t)
                    delete(ud.celldrawinfo.t);
                end;
                ud.celldrawinfo.h = [];
                ud.celldrawinfo.t = [];
            end
            ud.cell_indices_changed = false;
        end
        if length(ud.celldrawinfo.h)~=length(ud.celllist)
            % might need to draw cells
            % we do when we are drawing for first time
            % or if we are adding a cell
            drift = getcurrentdirdrift(ud,NUMPREVIEWFRAMES);
            if 1+length(ud.celldrawinfo.h)<=length(ud.celllist),
                start = 1+length(ud.celllist)-(-length(ud.celldrawinfo.h)+length(ud.celllist));
            elseif isempty(ud.celldrawinfo.h)
                start = 1;
            else  % maybe we removed some cells, start over
                if ishandle(ud.celldrawinfo.h)
                    delete(ud.celldrawinfo.h);
                end;
                if ishandle(ud.celldrawinfo.t)
                    delete(ud.celldrawinfo.t);
                end;
                ud.celldrawinfo.h = [];
                ud.celldrawinfo.t = [];
                start = 1;
            end;
            slicelistlookup.test = [];
            for j=1:length(ud.slicelist),
                slicelistlookup.(dir2fieldname(ud.slicelist(j).dirname)) = j;
            end;
            
            axes(ft(fig,'tpaxes')); %#ok<MAXES> necessary for following text
            hold on
            for i=start:length(ud.celllist),
                xi = ud.celllist(i).xi;
                yi = ud.celllist(i).yi;
                zi = median(ud.celllist(i).zi);
                if (~isfield(ud.celllist(i),'dimensions') ||...
                        (ud.celllist(i).dimensions>1)) && ...
                        ~is_linearroi(ud.celllist(i).type)
                    % close ROI
                    xi(end+1) = xi(1);
                    yi(end+1) = yi(1);
                end
                ud.celldrawinfo.h(end+1) = plot(xi-drift(1),yi-drift(2),'linewidth',1);
                set(ud.celldrawinfo.h(end),'tag',num2str(zi)); % set slice
                ud.celldrawinfo.t(end+1) = text(mean(xi)-drift(1),mean(yi)-drift(2),...
                    int2str(ud.celllist(i).index),...
                    'fontsize',12,'fontweight','bold','horizontalalignment','center');
                set(ud.celldrawinfo.t(end),'tag',num2str(zi)); % set slice
                set(gca,'tag','tpaxes');
                
                if ud.slicelist( slicelistlookup.(dir2fieldname(ud.celllist(i).dirname)) ).('drawcells')
                    visstr_rois = 'on';
                else
                    visstr_rois = 'off';
                end;
                if ~isfield(ud.slicelist( slicelistlookup.(dir2fieldname(ud.celllist(i).dirname)) ),'drawroinos')
                    ud.slicelist( slicelistlookup.(dir2fieldname(ud.celllist(i).dirname)) ).('drawroinos') = 0;
                end
                if ud.slicelist( slicelistlookup.(dir2fieldname(ud.celllist(i).dirname)) ).('drawroinos')
                    visstr_roinos = 'on';
                else
                    visstr_roinos = 'off';
                end;
                set(ud.celldrawinfo.h(end),'visible',visstr_rois);
                set(ud.celldrawinfo.t(end),'visible',visstr_roinos);
            end;
        end;
        color_rois( ud.celllist, ud.celldrawinfo,fig);
        set(fig,'userdata',ud);
    case 'UpdateCellLabels'
        if ~isempty(ud.celllist),
            items = get(ft(fig,'celllist'),'value');
            if isempty(items)
                return
            end
            v = items(1);
            [dummy,newvals] = intersect(get(ft(fig,'labelList'),'string'),ud.celllist(v).labels); %#ok<ASGLU>
            types = get(ft(fig,'cellTypePopup'),'string');
            [dummy,newtypev] = intersect(types,ud.celllist(v).type); %#ok<ASGLU>
            if isempty(newtypev)
                types{end+1}=ud.celllist(v).type;
                set(ft(fig,'cellTypePopup'),'string',types);
                [dummy,newtypev] = intersect(types,ud.celllist(v).type); %#ok<ASGLU>
            end
            newpresent = mode([ud.celllist(items).present]);
            multiple_presence_states = ( max([ud.celllist(items).present])~=min([ud.celllist(items).present]));
            
            if  length(items)==1
                set(ft(fig,'roidrawpanel'),'title',['ROI ' num2str(ud.celllist(v).index)])
            else
                set(ft(fig,'roidrawpanel'),'title',['ROI ' num2str(ud.celllist(items(1)).index) '...' num2str(ud.celllist(items(end)).index)])
            end
        else
            newvals = 1;
            newtypev = 1;
            newpresent = 1;
            multiple_presence_states = false;
        end;
        set(ft(fig,'labelList'),'value',newvals);
        set(ft(fig,'cellTypePopup'),'value',newtypev);
        set(ft(fig,'presentCB'),'value',newpresent);
        if multiple_presence_states
            set(ft(fig,'presentCB'),'foregroundcolor',0.5*[1 1 1]);
        else
            set(ft(fig,'presentCB'),'foregroundcolor','black');
        end
    case 'exportROIsBt'
        ud.record.ROIs.celllist = ud.celllist;
        record = ud.record;
        tp_export_rois(record)
    case 'DrawROIsCB',
        sv = get(ft(fig,'sliceList'),'value');
        ud.slicelist(sv).drawcells = 1-ud.slicelist(sv).drawcells;
        ud.celldrawinfo.dirname = '';
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'DrawROINosCB',
        sv = get(ft(fig,'sliceList'),'value');
        ud.slicelist(sv).drawroinos = 1-ud.slicelist(sv).drawroinos;
        ud.celldrawinfo.dirname = '';
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'sliceList'
        analyzetpstack('UpdateSliceDisplay',[],fig);
    case 'celllist'
        center_on_roi(fig);
        analyzetpstack('UpdateCellLabels',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
        
        % sync with others
        if ~isempty(ud.celllist),
            items = get(ft(fig,'celllist'),'value');
            if get(ft(fig,'syncCB'),'value')
                sync2otherslices(ud.record,ud.celllist(items(1)).index);
            end
        end
    case 'remoteCallCelllist'
        center_on_roi(fig);
        analyzetpstack('UpdateCellLabels',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'syncCB'
        analyzetpstack('celllist',[],fig);
    case 'analyseBt'
        ud.record.ROIs.celllist = ud.celllist;
        ud.record = analyse_tptestrecord( ud.record);
        ud.celllist = ud.record.ROIs.celllist;
        set(fig,'userdata',ud);
        analyzetpstack('ResultsBt',[],fig);
        analyzetpstack('UpdateCellList',[],fig);
    case 'moveCellBt'
        v = get(ft(fig,'celllist'),'value');
        if length(v)>1
            disp('Only single ROI can be moved at one time.')
            return
        end
        sv = get(ft(fig,'sliceList'),'value'); currdir = get(ft(fig,'sliceList'),'string'); currdir = trimws(currdir{sv});
        ancestors = {'.'};
        cellisinthisimage = ~isempty(intersect(ud.celllist(v).dirname,ancestors));
        cellisactualcell = strcmp(ud.celllist(v).dirname,currdir);
        if ~cellisinthisimage,
            disp('ANALYZETPSTACK: Cannot move cell whose preview image is not being viewed.');
            return;
        end;
        % at this point, we are going to make a move so let's get the coordinate
        disp('Click new center location.');
        [x,y] = ginput(1);
        sz = size(get(ud.previewim,'CData'));
        [blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));
        drift = getcurrentdirdrift(ud,  NUMPREVIEWFRAMES);
        if cellisactualcell,
            cr = ud.celllist(v);
            cr.xi = ud.celllist(v).xi - mean(ud.celllist(v).xi) + x + drift(1) ;
            cr.yi = ud.celllist(v).yi - mean(ud.celllist(v).yi) + y + drift(2);
            if ~ud.ztproject
                cr.zi = str2double(get(ft(fig,'frameTxt'),'String')); % frame
            end
            bw = inpolygon(blankprev_x,blankprev_y,cr.xi,cr.yi);
            cr.pixelinds = find(bw);
            ud.celllist(v) = cr;
        else
            changes = getChanges(ud,v,currdir,ancestors);
            changes.xi = ud.celllist(v).xi+drift(1)-mean(ud.celllist(v).xi)+x;
            changes.yi = ud.celllist(v).yi+drift(2)-mean(ud.celllist(v).yi)+y;
            if ~ud.ztproject
                changes.zi = str2double(get(ft(fig,'frameTxt'),'String')); % frame
            end
            bw = inpolygon(blankprev_x,blankprev_y,changes.xi,changes.yi);
            changes.pixelinds = find(bw);
            changes.dirname = currdir;
            setChanges(ud,fig,v,changes);
            ud = get(fig,'userdata');
        end;
        ud.cell_indices_changed = true;
        
        ud.celldrawinfo.dirname = '';
        set(fig,'userdata',ud);
        
        analyzetpstack('UpdateCellImage',[],fig);
    case 'newcellindexEdit'
        v = fix(str2double(get(ft(fig,'newcellindexEdit'),'String')));
        ud.record.ROIs.new_cell_index = next_available_cell_index(v-1,ud.celllist );
        set(fig,'userdata',ud);
        set(ft(fig,'newcellindexEdit'),'String',num2str(ud.record.ROIs.new_cell_index));
    case 'redrawCellBt',
        v = get(ft(fig,'celllist'),'value');
        if length(v)>1
            disp('Only single ROI can be redrawn at the time.');
            return
        end
        sv = get(ft(fig,'sliceList'),'value');
        currdir = get(ft(fig,'sliceList'),'string');
        currdir = trimws(currdir{sv});
        ancestors={'.'};%getallparents(ud,currdir);
        cellisinthisimage = ~isempty(intersect(ud.celllist(v).dirname,ancestors));
        cellisactualcell = strcmp(ud.celllist(v).dirname,currdir);
        if ~cellisinthisimage,
            disp('Cannot redraw cell whose preview image is not being viewed.'); return;
        end;
        % at this point, we are going to redraw so let's have the user redraw
        disp('Draw new ROI for cell.');
        axes(ft(fig,'tpaxes')); %#ok<MAXES> necessary for following roipoly
        zoom off;
        [bw,xi,yi]=roipoly();
        % now what happens is different
        drift = getcurrentdirdrift(ud, NUMPREVIEWFRAMES);
        if cellisactualcell
            cr = ud.celllist(v);
            cr.xi = xi+drift(1);
            cr.yi = yi+drift(2);
            cr.pixelinds = find(bw);
            ud.celllist(v) = cr;
        else
            sz = size(get(ud.previewim,'CData'));
            [blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));
            changes = getChanges(ud,v,currdir,ancestors);
            changes.xi = xi+drift(1);
            changes.yi = yi+drift(2);
            bw = inpolygon(blankprev_x,blankprev_y,changes.xi,changes.yi);
            changes.pixelinds = find(bw);
            changes.dirname = currdir;
            setChanges(ud,fig,v,changes);
            ud = get(fig,'userdata');
        end;
        ud.celldrawinfo.dirname = '';
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellImage',[],fig);
        
    case 'maxzBt'
        % take z-frame with maximum intensity as z-component
        % for neurites this is done on a pixel by pixel basis
        % for non-neurites this is done for all pixels together
         v = get(ft(fig,'celllist'),'value');
         
         % get max_of_channel
        str=get(ft(fig,'maxzPopup'),'string');
        max_of_channel = str2num( str{get(ft(fig,'maxzPopup'),'value')} ); %#ok<ST2NM>
        if isempty(max_of_channel)
            errormsg('No channel set for maximum mapping.');
            return
        end
        proj_mode = 1; % mean data for each frame

        verbose = (length(v)==1);
        if ~verbose
            hwaitbar = waitbar(0,'Finding max Z frame...');
        end
        for i=1:length(v)
            if ~verbose
                hwaitbar = waitbar(i/length(v));
            end
            if is_neurite(ud.celllist(v(i)).type)
                % do per pixel
                logmsg('Neurite mapping to max z-projection is not implemented yet.');
            else
                data = tpreaddata(ud.record, [-inf inf], {ud.celllist(v(i)).pixelinds},proj_mode,max_of_channel,verbose);
                [tempmax,frame] = max( data{1} ); %#ok<ASGLU>
                ud.celllist(v(i)).zi = frame*ones(size(ud.celllist(v(i)).xi));
            end
        end
        if ~verbose
            close(hwaitbar);
        end
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'labelList'
        strs = get(ft(fig,'labelList'),'string');
        vals = get(ft(fig,'labelList'),'value');
        v = get(ft(fig,'celllist'),'value');
        for i=1:length(v), ud.celllist(v(i)).labels = strs(vals); end;
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
    case 'cellTypePopup'
        strs = get(ft(fig,'cellTypePopup'),'string');
        val = get(ft(fig,'cellTypePopup'),'value');
        v = get(ft(fig,'celllist'),'value');
        for i=1:length(v), ud.celllist(v(i)).type= strs{val}; end;
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
    case 'presentCB'
        present = get(ft(fig,'presentCB'),'value');
        v = get(ft(fig,'celllist'),'value');
        for i=1:length(v)
            ud.celllist(v(i)).present= present;
        end
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
    case 'addsliceBt',
        dirlist = {'.'};
        s = 1;
        ok = 1;
        if ok==1,
            newslice = emptyslicerec;
            newslice.dirname = dirlist{s};
            pvfilename = tpscratchfilename( ud.record, 1, 'preview');
            % see if we have a preview image already computed, and if not, compute it and save it
            if exist(pvfilename,'file')
                load(pvfilename);
            else
                
                record = ud.record;
                if newslice.dirname~='.'
                    record.slice = newslice.dirname;
                end
            end;
            ud.slicelist = [ud.slicelist newslice];
        end;
        set(fig,'userdata',ud);
    case 'autoDrawCellsBt',
        if ud.zstack
            % for  puncta analysis
            method = 'detect_puncta';
        else
            method = 'MM';
            
        end
        
        v = get(ft(fig,'sliceList'),'value');
        dirname = trimws(ud.slicelist(v).dirname);
        switch method
            case 'MM'
                [dummy,params] = find_cellsMM; %#ok<ASGLU>
                cell_list = find_cellsMM(nanmean(ud.previewimage{v},3),params);
            case 'detect_puncta'
                ud.record.ROIs.celllist = ud.celllist;
                cell_list = tp_detect_puncta( ud.record,ud.image_processing.unmixing );
                
        end
        typestr = get(ft(fig,'cellTypePopup'),'string');
        labelstr = get(ft(fig,'labelList'),'string');
        for i=1:length(cell_list),
            newcell = tp_emptyroirec;
            newcell.dirname = dirname;
            newcell.pixelinds = cell_list(i).pixelinds;
            newcell.xi = cell_list(i).xi;
            newcell.yi = cell_list(i).yi;
            if isfield(ud.celllist,'zi')
                if isfield( cell_list, 'zi')
                    newcell.zi = cell_list(i).zi;
                else
                    newcell.zi = NaN*newcell.xi;
                end
            end
            newcell.type = typestr{get(ft(fig,'cellTypePopup'),'value')};
            newcell.labels= labelstr(get(ft(fig,'labelList'),'value'));
            newcell.index = ud.record.ROIs.new_cell_index;
            ud.celllist = [ud.celllist newcell];
            ud.record.ROIs.new_cell_index = next_available_cell_index( ud.record.ROIs.new_cell_index,ud.celllist);
        end;
        set(ft(fig,'newcellindexEdit'),'String',num2str(ud.record.ROIs.new_cell_index));
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
    case 'drawnewBt',
        if ud.zstack && ud.ztproject
            uiwait(warndlg('Note that you are drawing ROIs in z-projection.','Z-Projection','modal'));
        end
        v = get(ft(fig,'sliceList'),'value');
        dirname = trimws(ud.slicelist(v).dirname);
        dr = getcurrentdirdrift(ud, NUMPREVIEWFRAMES);
        figure(fig);
        axes(ft(fig,'tpaxes')); %#ok<MAXES> necessary for following roipoly
        zoom off;
        [bw,xi,yi] = roipoly();
        newcell = tp_emptyroirec;
        newcell.dirname = dirname;
        newcell.pixelinds = find(bw);
        newcell.xi = xi+dr(1);
        newcell.yi = yi+dr(2);
        if ud.ztproject % i.e. no z specified
            newcell.zi = NaN * xi;
        else % set current frame as z
            frame = round(get(ft(fig,'FrameSlid'),'value'));
            newcell.zi = frame * ones(size( xi));
        end
        
        
        % get intensity
        if ~ud.ztproject % i.e. no z specified
            im = ud.previewimage{1};
            for ch = 1:size( im, 3)
                imc = im(:,:,ch);
                newcell.intensity_mean(ch) = mean( imc(newcell.pixelinds) );
                newcell.intensity_max(ch) = max( imc(newcell.pixelinds) );
            end
            disp(['Mean intensity: ' num2str(fix(newcell.intensity_mean)) ]);
        end
        
        typestr = get(ft(fig,'cellTypePopup'),'string');
        newcell.type = typestr{get(ft(fig,'cellTypePopup'),'value')};
        labelstr = get(ft(fig,'labelList'),'string');
        newcell.labels= labelstr(get(ft(fig,'labelList'),'value'));
        newcell.index = ud.record.ROIs.new_cell_index;
        
        ud.celllist = [ud.celllist newcell];
        ud.record.ROIs.new_cell_index = next_available_cell_index( ud.record.ROIs.new_cell_index,ud.celllist);
        set(ft(fig,'newcellindexEdit'),'String',num2str(ud.record.ROIs.new_cell_index));
        set(ft(fig,'celllist'),'value',length(ud.celllist)); % select new ROI
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
    case 'drawnewballBt',
        disp('Click on Enter to stop drawing.');
        
        if ud.zstack && ud.ztproject
            uiwait(warndlg('Note that you are drawing ROIs in z-projection.','Z-Projection','modal'));
        end
        
        v = get(ft(fig,'sliceList'),'value');
        dirname = trimws(ud.slicelist(v).dirname);
        dr = getcurrentdirdrift(ud, NUMPREVIEWFRAMES);
        sz = size(get(ud.previewim,'CData'));
        [blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));
        newballdiastr = get(ft(fig,'newballdiameterEdit'),'string');
        if ~isempty(newballdiastr),
            newballdia = str2double(trim(newballdiastr));
            if isnan(newballdia)
                newballdia = 12;
            end;
        else
            newballdia = 12;
        end;
        set(ft(fig,'newballdiameterEdit'),'string',num2str(newballdia));
        rad = round(newballdia/2);
        xi_ = ((-rad):1:(rad));
        yi_p = sqrt(rad^2-xi_.^2);
        yi_m = - sqrt(rad^2-xi_.^2);
        figure(fig);
        axes(ft(fig,'tpaxes')); %#ok<MAXES> % necessary for ginput
        zoom off;
        
        % get snap_to_channel
        str=get(ft(fig,'snaptoPopup'),'string');
        snap_to_channel = str2num( str{get(ft(fig,'snaptoPopup'),'value')} ); %#ok<ST2NM>
        
        
        [x,y,button] = ginput(1);
        while ~isempty(x) && button==1 % as long as not empty (enter) and left click
            newcell = tp_emptyroirec;
            newcell.dirname = dirname;
            
            xi = [xi_ xi_(end:-1:1)]+x+dr(1);
            yi = [yi_p yi_m(end:-1:1)]+y+dr(2);
            bw = inpolygon(blankprev_x,blankprev_y,xi,yi);
            pixelinds = find(bw);
            
            if ud.ztproject % i.e. no z specified
                newcell.zi = NaN * ones(1,2*length( xi_));
            else
                frame = round(get(ft(fig,'FrameSlid'),'value'));
                if ~isempty(snap_to_channel)
                    % find maximum z-projection
                    proj_mode = 1; % mean data for each frame
                    
                    % NOTE: tpreaddata does not use image processing
                    data = tpreaddata(ud.record, [max(1,frame-2) frame+2], {pixelinds},proj_mode,snap_to_channel);
                    [tempmax,maxframe] = max( data{1} ); %#ok<ASGLU>
                    frame = maxframe + max(1,frame-2);
                    goto_frame( frame,fig );
                    ud=get(fig,'userdata');
                end
                newcell.zi = frame * ones(1,2*length( xi_));
            end
            
            if ~isempty(snap_to_channel)
                % find maximum intensity pixel
                im = ud.previewimage{1}(:,:,snap_to_channel);
                [tempmax,m_ind] = max(im(pixelinds)); %#ok<ASGLU>
                [y,x] = ind2sub(size(im),pixelinds(m_ind));
                xi = [xi_ xi_(end:-1:1)]+x+dr(1);
                yi = [yi_p yi_m(end:-1:1)]+y+dr(2);
                bw = inpolygon(blankprev_x,blankprev_y,xi,yi);
                pixelinds = find(bw);
            end
            
            if ~ud.ztproject % i.e. no z specified
                % get intensity
                for ch = 1:size( ud.previewimage{1}, 3)
                    imc = double(squeeze(tpreadframe(ud.record,ch,frame,ud.image_processing)));
                    newcell.intensity_mean(ch) = mean( imc(pixelinds) );
                    newcell.intensity_max(ch) = max( imc(pixelinds) );
                end
                disp(['Mean intensity: ' num2str(fix(newcell.intensity_mean)) ]);
            end
            
            newcell.pixelinds = pixelinds;
            newcell.xi = xi;
            newcell.yi = yi;
            
            typestr = get(ft(fig,'cellTypePopup'),'string');
            newcell.type = typestr{get(ft(fig,'cellTypePopup'),'value')};
            labelstr = get(ft(fig,'labelList'),'string');
            newcell.labels = labelstr(get(ft(fig,'labelList'),'value'));
            newcell.present = get(ft(fig,'presentCB'),'value');
            newcell.index = ud.record.ROIs.new_cell_index;
            if isempty(ud.celllist)
                ud.celllist = newcell;
            else
                ud.celllist = [ud.celllist newcell];
            end
            ud.record.ROIs.new_cell_index = next_available_cell_index( ud.record.ROIs.new_cell_index,ud.celllist);
            set(ft(fig,'newcellindexEdit'),'String',num2str(ud.record.ROIs.new_cell_index));
            set(fig,'userdata',ud);
            set(ft(fig,'celllist'),'value',length(ud.celllist)); % select new ROI
            analyzetpstack('UpdateCellList',[],fig);
            ud=get(fig,'userdata');
            figure(fig);
            [x,y,button]=ginput(1);
        end;
    case 'drawNeuriteBt',
        logmsg('Click on Enter to stop drawing. Right click removes last point.');
        logmsg('Default neurite type can be set in tpprocessparams.');
        
        if ud.zstack && ud.ztproject
            uiwait(warndlg('Note that you are drawing in z-projection.','Z-Projection','modal'));
        end
        
        v = get(ft(fig,'sliceList'),'value');
        dirname = trimws(ud.slicelist(v).dirname);
        dr = getcurrentdirdrift(ud, NUMPREVIEWFRAMES);
        sz = size(get(ud.previewim,'CData'));
        
        [blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));
        
        newballdiastr = get(ft(fig,'newballdiameterEdit'),'string'); % used for snapping to local max
        if ~isempty(newballdiastr),
            newballdia = str2double(trim(newballdiastr));
            if isnan(newballdia)
                newballdia = 6;
            end;
        else
            newballdia = 6;
        end;
        
        newneurite = tp_emptyroirec(ud.record);
        newneurite.dirname = dirname;
        
        rad = round(newballdia/2);
        xi_ = ((-rad):1:(rad));
        yi_p = sqrt(rad^2-xi_.^2);
        yi_m = - sqrt(rad^2-xi_.^2);
        figure(fig);
        axes(ft(fig,'tpaxes')); %#ok<MAXES> necessary for ginput
        zoom off;
        
        [x,y,button] = ginput(1);
        h_temp_line = [];
        
        % get snap_to_channel
        str=get(ft(fig,'snaptoPopup'),'string');
        snap_to_channel = str2num( str{get(ft(fig,'snaptoPopup'),'value')} ); %#ok<ST2NM>
        
        if button~=1 % not left click
            x = []; % i.e. do not enter next loop
        end
        
        while ~isempty(x),
            switch button
                case 1
                    xi = [xi_ xi_(end:-1:1)]+x+dr(1);
                    yi = [yi_p yi_m(end:-1:1)]+y+dr(2);
                    bw = inpolygon(blankprev_x,blankprev_y,xi,yi);
                    pixelinds = find(bw);
                    
                    if ud.ztproject % i.e. no z specified
                        frame = NaN;
                    else
                        if isempty(snap_to_channel)
                            % set current frame as z
                            frame = round(get(ft(fig,'FrameSlid'),'value'));
                        else
                            % find maximum z-projection
                            proj_mode = 1; % mean data for each frame
                            data = tpreaddata(ud.record, [-inf inf], {pixelinds},proj_mode,snap_to_channel);
                            [tempmax,frame] = max( data{1} ); %#ok<ASGLU>
                            goto_frame( frame,fig );
                            ud=get(fig,'userdata');
                        end
                    end
                    
                    if isempty(snap_to_channel)
                        channel = 1; % only used for siez of image
                    else
                        channel = snap_to_channel;
                    end
                    
                    im = ud.previewimage{1}(:,:,channel);
                    if ~isempty(snap_to_channel)
                        % find maximum intensity pixel
                        [tempmax,m_ind] = max(im(pixelinds)); %#ok<ASGLU>
                        [y,x] = ind2sub(size(im),pixelinds(m_ind));
                    end
                    
                    % confine to image
                    x = min(x,size(im,2));
                    x = max(1,x);
                    y = min(y,size(im,1));
                    y = max(1,y);
                    
                    newneurite.pixelinds(end+1) = sub2ind(size(im),y,x);
                    newneurite.xi(end+1) = x;
                    newneurite.yi(end+1) = y;
                    newneurite.zi(end+1) = frame;
                    
                    center_at_position([x y],fig);
                    
                    if ishandle(h_temp_line)
                        delete(h_temp_line);
                    end
                    h_temp_line = line(newneurite.xi,newneurite.yi,'color',[1 1 0]);
                case 28
                    move_slice_up;
                    ud = get(fig, 'userdata');
                case 29
                    move_slice_down;
                    ud = get(fig, 'userdata');
                otherwise              % remove last point
                    newneurite.pixelinds = newneurite.pixelinds(1:end-1);
                    newneurite.xi = newneurite.xi(1:end-1);
                    newneurite.yi = newneurite.yi(1:end-1);
                    newneurite.zi = newneurite.zi(1:end-1);
                    if ~isempty(newneurite.xi)
                        center_at_position( [newneurite.xi(end) newneurite.yi(end)],fig );
                        delete(h_temp_line);
                        h_temp_line = line(newneurite.xi,newneurite.yi,'color',[1 1 0]);
                    end
            end
            figure(fig);
            [x,y,button] = ginput(1);
            
            
            
        end;
        delete(h_temp_line);
        processparams = tpprocessparams( ud.record );
        newneurite.type = processparams.newneuritetype;
        
        labelstr = get(ft(fig,'labelList'),'string');
        newneurite.labels = labelstr(get(ft(fig,'labelList'),'value'));
        newneurite.present = get(ft(fig,'presentCB'),'value');
        newneurite.index = ud.record.ROIs.new_cell_index;
        
        
        newneurite.neurite = [NaN tp_get_neurite_length(newneurite,ud.record) ];
        
        if isempty(ud.celllist)
            ud.celllist = newneurite;
        else
            ud.celllist = [ud.celllist newneurite];
        end
        ud.record.ROIs.new_cell_index = next_available_cell_index( ud.record.ROIs.new_cell_index,ud.celllist);
        set(ft(fig,'newcellindexEdit'),'String',num2str(ud.record.ROIs.new_cell_index));
        set(fig,'userdata',ud);
        set(ft(fig,'celllist'),'value',length(ud.celllist)); % select new ROI
        analyzetpstack('UpdateCellList',[],fig);
    case 'deletecellBt',
        if ~isempty(ud.celllist)
            items = get(ft(fig,'celllist'),'value');
            items = sort(items,2,'descend');
            while ~isempty(items)
                v=items(1);
                items = items(2:end);
                
                ud.celllist = [ud.celllist(1:(v-1)) ud.celllist((v+1):end)];
                delete(ud.celldrawinfo.h(v));
                delete(ud.celldrawinfo.t(v));
                if isfield(ud.celldrawinfo,'changes'),
                    if length(ud.celldrawinfo.changes)>=v,
                        ud.celldrawinfo.changes = ud.celldrawinfo.changes([1:(v-1) (v+1):length(ud.celldrawinfo.changes)]);
                    end;
                end;
                ud.celldrawinfo.h= [ud.celldrawinfo.h(1:(v-1)) ud.celldrawinfo.h((v+1):end)];
                ud.celldrawinfo.t= [ud.celldrawinfo.t(1:(v-1)) ud.celldrawinfo.t((v+1):end)];
            end
            if v>length(ud.celldrawinfo.h) && v>1
                set(ft(fig,'celllist'),'value',v-1);
            end
            set(fig,'userdata',ud);
            analyzetpstack('UpdateCellList',[],fig);
        end
    case 'StimulusBt'
        stims = getstimsfile( ud.record );
        if isempty(stims)
            % create stims file
            stiminterview(record);
            stims = getstimsfile( record );
        end;
        savedscript = stims.saveScript;
        %[s.mti,starttime]=tpcorrectmti(s.mti,record);
        do = getDisplayOrder(savedscript);
        getparameters(savedscript)
        disp(['ANALYZETPSTACK: ' num2str(length(do)) ' stimuli. Script available as ''savedscript''']);
        evalin('base','global savedscript');
    case 'sliceOffsetEdit',
        v = get(ft(fig,'sliceList'),'value');
        xyoffset = str2num(get(ft(fig,'sliceOffsetEdit'),'string')); %#ok<ST2NM>
        if ~eqlen(size(xyoffset),[1 2]), error('xyoffset wrong size.'); end;
        ud.slicelist(v).xyoffset = xyoffset;
        ud.previewdir = '';
        ud.celldrawinfo.dirname = '';
        set(fig,'userdata',ud);
        analyzetpstack('UpdatePreviewImage',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
    case {'AnalyzeParamBt','AnalyzeRawBt','ExportRawBt','AnalyzePatternsBt','QuickPSTHBt'}
        % get epoch to read and analyze
        epochsstr = get(ft(fig,'epochsEdit'),'string');
        if ~isempty(trim(epochsstr))
            epochslist = split(epochsstr);
        else
            epochslist = {ud.record.epoch};
        end
        
        for i = 1:length(epochslist) % construct array with record for each epoch
            records(i) = ud.record; %#ok<*AGROW>
            records(i).epoch = epochslist{i};
        end
        
        timeintstr = get(ft(fig,'timeintEdit'),'string');
        if ~isempty(trim(timeintstr))
            timeint= eval(timeintstr);
        else
            timeint = [];
        end;
        %         sptimeintstr = get(ft(fig,'sptimeintEdit'),'string');
        %         if ~isempty(trim(sptimeintstr))
        %             sptimeint= eval(sptimeintstr);
        %         else
        %             sptimeint= [];
        %         end;
        [listofcells,listofcellnames,selected_cells] = getpresentcells(ud,fig);
        if isempty(listofcells)
            disp('No cells are present. Nothing to compute');
            return
        end
        
        channel = ud.channel;
        procfilename = tpscratchfilename( records, channel, 'proc');
        recompute = get(ft(fig,'recomputeCB'),'value');
        
        % if processed data file does not exist, we need to recompute
        if ~exist(procfilename,'file')
            recompute = true;
        end
        
        if ~recompute
            % check if current cellnames are identical to stored ones
            g = load(procfilename,'-mat');
            recompute = ~(g.listofcellnames==listofcellnames);
            if ~recompute
                recompute = ~eqlen(g.listofcells,listofcells);
            end;
            process_params = g.process_params;
        end
        
        params = tpreadconfig(records);
        
        if ~recompute
            disp(['loading processed data scratch file: ' procfilename]);
            load(procfilename,'-mat');
        else % recompute
            reread = false;
            rawfilename = tpscratchfilename( records, channel, 'raw');
            if ~exist( rawfilename, 'file')
                reread = true;
            end
            if ~reread
                g = load(rawfilename,'-mat');
                reread = ~(g.listofcellnames==listofcellnames);
                if ~reread
                    reread = ~eqlen(g.listofcells,listofcells);
                end;
            end
            if reread
                [data,t] = tpreaddata(records,[-Inf Inf],listofcells,1,channel);
                save(rawfilename,'data','t','listofcells','listofcellnames','params','-mat');
            else
                logmsg('Loading raw data scratch file');
                load(rawfilename,'-mat');
            end
            process_params = tpprocessparams(ud.record);
            process_params.detect_events_time = 'peak';
            [data,t] = tpsignalprocess(process_params, data, t);
            save(procfilename,'data','t','listofcells','listofcellnames','params','process_params','-mat');
        end
        
        % use only selected cells
        data = data(:,selected_cells);
        t = t(:,selected_cells);
        listofcells = listofcells(:,selected_cells);
        listofcellnames = listofcellnames(:,selected_cells);
        
        switch command
            case 'AnalyzePatternsBt'
                methodind = get(ft(fig,'patternanalysisPopup'),'value');
                methods = get(ft(fig,'patternanalysisPopup'),'String');
                method = methods{ methodind };
                analyze_tppatterns(method, data, t, listofcells, listofcellnames, params(1), process_params, timeint);
            case 'AnalyzeRawBt'
                tpplotdata( data, t, listofcells, listofcellnames, params(1), process_params, timeint,'',ud.record);
            case 'ExportRawBt'
                tp_export_raw( data, t, ud.record);
            case 'AnalyzeParamBt' % tuning
                pixelarg.data = data;
                pixelarg.listofcells = listofcells;
                pixelarg.listofcellnames = listofcellnames;
                pixelarg.t = t;
                
                % get trials to analyze
                trialsstr = get(ft(fig,'trialsEdit'),'string');
                if ~isempty(trim(trialsstr))
                    trialslist = split(trialsstr);
                else
                    trialslist = [];
                end;
                
                % get blankID
                blankIDstr = get(ft(fig,'BlankIDEdit'),'string');
                if ~isempty(trim(blankIDstr))
                    blankID = eval(blankIDstr);
                else
                    blankID = [];
                end;
                
                % get parameter to group for tuning curve. empty -> stim#
                paramname = trim(get(ft(fig,'stimparamnameEdit'),'string'));
                
                if ~isempty(paramname)
                    ud.record.variable = paramname;
                end
                ud.record.ROIs.celllist = ud.celllist;
                
                ud.record = analyse_tptestrecord(ud.record);
                ud.celllist = ud.record.ROIs.celllist;
                
                set(fig,'userdata',ud);
                analyzetpstack('ResultsBt',[],fig);
        end
        set(ft(fig,'recomputeCB'),'value',0);
    case 'ResultsBt'
        [~,~,selected_cells] = getpresentcells(ud,fig);
        temprecord = ud.record;
        temprecord.measures = temprecord.measures(selected_cells);
        results_tptestrecord(temprecord);
    case 'infoBt'
        tpstackinfo(ud.record);
    case 'checkDriftBt',
        dirname = tpdatapath(ud.record);
        %refdirname = tpdatapath(ud.ref_record);
        %epochsstr = get(ft(fig,'epochsEdit'),'string');
        %if ~isempty(epochsstr), epochslist = eval(epochsstr); else epochslist = []; end;
        %timeintstr = get(ft(fig,'timeintEdit'),'string');
        %if ~isempty(timeintstr), timeint= eval(timeintstr); else timeint= []; end;
        %sptimeintstr = get(ft(fig,'sptimeintEdit'),'string');
        %if ~isempty(sptimeintstr), sptimeint= eval(sptimeintstr); else sptimeint= []; end;
        val = get(ft(fig,'celllist'),'value');
        %        if strcmp(ud.celllist(val).dirname,refdirname),
        ancestors = {'.'};%getallparents(ud,dirname);
        changes = getChanges(ud,val,dirname,ancestors);
        if ~changes.present
            errordlg('Cell is not ''present'' in this recording.');
            return;
        end
        centerloc = [mean(changes.xi)  mean(changes.yi)];
        roirect = round([ -20 -20 20 20] + [centerloc centerloc]);
        roiname=['cell ' int2str(ud.celllist(val).index) ' ref ' ud.celllist(val).dirname];
        tpcheckroidrift(ud.record,ud.channel,roirect,changes.pixelinds,changes.xi-centerloc(1),...
            changes.yi-centerloc(2),roiname,1);
    case 'closeFiguresBt'
        close_figs;
    case 'checkAlignmentBt'
        sliceind1 = get(ft(fig,'sliceList'),'value');
        currstr_ = get(ft(fig,'sliceList'),'string');
        if iscell(currstr_) && ~isempty(currstr_)
            dirname1 = trimws(currstr_{sliceind1});  % currently selected
        else
            disp('No directories in list to examine.');
            return;
        end;
        sliceind2 = listdlg('ListString',currstr_,'PromptString','Select dir to compare','SelectionMode','single');
        if isempty(sliceind2)
            return;
        else
            dirname2 = trimws(currstr_{sliceind2});
        end;
        ancestors2 = {'.'};%getallparents(ud,dirname2);
        ancestors1 = {'.'};%getallparents(ud,dirname1);
        if isempty(intersect(dirname1,ancestors2))
            error(['Error checking alignment: ' dirname1 ' and ' dirname2 ' are not recordings at the same place.']);
        end;
        [listofcells1,listofcellnames1,mycellstructs,changes1] = getcurrentcellschanges(ud,dirname1,ancestors1); %#ok<ASGLU>
        [listofcells2,listofcellnames2,mycellstructs,changes2] = getcurrentcellschanges(ud,dirname2,ancestors2); %#ok<ASGLU>
        [thelist,thelistinds1,thelistinds2] = intersect(listofcellnames1,listofcellnames2); %#ok<ASGLU>
        if ud.channel~=1
            pvimg1 = eval(['ud.previewimage' num2str(ud.channel) '{sliceind1};']);
        else
            pvimg1 = ud.previewimage{sliceind1};
        end
        if ud.channel~=1
            pvimg2 = eval(['ud.previewimage' num2str(ud.channel) '{sliceind2};']);
        else
            pvimg2 = ud.previewimage{sliceind2};
        end
        drift1 = getcurrentdirdrift(ud,NUMPREVIEWFRAMES);
        drift2 = getcurrentdirdrift(ud,NUMPREVIEWFRAMES);
        plottpcellalignment(listofcellnames1(thelistinds1),listofcellnames2(thelistinds2),changes1(thelistinds1),changes2(thelistinds2),...
            pvimg1,pvimg2,dirname1,dirname2,drift1,drift2,3);
    case 'movieBt',
        trialsstr = trim(get(ft(fig,'trialsEdit'),'string'));
        if ~isempty(trialsstr), trialslist = eval(trialsstr); else trialslist = []; end;
        stimstr = trim(get(ft(fig,'movieStimsEdit'),'string'));
        if ~isempty(stimstr), stimlist = eval(stimstr); else stimlist = []; end;
        dF = get(ft(fig,'moviedFCB'),'value');
        sorted=get(ft(fig,'movieSortCB'),'value');
        
        processparams = tpprocessparams(ud.record);
        
        movietype = processparams.movietype; %'plain';
        movfname = [ud.record.date '_' ud.record.epoch '_' get(ft(fig,'movieFileEdit'),'string') '_' movietype];
        movfname = fullfile(tpdatapath(ud.record),movfname);
        fprintf('Preparing movie...will take several seconds...\n');
        cfg = tpreadconfig( ud.record );
        movie_sync_factor = 1.02;
        fps = 1/cfg.frame_period * movie_sync_factor;
        disp(['ANALYZETPSTACK: Using movie_sync_factor ' num2str(movie_sync_factor) ]);
        
        
        tpmovie(ud.record,ud.channel,trialslist,stimlist,sorted,dF,fps,movfname,movietype);
    case 'QuickMapBt'
        %         paramname = trim(get(ft(fig,'stimparamnameEdit'),'string'));
        %         scratchname = tpscratchfilename(ud.record,[],['analysis_' paramname]);
        %         if ~exist(scratchname,'file')
        %             analyzetpstack('AnalyzeParamBt',[],fig);
        %         end
        %         if ~exist(scratchname,'file')
        %             errordlg('Can''t open analysis file.  Please analyze data first by calculating tuning.');
        %             return
        %         end
        %         g = load(scratchname,'resps','listofcells','listofcellnames','-mat');
        thresh = str2double(get(ft(fig,'mapthreshEdit'),'string'));
        listofcells = getpresentcells(ud,fig);
        tpquickmap(ud.record,ud.channel,ud.record.measures,listofcells,1,'threshold',thresh);
        %     case 'baselineBt',
        %         dirname = get(ft(fig,'stimdirnameEdit'),'string');
        %         %refdirname = getrefdirname(ud,dirname);
        %         %fulldirname = [fixpath(getpathname(ud.ds)) dirname];
        %         ancestors = getallparents(ud,dirname);
        %         [listofcells,listofcellnames] = getcurrentcellschanges(ud,dirname,ancestors);
        %         %tpfile = load([fulldirname filesep 'twophotontimes.txt'],'-ascii'),
        %         fprintf('Analyzing...will take a few seconds...\n');
        %         %[d,t]=tpreaddata(fulldirname,[tpfile(2)+5 tpfile(end)-5],listofcells,1,channel);
        %         [d,t] = tpreaddata(record,[0 Inf],listofcells,1,ud.channel);
        %         figure;
        %         colors=[ 1 0 0;0 1 0;0 0 1;1 1 0;0 1 1;1 1 1;0.5 0 0;0 0.5 0;0 0 0.5;0.5 0.5 0;0.5 0.5 0.5];
        %         for i=1:length(ud.celllist),
        %             hold on;
        %             ind=mod(i,length(colors)); if ind==0,ind=length(colors); end;
        %             plot(t{i},d{i},'color',colors(ind,:));
        %         end;
        %         legend(listofcellnames);
        %         ylabel('Raw signal'); xlabel('Time (s)');
    case 'correctDriftBt'
        tpdriftcheck(ud.record,ud.channel,ud.ref_record,ud.driftcorrectionmethod,1,1);
    case 'ImageMathBt'
        str = get(ft(fig,'ImageMathEdit'),'string');
        op_minus = find(str=='-');
        op_plus = find(str=='+');
        op_mult = find(str=='*');
        op_divide = find(str=='/');
        op_loc = [ op_minus op_plus op_mult op_divide];
        op = str(op_loc);
        if length(op_loc)>1
            disp('ANALYZETPSTACK: too many mathematical operators');
            return
        end
        stim1 = str2double(str(1:op_loc-1));  %#ok<BDSCI>
        stim2 = str2double(str(op_loc+1:end)); %#ok<BDSCI>
        dirname = get(ft(fig,'stimdirnameEdit'),'string');
        fprintf('Analyzing...will take a few seconds...\n');
        [r,im1,im2] = tpimagemath(ud.record,ud.channel,stim1,stim2,op,1,[dirname ' | ' str]); %#ok<ASGLU>
        imagedisplay(im1,'Title',int2str(stim1)); axis image
        imagedisplay(im2,'Title',int2str(stim2)); axis image
    case 'singleCondBt'
        trialsstr = trim(get(ft(fig,'trialsEdit'),'string'));
        if ~isempty(trialsstr), trialslist = eval(trialsstr); else trialslist = []; end;
        timeintstr = trim(get(ft(fig,'timeintEdit'),'string'));
        if ~isempty(timeintstr), timeint= eval(timeintstr); else timeint= []; end;
        sptimeintstr = trim(get(ft(fig,'sptimeintEdit'),'string'));
        if ~isempty(sptimeintstr), sptimeint= eval(sptimeintstr); else sptimeint= []; end;
        fprintf('Analyzing...will take a few seconds...\n');
        [r,indimages] = tpsinglecondition(ud.record,ud.channel,trialslist,timeint,sptimeint,1);  %#ok<NASGU>
        scratchfilename = tpscratchfilename(ud.record,[],'single_condition');
        save(scratchfilename,'r','indimages','-mat');
    case 'clearScratchBt'
        scratchfilename = tpscratchfilename(ud.record,[],'*');
        delete(scratchfilename);
        
        image_processing.unmixing = 1;
        image_processing.spatial_filter = 1;
        filename = tpfilename( ud.record, [], [], image_processing);
        if exist(filename,'file')
            delete( filename );
        end
        image_processing.unmixing = 0;
        image_processing.spatial_filter = 1;
        filename = tpfilename( ud.record, [], [], image_processing);
        if exist(filename,'file')
            delete( filename );
        end
        image_processing.unmixing = 1;
        image_processing.spatial_filter = 0;
        filename = tpfilename( ud.record, [], [], image_processing);
        if exist(filename,'file')
            delete( filename );
        end
        
        ud.record.measures = [];
        set(fig,'userdata',ud);
    case 'saveBt'
        scratchfilename = tpscratchfilename(ud.record,[],'stack');
        slicelist = ud.slicelist; %#ok<NASGU>
        ud.record.ROIs.celllist = ud.celllist;
        record = ud.record;
        changes = {}; %#ok<NASGU>
        if isfield(ud.celldrawinfo,'changes')
            changes = ud.celldrawinfo.changes; %#ok<NASGU>
        end;
        save(scratchfilename,'slicelist','changes','record','-mat');
        
        % check to see if TP database is open
        h_db = get_fighandle('TP database*');
        if isempty( h_db ) %
            wrndlg('TP database is not open. Not exporting');
        else
            db_ud = get(h_db,'userdata');
            
            commentfilt = record.comment;
            commentfilt(commentfilt==',') = '*';
            ind = find_record( db_ud.db, ['mouse=' record.mouse ',date=' record.date ...
                ',stack=' record.stack ',epoch=' record.epoch ',comment=' commentfilt]);
            if isempty(ind)
                
                ind = find_record( db_ud.db, ['mouse=' record.mouse ',date=' record.date ...
                    ',epoch=' record.epoch ',comment=' commentfilt]);
                if length(ind)==1 && isempty(db_ud.db(ind).stack)
                    % ok, probably just defaulted to Live_0000
                else
                    ind = [];
                end
            end
            
            
            if isempty(ind)
                disp('ANALYZETPSTACK: could not find record in twophoton database. Adding record to end of database.');
                ind = length(db_ud.db)+1;
            elseif length(ind)>1
                disp('ANALYZETPSTACK: found more than one record in twophoton database. Updating first');
                ind = ind(1);
            end
            db_ud.db(ind) = record;
            db_ud.changed = 1;
            set(h_db,'userdata',db_ud);
            control_db_callback(db_ud.h.filter);
            
            control_db_callback(db_ud.h.current_record);
            disp('ANALYZETPSTACK: Stored record in database');
        end
        if ud.verbose
            disp(record);
        end
    case 'loadBt',
        scratchfilename = tpscratchfilename( ud.record,[],'stack');
        if exist(scratchfilename,'file')
            g = load( scratchfilename,'-mat');
            % update slicelist version if necessary
            if length(g.slicelist)>=1,
                if ~isfield(g.slicelist(1),'xyoffset'),
                    newlist = g.slicelist(1);
                    newlist.xyoffset = [0 0];
                    newlist=newlist([]);
                    for i=1:length(g.slicelist),
                        newentry = g.slicelist(i);
                        newentry.xyoffset = [0 0];
                        newlist(i) = newentry;
                    end;
                    g.slicelist = newlist;
                end;
            end;
            if isfield(g,'record') && isempty(ud.record.ROIs)
                % if no ROIs in current record, use saved record, necessary
                % when database is not used
                ud.record= g.record;
            end
            set(ft(fig,'ref_epochEdit'),'string',ud.record.ref_epoch);
            if isfield(ud.record,'ROIs') && isfield( ud.record.ROIs,'celllist')
                ud.celllist=ud.record.ROIs.celllist;
            else
                ud.celllist = [];
                ud.celllist.index = [];
                ud.celllist = ud.celllist([]);
            end
            if ~isfield(ud.record,'ROIs') || ~isfield(ud.record.ROIs,'new_cell_index') || isempty(ud.record.ROIs.new_cell_index)
                ud.record.ROIs.new_cell_index = max([ud.celllist(:).index])+1;
                set(ft(fig,'newcellindexEdit'),'String',num2str(ud.record.ROIs.new_cell_index));
            end
            ud.slicelist=g.slicelist;
            if isfield(g,'changes'), ud.celldrawinfo.changes = g.changes; end;
        end;
        set(ft(fig,'newcellindexEdit'),'String',num2str(ud.record.ROIs.new_cell_index));
        
        if ud.verbose
            ud.record;
        end
        set(fig,'userdata',ud);
        
        analyzetpstack('UpdateCellList',[],fig);
        analyzetpstack('UpdateSliceDisplay',[],fig);
    case {'ColorMin1Edit','ColorMax1Edit','ColorGamma1Edit',...
            'ColorMin2Edit','ColorMax2Edit','ColorGamma2Edit',...
            'ColorMin3Edit','ColorMax3Edit','ColorGamma3Edit',...
            'ColorMin4Edit','ColorMax4Edit','ColorGamma4Edit'}
        ud.previewdir = '';
        set(fig,'userdata',ud);
        analyzetpstack('UpdatePreviewImage',[],fig);
    case 'ref_epochEdit',
        ud.record.ref_epoch=get(ft(fig,'ref_epochEdit'),'string');
        ud.ref_record = tp_get_refrecord( ud.record.ref_epoch);
        %ud.ref_record.ref_epoch = ud.record.ref_epoch;
        set(fig,'userdata',ud);
    case 'stimChannelEdit'
        ud.channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string'))); %#ok<ST2NM>
        set(fig,'userdata',ud);
    case 'driftcheckmethodPopup'
        driftcorrectionmethods = get(ft(fig,'driftcheckmethodPopup'),'string');
        val = get(ft(fig,'driftcheckmethodPopup'),'value');
        ud.driftcorrectionmethod = driftcorrectionmethods{val};
        set(fig,'userdata',ud);
    case 'zoomBt'
        if get(ft(fig,'zoomBt'),'value')
            set(ft(fig,'panBt'),'value',0)
            axes(ft(fig,'tpaxes')); %#ok<MAXES>
            if isempty(ud.zoom_object)
                ud.zoom_object = zoom;
                set(ud.zoom_object,'ActionPostCallback',@zoom_callback);
            end
            set(ud.zoom_object,'Enable','on');
            zoom on;
        else
            set(ud.zoom_object,'Enable','off');
            zoom off;
        end
        set(fig,'userdata',ud);
        zoom_callback(fig, ft(fig,'tpaxes') );
    case 'zoomOutBt'
        axes(ft(gcf,'tpaxes')); %#ok<MAXES>
        zoom out;
        zoom_callback(fig, ft(fig,'tpaxes') );
    case 'panBt'
        if get(ft(fig,'panBt'),'value')
            set(ft(fig,'zoomBt'),'value',0)
            axes(ft(fig,'tpaxes')); %#ok<MAXES>
            set(ud.zoom_object,'Enable','off');
            pan;
        else
            pan off
        end
    case 'signalprocessPopup'
        set(ft(fig,'recomputeCB'),'value',1); % setup recompute checkbox
    case 'ZTProjectTB'
        toggled = false;
        switch get(ft(fig,'ZTProjectTB'),'value')
            case 0
                set(ft(fig,'FrameSlid'),'visible','on')
                set(ft(fig,'frameTxt'),'visible','on')
                
                set(ft(fig,'FirstFrameEdit'),'visible','off');
                set(ft(fig,'LastFrameEdit'),'visible','off');
                set(ft(fig,'FirstFrameTxt'),'visible','off');
                set(ft(fig,'LastFrameTxt'),'visible','off');
                if ud.ztproject
                    toggled = true;
                end
                ud.ztproject = false;
            case 1
                set(ft(fig,'FrameSlid'),'visible','off')
                set(ft(fig,'frameTxt'),'visible','off')
                set(ft(fig,'FirstFrameEdit'),'visible','on');
                set(ft(fig,'LastFrameEdit'),'visible','on');
                set(ft(fig,'FirstFrameTxt'),'visible','on');
                set(ft(fig,'LastFrameTxt'),'visible','on');
                if ~ud.ztproject
                    toggled = true;
                end
                ud.ztproject = true;
        end
        if toggled
            %colormin = str2double(get(ft(fig,'ColorMin1Edit'),'String'));
            %colormax = str2double(get(ft(fig,'ColorMax1Edit'),'String'));
            %colorgamma = str2double(get(ft(fig,'ColorGamma1Edit'),'String'));
            %set(ft(fig,'ColorMin1Edit'),'String',num2str(ud.colormin_prev))
            %set(ft(fig,'ColorMax1Edit'),'String',num2str(ud.colormax_prev))
            %set(ft(fig,'ColorGamma1Edit'),'String',num2str(ud.colorgamma_prev))
            %ud.colormin_prev = colormin;
            %ud.colormax_prev = colormax;
            %ud.colorgamma_prev = colorgamma;
            ud.recompute_preview = true;
        end
        set(fig,'userdata',ud);
        analyzetpstack('UpdatePreviewImage',[],fig);
        
    case 'matchRefBt' % match ROIs with reference epoch
        match_linked = get(ft(fig,'matchLinkedCB'),'Value');
        match_unique = get(ft(fig,'matchUniqueCB'),'Value');
        
        
        ud.record = tp_match_rois_with_reference( ud.record, match_unique, match_linked );
        ud.cell_indices_changed = true;
        ud.celllist = structconvert(ud.record.ROIs.celllist,tp_emptyroirec);
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
        analyzetpstack('UpdateSliceDisplay',[],fig);
    case 'alignRefBt' % align with reference epoch
        ud.record = tp_align_with_reference( ud.record );
        ud.cell_indices_changed = true;
        set(fig,'userdata',ud);
    case 'verboseCB'
        ud.verbose=get(ft(fig,'verboseCB'),'Value');
        set(fig,'userdata',ud);
    case 'spatialFilterBt'
        ud.image_processing.spatial_filter = get(ft(fig,'spatialFilterBt'),'Value');
        ud.recompute_preview = true;
        set(fig,'userdata',ud);
        analyzetpstack('UpdatePreviewImage',[],fig);
    case 'unmixingBt'
        ud.image_processing.unmixing = get(ft(fig,'unmixingBt'),'Value');
        ud.recompute_preview = true;
        set(fig,'userdata',ud);
        analyzetpstack('UpdatePreviewImage',[],fig);
    case 'histogramBt'
        tp_histogram( ud.record, ud.image_processing);
    case 'importRefROIsBt'
        button = 'Keep';
        
        current_celllist = [];
        current_new_cell_index = 1;
        
        if ~isempty(ud.celllist)
            button = questdlg('What to do with current ROIs?',...
                'Replace current ROIs',...
                'Delete all','Keep','Cancel','Cancel');
            if strcmp(button,'Cancel')
                return
            end
            if strcmp(button,'Keep')
                disp('ANALYZETPSTACK: Current ROIs are kept and reference ROIs with unique numbers are added as not present.');
                current_celllist = ud.celllist;
                current_new_cell_index = ud.record.ROIs.new_cell_index;
            end
            if strcmp(button,'Delete all')
                disp('ANALYZETPSTACK: All current ROIs are removed.');
                current_celllist = [];
                current_new_cell_index = 1;
            end
            
        end
        
        [ud.celllist,ud.record.ROIs.new_cell_index] = import_ref_rois(ud.record);
        
        if strcmp(button,'Keep')
            disp('ANALYZETPSTACK: adding new imported ROIs to existing as not-present');
            
            params = tpreadconfig(ud.record); % for image stepsizes
            
            imported_celllist = ud.celllist;
            ud.celllist = current_celllist;
            if ~isempty(current_celllist)
                
                present_in_both_index = ...
                    intersect([current_celllist(logical([current_celllist.present])).index],...
                    [imported_celllist(logical([imported_celllist.present])).index]);
                
                
                present_in_both = [];
                for i=1:length(present_in_both_index)
                    single_pres_in_both = find([imported_celllist.index]==present_in_both_index(i));
                    if length(single_pres_in_both)>1
                        errordlg('Imported celllist has a duplicate index. Not importing all.');
                        disp('ANALYZETPSTACK: Imported celllist has a duplicate index. Not importing all.');
                        return
                    end
                    present_in_both(i) = single_pres_in_both;
                end
                
                for i=1:length(imported_celllist)
                    % check if index is not already present in current ROIlist
                    if isempty(find( [current_celllist(:).index]==imported_celllist(i).index,1))
                        disp(['ANALYZETPSTACK: importing ROI# ' num2str(imported_celllist(i).index) ]);
                        if isfield(params,'z_step')
                            z_step = params.z_step;
                        else
                            z_step = 0;
                        end
                        
                        % find closeby ROIs to correct location
                        r = roi_center(imported_celllist(i));
                        d = get_ROI_distance( imported_celllist(present_in_both),r,[params.x_step params.y_step z_step]);
                        ind_closeby = [];
                        neighborhood_for_location_transform = 1; % in um
                        while length(ind_closeby)<10 &&  neighborhood_for_location_transform<50
                            ind_closeby = present_in_both(d<neighborhood_for_location_transform);
                            neighborhood_for_location_transform = neighborhood_for_location_transform+1; % in um
                        end
                        
                        dr = [];
                        for j = 1:length(ind_closeby)
                            or = roi_center(imported_celllist(ind_closeby(j)));
                            current_ind = find([current_celllist.index]==imported_celllist(ind_closeby(j)).index,1);
                            nr = roi_center(current_celllist(current_ind));
                            dr(j,:) = nr-or;
                        end
                        new_roi = imported_celllist(i);
                        if length(ind_closeby)>2
                            new_roi.xi = new_roi.xi + mean(dr(:,1));
                            new_roi.yi = new_roi.yi + mean(dr(:,2));
                            new_roi.zi = new_roi.zi + mean(dr(:,3));
                        end
                        new_roi.present = 0;
                        ud.celllist(end+1) = new_roi;
                    end
                end
            else
                ud.celllist = imported_celllist;
            end
            
            ud.record.ROIs.new_cell_index = max(ud.record.ROIs.new_cell_index,current_new_cell_index);
        end
        
        ud.cell_indices_changed = 1;
        set(ft(fig,'newcellindexEdit'),'String',num2str(ud.record.ROIs.new_cell_index));
        
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
        analyzetpstack('UpdatePreviewImage',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'checkMatchBt'
        switch get(ft(fig,'checkMatchBt'),'Value')
            case 0
                if isfield(ud,'h_check_rois')
                    delete( ud.h_check_rois);
                    ud.h_check_rois = [];
                end
            case 1
                ud.h_check_rois = [];
                ref_celllist = import_ref_rois(ud.record);
                for i=1:length(ref_celllist)
                    refroi = ref_celllist(i);
                    if is_linearroi(refroi.type)
                        clr = [0.4 0 0];
                    else
                        clr = [1 0 0];
                    end
                    ud.h_check_rois(end+1) = plot(refroi.xi,refroi.yi,'--','color',clr);
                end
                for i=1:length(ud.celllist)
                    roi = ud.celllist(i);
                    if is_linearroi(roi.type)
                        continue
                    end
                    refroi=ref_celllist([ref_celllist.index]==roi.index);
                    if ~isempty(refroi)
                        refroi_center = roi_center(refroi);
                        roi_cent = roi_center(roi);
                        ud.h_check_rois(end+1) = plot(refroi.xi,refroi.yi,'--','color',[0.4 0 0]);
                        ud.h_check_rois(end+1) = plot( [refroi_center(1) roi_cent(1)],...
                            [refroi_center(2) roi_cent(2)] ,'color',[0.8 0.8 0]);
                    else
                        ud.h_check_rois(end+1) = plot(roi.xi,roi.yi,'--','color',[0.3 0.3 1]);
                    end
                end
                
        end
        set(fig,'userdata',ud);
    case 'importROIsBt'
        if 1 % importing imaris
            [imaris_celllist, ud.record.ROIs.new_cell_index] = ...
                import_imaris_filaments( ud.record, ud.record.ROIs.new_cell_index );
            ud.celllist = [ud.celllist imaris_celllist];
        end
        
        if 1 % not doing imagej
            [imagej_celllist, ud.record.ROIs.new_cell_index] = ...
                import_imagej_rois( ud.record, ud.record.ROIs.new_cell_index );
            ud.celllist = [ud.celllist  imagej_celllist];
        end
        
        ud.cell_indices_changed = 1;
        set(ft(fig,'newcellindexEdit'),'String',num2str(ud.record.ROIs.new_cell_index));
        
        set(fig,'userdata',ud);
        
        analyzetpstack('UpdateCellList',[],fig);
        analyzetpstack('UpdatePreviewImage',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'linkROIsBt'
        btn=questdlg('Do you want to link all ROIs by distance to neurite?','Link all','Ok','Cancel','Ok');
        if strcmp(btn,'Ok')
            ud.record.ROIs.celllist = ud.celllist;
            ud.record = tp_link_rois( ud.record );
            ud.celllist = ud.record.ROIs.celllist;
            set(fig,'userdata',ud);
            analyzetpstack('UpdateCellList',[],fig);
        end
    case 'linkOneROIBt'
        items = get(ft(fig,'celllist'),'value');
        items = sort(items,2,'descend');
        
        answer = inputdlg('Neurite index:','Link to neurite',1,{'1'});
        if ~isempty(answer)
            neurite_index = str2double(answer{1});
            if ~isnan(neurite_index)
                for i = items
                    ud.celllist(i).neurite = neurite_index;
                end
                set(fig,'userdata',ud);
                analyzetpstack('UpdateCellList',[],fig);
            end
        end
    case 'sortROIsBt'
        cols = get(ft(fig,'sortROIsBt'),'String');
        sort_by = cols{get(ft(fig,'sortROIsBt'),'Value')};
        [ud.celllist,ind] = sort_db(ud.celllist,sort_by);
        ud.celldrawinfo.h = ud.celldrawinfo.h(ind);
        ud.celldrawinfo.t = ud.celldrawinfo.t(ind);
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
        
    case 'setROIindexBt'
        if ~isempty(ud.celllist)
            items = get(ft(fig,'celllist'),'value');
            items = sort(items,2,'ascend');
            for v = items
                
                %                v=items(1);
                ud.celllist(v).index = fix(str2double( get(ft(fig,'newcellindexEdit'),'String')));
                ud.record.ROIs.new_cell_index = next_available_cell_index(ud.celllist(v).index,ud.celllist );
                set(ft(fig,'newcellindexEdit'),'String',num2str(ud.record.ROIs.new_cell_index));
                ud.celldrawinfo.changes(v) = 1;
                set(fig,'userdata',ud);
                
            end
            analyzetpstack('UpdateCellList',[],fig);
        end
    case 'HelpBt'
        help_url = 'https://sites.google.com/site/alexanderheimel/protocols/puncta-analysis-using-matlab';
        switch computer
            case {'PCWIN','PCWIN64'}
                msgbox('Database and record available by ''global global_db global_record''','Analyzetpstack');
                dos(['start ' help_url]);
            otherwise
                msgbox(['Load ' help_url ' in your favorite browser. Database and record available by ''global global_db global_record''']);
                disp('ANALYZETPSTACK: Do not know how to open a browser on a MAC or LINUX PC');
        end
end










% speciality functions

function sr = emptyslicerec
sr = struct('dirname','','drawcells',1,'drawroinos',0,'analyzecells',1,'xyoffset',[0 0]);

function obj = ft(fig, name)
obj = findobj(fig,'Tag',name);

% function refdirname = getrefdirname(ud,dirname)
% %namerefs = getnamerefs(ud.ds,dirname);
% match = 0;
% for i=1:length(ud.slicelist),
%     nr = getnamerefs(ud.ds,ud.slicelist(i).dirname);
%     mtch = 1;
%     for j=1:length(nr),
%         for k=1:length(namerefs),
%             mtch=mtch*double((strcmp(nr(j).name,namerefs(k).name)&(nr(j).ref==namerefs(k).ref)));
%         end;
%     end;
%     if mtch==1
%         match = i;
%         break;
%     end;
% end;
% if match~=0
%     refdirname = ud.slicelist(match).dirname;
% else
%     refdirname ='';
% end;


function [listofcells,listofcellnames,selected_cells] = getpresentcells(ud,fig)
% get selection
items = get(ft(fig,'celllist'),'value');
selected_indices = [ud.celllist(items).index];

listofcells = {};
listofcellnames = {};
selected_cells = false(0);
for i=1:length(ud.celllist)
    if ud.celllist(i).present
        listofcells{end+1} = ud.celllist(i).pixelinds;
        listofcellnames{end+1}=[ud.celllist(i).type ' ' int2str(ud.celllist(i).index)];
        selected_cells(end+1) = ismember(ud.celllist(i).index,selected_indices);
    end
end





function [listofcells,listofcellnames,cellstructs,thechanges] = getcurrentcellschanges(ud,currdirname,ancestors)
listofcells = {}; listofcellnames = {}; thechanges = {};
cellstructs = tp_emptyroirec;
cellstructs = cellstructs([]);
for i=1:length(ud.celllist),
    if ~isempty(intersect(ud.celllist(i).dirname,ancestors)),
        changes = getChanges(ud,i,currdirname,ancestors);
        if changes.present  % if the cell exists in this recording, go ahead and add it to the list
            listofcells{end+1} = changes.pixelinds;
            listofcellnames{end+1}=['cell ' int2str(ud.celllist(i).index) ' ref ' ud.celllist(i).dirname];
            cellstructs = [cellstructs ud.celllist(i)];
            thechanges{end+1} = changes;
        end;
    end;
end;

% these functions deal with setting the 'changes' field in the celllist
function [changes,gotChanges] = getChanges(ud,i,newdir,ancestors)  % cell id is i
gotChanges = 0;
if isfield(ud.celldrawinfo,'changes'),
    if length(ud.celldrawinfo.changes)>=i,
        changes = ud.celldrawinfo.changes{i};
        if ~isempty(changes),
            changedirs = {changes.dirname};
            [ch,temp,ib]=intersect(ancestors,changedirs); %#ok<ASGLU>
            if ~isempty(ch),
                changes = changes(ib(end)); gotChanges = 1;
            end;
        end;
    end;
end;
% if no changes have been specified, return the default
if ~gotChanges,
    if ~isempty(i) && i<=length(ud.celllist),
        changes = struct('present',1,'dirname',newdir,...
            'xi',ud.celllist(i).xi,'yi',ud.celllist(i).yi,...
            'pixelinds',ud.celllist(i).pixelinds);
        if isfield(ud.celllist(i),'zi')
            changes.zi = ud.celllist(i).zi;
        end
    else
        changes = struct('present',1,'dirname',newdir,'xi',[],'yi',[],'zi',[],'pixelinds',[]);
    end;
end;

function setChanges(ud,fig,i,newchanges)
if ~isfield(ud.celldrawinfo,'changes'), ud.celldrawinfo.changes = {}; end;
gotChanges = 0;
if length(ud.celldrawinfo.changes)<i, ud.celldrawinfo.changes{i} = []; end;
changes = ud.celldrawinfo.changes{i};
currChanges = {};
for j=1:length(changes),   % if there are already changes, we have to overwrite them
    if strcmp(changes(j).dirname,newchanges.dirname)
        gotChanges = j;
        break;
    else
        currChanges{end+1} = changes(j).dirname;
    end;
end;
if gotChanges == 0
    if isempty(changes)
        ud.celldrawinfo.changes{i} = newchanges;
    else
        ud.celldrawinfo.changes{i}(end+1) = newchanges;
        currChanges{end+1} = newchanges.dirname;
        [dummy,inds]=sort(currChanges); %#ok<ASGLU>
        ud.celldrawinfo.changes{i} = ud.celldrawinfo.changes{i}(inds);
    end;
else
    ud.celldrawinfo.changes{i}(gotChanges) = newchanges;
end;
set(fig,'userdata',ud);

function str = trimws(mystring)
str=mystring;
inds=find(str~=' ');
if ~isempty(inds)
    str=str(inds(1):end);
end


% function ancestors = getallparents(ud,dirname)
% namerefs = getnamerefs(ud.ds,dirname);
% ancestors = {};
% for i=1:length(ud.slicelist),
%     if ~strcmp(ud.slicelist(i).dirname,dirname),
%         nr = getnamerefs(ud.ds,ud.slicelist(i).dirname);
%         mtch = 1;
%         for j=1:length(nr),
%             for k=1:length(namerefs),
%                 mtch=mtch*double((strcmp(nr(j).name,namerefs(k).name)&(nr(j).ref==namerefs(k).ref)));
%             end;
%         end;
%         if mtch==1, ancestors{end+1} = ud.slicelist(i).dirname; end;
%     else
%         break;
%     end;
% end;
% if ~isempty(dirname)
%     ancestors{end+1} = dirname;
% end
% parent should be first, followed by other ancestors, then self




function dr = getcurrentdirdrift(ud, numpreviewframes)
df = tpscratchfilename(ud.record,[],'drift');
if ~exist(df, 'file')
    %disp(['No driftcorrect file ' df '; shift information will change after drift correction.']);
    dr = [0 0];
else
    drift=[];
    load(df,'-mat');
    if isstruct(drift)
        dr = [mean(drift.x(1: min(numpreviewframes,end) ,:)) mean(drift.y(1:min(numpreviewframes,end),:))]; % get the mean initial drift
    else
        disp(['Driftcorrect file ' df ' not in right format; shift information will change after drift correction.']);
        dr = [0 0];
    end
end
% now add XY offset to drift
dr = dr + getxyoffset(ud);

function xyoffset = getxyoffset(ud)
myparent = '.';% getrefdirname(ud,dirname);
xyoffset = [0 0];
for j=1:length(ud.slicelist),
    if strcmp(myparent,trimws(ud.slicelist(j).dirname)),
        xyoffset = ud.slicelist(j).xyoffset;
    end;
end;


% function [slicestructupdate] = updatecelldraw(ud,i,slicestruct,currdir,numpreviewframes)
% % make a lookup table for slicelist, drift, and ancestors, if it doesn't
% % already exist
% if isempty(slicestruct)
%     slicestruct.slicelistlookup.test = [];
%     slicestruct.slicedriftlookup.test = [];
%     slicestruct.sliceancestorlookup.test = [];
%     for j=1:length(ud.slicelist),
%         slicestruct.slicelistlookup.(dir2fieldname(ud.slicelist(j).dirname)) = j;
%         slicestruct.slicedriftlookup.(dir2fieldname(ud.slicelist(j).dirname)) = getcurrentdirdrift(ud,trimws(ud.slicelist(j).dirname),numpreviewframes);
%         slicestruct.sliceancestorlookup.(dir2fieldname(ud.slicelist(j).dirname)) = getallparents(ud,trimws(ud.slicelist(j).dirname));
%     end;
% end;
% slicestructupdate = slicestruct;
%
% % must draw cell if it exists in current image or if
% %   its parent 'drawcells' field is checked.
% ancestors = slicestructupdate.sliceancestorlookup.(dir2fieldname( currdir ));
% cellisinthisimage = ~isempty(intersect(ud.celllist(i).dirname,ancestors));
%
% drawcellsinthisimage = ud.slicelist(slicestructupdate.slicelistlookup.(dir2fieldname(currdir))).('drawcells');
% if ~isfield(ud.slicelist(slicestructupdate.slicelistlookup.(dir2fieldname(currdir))),'drawroinos')
%     ud.slicelist(slicestructupdate.slicelistlookup.(dir2fieldname(currdir))).('drawroinos') = 0;
% end
% drawroinosinthisimage = ud.slicelist(slicestructupdate.slicelistlookup.(dir2fieldname(currdir))).('drawroinos');
% thiscellsparentdrawcells = ud.slicelist(slicestructupdate.slicelistlookup.(dir2fieldname(ud.celllist(i).dirname))).('drawcells');
% thiscellsparentdrawroinos = ud.slicelist(slicestructupdate.slicelistlookup.(dir2fieldname(ud.celllist(i).dirname))).('drawroinos');
% if (cellisinthisimage && drawcellsinthisimage) || (~cellisinthisimage && thiscellsparentdrawcells),
%     % show cell
%     set(ud.celldrawinfo.h(i),'visible','on');
% else % hide it
%     set(ud.celldrawinfo.h(i),'visible','off');
% end;
% if (cellisinthisimage && drawroinosinthisimage) || (~cellisinthisimage && thiscellsparentdrawroinos)
%     % show roino
%     set(ud.celldrawinfo.t(i),'visible','on');
% else % hide it
%     set(ud.celldrawinfo.t(i),'visible','off');
% end;
% % now draw cell with appropriate position and color
% if cellisinthisimage,
%     drift = slicestructupdate.slicedriftlookup.(dir2fieldname(currdir));
%     changes = getChanges(ud,i,currdir,ancestors);
% else
%     drift = slicestructupdate.slicedriftlookup.(dir2fieldname(ud.celllist(i).dirname));
%     changes = getChanges(ud,i,ud.celllist(i).dirname,[]);
% end;
%
% v = get(ft(gcf,'celllist'),'value');
% clr = roi_color( ud.celllist(i),v==i,str2double(get(ud.celldrawinfo.t(i),'tag')));
% set(ud.celldrawinfo.h(i),'color',clr);
% set(ud.celldrawinfo.t(i),'color',clr);
% xi = changes.xi;
% yi = changes.yi;
% if ~isfield(ud.celllist(i),'dimensions') || ud.celllist(i).dimensions>1
%     % close ROI
%     xi(end+1) = xi(1);
%     yi(end+1) = yi(1);
% end
% set(ud.celldrawinfo.h(i),'xdata',xi-drift(1),'ydata',yi-drift(2));
% set(ud.celldrawinfo.t(i),'position',[mean(xi)-drift(1) mean(yi)-drift(2) 0]);


function fieldname = dir2fieldname(dirname)
fieldname = trimws(dirname);
fieldname =['f' fieldname(fieldname~=' ')];
fieldname( fieldname=='.' ) = 'p';


function parse_analysis_parameters( analysis_parameters,fig)

if isfield(analysis_parameters, 'epochs')
    set(ft(fig,'epochsEdit'),'string',analysis_parameters.epochs);
end
if isfield(analysis_parameters, 'trials')
    set(ft(fig,'trialsEdit'),'string',analysis_parameters.epochs);
end
if isfield(analysis_parameters, 'timeint')
    set(ft(fig,'timeintEdit'),'string',mat2str(analysis_parameters.timeint));
end
if isfield(analysis_parameters, 'sptimeint')
    set(ft(fig,'sptimeintEdit'),'string',analysis_parameters.sptimeint);
end
if isfield(analysis_parameters, 'blankID')
    set(ft(fig,'BlankIDEdit'),'string',analysis_parameters.blankID);
end


return


function zoom_callback( obj,evd)
if isstruct(evd)
    h = evd.Axes;
else
    h = evd;
end
set(ft(obj,'zoomTxt'),'String',[num2str(get_zoom_factor(h),2) 'x']);



function zoom_factor = get_zoom_factor( h )
set(h,'units','pixels');
p = get(gca,'position');
set(h,'units','normalized');
a_xl = [p(1) p(3)];
a_yl = [p(2) p(4)];
c_xl = xlim(h);
c_yl = ylim(h);
zoom_factor_x = diff(a_xl)/diff(c_xl);
zoom_factor_y = diff(a_yl)/diff(c_yl);
zoom_factor = min(zoom_factor_x,zoom_factor_y);

function new_cell_index = next_available_cell_index( new_cell_index, celllist)
found = true;
while found
    new_cell_index = new_cell_index + 1;
    found = any( [celllist(:).index]==new_cell_index);
end


function color_rois( celllist, celldrawinfo,fig)
v = get(ft(fig,'celllist'),'value');
if ~isempty(v)
    v = v(1);
end

ud = get(fig,'userdata');
if ud.ztproject
    curframe = NaN;
else
    curframe = round(get(ft(fig,'FrameSlid'),'value'));
end
curframe=num2str(curframe);

if get(ft(fig,'DrawROIsCB'),'value')
    visrois = 'on';
else
    visrois = 'off';
end

if get(ft(fig,'DrawROINosCB'),'value')
    visroinos = 'on';
else
    visroinos = 'off';
end

for i = 1:length(celllist)
    clr = roi_color(celllist(i),i==v,strcmp(get(celldrawinfo.h(i),'tag'),curframe));
    if any(get(celldrawinfo.h(i),'color')~=clr) % only recolor if different
        set(celldrawinfo.h(i),'color',clr);
        set(celldrawinfo.t(i),'color',clr);
    end
    set(celldrawinfo.h(i),'visible',visrois);
    set(celldrawinfo.t(i),'visible',visroinos);
end


function clr = roi_color(roi,selected,in_current_frame)
roi.frame = median(roi.zi);
switch roi.present
    case 1 % base is blue
        if selected && in_current_frame
            clr = [1 1 0];
        elseif selected
            clr = [0.7 0.7 0];
        elseif  in_current_frame
            clr = [0 0 1];
        else
            clr = [0 0 0.5];
        end
    case 0 % base is gray
        if selected && in_current_frame
            clr = [0.8 0.8 0.8];
        elseif selected
            clr = [0.7 0.7 0.7];
        elseif  in_current_frame
            clr = [0.6 0.6 0.6];
        else
            clr = [0.3 0.3 0.3];
        end
end


function figure_keyrelease(src,event) %#ok<INUSL>
global shift_state control_state

if isfield(event,'Key')
    switch event.Key
        case 'shift'
            shift_state = false;
        case 'control'
            control_state = false;
    end
end


function figure_buttondown(src,event) %#ok<INUSD>
% select ROI
p=get(gca,'currentpoint');
x=p(1,1);
y=p(1,2);
ud = get(gcf,'userdata');
found_match = false;

% put neurites at the end
neurite_ind = find(cellfun(@is_linearroi,{ud.celllist.type}));
ind = [setdiff(1:length(ud.celllist),neurite_ind) neurite_ind];

for j=ind
    if inpolygon(x,y,[ud.celllist(j).xi(:)' ud.celllist(j).xi(1)],...
            [ud.celllist(j).yi(:)' ud.celllist(j).yi(1)])
        found_match = true;
        break
    end
end
if found_match
    set(ft(gcf,'celllist'),'value',j); % select new ROI
    analyzetpstack('celllist',[],gcf);
end

function figure_keypress(src,event)
% short-cut key catching and handling
global shift_state control_state

set(src,'WindowKeyPressFcn',[]);

if isfield(event,'Key')
    obj = get(src,'currentobject');
    prop = get(obj);
    if isfield(prop,'Style') && strcmp(prop.Style,'edit')
        % typing text, so do respond to key short cuts
        set(src,'WindowKeyPressFcn',@figure_keypress);
        return;
    end
    
    %  event
    switch event.Key
        case {'downarrow','uparrow'} % move celllistbox value up
            v = get(ft(gcf,'celllist'),'value');
            switch event.Key
                case 'uparrow'
                    if v>1
                        v = v -1;
                    end
                case 'downarrow'
                    if v<length(get(ft(gcf,'celllist'),'String'))
                        v =v +1;
                    end
            end
            set(ft(gcf,'celllist'),'value',v);
            
            analyzetpstack('celllist',[],gcf);
        case 'leftarrow' % move frameslider left = up
            move_slice_up;
        case 'rightarrow' % move frameslider right = down
            move_slice_down;
            
        case {'1','2','3','4','5','6','7','8','9','numpad1','numpad2',...
                'numpad3','numpad4','numpad5','numpad6','numpad7', ...
                'numpad8','numpad9'}
            if length(event.Key) == 1
                channelstring = ['channel' event.Key 'Tg'];
            else % numpad1
                channelstring = ['channel' event.Key(end) 'Tg'];
            end
            if ~isempty(ft(gcf,channelstring))
                set(ft(gcf,channelstring),'value',1-get(ft(gcf,channelstring),'value'));
                analyzetpstack(channelstring,[],src);
            end
        case 'control'
            control_state = true;
        case 'shift'
            shift_state = true;
        case 'j' % project
            set(ft(gcf,'ZTProjectTB'),'value',1-get(ft(gcf,'ZTProjectTB'),'value'));
            analyzetpstack('ZTProjectTB',[],src);
        case 'c'
            analyzetpstack('drawnewballBt',[],src);
        case 'm'
            analyzetpstack('moveCellBt',[],src);
        case 'p'
            set(ft(gcf,'panBt'),'value',1-get(ft(gcf,'panBt'),'value'));
            analyzetpstack('panBt',[],src);
        case 'x' % zoom five times
            p=get(gca,'currentpoint');
            %p=get(ft(gcf,'tpaxes') ,'currentpoint');
            zoom(5/get_zoom_factor( ft(gcf,'tpaxes') ));
            ax = axis;
            axis([p(1,1)-(ax(2)-ax(1))/2 p(1,1)+(ax(2)-ax(1))/2 p(1,2)-(ax(4)-ax(3))/2 p(1,2)+(ax(4)-ax(3))/2]);
            zoom_callback(gcf, ft(gcf,'tpaxes') );
            analyzetpstack('celllist',[],gcf);
            
        case 'z'
            p=get(gca,'currentpoint');
            zoom(2);
            center_at_position(p,gcf);
            zoom_callback(gcf, ft(gcf,'tpaxes') );
        case 'o'
            zoom(0.5);
            zoom_callback(gcf, ft(gcf,'tpaxes') );
        case 's'
            set(ft(gcf,'DrawROIsCB'),'value',1-get(ft(gcf,'DrawROIsCB'),'value'));
            analyzetpstack('DrawROIsCB',[],src);
        case 'a'
            if ismember('control',event.Modifier)
                v = ft(gcf,'celllist');
                set(v,'value',1:length(get(v,'String')));
            end
            
    end
elseif isfield(event,'VerticalScrollCount')
    obj = get(src,'currentobject');
    prop = get(obj);
    if isfield(prop,'Style') && strcmp(prop.Style,'listbox')
        % listboxes also have scrollbars, so do respond to key short cuts
        set(src,'WindowKeyPressFcn',@figure_keypress);
        return;
    end
    
    
    if shift_state % zoom in or out
        if event.VerticalScrollCount<0
            zoom(2);
        else
            zoom(0.5);
        end
    else
        ax = axis;
        switch control_state % scroll vertically or horizontally
            case false % vertical
                axis([ax(1) ax(2) ax(3)+event.VerticalScrollCount*0.1*(ax(4)-ax(3)) ax(4)+event.VerticalScrollCount*0.1*(ax(4)-ax(3))]);
            case true % horizontal
                axis([ax(1)+event.VerticalScrollCount*0.1*(ax(2)-ax(1)) ax(2)+event.VerticalScrollCount*0.1*(ax(2)-ax(1)) ax(3) ax(4)]);
                
        end
    end
end

set(src,'WindowKeyPressFcn',@figure_keypress);



function move_slice_up
ud = get(gcf,'userdata');
if ~ud.ztproject
    min = get(ft(gcf,'FrameSlid'),'min');
    frame = round(get(ft(gcf,'FrameSlid'),'value'));
    if frame > min
        frame = frame -1;
        set(ft(gcf,'FrameSlid'),'value',frame);
        analyzetpstack('UpdatePreviewImage',[],gcf);
    end
end

function move_slice_down
ud = get(gcf,'userdata');
if ~ud.ztproject
    max = get(ft(gcf,'FrameSlid'),'max');
    frame = round(get(ft(gcf,'FrameSlid'),'value'));
    if frame < max
        frame = frame +1;
        set(ft(gcf,'FrameSlid'),'value',frame);
        analyzetpstack('UpdatePreviewImage',[],gcf);
    end
end



function center_on_roi(fig)
v = get(ft(fig,'celllist'),'value');
if isempty(v)
    return
else
    v = v(1); % select first
end
ud  = get(fig,'userdata');
x=mean(ud.celllist(v).xi);
y=mean(ud.celllist(v).yi);
center_at_position([x y],fig);
if ~ud.ztproject
    goto_frame( median(ud.celllist(v).zi),fig);
end

function goto_frame( frame,fig )
if ~isnan(frame)
    cur_frame = round(get(ft(fig,'FrameSlid'),'value'));
    if cur_frame~=frame
        min_frame = get(ft(fig,'FrameSlid'),'min');
        max_frame = get(ft(fig,'FrameSlid'),'max');
        if frame < min_frame
            frame = min_frame;
            disp('ANALYZETPSTACK: roi.zi is below first frame');
        elseif frame > max_frame
            frame = max_frame;
            disp('ANALYZETPSTACK: roi.zi exceeds last frame');
        end
        set(ft(fig,'FrameSlid'),'value',frame);
        analyzetpstack('UpdatePreviewImage',[],fig);
    end
end



function center_at_position( p, fig )
h_tpaxes = ft(fig,'tpaxes');
c = get(h_tpaxes,'children');
if isfield(get(c(end)),'CData')
    extent = size(get(c(end),'CData'));
    
    xl = xlim(h_tpaxes);
    hw = (xl(2)-xl(1))/2;
    if 2*hw<extent(1)
        xlim(h_tpaxes,[p(1,1)-hw p(1,1)+hw]);
    end
    
    yl = ylim(h_tpaxes);
    hh = (yl(2)-yl(1))/2;
    if 2*hh<extent(2)
        ylim(h_tpaxes,[p(1,2)-hh p(1,2)+hh]);
    end
    %center_mouse(ft(gcf,'tpaxes'));
end

function center_mouse( h ) %#ok<DEFNU>
% not finished
panelh=get(h, 'Parent');
figh=gcf;
%unit_root=get(0, 'Unit');
%unit_fig=get(figh, 'Unit');
%unit_obj=get(h, 'Unit');
set(0, 'Units', 'pixels');
set(figh, 'Units', 'pixels');
set(panelh, 'Units', 'pixels');
set(h, 'Units', 'pixels');

fig_pos=get(gcf, 'Position');
panel_pos=get(panelh, 'Position');
obj_pos=get(h, 'Position');

act_pos=fig_pos+panel_pos;%+obj_pos;
act_pos=act_pos(1:2);
act_pos(1)=act_pos(1)+(obj_pos(3)-obj_pos(1))/2+3;
act_pos(2)=act_pos(2)+(obj_pos(4)-obj_pos(2))/2-7;

% set the mouse pointer to the upper left corner of the object
% (I did this for listboxes, to highlight the first entry)

set(0, 'PointerLocation', act_pos);

%axis([p(1,1)-(ax(2)-ax(1))/2 p(1,1)+(ax(2)-ax(1))/2 p(1,2)-(ax(4)-ax(3))/2 p(1,2)+(ax(4)-ax(3))/2]);



function d = get_ROI_distance( celllist,ri,step)
% step is 1x3 x,y,z step size in um
% cellist is array of ROI struct
% ri = [xi,yi,zi];
cxi = cellfun(@median,{celllist.xi});
cyi = cellfun(@median,{celllist.yi});
czi = cellfun(@median,{celllist.zi});
d = sqrt( step(1)^2*(cxi-ri(1)).^2 + step(2)^2*(cyi-ri(2)).^2 + step(3)^2*(czi-ri(3)).^2 );

function buttondownfcn_preview(src,~ )
ax=get(src,'parent');
pn=get(ax,'parent');
fig=get(pn,'parent');
if strcmp(get(fig,'selectiontype'),'alt')
    % possible right click or control click
    imsave(src);
end

function figure_resize(src,evt) %#ok<INUSD>
oldunits = get(gcf,'Units');
set(gcf,'Units','pixels');
fpos = get(gcf,'Position');

% push side panels to rhs
rightborder =fpos(3);
topside = 0;
sidepanels = ft(gcf,'sidepanel');
for h = sidepanels(:)'
    p = get(h,'position');
    p(1) = fpos(3)-p(3);
    rightborder = p(1);
    topside = max(topside,p(2)+p(4));
    set(h,'position',p);
end


roipos = get(ft(gcf,'roilabelspanel'),'Position');
if ~isempty(roipos)
    if topside<=roipos(2)+roipos(4)
        rightborder = fpos(3);
    end
    hpreview = ft(gcf,'previewpanel');
    set(hpreview,'Units','pixels');
    pos = get(hpreview,'Position') ;
    pos(2) = roipos(2)+roipos(4);
    pos(4) = fpos(4)-pos(2);
    pos(3) = rightborder - pos(1);
    set(hpreview,'Position',pos);
end

set(gcf,'Units',oldunits);
zoom_callback(gcf, ft(gcf,'tpaxes') );


function r = roi_center( rois )
for i=1:length(rois)
    r(i,1) = median(rois(i).xi);
    r(i,2) = median(rois(i).yi);
    r(i,3) = median(rois(i).zi);
end


function ud = add_resps_to_measures(ud,resps,listofcellnames,selected_cells)

global measures
measures = ud.record.measures;
if ~isempty(resps)
    flds = fields(resps);
    ind = find(selected_cells);
    for i = 1:length(ind)
        measures(ind(i)).cellname = listofcellnames{i};
        measures(ind(i)).index = ud.celllist(ind(i)).index;
        measures(ind(i)).labels = ud.celllist(ind(i)).labels;
        measures(ind(i)).type = ud.celllist(ind(i)).type;
        measures(ind(i)).contains_data = true;
        measures(ind(i)).usable = true;
        for field = flds'
            measures(ind(i)).(field{1}) = resps(i).(field{1});
        end
    end
end
ud.record.measures = measures;

temprecord = ud.record;
temprecord.measures = measures(ind);
results_tptestrecord(temprecord);

evalin('base','global measures');
disp('ANALYZETPSTACK: Data available as measures');
