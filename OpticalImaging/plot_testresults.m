function h=plot_testresults(fname,response,response_sem,response_all,tc_roi,tc_ror,ratio,roi,ror,record)
%PLOT_TESTRESULTS plots results of a testrecord
%
% 2005, Alexander Heimel
%
if nargin<9
    record=[];
    stim_onset=3;
    stim_offset=9;
    stim_type='';
else
    stim_onset=record.stim_onset;
    stim_offset=record.stim_offset;
    stim_type=record.stim_type;
end

h=[];

conditions=[];
if ~isempty(record)
    [conditions,condnames]=get_conditions_from_record(record);
end

if ~iscell(fname)
    fname={fname};
end

% check if less than 16 stimuli are used
n_stims=length(record.stim_contrast)*length(record.stim_sf)*length(record.stim_tf);
if n_stims>15
    logmsg('Stimulus setups can only start 15 different stimuli!');
end

% get file info

filename=[fname{1} 'B0.BLK'];
fileinfo=imagefile_info( filename );

if isempty(fileinfo.name)
    logmsg(['Cannot open ' filename ]);
    fileinfo.n_conditions=length(conditions);
    fileinfo.cameraframes_per_frame=15;
    logmsg('Number of cameraframes per frames may be wrong');
    fileinfo.xbin=1;
    fileinfo.ybin=1;
    logmsg('Spatial binning may be wrong');
end

if isempty(fileinfo.name)
    logmsg(['Cannot open ' filename ]);
    fileinfo.name=filename;
else
    filename=fileinfo.name;
end

if ~isfield(fileinfo,'frameduration')
    logmsg('Defaulting frameduration to 0.6s');
    fileinfo.frameduration=0.6;
end

