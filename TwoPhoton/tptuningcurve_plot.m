function tptuningcurve_plot(measures)

%,resps,listofcells,listofcellnames,paramname,channel,epochslist,trialslist,timeint,sptimeint,blankID)
%TPTUNINGCURVE_PLOT plot twophoton tuning curves
%
%  TPTUNINGCURVE_PLOT( RECORDS,RESPS,LISTOFCELLS,LISTOFCELLNAMES,...
%      PARAMNAME,CHANNEL,EPOCHSLIST,TRIALSLIST,TIMEINT,SPTIMEINT,BLANKID)
%
%
% 2011-2013, Alexander Heimel based on code by Steve Vanhooser
%

if isempty(measures)
    disp('TPTUNINGCURVE_PLOT: No measures found.');
    return
end

paramname = measures(1).variable;


for roi_nr = 1:length(measures)
    measure = measures(roi_nr);
    curve = measure.curve;
    
    if isempty(curve)
        continue
    end
    
    figure('Name',[capitalize(measure.cellname) ' tuning'],'NUmberTitle','off');
    hold on;
    
    switch paramname
        case 'angle'
            curve(1,end+1) = curve(1,1)+360; %#ok<AGROW>
            curve(2:4,end) = curve(2:4,1);
            
            plot(curve(1,:),curve(2,:),'ko','linewidth',2);
            otcurve = fit_otcurve(curve);
            plot(otcurve(1,:),otcurve(2,:),'k');
        otherwise
            plot(curve(1,:),curve(2,:),'k-','linewidth',2);
    end
    
    
    h=myerrorbar(curve(1,:),curve(2,:),curve(4,:),curve(4,:));
    delete(h(2)); set(h(1),'linewidth',2,'color',0*[1 1 1]);
    if exist('blankresp','var')==1, % plot blank response if it exists
        a = axis;
        plot([-1000 1000],blankresp(1)*[1 1],'k-','linewidth',1);
        plot([-1000 1000],[1 1]*(blankresp(1)-blankresp(3)),'k--','linewidth',0.5);
        plot([-1000 1000],[1 1]*(blankresp(1)+blankresp(3)),'k--','linewidth',0.5);
        axis(a); % make sure the axis doesn't get changed on us
    end;
    xlabel(capitalize(paramname));
    ylabel(tpresponselabel(measure.channel));
    title(measure.cellname);
    switch paramname
        case 'eyes'
            set(gca,'Xtick',[0 1 2]);
            set(gca,'Xticklabel',{'Left','Right','Both'});
        case 'angle'
            xlim([-5 365]);
            set(gca,'XTick',(0:45:360));
            disp(['TPTUNINGCURVE_PLOT: ' measure.cellname ': osi = ' num2str(measure.osi)]);

        otherwise
            % nothing special
    end
    smaller_font(-8);
    bigger_linewidth(2);
    
end