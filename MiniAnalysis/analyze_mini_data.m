function [control,transgenic,description]=analyze_mini_data(dataset)
% dataset eg.

if nargin<1
    dataset=[];
end
if isempty(dataset)
    % check /home/data/Slice/Minis
    %dataset='TrkB/Inh';
    % dataset='Gephyrin';
    % dataset='TrkB/Inh'; % check /home/data/Slice/Minis
    dataset='TrkB_Mosaic/Inh'; % check /home/data/Slice/Minis
    %dataset='TrkB/Exc'; % check /home/data/Slice/Minis
    %dataset='unfiltered_data';
end
disp(['Using dataset: ' dataset]);

if ~exist('transgenic')
    [control,transgenic,description]=load_mini_data(dataset);
end

% sort in time
control=sort_time(control);
transgenic=sort_time(transgenic);



% include isi as extra column
description{end+1}='PSC interval (ms)';
control=add_isi(control);
transgenic=add_isi(transgenic);


switch dataset
    case 'Gephyrin/Inh'
        do_remove_last_minute = false;
        do_select_first_minutes = false;
        do_select_low_rise_times = false;
        do_select_low_decay_times = true;
    otherwise
        do_select_low_rise_times = false;
        do_remove_last_minute = true;
        do_select_first_minutes = true;
        do_select_low_decay_times = true;
end



if 0
    % select last x minutes
    last_minutes=10;
    control=select_last_minutes(control,last_minutes);
    transgenic=select_last_minutes(transgenic,last_minutes);
end



if do_remove_last_minute
    % remove last minute (usually unstable)
    minutes=1;
    control=remove_last_minutes(control,minutes);
    transgenic=remove_last_minutes(transgenic,minutes);
end


if do_select_first_minutes
    % select first x minutes
    minutes = 10;
    control = select_first_minutes(control,minutes);
    transgenic = select_first_minutes(transgenic,minutes);
end


if do_select_low_rise_times
    % select for rise times under x ms
    control=select_under(control,4,3); % 4=rise, 3ms
    transgenic=select_under(transgenic,4,3); % 4=rise, 3ms
end

if do_select_low_decay_times
    % select for decay times under x ms
    control=select_under(control,5,10); % 5=decay, 10ms
    transgenic=select_under(transgenic,5,10); % 5=decay, 10ms
end


if 1
    % select for amplitudes under 200 pA
    control=select_under(control,3,200); % 3=amplitude 200pA
    transgenic=select_under(transgenic,3,200); % 3=amplitude, 200pA
end


ctl_means=nan*zeros(length(control),size(control{1},2));
for c=1:length(control)
    ctl_means(c,:)=mean(control{c});
    ctl_medians(c,:)=median(control{c});
    ctl_std(c,:)=std(control{c});
    
    disp(['Control cell ' num2str(c) ',median interval,' num2str(ctl_medians(c,19)) ',mean interval,' num2str(ctl_means(c,19))]);
    disp(['Control cell ' num2str(c) ',median amplitude,' num2str(ctl_medians(c,3)) ',mean amplitude,' num2str(ctl_means(c,3))]);
end

trg_means=nan*zeros(length(transgenic),size(transgenic{1},2));
for c=1:length(transgenic)
    trg_means(c,:)=mean(transgenic{c});
    trg_medians(c,:)=median(transgenic{c});
    trg_std(c,:)=std(transgenic{c});

    disp(['Transgenic cell ' num2str(c) ',median interval,' num2str(trg_medians(c,19)) ',mean interval,' num2str(trg_means(c,19))]);
    disp(['Transgenic cell ' num2str(c) ',median amplitude,' num2str(trg_medians(c,3)) ',mean amplitude,' num2str(trg_means(c,3))]);

end