if length(conditions)~=fileinfo.n_conditions
    logmsg('Number conditions in record does not match data');
    if isempty(conditions)
        conditions=(0:fileinfo.n_conditions-1);
        condnames=num2str( conditions','%3g');
    end
end

frame_duration=fileinfo.frameduration;
if ~isempty(strfind(filename,'BLK'))
    ref_image=read_oi_compressed(filename,1,1,1,1,0);
else
    ref_image=[];
end

if isempty(record)
    tit=[fname{:}];
else
    tit=[record.mouse ' ' record.date ' ' record.test];
end
switch record.stim_type
    case {'od','od_bin','od_mon'}
    otherwise
        tit=[tit ' ' record.eye];
end

tit(tit=='_')='-';

mousedb=load_mousedb;
ind=find_record(mousedb,['mouse=' record.mouse]);
if length(ind)>1
    errormsg(['Two mice with name ' record.mouse ...
        ' in mouse_db']);
    return
end
if isempty(ind)
    logmsg(['Cannot find mouse with name ' record.mouse ...
        ' in mouse_db']);
    return
end

mouse=mousedb(ind);
tit=[tit ' \newline ' mouse.strain];
if ~isempty(mouse.type)
    tit=[tit ', ' mouse.type];
end
if mouse.typing_lsl>0
    tit=[tit ' ' mouse.lsl ':' typing2str(mouse.typing_lsl)];
end
if mouse.typing_koki>0
    tit=[tit ' ' mouse.koki ':' typing2str(mouse.typing_koki)];
end
if mouse.typing_cre>0
    tit=[tit ' ' mouse.cre ':' typing2str(mouse.typing_cre)];
end
birthdate=mouse.birthdate;
if ~strcmp(birthdate,'unknown')
    try
        age=datenumber(record.date)-datenumber(birthdate(1:10));
    catch
        logmsg(['Could not get mouse age. wrongly entered in' ...
            ' mouse_db?']);
        age='unknown';
    end
else
    age='unknown';
end
tit=[tit ', age = ' num2str(age) ' days, ' record.comment];

show_single_condition_maps(record,fname,condnames,fileinfo,roi,ror,tit);

h=figure('name',tit,'numbertitle','off');
set(h,'PaperType','a4');
pos=get(h,'position');
pos([3 4])=[700 500];
h_ed=get_fighandle('OI database*');
if ~isempty(h_ed)
    pos_ed=get(h_ed,'Position');
    pos(2)=pos_ed(2)-pos(4)-100;
end
set(h,'position',pos);

colormap gray;

subplot(4,2,2)
htitle=title(tit);
set(htitle,'FontSize',8);
pos=get(htitle,'Position');
pos(1)=0; %-0.25*size(roi,2);
set(htitle,'Position',pos);
set(htitle,'HorizontalAlignment','left');
axis off;

% plot responses
if numel(response_all,2)~=length(response_all)
    subplot(2,2,1);
    [x,y]=meshgrid( (1:size(response_all,2)),...
        linspace(-0.25,0.25,size(response_all,1)));
    
    plot( x'+y',response_all','.');
    % plot( x',response_all','.');
    %  keyboard
    ax=axis;ax([1 2])=[0.5 length(response)+0.5];axis(ax);
    box off;
    %xlabel('Stimulus');
    ylabel('% change');
    if ~isempty(condnames)
        set(gca,'XTick',(1:length(response)));
        set(gca,'XTickLabel',condnames);
    end
end


subplot(2,2,3);
%  boxplot(tresponse');
switch stim_type
    case 'sf_contrast'
        sf=record.stim_sf;
        contrast=record.stim_contrast;
        if ~isempty(strfind(record.comment,'contrast_sf'))
            contrast_sf=1;
            x=repmat(contrast,length(sf),1);
            x=x*100;
            y=reshape(response,length(sf),length(contrast));
            dy=reshape(response_sem,length(sf),length(contrast));
        else
            contrast_sf=0;
            x=repmat(sf,length(contrast),1);
            y=reshape(response,length(sf),length(contrast))';
            dy=reshape(response_sem,length(sf),length(contrast))';
        end
        
        
        
        
        if ~isempty(dy)
            errorbar(x',y',dy','o');
        end
        hold on;
        ax=axis;ax([1 2])=[0.01 1];
        if ax(3)>0;ax(3)=0;end
        axis(ax);
        box off;
        ylabel('% Change');
        
        ytext=ax(4)*0.9;
        xtext=0.5;
        color='bgrc';
        if ~contrast_sf
            xlim([0.01 1]);
            xlabel('Spatial frequency (cpd)');
            for i=1:length(contrast)
                [acuity,rc,offset]=cutoff_thresholdlinear(x(i,:),y(i,:));
                acuity_sem=nan;
                sf_fit=(0.01:0.01:0.9);
                plot(sf_fit,thresholdlinear( sf_fit*rc+offset), ...
                    [color(mod(length(color)-1,i)+1) '-']);
                
                ytext=printtext([  num2str(acuity,2) ...
                    ' \pm ' num2str(acuity_sem,1) ' cpd'],ytext,xtext);
            end
        else
            xlim([8 100]);
            xlabel('% Contrast');
            set(gca,'XScale','log');
            set(gca,'XTick',sort(x(1,:)));
            cfit=linspace(0.01,1,100);
            rfit=cell(length(sf),1);
            for i=1:length(sf)
                [rm,b,n]=naka_rushton(x(i,:)/100,y(i,:));
                rfit{i} = rm*cfit.^n./(b^n+cfit.^n);
                plot(cfit*100,rfit{i},['-' color(i)]);
                
                ind=findclosest(rfit{i},0.5*max(rfit{i}));
                c50=cfit(ind);
                logmsg(['c50 = ' num2str(c50*100) ' % ']);
                plot([c50 c50],[0 rfit{i}(ind)],[':' color(i)]);
            end
        end
    case {'sf','sf_temporal','sf_low_tf'}
        x=conditions;
        y=response;
        dy=response_sem;
        blank=find(x==0);
        condind=setdiff( (1:length(x)), blank);
        if ~isempty(dy)
            errorbar(x(condind),y(condind),dy(condind),'ko');
        end
        hold on;
        ax=axis;ax([1 2])=[0.01 1];
        if ax(3)>0;ax(3)=0;end
        axis(ax);
        if ~isempty(blank)
            plot( [ax(1) ax(2)],[y(blank)-dy(blank) y(blank)-dy(blank)],'k:');
            plot( [ax(1) ax(2)],[y(blank)           y(blank)          ],'k--');
            plot( [ax(1) ax(2)],[y(blank)+dy(blank) y(blank)+dy(blank)],'k:');
        end
        
        box off;
        ylabel('% Change');
        xlabel('Spatial frequency (cpd)');
        
        %c=polyfit(x(condind),y(condind),1);
        %acuity= -c(2)/c(1)
        
        hold on
        
        
        [acuity,rc,offset]=cutoff_thresholdlinear(x(condind),y(condind));
        acuity_sem=nan;
        if ~isempty(record)
            [acuity,acuity_sem] = get_valrecord(record,'sf_cutoff');
        end
        sf=(0.01:0.01:0.9);
        plot(sf,thresholdlinear( sf*rc+offset),'k-');
        textx=0.3;
        
        
        if min(x(condind))<0.1
            %      set(gca,'XScale','log');
            %      set_logticks;
            %      textx=0.1;
        end
        
        text(textx,ax(4)*0.9,[' acuity = ' num2str(acuity,2) ...
            ' \pm ' num2str(acuity_sem,1) ' cpd']);
        
    case 'tf',
        x=conditions;
        y=response;
        dy=response_sem;
        blank=find(x==0);
        condind=setdiff( (1:length(x)), blank);
        if ~isempty(dy)
            errorbar(x(condind),y(condind),dy(condind),'ko');
        end
        hold on;
        ax=axis;
        if ~isempty(blank)
            plot( [ax(1) ax(2)],[y(blank)-dy(blank) y(blank)-dy(blank)],'k:');
            plot( [ax(1) ax(2)],[y(blank)           y(blank)          ],'k--');
            plot( [ax(1) ax(2)],[y(blank)+dy(blank) y(blank)+dy(blank)],'k:');
        end
        ax=axis;
        if ax(3)>0;ax(3)=0;end
        axis(ax);
        box off;
        ylabel('% Change');
        xlabel('Temporal frequency (Hz)');
        
        %c=polyfit(x(condind),y(condind),1);
        %acuity= -c(2)/c(1)
        hold on
        
        [acuity,rc,offset]=...
            cutoff_thresholdlinear([x(condind) 30 ],[y(condind) 0]);
        tf=(5:1:40);
        plot(tf,thresholdlinear( tf*rc+offset),'k-');
        text(15,ax(4)*0.9,[' temp. acuity = ' num2str(acuity,2) ' Hz']);
        
        
    case 'contrast',
        x=conditions;
        y=response;
        dy=response_sem;
        blank=find(x==0);
        condind=setdiff( (1:length(x)), blank);
        if ~isempty(dy)
            errorbar(x(condind)*100,y(condind),dy(condind),'ko');
        end
        hold on;
        ax=axis;
        if ~isempty(blank)
            plot( [ax(1) ax(2)],[y(blank)-dy(blank) y(blank)-dy(blank)],'k:');
            plot( [ax(1) ax(2)],[y(blank)           y(blank)          ],'k--');
            plot( [ax(1) ax(2)],[y(blank)+dy(blank) y(blank)+dy(blank)],'k:');
        end
        ax=axis;
        if ax(3)>0;ax(3)=0;end
        axis(ax);
        box off;
        ylabel('% Change');
        xlabel('Contrast (%)');
        hold on
        [rm,b,n]=naka_rushton([0.01 0.02 x(condind)],[0 0 y(condind)]);
        cfit=linspace(0.01,1,100);
        rfit = rm*cfit.^n./(b^n+cfit.^n);
        plot(cfit*100,rfit,'k-');
        ax=axis;y=ax(3)+0.9*(ax(4)-ax(3));
        y=printtext(['n = ' num2str(n,2)],y,10);
        y=printtext(['b = ' num2str(b,2)],y,10);
        
    case {'od','od_bin','od_mon'},
        h=bar( (1:length(response)),response);
        set(h,'FaceColor',0.8*[1 1 1]);
        hold on
        if ~isempty(response_sem)
            errorbar( (1:length(response)),response,response_sem,'.k') ;
        end
        if ~isempty(condnames)
            set(gca,'XTick',(1:length(response)));
            set(gca,'XTickLabel',condnames);
        end
        box off;
        xlabel('Eye');
        ylabel('% change');
        
        ind_contra=find(conditions==1);
        ind_ipsi=find(conditions==-1);
        cdi=abs(response(ind_contra)/response(ind_ipsi));
        cdi_sem=cdi*sqrt( (response_sem(ind_contra)/response(ind_contra))^2+...
            (response_sem(ind_ipsi)/response(ind_ipsi))^2);
        
        odi=(response(ind_contra)-response(ind_ipsi))/...
            (response(ind_contra)+response(ind_ipsi));
        odi_sem=...
            sqrt( (response_sem(ind_contra)/(response(ind_contra)+response(ind_ipsi)))^2+...
            (response_sem(ind_ipsi)/(response(ind_contra)+response(ind_ipsi)))^2);
        odi_sem = odi_sem + odi_sem*odi;
        
        xlab = ['C/I = ' num2str(cdi,3) ' +- ' num2str(cdi_sem,2) ' \newline '...
            'ODI = ' num2str(odi,3) ' +- ' num2str(odi_sem,2) ];
        
        xlabel(xlab,'FontSize',4);
        
        ss=sum(tc_roi(1:5,:));
        ip=5*tc_roi(1,2)-ss(2);
        co=5*tc_roi(1,3)-ss(3);
        logmsg([ 'normalized C/I = ' num2str(cdi)]);
        logmsg([ 'ipsi= ' num2str( ip) ' contra= ' num2str(co) ' ratio= ' ...
            num2str(co/ip)]);
        
    otherwise,
        h=bar( (1:length(response)),response);
        set(h,'FaceColor',0.8*[1 1 1]);
        hold on
        if ~isempty(response_sem)
            errorbar( (1:length(response)),response,response_sem,'.k') ;
        end
        if ~isempty(condnames)
            set(gca,'XTick',(1:length(response)));
            set(gca,'XTickLabel',condnames);
        end
        box off;
        xlabel('Stimulus');
        ylabel('% change');
end

if ~isempty(tc_roi)
    subplot(4,3,6);
    norm=repmat(tc_roi( ceil(record.stim_onset/frame_duration+1),:),size(tc_roi,1),1);
    h_leg=plot_timecourse(-100+100*tc_roi./norm,...
        '',frame_duration,stim_onset,stim_offset,condnames);
    ylabel('ROI %\Delta ');
    xlabel('');
    pos=get(h_leg,'Position');
    pos(1)=1-pos(3);
    set(h_leg,'Position',pos);
    
    subplot(4,3,9);
    plot_timecourse(-100+100*tc_ror/mean(tc_ror(:)),...
        '',frame_duration,stim_onset,stim_offset,0);
    ylabel('ROR %\Delta');
    xlabel('');
    
    subplot(4,3,12);
    plot_timecourse(ratio,'',frame_duration,...
        stim_onset,stim_offset,0);
    ylabel('ROI/ROR %\Delta');
    
end

bigger_linewidth(1.3);
smaller_font(-4);

if exist('h_leg','var') % to bypass bug in matlab 7.3
    set(h_leg,'Position',pos);
    set(h_leg,'FontSize',10);
end

