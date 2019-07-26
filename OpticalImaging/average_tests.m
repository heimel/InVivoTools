function [newud,conditions,response,response_sem]=average_tests( ud, normalized,show )
%AVERAGE_TESTS averages results from filtered test records
%
%  NEWUD=AVERAGE_TESTS( UD )
%
%  2005-2006, Alexander Heimel
%

if nargin<3 || isempty(show)
    show = 1;
end
if nargin<2 || isempty(normalized)
    normalized = 0;
end

if isempty(ud.ind)
    logmsg('No filtered records');
    return
end
newud = ud;

records = ud.db(ud.ind);
n_records = length(records);

lconditions = [];
lresponse = [];
lresponse_sem = [];
for i=1:length(records)
    if ~isempty(records(i).response)
        conditions = get_conditions_from_record(records(i));
        if normalized
            switch records(i).stim_type
                case 'tf'
                    normc=find(conditions==5);
                    if isempty(normc)
                        normc = find(conditions==...
                            min(conditions(conditions>0)));
                    end
                    norm=records(i).response( normc);
                case 'sf'
                    [sc,normc]=sort(conditions);
                    if sc(1)==0
                        normc=normc(2);
                    else
                        normc=normc(1);
                    end
                    norm=records(i).response( normc);
                otherwise
                    norm=max(records(i).response);
            end
        else
            norm=1;
        end
        
        for c=1:length(conditions)
            lconditions(end+1)=conditions(c);
            
            
            
            lresponse(end+1)=records(i).response(c) / norm;
            lresponse_sem(end+1)=records(i).response_sem(c) /norm;
        end
    end
end

% remove sf tests below 0.1 cpd
if strcmp(records(end).stim_type,'sf')==1
    ind=find(lconditions>=0.08);
    lconditions=lconditions(ind);
    lresponse=lresponse(ind);
    lresponse_sem=lresponse_sem(ind);
    
    ind=find(lconditions==0.08);
    lconditions(ind)=0.1;
    
    
end

% remove tf tests below 5 Hz
if strcmp(records(end).stim_type,'tf')==1
    ind=find(lconditions>=5);
    lconditions=lconditions(ind);
    lresponse=lresponse(ind);
    lresponse_sem=lresponse_sem(ind);
end

[lconditions,ind] = sort(lconditions);
lresponse = lresponse(ind);
lresponse_sem = lresponse_sem(ind);

conditions = uniq(lconditions);
response = [];
response_sem = [];
for c=1:length(conditions)
    response(end+1) = mean( lresponse( lconditions==conditions(c)));
    response_sem(end+1) = sem( lresponse( lconditions==conditions(c)));
end
condnames = get_condnames(records(end).stim_type, conditions);


if show
    h = figure;
    set(h,'PaperType','a4');
    switch records(1).stim_type
        case 'od'
            h=bar(response);
            set(h,'FaceColor',0.8*[1 1 1]);
            hold on
            errorbar(response,response_sem,'.k');
            contra=find( conditions==1);
            ipsi=find(conditions==-1);
            od=response(contra)/response(ipsi);
            od_sem=sqrt( response_sem(contra)^2+ response_sem(ipsi)^2);
            tit=[ 'OD = ' num2str(od,3) ' +- ' num2str(od_sem,2) ];
            tit=[tit ' (n=' num2str(n_records) ')'];
            if ~isempty(condnames)
                set(gca,'XTick',(1:length(response)));
                set(gca,'XTickLabel',condnames);
            end
        case 'sf'
            x=conditions;
            y=response;
            dy=response_sem;
            blank=find(x==0);
            cond=setdiff( (1:length(x)), blank);
            
            errorbar(x(cond),y(cond),dy(cond),'ko');
            
            [rc,offset]=fit_thresholdlinear2(x(cond),y(cond),dy(cond),-1/ ...
                -max(y)/0.8,max(y));
            
            hold on;
            sf=(0:0.01:0.8);
            plot( sf,thresholdlinear(sf*rc+offset),'-k');
            acuity=- offset/rc;
            disp(['Spatial acuity = ' num2str(acuity,2) ' cpd']);
            
            box off;
            if normalized
                ylabel('Normalized response');
                axis([0 0.8 -0.2 1]);
            else
                ylabel('Change %');
            end
            xlabel('Spatial frequency (cpd)');
            tit=[ 'SF'];
            tit=[tit ' (n=' num2str(n_records) ')'];
            
        case 'tf'
            x = conditions;
            y = response;
            dy = response_sem;
            blank = find(x==0);
            cond = setdiff( (1:length(x)), blank);
            errorbar(x(cond),y(cond),dy(cond),'ko');
            [rc,offset]=fit_thresholdlinear2(x(cond),y(cond),dy(cond),-1/ ...
                20,1);
            hold on
            tf = (5:0.1:25);
            plot( tf,thresholdlinear(tf*rc+offset),'-k');
            box off
            if normalized
                ylabel('Normalized response');
                axis([4.5 25 -0.2 1]);
            else
                ylabel('Change %');
            end
            xlabel('Temporal frequency (Hz)');
            tit = 'TF';
            tit = [tit ' (n=' num2str(n_records) ')'];
        otherwise
            h = bar(response);
            set(h,'FaceColor',0.8*[1 1 1]);
            hold on
            errorbar(response,response_sem,'.k');
            tit = [ ' (n=' num2str(n_records) ')'];
            if ~isempty(condnames)
                set(gca,'XTick',(1:length(response)));
                set(gca,'XTickLabel',condnames);
            end
            ylabel('% change');
    end
    title(tit);
    ax=axis;
    if ax(3)<0
        hold on
        plot( [ax(1) ax(2)],[0 0],'-k' );
        axis(ax);
    end
end