%% analyze all fields
for fn = [3 19] %fn=[3 4 5 6 7 8  19]
    %for fn=[3 19]
    if mean(ctl_means(:,fn))==0 || mean(ctl_means(:,fn))==-1
        continue
    end
    disp(description{fn})

    
    
    
    disp(['control    mean of cell means: ' num2str(mean(ctl_means(:,fn)),3) ...
        ' +- ' num2str(sem(ctl_means(:,fn)),3) ...
        '  (n = ' num2str(size(ctl_means,1)) ')' ]);
    disp(['transgenic mean of cell means: ' num2str(mean(trg_means(:,fn)),3)...
        ' +- ' num2str(sem(trg_means(:,fn)),3) ...
        '  (n = ' num2str(size(trg_means,1)) ')']);
    
    
    
    
    [h,p]=ttest2(ctl_means(:,fn),trg_means(:,fn));

    
    
    
    disp(['ttest on cell means: p = ' num2str(p,3)]);
    p=kruskal_wallis_test(ctl_means(:,fn),trg_means(:,fn));
    disp(['kruskal wallis on cell means: p = ' num2str(p,3)]);
    
    if 1
        control_data=[];
        for c=1:length(control)
            control_data=[control_data; control{c}(:,fn)];
        end
        transgenic_data=[];
        for c=1:length(transgenic)
            transgenic_data=[transgenic_data; transgenic{c}(:,fn)];
        end
        %  [pkw]=kruskal_wallis_test(control_data,transgenic_data);
        % [pkw]=kruskalwallis([control_data;transgenic_data],[zeros(length(control_data),1); ones(length(transgenic_data),1)]);
        % disp(['kruskal-wallis on all data (meaningless): p = ' num2str(pkw,2)]);
        [h,p] = kstest2( control_data, transgenic_data);
        disp(['Kolmogorov-Smirnov on all data: p = ' num2str(p,3)]);
        
    end
    
    if 0
        disp(['control    mean of cell medians: ' num2str(mean(ctl_medians(:,fn)),3)]);
        disp(['transgenic mean of cell medians: ' num2str(mean(trg_medians(:,fn)),3)]);
        [h,p]=ttest2(ctl_medians(:,fn),trg_medians(:,fn));
        disp(['ttest on cell medians: p = ' num2str(p,3)]);
    end
    
    
    figure;
    h1=subplot(1,2,1);
    plot_mini_data(control,fn,description{fn},'control');
    ax1=axis;
    h2=subplot(1,2,2);
    plot_mini_data(transgenic,fn,description{fn},'transgenic');
    ax2=axis;
    axmax=max(ax1,ax2);
    axmin=min(ax1,ax2);
    ax=[axmin(1) axmax(2) axmin(3) axmax(4)];
    axes(h1);axis(ax);
    axes(h2);axis(ax);
    
    bigger_linewidth(3);
    smaller_font(-12);
    
    %filename=['mini_' dataset '_' description{fn} '_timecourse'];
    %save_figure(filename);
    
    
    graph({ctl_means(:,fn),trg_means(:,fn)},[],...
        'ylab',description{fn},...
        'xticklabels',['control';'mutant '],...
        'errorbars','sem',...
        'showpoints',2,'spaced',1,...
        'test','ttest');
    filename=['mini_' dataset '_' description{fn} '_bar'];
    save_figure(filename);
    
    disp('_____________________')
    
    
    plot_cumulative_both({control{randperm(length(control))}},transgenic,fn,description,dataset);
    
    
    if 0
        % for hadi
        % plotting curves from exponential graph
        hold on
        mc=mean(ctl_means(:,fn))
        ax=axis;
        x=linspace(ax(1),ax(2),100);
        h=plot(x,1-exp(-x/mc),'b--');
        set(h,'LineWidth',3);
        
        mc=mean(trg_means(:,fn))
        ax=axis;
        x=linspace(ax(1),ax(2),100);
        h=plot(x,1-exp(-x/mc),'r--');
        set(h,'LineWidth',3);
    end
    
end

return



%%
function plot_cumulative_both(control,transgenic,fn,description,title)

figure;
hold on;

