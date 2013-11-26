function tppuncta_results(result)
%TPPUNCTA_RESULTS displays results from TPPUNCTA_ANALYSIS
%
%  TPPUNCTA_RESULTS( RESULT )
%
%  Use TPPUNCTA_ANALYSIS for calculating the results
%
% 2011, Alexander Heimel
%

puncta = result.puncta;
dendrites = result.dendrites;
days = result.days;


total_number_unique_puncta = nansum(sum(result.gain)-sum(result.reappearing))+sum(result.total(:,1));
disp(['Unique puncta: ' num2str(total_number_unique_puncta)])


disp(['Days : ' num2str(days, ' %3d')])
for d = 1:length(dendrites)
    if ~isempty(puncta{d})
        disp([strpad(dendrites{d},25) 'Total: ' num2str(result.total(d,:)) ]);
        disp([strpad(dendrites{d},25) 'Gain : ' num2str(result.gain(d,:)) ]);
        disp([strpad(dendrites{d},25) 'Loss : ' num2str(result.loss(d,:)) ])
    end
end
disp([strpad('',25) 'Days : ' num2str(days, ' %3d')])

parameters.minimum_puncta_per_dendrite = 10;
rows = (mean(result.total,2) >= parameters.minimum_puncta_per_dendrite); % select dendrites with at least X puncta
disp(['TPPUNCTA_RESULTS: available n = ' num2str(sum(rows))]);

parameters.pool_small_dendrites = true;

if parameters.pool_small_dendrites
    rows_small_dendrites = setdiff( [1:size(result.total,1)],find(rows));
    rows(end+1) = true;
    result.total(end+1,:) = sum(result.total(rows_small_dendrites,:));
    result.gain(end+1,:) = sum(result.gain(rows_small_dendrites,:));
    result.loss(end+1,:) = sum(result.loss(rows_small_dendrites,:));
    result.total_big_puncta(end+1,:) = sum(result.total_big_puncta(rows_small_dendrites,:));
    result.gain_big_puncta(end+1,:) = sum(result.gain_big_puncta(rows_small_dendrites,:));
    result.loss_big_puncta(end+1,:) = sum(result.loss_big_puncta(rows_small_dendrites,:));
    result.p_cluster_lost_puncta(end+1,:) = sum(result.p_cluster_lost_puncta(rows_small_dendrites,:));
    result.p_cluster_gained_puncta(end+1,:) = sum(result.p_cluster_gained_puncta(rows_small_dendrites,:));
    result.reversed_dendrite(end+1) = NaN;
    result.dendritic_length(end+1,:) = sum(result.dendritic_length(rows_small_dendrites,:));
    result.density(end+1,:) = mean(result.dendritic_length(rows_small_dendrites,:));
    result.gain_per_length(end+1,:) = mean(result.gain_per_length(rows_small_dendrites,:));
    result.loss_per_length(end+1,:) = mean(result.loss_per_length(rows_small_dendrites,:));
    result.total(rows,:)
end



%weight = mean(result.total,2);
%weight = weight/sum(weight);

% select only reversed or not
%rows = (rows & logical(~result.reversed_dendrite)); % forward analysed
%rows = (rows & logical(result.reversed_dendrite)); % backward analysed
%rows = (rand(10,1)>0.5); % random selection

disp(['TPPUNCTA_RESULTS: using n = ' num2str(sum(rows)) ]);

%weightmatrix = max(1,repmat(weight(rows,1),1,8));

switch result.puncta_type
    case 'synapse'
        suff = '';
    case 'all'
        suff = ' (everything)';
    case 'spine'
        suff = ' on spines';
    case 'shaft'
        suff = ' on shafts';
end


for_paper = false;

