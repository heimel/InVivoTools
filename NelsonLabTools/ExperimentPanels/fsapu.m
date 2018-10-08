function fsapu (arg)
%FSAPU is a fast and sloppy popper-upper
%
% 200X Steve Van Hooser
%
% 2006-12-06 JFH Only do reverse_correlation if a cell has some spikes in
%                interval

global rc tc pc

z = geteditor('RunExperiment');
if ~isempty(z)
    ud=get(z,'userdata');
    cksds = ud.cksds;
else
    error('no runexperiment. grrrrrr!');
end
if nargin==1
    if isstruct(arg)
        record = arg;
    else
        h_db = get_fighandle('ec database*');
        ud = get(h_db,'Userdata');
        record = ud.db(ud.current_record);
        channels2analyze = get_channels2analyze( record );
    end
    datapath=experimentpath(record,false);
    cksds = cksdirstruct(datapath);
    cells = import_spikes( record, [], true );
    
    fsapu(); % make figure
    f = 1234;
    ud = get(f,'userdata');
    %l = {'t00048'};
    vl = get(ud.gettests,'String');
    nr = getallnamerefs(cksds);
    nv = get(ud.namerefs,'value');
    nts = get(ud.notes,'String');
    usepc = get(ud.usepc,'value');
    
    ps = get(ud.param,'String');
    pv = get(ud.param,'value');
    par = ps{pv};
    if isfield(record,'test')
        test = record.test;
    elseif isstruct(arg)
        if isfield(record,'test')
            test = record.test;
        else
            test = record.epoch;
        end
    else
        test = vl;
    end
    s = getstimscripttimestruct(cksds,test);
    try
        g = getcells(cksds,nr(nv));
    catch
        logmsg('does not exist.');
        g = getcells(cksds);
    end
    
    loadstr = '';
    for i=1:length(g)
        loadstr = [loadstr ',''' g{i} '''']; %#ok<AGROW>
    end
    loadstr = loadstr(2:end);
    
    if isempty(loadstr)
        logmsg('Empty data');
        delete(f);
        logmsg('does not exist.');
    end
    eval(['d = load(getexperimentfile(cksds),' loadstr ',''-mat'');']);
    
    if strcmp(par,'rev cor')
        for i=1:length(g)
            if ~ismember(cells(i).channel,channels2analyze)
                continue
            end
            inp.stimtime = stimtimestruct(s,1);
            inp.spikes={}; 
            inp.cellnames = {};
            inp.spikes{1}=getfield(d,g{i});
            n_spikes=length(get_data(inp.spikes{1},...
                [inp.stimtime.mti{1}.startStopTimes(1),...
                inp.stimtime.mti{1}.startStopTimes(end)]));
            if n_spikes >0 % if at least some spikes in interval
                inp.cellnames{1} = [g{i}];
                disp([g{i} ' n_spikes=' num2str(n_spikes)]);
                where.figure = figure;where.rect=[0 0 1 1]; where.units='normalized';
                orient(where.figure,'landscape');
                
                %%% rc = reverse_corr(inp,'default',where);
                %%%  changed by Alexander 2006-12-13
                rc = reverse_corr(inp,'default',[]); %where);
                para_rc=getparameters(rc);
                para_rc.interval=[0.050 0.350];
                para_rc.timeres = 0.100;
                para_rc.bgcolor=2;
                rc=setparameters(rc,para_rc);
                rc = setlocation(rc,where);
                rcs=getoutput(rc);
                rcs=rcs.reverse_corr;
                
                % show normalized receptive field plot
                figure;
                rf=squeeze(rcs.rc_avg(1,para_rc.datatoview(2),:,:,end))';
                %rf=gaussian(size(rf),[fix(size(rf,1)/2) 2],[2 1],[1 -1;1 1]);
                imagesc(rf');
                colormap gray
                
                % calc feature mean
                p2 = getparameters(inp.stimtime(1).stim);
                % feamean is RGB-vector
                feamean=sum(repmat(p2.dist,1,3).*p2.values,1)/sum(p2.dist);
                %flatten feature mean and sem, only works for gray levels
                feamean=mean(feamean);
                
                if 0
                    %distribution is not gaussian but multinominal
                    %calculation of responsive area is done by monte carlo
                    %a patch is responsive if there is less than X chance
                    %that it comes from the finite sampling of the feature mean
                    
                    % this procedure does not take into account the possible limited
                    % number of samples
                    
                    cumdist=cumsum(p2.dist)'/sum(p2.dist); %#ok<UNRCH>
                    chance_higher=zeros(size(rf));
                    chance_lower=zeros(size(rf));
                    tic
                    n_samples=1000;
                    for sample=1:n_samples
                        stimsample=sum(repmat(rand(n_spikes,1),1,length(cumdist))>repmat(cumdist,n_spikes,1),2)+1;
                        samplemean=mean(p2.values(stimsample,:));
                        samplemean=mean(samplemean);
                        chance_higher=chance_higher+(rf>samplemean);
                        chance_lower=chance_lower+(rf<samplemean);
                    end
                    chance_higher=chance_higher/n_samples;
                    chance_higher=chance_higher>1-1/prod(size(rf)); % max 1 patch false positive
                    chance_lower=chance_lower/n_samples;
                    chance_lower=chance_lower>1-1/prod(size(rf)); % max 1 patch false positive
                    toc
                    figure;imagesc(rf'.*(chance_higher'+chance_lower')+...
                        feamean*(1-chance_higher'-chance_lower'));colormap gray
                    
                    rf_onsize=sum(chance_higher(:));
                    disp(['new ON-response in  ' num2str(rf_onsize) ' patches']);
                    rf_offsize=sum(chance_lower(:));
                    disp(['new OFF-response in  ' num2str(rf_offsize) ' patches']);
                    
                end
                
                %below assume enough spikes or stimuli for multinomial distribution to
                %resemble gaussian distribution
                
                % if there are very few spikes, than perhaps not all
                % stimuli are sampled. To correct for this we assume
                % poisson-spiking (not accurate in case of periodic bursts)
                % and deduct the number of samples which were probably not
                % sampled by spikes)
                
                spikes_per_sample=n_spikes/p2.N;
                prob_notsampled=exp(-spikes_per_sample);
                % from poisson-dist: p_l(m)=l^m exp(-l)/m!
                n_samples=p2.N*(1 - prob_notsampled); %
                
                feamean_std=sqrt(sum(repmat(p2.dist,1,3).*(p2.values.^2),1)/sum(p2.dist)...
                    -feamean.^2);
                feamean_sem=feamean_std/sqrt(n_samples);
                
                %flatten feature mean and sem, only works for gray levels
                %feamean_std=mean(feamean_std);
                feamean_sem=mean(feamean_sem);
                
                %maxc=feamean+3*feamean_std;
                %minc=feamean-3*feamean_std;
                
                % take all point within first and third quartile
                topbox=prctile(rf(:),75);
                minbox=prctile(rf(:),25);
                %ind_box=find( rf(:)<topbox & rf(:)>minbox);
                mrf = mean(rf(rf(:)<topbox & rf(:)>minbox));
                
                if mrf<feamean-feamean_sem || mrf>feamean+feamean_sem
                    disp('Not sampled long enough. Feature mean too far from data mean');
                end
                
                rf_on=(rf> (feamean+3*feamean_sem));
                disp(['ON-response in  ' num2str(sum(rf_on(:))) ' patches ' ]);
                
                rf_off=(rf< (feamean-3*feamean_sem));
                disp(['OFF-response in ' num2str(sum(rf_off(:))) ' patches']);
                
                figure;
                image( 64/(2*feamean)*...
                    ((rf'.*(rf_on'+rf_off')+...
                    feamean*(1-rf_on'-rf_off'))));
                colormap gray
                
                %set(gca,'CLim',[min(rf(:)) max(rf(:))]);
                
                if 0 % no gaussian fitting of receptive field
                    % take all point within first and third quartile
                    topbox=prctile(rf(:),90); %#ok<UNRCH>
                    minbox=prctile(rf(:),10);
                    ind_box=find( rf(:)<topbox & rf(:)>minbox);
                    mrf=mean(rf(ind_box));
                    
                    srf=std(rf(ind_box));
                    maxc=mrf+4*srf;
                    minc=mrf-4*srf;
                    
                    
                    rf_type='';
                    if maxc<max(rf(:))
                        disp('possible on-response');
                        rf_type='on';
                        maxc=max(rf(:));
                    end
                    if minc>min(rf(:))
                        disp('possible off-response');
                        rf_type='off';
                        minc=min(rf(:));
                    end
                    if ~isempty(rf_type)
                        % still working on
                        % still need to fit offset instead of removing min
                        % still need to give advice of goodness of fit
                        
                        % fit 2d-gaussian to receptive field
                        switch rf_type
                            case 'on'
                                [cx,cy,sx,sy,cxy,PeakOD]=...
                                    Gaussian2D( rf-feamean ,0.001,p2.rect);
                                %                                Gaussian2D( thresholdlinear(rf-feamean)+srf/100 ,0.001,p2.rect);
                            case 'off'
                                [cx,cy,sx,sy,cxy,PeakOD]=...
                                    Gaussian2D( thresholdlinear(-rf+feamean)+srf/100 ,0.001,p2.rect);
                                PeakOD=-PeakOD;
                            otherwise
                                disp(['error: rf_type [' rf_type '] not implemented yet']);
                        end
                        
                        % plot fit
                        hold on
                        xx=linspace(p2.rect(1),p2.rect(3),50);
                        yy=linspace(p2.rect(2),p2.rect(4),50);
                        [x,y] = MeshGrid(xx,yy);
                        nx=(x-cx);
                        ny=(y-cy);
                        detc=(sx*sy)^2-cxy^2;
                        fit = feamean+...
                            abs(PeakOD)*(exp( -0.5/detc*(sy^2*nx.^2-2*cxy*nx.*ny+sx^2*ny.^2 ) ));
                        figure; hold on;
                        IM = surf(repmat(xx,length(yy),1)',repmat(yy,length(xx),1),...
                            zeros(length(xx),length(yy)),fit);
                        set(gca,'ydir','reverse','tag','analysis_generic','userdata','revaxes');
                        shading flat;
                        axis equal;
                        axis([p2.rect(1) p2.rect(3) p2.rect(2) p2.rect(4)]);
                        colormap gray
                        set(gca,'CLim',[mrf-3*srf mrf+3*srf])
                        [cs,h]=contour(repmat(xx,length(yy),1)',repmat(yy,length(xx),1),fit,...
                            'linespec','k');
                        clabel(cs,h);
                    end
                end
            end
        end
        delete(f);
    else % not reverse correlation
        for i=1:length(g)
            inp.st=s;
            inp.spikes=getfield(d,g{i});
            inp.paramname=par;
            inp.title=[g{i}];
            where.figure=figure;where.rect=[0 0 1 1]; where.units='normalized';
            orient(where.figure,'landscape');
            %set(where.figure,'inverthardcopy','off');
            if ~usepc
                tc=tuning_curve(inp,'default',where);
            else
                inp.paramnames={par};
                pc=periodic_curve(inp,'default',where);
            end
        end
        delete(f);
    end
    nts = [vl ' : ' nts];
    axes('position',[0 0 1 1],'visible','off');
    text(0.5,0.02,nts,'HorizontalAlignment','center','Interpreter','none');
else % called fsapu without arguments, probably first time
    h0 = figure(1234);
    set(h0,'Color',[0.8 0.8 0.8], ...
        'PaperPosition',[18 180 676 432], ...
        'PaperUnits','points', ...
        'Position',[389 260 590 314], ...
        'Tag','', ...
        'MenuBar','figure');
    settoolbar(h0,'figure');
    uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'FontSize',12, ...
        'FontWeight','bold', ...
        'ListboxTop',0, ...
        'Position',[50.91012549212599 249.7477854330709 296.8156373031496 18.25079970472441], ...
        'String','Fast, sloppy, analysis popper-upper', ...
        'Style','text', ...
        'Tag','StaticText1');
    uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ListboxTop',0, ...
        'Position',[64.35808316929135 216.1278912401575 347.7257627952756 20.17193651574803], ...
        'String','Displays a quick and dirty tuning curve', ...
        'Style','text', ...
        'Tag','StaticText2');
    uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ListboxTop',0, ...
        'Position',[268 25 91 29], ...
        'String','Do it', ...
        'Tag','Pushbutton1','Callback','fsapu doit');
    uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ListboxTop',0, ...
        'Position',[61.47637795275591 165.2177657480315 121.0316190944882 20.17193651574803], ...
        'String','parameter:', ...
        'Style','text', ...
        'Tag','StaticText3');
    param = uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ListboxTop',0, ...
        'Min',1, ...
        'Position',[197.8771  163.2966  101.8203   24.0142], ...
        'String',{'rev cor','angle','sFrequency','tFrequency','contrast','sPhaseShift','velocity','angVelocity','direction','coherence','dotsize'}, ...
        'Style','popupmenu', ...
        'Tag','PopupMenu1', ...
        'Value',1);
    uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ListboxTop',0, ...
        'Position',[61.47637795275591 132.5584399606299 121.0316190944882 20.17193651574803], ...
        'String','test:', ...
        'Style','text', ...
        'Tag','StaticText3');
    gettests = uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'Min',1, ...
        'Position',[197.8771  132.5584  101.8203   24.0142], ...
        'FontSize',8,...
        'String','t00001', ...
        'Style','edit', ...
        'Tag','PopupMenu1', ...
        'Value',1);
    uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ListboxTop',0, ...
        'Position',[60.5158095472441 99.89911417322836 121.0316190944882 20.17193651574803], ...
        'String','nameref:', ...
        'Style','text', ...
        'Tag','StaticText3');
    nrs = {'none'};
    nr = getallnamerefs(cksds);
    for i=1:length(nr)
        nrs{i} = [nr(i).name ' | ' int2str(nr(i).ref) ];
    end
    namerefs = uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',[0.8 0.8 0.8], ...
        'ListboxTop',0, ...
        'Min',1, ...
        'Position',[197.8771   98.9385  101.8203   24.0142], ...
        'FontSize',8,...
        'String',nrs, ...
        'Style','popupmenu', ...
        'Tag','PopupMenu1', ...
        'Value',1);
    notes=uicontrol('Parent',h0, ...
        'Units','points', ...
        'BackgroundColor',0.8*[1 1 1], ...
        'Min',1, ...
        'Position',[198  70 200.8203   24.0142], ...
        'FontSize',8,...
        'String','', ...
        'Style','edit', ...
        'Tag','PopupMenu1', ...
        'Value',1);
    usepc=uicontrol('Parent',h0,...
        'Units','points',...
        'BackgroundColor',[0.8 0.8 0.8],...
        'String','use periodic_curve',...
        'Style','checkbox',...
        'Position',[100 30 100 24],...
        'FontSize',8,...
        'Value',0);
    
    set(h0,'userdata',struct('namerefs',namerefs,'gettests',gettests,'param',param,'notes',notes,'usepc',usepc));
end