switch fn
    case 3
        prefax=[10 100];
    case 19
        prefax=[0 800]; % hadi
        prefax=[0 1500];
        prefax=[0 4000];
        %        prefax = []; %2012-02-03
    otherwise
        prefax = [];
end

pool=pool_minis({control{:},transgenic{:}},fn);
[n,histbin_centers]=hist(pool,100 );

rc={};
for c=1:length(control)
    rc{c}=control{c}(:,fn)';
end
[cf_mean,histbin_centers]=plot_cumulative( rc,histbin_centers,'b',0,prefax);
hold on;
rt={};
for c=1:length(transgenic)
    rt{c}=transgenic{c}(:,fn)';
end


[cf_mean,histbin_centers]=plot_cumulative( rt,histbin_centers,'r',0,prefax);
h_leg=legend('= Control','= Mutant','Location','SouthEast');
set(h_leg,'Box','off');
xlabel(description{fn});
ylabel('Fraction');

[cf_mean,histbin_centers]=plot_cumulative( rc,histbin_centers,'b',1);
[cf_mean,histbin_centers]=plot_cumulative( rt,histbin_centers,'r',1);
bigger_linewidth(3);
smaller_font(-12);
set(h_leg,'FontSize',24);

filename=['mini_' title '_' description{fn} 'cumulative'];
save_figure(filename);


return





%%
function minis=pool_minis(miniset,fn)
minis=[];
for c=1:length(miniset)
    minis=[minis; miniset{c}(:,fn)];
end
return

%%
function minis=select_last_minutes(minis,last_minutes)
for i=1:length(minis)
    time_end=minis{i}(end,2);
    time_start=time_end-last_minutes*60*1000; % to convert to ms
    ind_start=find( minis{i}(:,2)>time_start,1);
    minis{i}=minis{i}(ind_start:end,:);
end
return

%%
function minis=select_first_minutes(minis,minutes)
for i=1:length(minis)
    time_start=minis{i}(1,2);
    time_end=time_start+minutes*60*1000; % to convert to ms
    ind_end=find( minis{i}(:,2)>=time_end ,1);
    if isempty(ind_end)
        ind_end=size(minis{i},1)
    end
    minis{i}=minis{i}(1:ind_end,:);
end
return

%%
function minis=remove_last_minutes(minis,minutes)
for i=1:length(minis)
    time_end=minis{i}(end,2)-minutes*60*1000; % to convert to ms
    ind_end=find( minis{i}(:,2)>=time_end ,1);
    if isempty(ind_end)
        ind_end=size(minis{i},1)
    end
    minis{i}=minis{i}(1:ind_end,:);
end
return

%%
function minis=select_under(minis,fn,par) % 5=decay, 10ms
for i=1:length(minis)
    ind=find(minis{i}(:,fn)<par);
    if length(ind)<0.95*size(minis{i},1) % less than 95%
        disp('removing many minis!')
    end
    minis{i}=minis{i}(ind,:);
end
return

function plot_mini_data(minis,fn,ylab,tit)
hold on
title(tit,'FontSize',20)
color='bgrcmykbgrcmykbgrcmykbgrcmykbgrcmyk';
for c=1:length(minis)
    data=minis{c}(:,fn);
    window = 10; % earlier 500
    time_sw=conv(minis{c}(:,2),ones(window,1))/window;
    data_sw=conv(data,ones(window,1))/window;
    data_sw=data_sw(window:end-window);
    time_sw=time_sw(window:end-window);
    time_sw=time_sw/1000/60; % minutes
    plot(time_sw,data_sw,color(c));
end
xlabel('time (min)');
ylabel(ylab);
return

function minis=add_isi(minis)
for c=1:length(minis)
    tmp=minis{c}(2:end,2)-minis{c}(1:end-1,2);
    minis{c}(1,end+1)=0;
    minis{c}(2:end,end)=tmp;
end
return

function minis=sort_time(minis)
for c=1:length(minis)
    [s,ind]=sort(minis{c}(:,2));
    minis{c}=minis{c}(ind,:);
end
return