if for_paper
    % loss and gain figure
    hmean = figure('name',['Rate (%)' suff],'NumberTitle','off');
    hmean = show_results( result.gain(rows,2:end)./max(1,result.total(rows,2:end))*100,['Rate (%)' suff],days(2:end),false,true,hmean,[0.8 0 0],true);
    hmean = show_results( result.loss(rows,2:end)./max(1,result.total(rows,1:end-1))*100,['Rate (%)' suff],days(2:end),false,true,hmean,[0 0 0.8],true);
    %    hmean = show_results( result.loss(rows,2:end)./max(1,result.total(rows,1:end-1))*100,['Rate (%)' suff],days(2:end),true,true,hmean,[0 0 0.8],true);ylim([0 100]);
    ax=axis;
    if ~isempty(findstr(result.mouse_type,'MD'))
        
        hbar = bar(7+6,ax(4)*2,12);
        set(hbar,'facecolor',0.8*[1 1 1],'linestyle','none');
        c=get(gca,'children');
        set(gca,'children',c(end:-1:1));
        text( 13,ax(4),'MD','horizontalalignment','center','verticalalignment','top');
        
    end
    smaller_font(-8);
    bigger_linewidth(1);
    figfilename = ['Rate_(p)' suff] ;
    save_figure(figfilename,'~/Projects/Gephyrin/Figures');
    
    if 0
    % loss and gain big punctafigure
    hmean = figure('name',['Rate large puncta(%)' suff],'NumberTitle','off');
    hmean = show_results( result.gain_big_puncta(rows,2:end)./max(1,result.total_big_puncta(rows,2:end))*100,['Rate large puncta (%)' suff],days(2:end),false,true,hmean,[0.8 0 0],true);
    hmean = show_results( result.loss_big_puncta(rows,2:end)./max(1,result.total_big_puncta(rows,1:end-1))*100,['Rate large puncta (%)' suff],days(2:end),false,true,hmean,[0 0 0.8],true);
    ax=axis;
    if ~isempty(findstr(result.mouse_type,'MD'))
        hbar = bar(7+6,ax(4)*2,12);
        set(hbar,'facecolor',0.8*[1 1 1],'linestyle','none');
        c=get(gca,'children');
        set(gca,'children',c(end:-1:1));
        text( 13,ax(4),'MD','horizontalalignment','center','verticalalignment','top');
    end
    smaller_font(-8);
    bigger_linewidth(1);
    figfilename = ['Rate_large_puncta(p)' suff] ;
    save_figure(figfilename,'~/Projects/Gephyrin/Figures');
    end 
    
    
    if 0
        % loss per um
        hmean = figure('name',['Rate (per um)' suff],'NumberTitle','off');
        dl = mean(result.dendritic_length,2);
        dl = repmat(dl,1,size(result.dendritic_length,2));
        
        hmean = show_results( result.gain(rows,2:end)./max(1,dl(rows,2:end))*100,['Rate (per um)' suff],days(2:end),false,true,hmean,[0.8 0 0],true);
        hmean = show_results( result.loss(rows,2:end)./max(1,dl(rows,1:end-1))*100,['Rate (per um)' suff],days(2:end),false,true,hmean,[0 0 0.8],true);
        ax=axis;
        
        if ~isempty(findstr(result.mouse_type,'MD'))
            hbar = bar(7+6,ax(4)*2,12);
            set(hbar,'facecolor',0.8*[1 1 1],'linestyle','none');
            c=get(gca,'children');
            set(gca,'children',c(end:-1:1));
            text( 13,ax(4),'MD','horizontalalignment','center','verticalalignment','top');
        end
        smaller_font(-8);
        bigger_linewidth(1);
        figfilename = ['Rate (per)' suff] ;
        save_figure(figfilename,'~/Projects/Gephyrin/Figures');
    end
    
else
    
    
    
    % general
    show_results( result.density(rows,:)  ,['Density (per um)' suff],days,false,true,[],[0 0 0],true,result.mouse_type);
    show_results( result.gain(rows,2:end)./max(1,result.total(rows,2:end)),['Relative gain' suff],days(2:end),false,true,[],[0 0 0],true,result.mouse_type);
    show_results( result.loss(rows,2:end)./max(1,result.total(rows,1:end-1)),['Relative loss' suff],days(2:end),false,true,[],[0 0 0],true,result.mouse_type);
    show_results( result.loss_per_length(rows,2:end),['Loss per um' suff],days(2:end),false,true,[],[0 0 0],true,result.mouse_type);
    %show_results( result.gain_big_puncta(rows,2:end)./max(1,result.total(rows,2:end)),['Relative gain large puncta' suff],days(2:end),false,true,[],[0 0 0],true,result.mouse_type);
    %show_results( result.loss_big_puncta(rows,2:end)./max(1,result.total(rows,1:end-1)),['Relative loss large puncta' suff],days(2:end),false,true,[],[0 0 0],true,result.mouse_type);
    %show_results( result.total(rows,:) ./ max(1,repmat(result.total(rows,1),1,8))*100 ,['Puncta (%)' suff],days,false,true,[],[0 0 0],true,result.mouse_type);
    %show_results( result.total(rows,:),['Puncta' suff],days,false,true,[],[0 0 0],true,result.mouse_type);
    %show_results( result.gain(rows,:),['Gain' suff],days,false,true,[],[0 0 0],true,result.mouse_type);
    %show_results( result.loss(rows,:),['Loss' suff],days,false,true,[],[0 0 0],true,result.mouse_type);
    %show_results( result.gain_big_puncta(rows,:),['Gain large puncta' suff],days,false,true,[],[0 0 0],true,result.mouse_type);
    %show_results( result.loss_big_puncta(rows,:),['Loss large puncta' suff],days,false,true,[],[0 0 0],true,result.mouse_type);
    %show_results( result.reappearing(rows,:),['Reappearing' suff],days,false,true,[],[0 0 0],true,result.mouse_type);
    %show_results( result.puncta_ranking_motility(rows,:),['Changes in rank' suff],days(2:end));
    show_results( result.persisting(rows,:) ./ max(1,repmat(result.total(rows,1),1,8))*100 ,['Persisting (%)' suff],days,false,true,[],[0 0 0],true,result.mouse_type);
    show_results( result.persisting(rows,:) ./ max(1,repmat(result.total(rows,1),1,8)) ,['Relative persisting' suff],days,false,true,[],[0 0 0],true,result.mouse_type);
    show_results( result.reappearing(rows,:)./ max(1,repmat(result.total(rows,1),1,8)),['Relative reappearing' suff],days,false,true,[],[0 0 0],true,result.mouse_type);
end
disp('Clustering');
disp(['Fraction of distances of shuffled lost puncta smaller than data (p-value) = ' num2str(mean(mean(result.p_cluster_lost_puncta(rows,:))),2)])
disp(['Fraction of distances of shuffled gained puncta smaller than data (p-value) = ' num2str(mean(mean(result.p_cluster_gained_puncta(rows,:))),2)])


function hfig = show_results( data,ylab,days,plotpoints,plotmean,fig,clr,plotsig,mouse_type )
if nargin<4
    plotpoints = true;
end
if nargin<5
    plotmean = true;
end
if nargin<6
    fig = [];
end
if isempty(fig)
    hfig = figure('name',ylab,'NumberTitle','off');
else
    hfig = fig;
end
if nargin<7
    clr = [];
end
if nargin<8
    plotsig = true;
end

% take out completely zero rows
nonzero_rows = (nansum(abs(data),2)>0);
data = data(nonzero_rows,:);

hold on

if plotmean
    hbar= errorbar(days,nanmean(data),sem(data),'k','linewidth',2);
    if ~isempty(clr)
        set(hbar,'color',clr);
    end
    
    set(hbar,'marker','o','MarkerFaceColor',[1 1 1],'MarkerSize',8);
    ax = axis;
    ax(3) = 0;
    ax(4) = ax(4)*1.1;
    axis(ax);
end

if plotpoints
    if ~isempty(clr)
        plot(days,data','color',clr);
    else
        plot(days,data');
    end
end
ax = axis;

if isempty(fig)  &&  ~isempty(findstr(mouse_type,'MD'))
    
    
    hbar = bar(7+6,ax(4)*2,12);
    set(hbar,'facecolor',0.8*[1 1 1],'linestyle','none');
    c=get(gca,'children');
    set(gca,'children',c(end:-1:1));
    text( 13,ax(4),'MD','horizontalalignment','center','verticalalignment','top');
end

%plot(days,nanmean(data',2),'k','linewidth',3);
if plotmean
    hbar=errorbar(days,nanmean(data),sem(data),'k','linewidth',2);
    if ~isempty(clr)
        set(hbar,'color',clr);
    end
    set(hbar,'marker','o','MarkerFaceColor',[1 1 1],'MarkerSize',8);
end

axis(ax);

xlabel('Time (days)');
xlim([-0.3 max(days)]);
set(gca,'xtick',days);
ylabel(ylab);

set(gca,'tickdir','out')
box off

if isempty(fig)
    bigger_linewidth(2);
    smaller_font(-8);
end

if plotmean && plotsig
    if isnan(data(1,1))
        for i=3:length(days)
            [~,p]=ttest( data(:,2),data(:,i));
            pf = friedman( [data(:,2) data(:,i)],[1],'off');
            if p<0.1
                disp([ylab ' different from baseline at day ' num2str(days(i)) ', friedman test p = ' num2str(pf,2)  ]);
                disp([ylab ' different from baseline at day ' num2str(days(i)) ', paired ttest p = ' num2str(p,2)  ]);
                if p<0.001
                    ch = '***';
                elseif p<0.01
                    ch = '**';
                elseif p<0.05
                    ch = '*';
                elseif p<0.1;
                    ch = '#';
                end
                if ~isempty(clr)
                    text(days(i),nanmean(data(:,i))+(ax(4)-ax(3))*0.1,ch,'fontsize',20,'color',clr);
                else
                    text(days(i),nanmean(data(:,i))+(ax(4)-ax(3))*0.1,ch,'fontsize',20);
                end
            end
        end
    else
        for i=2:length(days)
            [~,p]=ttest( data(:,1),data(:,i));
            pf = friedman( [data(:,1) data(:,i) ],[1],'off');
            if p<0.1
                disp([ylab ' different from baseline at day ' num2str(days(i)) ', friedman test p = ' num2str(pf,2)  ]);
                disp([ylab ' different from baseline at day ' num2str(days(i)) ', paired ttest p = ' num2str(p,2)  ]);
                if p<0.001
                    ch = '***';
                elseif p<0.01
                    ch = '**';
                elseif p<0.05
                    ch = '*';
                elseif p<0.1;
                    ch = '#';
                end
                if ~isempty(clr)
                    text(days(i),nanmean(data(:,i))+(ax(4)-ax(3))*0.1,ch,'fontsize',20,'color',clr);
                else
                    text(days(i),nanmean(data(:,i))+(ax(4)-ax(3))*0.1,ch,'fontsize',20);
                end
            end
            
        end
    end
end


figfilename = ylab;
save_figure(figfilename,'~/Projects/Gephyrin/Figures');

