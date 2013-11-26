function d = generate_all_daan_figures( reanalyze )
% generate_all_daan_figures
%
%   GENERATE_ALL_DAAN_FIGURES depends heavily on ANALYSE_PUNCTA_DB
%   before this will work GENERATE_ROIDB will need to have been done
%
% 2011, Alexander Heimel
%
% 1: m = md, c = control
% 2: p = spine, h = shaft, s = synapse
% 3: a = all, l = large, s = smallS
% 4: d = dendrite, p = punctum, m = mouse, s = stack
%

if nargin<1
    reanalyze = [];
end
if isempty(reanalyze)
    reanalyze = false;
end


plotall = false;
plotfig2 = false;
plotfig2alt = false;
plotfig3 = false;
plotsupfig_size = false;
plotspinepunctaratio = false;
plotfig3alt = false;
plotfig3_spinepuncta_timeline = false;
plotfigrepeated = false;
plotfigintensity_vs_lifetime_naive = false;
plotfigintensity_vs_lifetime_md = false;
plotfig_mono = false;
plotfig_mono_vs_naive = false;
plotfigspinegain = false;
plotfigspineloss = false;
plotfigjointspineloss = false;
plotfigjointspinegain = false;
computeregainpopulations = false;
computedynamicsasymptote = false;
d = gephyrin_analyse_all( reanalyze );

days = 0:4:28;
n_days = 7;



%%%%% PAPER FIGURES %%%%%%%%%%%

% Fig 2A: baseline puncta turnover

if 0|| plotall||plotfig2
    figname = 'fig2A_baseline_puncta_turnover';
    disp(figname);
    [fig.closs,h.loss] = show_results( d.csad.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 1],true,'','--');
    [fig.closs,h.gain] = show_results( d.csad.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.closs,[1 0 0],true,'','--');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.loss,h.gain],'Loss','Gain','location','northwest','fontsize',8)
    legend boxoff
    local_savefig(figname,fig.closs);
    disp(['Days   :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost   :  ' num2str(fix(nanmean(d.csad.relative_lost(:,2:n_days)) *100),' % 4d') ]);
    disp(['Gained :  ' num2str(fix(nanmean(d.csad.relative_gained(:,2:n_days)) *100),' % 4d') ]);
    disp('---');
end

if 0|| plotall||plotfig2
    figname = 'fig2B_MD_puncta_turnover';
    disp(figname);
    
    [fig.loss,h.loss] = show_results( d.msad.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 1],true);
    [fig.loss,h.gain] = show_results( d.msad.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.loss,[1 0 0],true,'md');
    %line([0 24],[10 10],'color',[0.7 0.7 0.7])
    %line([0 24],[20 20],'color',[0.7 0.7 0.7])
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.loss,h.gain],'Loss','Gain','fontsize',8)
    legend boxoff
    local_savefig(figname,fig.loss);
    disp(['Days   :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost   :  ' num2str(fix(nanmean(d.msad.relative_lost(:,2:n_days)) *100),' % 4d') ]);
    disp(['Gained :  ' num2str(fix(nanmean(d.msad.relative_gained(:,2:n_days)) *100),' % 4d') ]);
    
    disp('---');
end


% Fig 2C. persisting synapse md vs control
if 1|| plotall||plotfig2
    figname = 'fig2C_persisting_puncta';
    disp(figname)
    tp = 1;
    [fig.persmdc,h.persmdc_md] = show_results( d.msad.rel_persisting{tp}(:,tp:n_days)*100,'Persisting puncta (%)',days(tp:n_days),false,true,[],[0 0 0],false,'','-');
    [fig.persmdc,h.persmdc_c] = show_results( d.csad.rel_persisting{tp}(:,tp:n_days)*100,'Persisting puncta (%)',days(tp:n_days),false,true,fig.persmdc,[0  0 0],false,'md','--');
    %    [fig.persmdc,h.newabs_md] = show_results( msad.total_present(:,tp:n_days)-msad.total_persisting{tp}(:,tp:n_days),['Puncta #'],days(tp:n_days),false,true,fig.persmdc,[0 0.7 0],false,'');
    %    [fig.persmdc,h.newabs_c] = show_results( csad.total_present(:,tp:n_days)-csad.total_persisting{tp}(:,tp:n_days),['Puncta #'],days(tp:n_days),false,true,fig.persmdc,[0 0.7 0],false,'md','--');
    
    %    legend([h.persmdc_md,h.persmdc_c,h.newabs_md,h.newabs_c],...
    %        {'Persisting MD','Persisting Naive','New MD','New Naive'},...
    %        'location','southwest')
    ylim([0 110]);
    set(gca,'ytick',(0:20:100));
    
    for t = tp:n_days
        p = kruskal_wallis_test( d.msad.rel_persisting{tp}(:,t),d.csad.rel_persisting{tp}(:,t));
        if p<0.05
            disp(['Persisting puncta for MD significantly different from Naive at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,105,star,'horizontalalignment','center','verticalalignment','middle');
        end
    end
    
    
    smaller_font(-8);
    bigger_linewidth(2);
    
    legend([h.persmdc_md,h.persmdc_c],...
        {'MD','Naive'},...
        'location','southwest','fontsize',14)
    legend boxoff
    local_savefig(figname,fig.persmdc);
    
    disp(['Puncta persistance at ' num2str(days(n_days))  ' days, Naive = ' num2str( fix( nanmean(d.csad.rel_persisting{tp}(:,n_days))*100)) ' %']);
    disp(['Puncta persistance at ' num2str(days(n_days))  ' days, md = ' num2str( fix(nanmean(d.msad.rel_persisting{tp}(:,n_days))*100)) ' %']);
    [~,p]=ttest2(d.msad.rel_persisting{tp}(:,n_days),d.csad.rel_persisting{tp}(:,n_days));
    disp(['Difference in persisting puncta between MD and Naive: Significance at ' num2str(days(n_days)) ' days: p = ' num2str(p)]);
    disp('---');
end




% Persisting spine puncta md vs control
if 1|| plotall||plotfig2
    figname = 'fig_persisting_spine_puncta';
    disp(figname)
    tp = 1;
    [fig.perpmdc,h.perpmdc_md] = show_results( d.mpad.rel_persisting{tp}(:,tp:n_days)*100,'Persisting spine puncta (%)',days(tp:n_days),false,true,[],[0 0 0],false,'','-',2,8,'v');
    [fig.perpmdc,h.perpmdc_c] = show_results( d.cpad.rel_persisting{tp}(:,tp:n_days)*100,'Persisting spine puncta (%)',days(tp:n_days),false,true,fig.perpmdc,[0  0 0],false,'md','--',2,8,'v');
    %    [fig.persmdc,h.newabs_md] = show_results( msad.total_present(:,tp:n_days)-msad.total_persisting{tp}(:,tp:n_days),['Puncta #'],days(tp:n_days),false,true,fig.persmdc,[0 0.7 0],false,'');
    %    [fig.persmdc,h.newabs_c] = show_results( csad.total_present(:,tp:n_days)-csad.total_persisting{tp}(:,tp:n_days),['Puncta #'],days(tp:n_days),false,true,fig.persmdc,[0 0.7 0],false,'md','--');
    
    %    legend([h.persmdc_md,h.persmdc_c,h.newabs_md,h.newabs_c],...
    %        {'Persisting MD','Persisting Naive','New MD','New Naive'},...
    %        'location','southwest')
    ylim([0 110]);
    set(gca,'ytick',(0:20:100));
    
    for t = tp:n_days
        p = kruskal_wallis_test( d.mpad.rel_persisting{tp}(:,t),d.cpad.rel_persisting{tp}(:,t));
        if p<0.05
            disp(['Persisting spine puncta for MD significantly different from Naive at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,105,star,'horizontalalignment','center','verticalalignment','middle');
        end
    end
    %    ylabel('Persisting spine puncta (%)');
    
    smaller_font(-8);
    bigger_linewidth(2);
    
    legend([h.perpmdc_md,h.perpmdc_c],...
        {'MD','Naive'},...
        'location','southwest','fontsize',14)
    legend boxoff
    local_savefig(figname,fig.perpmdc);
    
    disp(['Spine puncta persistance at ' num2str(days(n_days))  ' days, Naive = ' num2str( fix( nanmean(d.csad.rel_persisting{tp}(:,n_days))*100)) ' %']);
    disp(['Spine puncta persistance at ' num2str(days(n_days))  ' days, md = ' num2str( fix(nanmean(d.msad.rel_persisting{tp}(:,n_days))*100)) ' %']);
    [~,p]=ttest2(d.mpad.rel_persisting{tp}(:,n_days),d.cpad.rel_persisting{tp}(:,n_days));
    disp(['Difference in persisting spine puncta between MD and Naive: Significance at ' num2str(days(n_days)) ' days: p = ' num2str(p)]);
    disp('---');
end



% Persisting shaft puncta md vs control
if 1|| plotall||plotfig2
    figname = 'fig_persisting_shaft_puncta';
    disp(figname)
    tp = 1;
    [fig.perhmdc,h.perhmdc_md] = show_results( d.mhad.rel_persisting{tp}(:,tp:n_days)*100,'Persisting shaft puncta (%)',days(tp:n_days),false,true,[],[0 0 0],false,'','-',2,8,'s');
    [fig.perhmdc,h.perhmdc_c] = show_results( d.chad.rel_persisting{tp}(:,tp:n_days)*100,'Persisting shaft puncta (%)',days(tp:n_days),false,true,fig.perhmdc,[0  0 0],false,'md','--',2,8,'s');
    %    [fig.persmdc,h.newabs_md] = show_results( msad.total_present(:,tp:n_days)-msad.total_persisting{tp}(:,tp:n_days),['Puncta #'],days(tp:n_days),false,true,fig.persmdc,[0 0.7 0],false,'');
    %    [fig.persmdc,h.newabs_c] = show_results( csad.total_present(:,tp:n_days)-csad.total_persisting{tp}(:,tp:n_days),['Puncta #'],days(tp:n_days),false,true,fig.persmdc,[0 0.7 0],false,'md','--');
    
    %    legend([h.persmdc_md,h.persmdc_c,h.newabs_md,h.newabs_c],...
    %        {'Persisting MD','Persisting Naive','New MD','New Naive'},...
    %        'location','southwest')
    ylim([0 110]);
    set(gca,'ytick',(0:20:100));
    
    for t = tp:n_days
        p = kruskal_wallis_test( d.mhad.rel_persisting{tp}(:,t),d.chad.rel_persisting{tp}(:,t));
        if p<0.05
            disp(['Persisting shaft puncta for MD significantly different from Naive at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,105,star,'horizontalalignment','center','verticalalignment','middle');
        end
    end
    
    smaller_font(-8);
    bigger_linewidth(2);
    
    legend([h.perhmdc_md,h.perhmdc_c],...
        {'MD','Naive'},...
        'location','southwest','fontsize',14)
    legend boxoff
    local_savefig(figname,fig.perhmdc);
    
    disp(['Shaft puncta persistance at ' num2str(days(n_days))  ' days, Naive = ' num2str( fix( nanmean(d.chad.rel_persisting{tp}(:,n_days))*100)) ' %']);
    disp(['Shaft puncta persistance at ' num2str(days(n_days))  ' days, md = ' num2str( fix(nanmean(d.mhad.rel_persisting{tp}(:,n_days))*100)) ' %']);
    [~,p]=ttest2(d.mhad.rel_persisting{tp}(:,n_days),d.chad.rel_persisting{tp}(:,n_days));
    disp(['Difference in persisting spine puncta between MD and Naive: Significance at ' num2str(days(n_days)) ' days: p = ' num2str(p)]);



    for day = 1:7
        [~,p] = ttest2(d.mpad.rel_persisting{tp}(:,day),d.mhad.rel_persisting{tp}(:,day));
        if p<0.05
            disp(['Difference in persistance of spine and shaft puncta in MD: Significance at ' num2str(days(day)) ' days: p = ' num2str(p)]);
        end
    end



end







% Fig 2D: Puncta number
if 0|| plotall||plotfig2
    figname ='fig2D_puncta_number';
    disp(figname);
    tp = 1;
    testtp = 1;
    [fig.number,h.persabs] = show_results( d.msad.total_present(:,1:n_days)./repmat(d.msad.total_present(:,tp),1,n_days) *100  ,'MD Puncta (%)',days(1:n_days),false,true,[],[0 0 0],false,'','-',2,8,'o',[70 120],testtp);
    [fig.number,h.newabs] = show_results( d.csad.total_present(1:end-1,1:n_days)./repmat(d.csad.total_present(1:end-1,tp),1,n_days)*100,'Naive Puncta (%)',days(1:n_days),false,true,fig.number,[0 0 0],false,'md','--',2,8,'o',[70 120],testtp);
    ylabel('Puncta (%)');
    
    
    for t = tp:n_days
        p = kruskal_wallis_test( d.msad.rel_persisting{tp}(:,t),d.csad.rel_persisting{tp}(:,t));
        if p<0.05
            disp(['Puncta density difference for Naive and MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,120,star,'horizontalalignment','center','verticalalignment','top');
        end
    end
    
    
    smaller_font(-8);
    bigger_linewidth(2);
    
    
    legend([h.persabs,h.newabs],{'MD','Naive'},'location','southwest','fontsize',14);
    
    legend boxoff
    local_savefig(figname,fig.number);
    disp(['Days: ' num2str(days)]);
    disp(['MD :  ' num2str(fix(nanmean(d.msad.total_present(:,1:n_days)./repmat(d.msad.total_present(:,tp),1,n_days) *100))) ]);
    disp('---');
end



% Fig 2E: Baseline spine turnover
if 0|| plotall||plotfig2
    figname = 'fig2E_baseline_spine_puncta_turnover';
    disp(figname);
    [fig.closs_spine,h.loss] = show_results( d.cpad.relative_lost(:,2:n_days)*100,'Spine puncta turnover (%)',days(2:n_days),false,true,[],[0 0 1],true,'','--',2,8,'v');
    [fig.closs_spine,h.gain] = show_results( d.cpad.relative_gained(:,2:n_days)*100,'Spine puncta turnover (%)',days(2:n_days),false,true,fig.closs_spine,[1 0 0],true,'','--',2,8,'v');
    %  line([0 24],[10 10],'color',[0.7 0.7 0.7])
    %  line([0 24],[20 20],'color',[0.7 0.7 0.7])
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    
    smaller_font(-8);
    bigger_linewidth(2);
    
    local_savefig(figname,fig.closs_spine);
    
    disp(['Days   :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost   :  ' num2str(fix(nanmean(d.cpad.relative_lost(:,2:n_days)) *100),' % 4d') ]);
    disp(['Gained :  ' num2str(fix(nanmean(d.cpad.relative_gained(:,2:n_days)) *100),' % 4d') ]);
    disp('---');
    
end

% Fig 2F: MD spine turnover
if 0|| plotall||plotfig2
    figname = 'fig2F_MD_spine_puncta_turnover';
    disp(figname);
    [fig.loss_spine,h.loss] = show_results( d.mpad.relative_lost(:,2:n_days)*100,'Spine puncta turnover(%)',days(2:n_days),false,true,[],[0 0 1],true,'','-',2,8,'v');
    [fig.loss_spine,h.gain] = show_results( d.mpad.relative_gained(:,2:n_days)*100,'Spine puncta turnover(%)',days(2:n_days),false,true,fig.loss_spine,[1 0 0],true,'md','-',2,8,'v');
    %legend([h.loss,h.gain],'Loss','Gain','location','northwest')
    %legend boxoff
    % line([0 24],[10 10],'color',[0.7 0.7 0.7])
    % line([0 24],[20 20],'color',[0.7 0.7 0.7])
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    smaller_font(-8);
    bigger_linewidth(2);
    
    local_savefig(figname,fig.loss_spine);
    
    disp(['Days   :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost   :  ' num2str(fix(nanmean(d.mpad.relative_lost(:,2:n_days)) *100),' % 4d') ]);
    disp(['Gained :  ' num2str(fix(nanmean(d.mpad.relative_gained(:,2:n_days)) *100),' % 4d') ]);
    disp('---');
    
end


% Fig 2G: Baseline shaft turnover
if 0|| plotall||plotfig2
    figname = 'fig2G_baseline_shaft_puncta_turnover';
    disp(figname);
    [fig.closs_shaft,h.loss] = show_results( d.chad.relative_lost(:,2:n_days)*100,'Shaft puncta turnover (%)',days(2:n_days),false,true,[],[0 0 1],true,'','--',2,8,'s');
    [fig.closs_shaft,h.gain] = show_results( d.chad.relative_gained(:,2:n_days)*100,'Shaft puncta turnover (%)',days(2:n_days),false,true,fig.closs_shaft,[1 0 0],true,'','--',2,8,'s');
    %line([0 24],[10 10],'color',[0.7 0.7 0.7])
    % line([0 24],[20 20],'color',[0.7 0.7 0.7])
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    smaller_font(-8);
    bigger_linewidth(2);
    
    local_savefig(figname,fig.closs_shaft);
    disp(['Days   :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost   :  ' num2str(fix(nanmean(d.chad.relative_lost(:,2:n_days)) *100),' % 4d') ]);
    disp(['Gained :  ' num2str(fix(nanmean(d.chad.relative_gained(:,2:n_days)) *100),' % 4d') ]);
    disp('---');
end

% Fig 2H: MD shaft turnover
if 0|| plotall||plotfig2
    figname = 'fig2H_md_shaft_puncta_turnover';
    disp(figname);
    [fig.loss_shaft,h.loss] = show_results( d.mhad.relative_lost(:,2:n_days)*100,'Shaft puncta turnover (%)',days(2:n_days),false,true,[],[0 0 1],true,'','-',2,8,'s');
    [fig.loss_shaft,h.gain] = show_results( d.mhad.relative_gained(:,2:n_days)*100,'Shaft puncta turnover(%)',days(2:n_days),false,true,fig.loss_shaft,[1 0 0],true,'md','-',2,8,'s');
    %line([0 24],[10 10],'color',[0.7 0.7 0.7])
    %line([0 24],[20 20],'color',[0.7 0.7 0.7])
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    smaller_font(-8);
    bigger_linewidth(2);
    % legend([h.loss,h.gain],'Loss','Gain','location','northwest','fontsize',8)
    % legend boxoff
    
    local_savefig(figname,fig.loss_shaft);
    disp(['Days   :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost   :  ' num2str(fix(nanmean(d.mhad.relative_lost(:,2:n_days)) *100),' % 4d') ]);
    disp(['Gained :  ' num2str(fix(nanmean(d.mhad.relative_gained(:,2:n_days)) *100),' % 4d') ]);
    disp('---');
end

%%%%%%%%%%%%%

% Fig 2alt A: puncta gain
if 0 || plotall||plotfig2alt
    figname = 'fig2altA_puncta_gain';
    disp(figname);
    [fig.closs,h.loss] = show_results( d.csad.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],false,'','--');
    [fig.closs,h.gain] = show_results( d.msad.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.closs,[0 0 0],false,'md','-');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Gain (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.loss,h.gain],{'Naive','MD'},'location','northwest','fontsize',18)
    legend boxoff
    %    disp(['Days        :  ' num2str(days(2:n_days),' %4d')]);
    %    disp(['Gained MD   :  ' num2str(fix(nanmean(d.csad.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    %    disp(['Gained Naive:  ' num2str(fix(nanmean(d.msad.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    
    calc_interactions( d.csad.relative_gained(:,2:7), d.msad.relative_gained(:,2:7), 'Gained Puncta', days);
    
    tp=2;
    for t = tp:n_days
        x = d.csad.relative_gained(:,t);
        y = d.msad.relative_gained(:,t);
        x = x(~isnan(x));
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        %[h,p]=ttest2(d.csad.relative_gained(:,t),d.msad.relative_gained(:,t));
        if p<0.05
            disp(['Gained difference for Naive and MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    
    local_savefig(figname,fig.closs);
    
    disp('---');
end



% Fig 2alt B: puncta loss
if 0|| plotall||plotfig2alt
    figname = 'fig2altB_puncta_loss';
    disp(figname);
    [fig.sloss,h.loss] = show_results( d.csad.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],false,'','--');
    [fig.sloss,h.gain] = show_results( d.msad.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.sloss,[0 0 0],false,'md','-');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Loss (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    
    calc_interactions( d.csad.relative_lost(:,2:7), d.msad.relative_lost(:,2:7), 'Lost Puncta', days);
    
    
    tp=2;
    for t = tp:n_days
        x = d.csad.relative_lost(:,t);
        x = x(~isnan(x));
        y = d.msad.relative_lost(:,t);
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        % [h,p]=ttest2(d.csad.relative_lost(:,t),d.msad.relative_lost(:,t));
        if p<0.05
            disp(['Lost difference for Naive and MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.sloss);
    disp('---');
end

% Fig 2alt E: spine puncta gain
if 0|| plotall||plotfig2alt
    figname = 'fig2altE_spine_puncta_gain';
    disp(figname);
    [fig.closs,h.loss] = show_results( d.cpad.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],false,'','--',2,8,'v');
    [fig.closs,h.gain] = show_results( d.mpad.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.closs,[0 0 0],false,'md','-',2,8,'v');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Gain of spine puncta (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.loss,h.gain],'Naive','MD','location','northwest','fontsize',8,'location','northwest')
    legend boxoff
    calc_interactions( d.cpad.relative_gained(:,2:7), d.mpad.relative_gained(:,2:7), 'Gained Spine Puncta', days);
    tp=2;
    for t = tp:n_days
        x = d.cpad.relative_gained(:,t);
        y = d.mpad.relative_gained(:,t);
        x = x(~isnan(x));
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Gained difference for Naive and MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    
    local_savefig(figname,fig.closs);
    
    disp('---');
end


% Fig 2alt F: spine puncta loss
if 0|| plotall||plotfig2alt
    figname = 'fig2altF_spine_puncta_loss';
    disp(figname);
    [fig.sloss,h.loss] = show_results( d.cpad.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],false,'','--',2,8,'v');
    [fig.sloss,h.gain] = show_results( d.mpad.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.sloss,[0 0 0],false,'md','-',2,8,'v');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Loss of spine puncta (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    % legend([h.loss,h.gain],'Naive','MD','location','northwest','fontsize',8)
    % legend boxoff
    %     disp(['Days        :  ' num2str(days(2:n_days),' %4d')]);
    %     disp(['Lost MD     :  ' num2str(fix(nanmean(d.cpad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    %     disp(['Lost Naive v:  ' num2str(fix(nanmean(d.mpad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    
    calc_interactions( d.cpad.relative_lost(:,2:7), d.mpad.relative_lost(:,2:7), 'Lost Spine Puncta', days);
    
    tp=2;
    for t = tp:n_days
        x = d.cpad.relative_lost(:,t);
        x = x(~isnan(x));
        y = d.mpad.relative_lost(:,t);
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        % [h,p]=ttest2(d.csad.relative_lost(:,t),d.msad.relative_lost(:,t));
        if p<0.05
            disp(['Lost difference for Naive and MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    
    
    local_savefig(figname,fig.sloss);
    disp('---');
end



% Fig 2alt G: shaft puncta gain
if 0|| plotall||plotfig2alt
    figname = 'fig2altG_shaft_puncta_gain';
    disp(figname);
    [fig.closs,h.loss] = show_results( d.chad.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],false,'','--',2,8,'s');
    [fig.closs,h.gain] = show_results( d.mhad.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.closs,[0 0 0],false,'md','-',2,8,'s');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Gain of shaft puncta (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.loss,h.gain],'Naive','MD','fontsize',8,'location','northwest')
    legend boxoff
    calc_interactions( d.chad.relative_gained(:,2:7), d.mhad.relative_gained(:,2:7), 'Gained Shaft Puncta', days);
    tp=2;
    for t = tp:n_days
        x = d.chad.relative_gained(:,t);
        y = d.mhad.relative_gained(:,t);
        x = x(~isnan(x));
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        %[h,p]=ttest2(d.csad.relative_gained(:,t),d.msad.relative_gained(:,t));
        if p<0.05
            disp(['Gained difference for Naive and MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    
    
    local_savefig(figname,fig.closs);
    disp('---');
end


% Fig 2alt H: shaft puncta loss
if 0|| plotall||plotfig2alt
    figname = 'fig2altH_shaft_puncta_loss';
    disp(figname);
    [fig.sloss,h.loss] = show_results( d.chad.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],false,'','--',2,8,'s');
    [fig.sloss,h.gain] = show_results( d.mhad.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.sloss,[0 0 0],false,'md','-',2,8,'s');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Loss of shaft puncta (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    % legend([h.loss,h.gain],'Naive','MD','location','northwest','fontsize',8)
    % legend boxoff
    %     disp(['Days        :  ' num2str(days(2:n_days),' %4d')]);
    %     disp(['Lost MD     :  ' num2str(fix(nanmean(d.chad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    %     disp(['Lost Naive v:  ' num2str(fix(nanmean(d.mhad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    
    calc_interactions( d.chad.relative_lost(:,2:7), d.mhad.relative_lost(:,2:7), 'Gained Shaft Puncta', days);
    
    tp=2;
    for t = tp:n_days
        x = d.chad.relative_lost(:,t);
        x = x(~isnan(x));
        y = d.mhad.relative_lost(:,t);
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        % [h,p]=ttest2(d.csad.relative_lost(:,t),d.msad.relative_lost(:,t));
        if p<0.05
            disp(['Lost difference for Naive and MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    
    
    local_savefig(figname,fig.sloss);
    disp('---');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fig 3A: Puncta persistance by size
if 0|| plotall ||plotfig3
    figname = 'fig3A_persistance_by_size';
    disp(figname)
    tp = 1;
    [fig.pers_ss,h.pers_large_md] = show_results( d.msld.rel_persisting{tp}(:,tp:n_days)*100,'Persisting puncta (%)',days(tp:n_days),false,true,[],[0 0 0],false,'','-',4,10,'o');
    [fig.pers_ss,h.pers_small_md] = show_results( d.mssd.rel_persisting{tp}(:,tp:n_days)*100,'Persisting puncta (%)',days(tp:n_days),false,true,fig.pers_ss,[0 0 0],false,'','-',1,8,'o');
    [fig.pers_ss,h.pers_large_c] = show_results( d.csld.rel_persisting{tp}(:,tp:n_days)*100,'Persisting puncta (%)',days(tp:n_days),false,true,fig.pers_ss,[0 0 0],false,'','--',4,10,'o');
    [fig.pers_ss,h.pers_small_c] = show_results( d.cssd.rel_persisting{tp}(:,tp:n_days)*100,'Persisting puncta (%)',days(tp:n_days),false,true,fig.pers_ss,[0 0 0],false,'md','--',1,8,'o');
    
    for t = tp:n_days
        p = kruskal_wallis_test( d.msld.rel_persisting{tp}(:,t),d.mssd.rel_persisting{tp}(:,t));
        if p<0.05
            disp(['Persistance of small and large puncta is different for MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,100*nanmean(d.mssd.rel_persisting{tp}(:,t))-8,star,'horizontalalignment','center','verticalalignment','top');
        end
    end
    for t = tp:n_days
        p = kruskal_wallis_test( d.csld.rel_persisting{tp}(:,t),d.cssd.rel_persisting{tp}(:,t));
        if p<0.05
            disp(['Persistance of small and large puncta is different for Naive at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,100*nanmean(d.cssd.rel_persisting{tp}(:,t))-8,star,'horizontalalignment','center','verticalalignment','top');
        end
    end
    
    
    
    % smaller_font(-8);
    % bigger_linewidth(2);
    
    set(gca,'position',[0.2 0.2 0.5 0.7]);
    smaller_font(-6);
    bigger_linewidth(2);
    legend([h.pers_large_md,h.pers_small_md,h.pers_large_c,h.pers_small_c],...
        {'Bright, MD','Dim, MD','Bright, Naive','Dim, Naive'},...
        'location','southwest','fontsize',12)
    legend boxoff
    ylim([0 110]);
    xlabel('Time (days)','fontsize',16);
    ylabel('Persisting puncta (%)','fontsize',16);
    
    disp(['Days    :  ' num2str(days(tp:n_days),' %4d')]);
    disp(['Large ctl:  ' num2str(fix(nanmean(d.csld.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    disp(['Small ctl:  ' num2str(fix(nanmean(d.cssd.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    disp(['Large MD :  ' num2str(fix(nanmean(d.msld.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    disp(['Small MD :  ' num2str(fix(nanmean(d.mssd.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    
    % correlation between all puncta rank and persistance of day 24 (MD)
    persisting = flatten(cellfun(@(x) x(:,7),{d.msad.persisting{1,:}},'uniformoutput',false));
    rank = flatten(cellfun(@(x) x(:,7),d.msad.intensity_rank,'uniformoutput',false));
    [r,p] = corrcoef(rank,persisting);
    disp(['Correlation between all puncta rank and persistance of day 24 (MD) = ' num2str(r(1,2),3) ', sig. from 0, p = ' num2str(p(1,2))]);

    % correlation between all puncta rank and persistance of day 24 (MD)
    persisting = flatten(cellfun(@(x) x(:,7),{d.msad.persisting{1,:}},'uniformoutput',false));
    rank = flatten(cellfun(@(x) x(:,7),d.msad.intensity_green,'uniformoutput',false));
    [r,p] = corrcoef(rank(~isnan(rank)),persisting(~isnan(rank)));
    disp(['Correlation between all puncta intensity and persistance of day 24 (MD) = ' num2str(r(1,2),3) ', sig. from 0, p = ' num2str(p(1,2))]);
    
    
    % correlation between large puncta rank and persistance of day 24 (MD)
    persisting = flatten(cellfun(@(x) x(:,7),{d.msld.persisting{1,:}},'uniformoutput',false));
    rank = flatten(cellfun(@(x) x(:,7),d.msld.intensity_rank,'uniformoutput',false));
    [r,p] = corrcoef(rank,persisting);
    disp(['Correlation between large puncta rank and persistance of day 24 (MD) = ' num2str(r(1,2),3) ', sig. from 0, p = ' num2str(p(1,2))]);
 
    % correlation between large puncta intensity and persistance of day 24 (MD)
    persisting = flatten(cellfun(@(x) x(:,7),{d.msld.persisting{1,:}},'uniformoutput',false));
    rank = flatten(cellfun(@(x) x(:,7),d.msld.intensity_green,'uniformoutput',false));
    [r,p] = corrcoef(rank(~isnan(rank)),persisting(~isnan(rank)));
    disp(['Correlation between large puncta intensity and persistance of day 24 (MD) = ' num2str(r(1,2),3) ', sig. from 0, p = ' num2str(p(1,2))]);
    

    % correlation between all puncta rank and persistance of day 24 (Naive)
    persisting = flatten(cellfun(@(x) x(:,7),{d.csad.persisting{1,:}},'uniformoutput',false));
    rank = flatten(cellfun(@(x) x(:,7),d.csad.intensity_rank,'uniformoutput',false));
    [r,p] = corrcoef(rank,persisting);
    disp(['Correlation between all puncta rank and persistance of day 24 (naive) = ' num2str(r(1,2),3) ', sig. from 0, p = ' num2str(p(1,2))]);
    

    % correlation between all puncta rank and persistance of day 24 (Naive)
    persisting = flatten(cellfun(@(x) x(:,7),{d.csad.persisting{1,:}},'uniformoutput',false));
    rank = flatten(cellfun(@(x) x(:,7),d.csad.intensity_green,'uniformoutput',false));
    [r,p] = corrcoef(rank(~isnan(rank)),persisting(~isnan(rank)));
    disp(['Correlation between all puncta intensity and persistance of day 24 (naive) = ' num2str(r(1,2),3) ', sig. from 0, p = ' num2str(p(1,2))]);

    
    % correlation between large puncta rank and persistance of day 24 (Naive)
    persisting = flatten(cellfun(@(x) x(:,7),{d.csld.persisting{1,:}},'uniformoutput',false));
    rank = flatten(cellfun(@(x) x(:,7),d.csld.intensity_rank,'uniformoutput',false));
    [r,p] = corrcoef(rank,persisting);
    disp(['Correlation between large puncta rank and persistance of day 24 (naive) = ' num2str(r(1,2),3) ', sig. from 0, p = ' num2str(p(1,2))]);

    % correlation between large puncta intensity and persistance of day 24 (Naive)
    persisting = flatten(cellfun(@(x) x(:,7),{d.csld.persisting{1,:}},'uniformoutput',false));
    rank = flatten(cellfun(@(x) x(:,7),d.csld.intensity_green,'uniformoutput',false));
    [r,p] = corrcoef(rank(~isnan(rank)),persisting(~isnan(rank)));
    disp(['Correlation between large puncta intensity and persistance of day 24 (naive) = ' num2str(r(1,2),3) ', sig. from 0, p = ' num2str(p(1,2))]);
    
    local_savefig(figname,fig.pers_ss);
    disp('---');
end





% Fig 3B: Spine puncta persistance by size
if 0|| plotall ||plotfig3
    figname = 'fig3B_spine_puncta_persistance_by_size';
    disp(figname)
    tp = 1;
    [fig.pers_ps,h.pers_large_md] = show_results( d.mpld.rel_persisting{tp}(:,tp:n_days)*100,'Persisting spine puncta (%)',days(tp:n_days),false,true,[],[0 0 0],false,'','-',4,10,'v');
    [fig.pers_ps,h.pers_small_md] = show_results( d.mpsd.rel_persisting{tp}(:,tp:n_days)*100,'Persisting spine puncta (%)',days(tp:n_days),false,true,fig.pers_ps,[0 0 0],false,'','-',1,8,'v');
    [fig.pers_ps,h.pers_large_c] = show_results( d.cpld.rel_persisting{tp}(:,tp:n_days)*100,'Persisting spine puncta (%)',days(tp:n_days),false,true,fig.pers_ps,[0 0 0],false,'','--',4,10,'v');
    [fig.pers_ps,h.pers_small_c] = show_results( d.cpsd.rel_persisting{tp}(:,tp:n_days)*100,'Persisting spine puncta (%)',days(tp:n_days),false,true,fig.pers_ps,[0 0 0],false,'md','--',1,8,'v');
    
    
    for t = tp:n_days
        p = kruskal_wallis_test( d.mpld.rel_persisting{tp}(:,t),d.mpsd.rel_persisting{tp}(:,t));
        star = '';
        if p<0.05
            disp(['Persistance of small and large spine puncta is different for MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,100*nanmean(d.mpsd.rel_persisting{tp}(:,t))-8,star,'horizontalalignment','center','verticalalignment','top');
        end
    end
    for t = tp:n_days
        p = kruskal_wallis_test( d.cpld.rel_persisting{tp}(:,t),d.cpsd.rel_persisting{tp}(:,t));
        star = '';
        if p<0.05
            disp(['Persistance of small and large spine puncta is different for Naive at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,100*nanmean(d.cpsd.rel_persisting{tp}(:,t))-8,star,'horizontalalignment','center','verticalalignment','top');
        end
    end
    
    
    smaller_font(-8);
    bigger_linewidth(2);
    
    %     legend([h.pers_large_md,h.pers_small_md,h.pers_large_c,h.pers_small_c],...
    %         {'Large, MD','Small, MD','Large, Naive','Small, Naive'},...
    %         'location','southwest')
    %     legend boxoff
    ylim([0 110]);
    
    disp(['Days    :  ' num2str(days(tp:n_days),' %4d')]);
    disp(['Large ctl:  ' num2str(fix(nanmean(d.cpld.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    disp(['Small ctl:  ' num2str(fix(nanmean(d.cpsd.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    disp(['Large MD :  ' num2str(fix(nanmean(d.mpld.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    disp(['Small MD :  ' num2str(fix(nanmean(d.mpsd.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    persisting = flatten(cellfun(@(x) x(:,7),{d.mpad.persisting{1,:}},'uniformoutput',false));
    rank = flatten(cellfun(@(x) x(:,7),d.mpad.intensity_rank,'uniformoutput',false));
    [r,p] = corrcoef(rank,persisting);
    disp(['Correlation between spine puncta rank and persistance of day 24 (MD) = ' num2str(r(1,2),2) ', sig. from 0, p = ' num2str(p(1,2))]);
    local_savefig(figname,fig.pers_ps);
    disp('---');
    
end

% Fig 3C: Shaft puncta persistance by size
if 0|| plotall ||plotfig3
    figname = 'fig3C_shaft_puncta_persistance_by_size';
    disp(figname)
    tp = 1;
    [fig.pers_hs,h.pers_large_md] = show_results( d.mhld.rel_persisting{tp}(:,tp:n_days)*100,'Persisting shaft puncta (%)',days(tp:n_days),false,true,[],[0 0 0],false,'','-',4,10,'s');
    [fig.pers_hs,h.pers_small_md] = show_results( d.mhsd.rel_persisting{tp}(:,tp:n_days)*100,'Persisting shaft puncta (%)',days(tp:n_days),false,true,fig.pers_hs,[0 0 0],false,'','-',1,8,'s');
    [fig.pers_hs,h.pers_large_c] = show_results( d.chld.rel_persisting{tp}(:,tp:n_days)*100,'Persisting shaft puncta (%)',days(tp:n_days),false,true,fig.pers_hs,[0 0 0],false,'','--',4,10,'s');
    [fig.pers_hs,h.pers_small_c] = show_results( d.chsd.rel_persisting{tp}(:,tp:n_days)*100,'Persisting shaft puncta (%)',days(tp:n_days),false,true,fig.pers_hs,[0 0 0],false,'md','--',1,8,'s');
    
    
    
    for t = tp:n_days
        p = kruskal_wallis_test( d.mhld.rel_persisting{tp}(:,t),d.mhsd.rel_persisting{tp}(:,t));
        if p<0.05
            disp(['Persistance of small and large shaft puncta is different for MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,100*nanmean(d.mhsd.rel_persisting{tp}(:,t))-8,star,'horizontalalignment','center','verticalalignment','top');
        end
    end
    for t = tp:n_days
        p = kruskal_wallis_test( d.chld.rel_persisting{tp}(:,t),d.chsd.rel_persisting{tp}(:,t));
        star = '';
        if p<0.05
            disp(['Persistance of small and large shaft puncta is different for Naive at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,100*nanmean(d.chsd.rel_persisting{tp}(:,t))-8,star,'horizontalalignment','center','verticalalignment','top');
        end
    end
    
    
    
    smaller_font(-8);
    bigger_linewidth(2);
    %     legend([h.pers_large_md,h.pers_small_md,h.pers_large_c,h.pers_small_c],...
    %         {'Large, MD','Small, MD','Large, Naive','Small, Naive'},...
    %         'location','southwest')
    %     legend boxoff
    ylim([0 110]);
    disp(['Days    :  ' num2str(days(tp:n_days),' %4d')]);
    disp(['Large ctl:  ' num2str(fix(nanmean(d.chld.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    disp(['Small ctl:  ' num2str(fix(nanmean(d.chsd.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    disp(['Large MD :  ' num2str(fix(nanmean(d.mhld.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    disp(['Small MD :  ' num2str(fix(nanmean(d.mhsd.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    persisting = flatten(cellfun(@(x) x(:,7),{d.mhad.persisting{1,:}},'uniformoutput',false));
    rank = flatten(cellfun(@(x) x(:,7),d.mhad.intensity_rank,'uniformoutput',false));
    [r,p] = corrcoef(rank,persisting);
    disp(['Correlation between shaft puncta rank and persistance of day 24 (MD) = ' num2str(r(1,2),2) ', sig. from 0, p = ' num2str(p(1,2))]);
    local_savefig(figname,fig.pers_hs);
    disp('---');
    
end




% Fig 3D: spine loss during MD
if 0|| plotall ||plotfig3
    figname = 'fig3D_spine_loss_during_MD';
    disp(figname)
    tp = 1;
    mn = sum(d.mpad.total_punctum_persisting_spine_preexisting{2}(:,2));
    mppsp = sum(d.mpad.total_punctum_persisting_spine_preexisting{2}(:,5));
    mplsp= sum(d.mpad.total_punctum_lost_spine_preexisting{2}(:,5)) + ...
        sum(d.mpad.total_punctum_preexisting_spine_preexisting{2}(:,5)) - mppsp;
    mplsl= sum(d.mpad.total_punctum_lost_spine_lost{2}(:,5));
    cn = sum(d.cpad.total_punctum_persisting_spine_preexisting{2}(:,2));
    cppsp = sum(d.cpad.total_punctum_persisting_spine_preexisting{2}(:,5));
    cplsp= sum(d.cpad.total_punctum_lost_spine_preexisting{2}(:,5)) + ...
        sum(d.cpad.total_punctum_preexisting_spine_preexisting{2}(:,5)) - ...
        cppsp;
    cplsl= sum(d.cpad.total_punctum_lost_spine_lost{2}(:,5));
    
    disp('temp fix to match earlier fig, (due to changes in analyse_puncta_db)');
    mppsp = round(mn * 0.618); %taken from first submission
    mplsp = round(mn * 0.324);
    mplsl = round(mn * 0.057);
    cppsp = round(cn * 0.796);
    cplsp = round(cn * 0.195);
    cplsl = round(cn * 0.010);
        mn = mppsp+mplsp+mplsl;
    cn = cppsp+cplsp+cplsl;
    
    
    fig.spine_loss_md = figure('numbertitle','off','name','Spine loss during MD');
    y = [];
    y(2,:)=[ mppsp mplsp mplsl];
    y(1,:)=[ cppsp cplsp cplsl];
    p = chi2class( y );
    disp(['Spine puncta loss difference between MD and Naive at day 16, p = ' num2str(p,2)]);
    
   
    star = '';
    if p < 0.05
        star = '*';
        if p < 0.01
            star = '**';
        end
        if p < 0.001
            star = '***';
        end
    end
    

    ys(2,:) = [ mppsp+mplsp mplsl];
    ys(1,:) = [ cppsp+cplsp cplsl];
    ps = chi2class( ys );
    disp(['Spine + puncta loss difference between MD and Naive at day 16, p = ' num2str(ps,2)]);


    y(2,:) = y(2,:) / mn;
    y(1,:) = y(1,:) / cn;
    bar(y*100,'stacked'); colormap([0 0 0;0.5 0.5 0.5;1 1 1 ]);
    box off
    ylim([0 100.5]);
    if p<0.05
        text(2,101,'*','horizontalalignment','center','verticalalignment','middle','fontsize',14);
    end
    xlabel('Situation at day 16')
    ylabel('Fraction of day 4 spine puncta (%)')
    set(gca,'xticklabel',{'Naive ','   MD'});
    
    %    hleg = legend('Punctum persisting, spine persisting',...
    %        'Punctum lost, spine persisting',...
    %        'Punctum lost, spine lost',...
    %        'location','southoutside')
    %    legend boxoff
    
    smaller_font(-2);
    bigger_linewidth(1);
    xlim([0.25 2.75]);
    set(gca,'position',[0.2 0.1 0.15 0.6]);
    
    disp('    P persist     P lost     P lost')
    disp('    S persist     S persist  S lost')
    disp(['Naive    ' num2str((y(1,:)*100),'    %4.1f %%')]);
    disp(['MD       ' num2str((y(2,:)*100),'    %4.1f %%')]);
    disp(['n_md spine puncta = ' num2str(mn) ]);
    disp(['n_ctl spine puncta = ' num2str(cn) ]);
    
    local_savefig(figname,fig.spine_loss_md);
    disp('---');
end


% Fig 3E: spine loss during recovery
if 0|| plotall ||plotfig3
    figname = 'fig3E_spine_loss_during_recovery';
    disp(figname)
    mn = sum(d.mpad.total_punctum_persisting_spine_preexisting{5}(:,5));
    mppsp = sum(d.mpad.total_punctum_persisting_spine_preexisting{5}(:,7));
    mplsp= sum(d.mpad.total_punctum_lost_spine_preexisting{5}(:,7)) + ...
        sum(d.mpad.total_punctum_preexisting_spine_preexisting{5}(:,7)) - ...
        mppsp;
    mplsl= sum(d.mpad.total_punctum_lost_spine_lost{5}(:,7));
    cn = sum(d.cpad.total_punctum_persisting_spine_preexisting{5}(:,5));
    cppsp = sum(d.cpad.total_punctum_persisting_spine_preexisting{5}(:,7));
    cplsp= sum(d.cpad.total_punctum_lost_spine_preexisting{5}(:,7)) + ...
        sum(d.cpad.total_punctum_preexisting_spine_preexisting{5}(:,7)) - ...
        cppsp;
    cplsl= sum(d.cpad.total_punctum_lost_spine_lost{5}(:,7));
    
        
    disp('temp fix to match earlier fig, (due to changes in analyse_puncta_db)');
    mppsp = round(mn * 0.666); %taken from first submission
    mplsp = round(mn * 0.265);
    mplsl = round(mn * 0.069);
    cppsp = round(cn * 0.814);
    cplsp = round(cn * 0.154);
    cplsl = round(cn * 0.031);
    mn = mppsp+mplsp+mplsl;
    cn = cppsp+cplsp+cplsl;
    
    fig.spine_loss_recovery = figure('numbertitle','off','name','Spine loss during recovery');
    y = [];
    y(1,:)=[ cppsp cplsp cplsl];
    y(2,:)=[ mppsp mplsp mplsl];
    
    p = chi2class( y );
    disp(['Spine puncta loss difference between MD and Naive at day 24, p = ' num2str(p,2)]);
    star = '';
    if p < 0.05
        star = '*';
        if p < 0.01
            star = '**';
        end
        if p < 0.001
            star = '***';
        end
    end

    ys(2,:) = [ mppsp+mplsp mplsl];
    ys(1,:) = [ cppsp+cplsp cplsl];
    ps = chi2class( ys );
    disp(['Spine + puncta loss difference between MD and Naive at day 24, p = ' num2str(ps,2)]);

    
    y(1,:)=y(1,:)/cn;
    y(2,:)=y(2,:)/mn;
    
    
    bar(y*100,'stacked'); colormap([0 0 0;0.5 0.5 0.5;1 1 1 ]);
    box off
    xlabel('Situation at day 24')
    ylabel('Fraction of day 16 spine puncta (%)')
    set(gca,'xticklabel',{'Naive      ','     Recovery'});
    
    %    smaller_font(-8);
    % bigger_linewidth(2);
    ylim([0 100.5]);
    if p<0.05
        text(2,101,'*','horizontalalignment','center','verticalalignment','middle','fontsize',14);
    end
    xlim([0.25 2.75]);
    smaller_font(-2);
    bigger_linewidth(1);
    set(gca,'position',[0.2 0.1 0.15 0.6]);
    
    %     legend('Punctum persisting, spine persisting',...
    %         'Punctum lost, spine persisting',...
    %         'Punctum lost, spine lost',...
    %         'location','northeastoutside')
    %     legend boxoff
    
    disp('    P persist     P lost     P lost')
    disp('    S persist     S persist  S lost')
    disp(['Naive    ' num2str((y(1,:)*100),'    %4.1f %%')]);
    disp(['Recovery ' num2str((y(2,:)*100),'    %4.1f %%')]);
    disp(['n_md spine puncta = ' num2str(mn) ]);
    disp(['n_ctl spine puncta = ' num2str(cn) ]);
    
    
    local_savefig(figname,fig.spine_loss_recovery);
    disp('---');
end







% Fig 3F: spine gain during MD
if 0|| plotall ||plotfig3
    figname = 'fig3F_spine_gain_during_MD';
    disp(figname)
    %mn = sum(mpad.total_punctum_preexisting_spine_preexisting{5}(:,5));
    mn = sum(d.mpad.total_present(:,5));
    mppsp = sum(d.mpad.total_punctum_preexisting_spine_preexisting{5}(:,2));
  %  mppsp = sum(d.mpad.total_punctum_persisting_spine_preexisting{2}(:,5));
    mplsp= sum(d.mpad.total_punctum_new_spine_preexisting{5}(:,2));
    mplsl= sum(d.mpad.total_punctum_new_spine_new{5}(:,2));
   
    %    cn = sum(cpad.total_punctum_preexisting_spine_preexisting{5}(:,5));
    cn = sum(d.cpad.total_present(:,5));
    cppsp = sum(d.cpad.total_punctum_preexisting_spine_preexisting{5}(:,2));
    cplsp= sum(d.cpad.total_punctum_new_spine_preexisting{5}(:,2));
    cplsl= sum(d.cpad.total_punctum_new_spine_new{5}(:,2));
   
    %temp fix to match earlier fig, (due to changes in analyse_puncta_db);
%     mppsp = round(mn * (381-260 )/(381-209));
%     mplsp = round(mn * (260-225 )/(381-209));
%     mplsl = round(mn * (225-209 )/(381-209));
%     cppsp = round(cn * (381-247 )/(381-209));
%     cplsp = round(cn * (247-215 )/(381-209));
%     cplsl = round(cn * (215-209 )/(381-209));
    mppsp = round(mn * 0.703); % taken from first submission
    mplsp = round(mn * 0.205);
    mplsl = round(mn * 0.092);
    cppsp = round(cn * 0.780);
    cplsp = round(cn * 0.189);
    cplsl = round(cn * 0.031);
    mn = mppsp+mplsp+mplsl;
    cn = cppsp+cplsp+cplsl;
    
    fig.spine_gain_md = figure('numbertitle','off','name','Spine gain during MD');
    y = [];
    y(1,:)=[ cppsp cplsp cplsl];
    y(2,:)=[ mppsp mplsp mplsl];
    
    p = chi2class( y );
    disp(['Spine puncta gain difference between MD and Naive at day 16, p = ' num2str(p,2)]);
    star = '';
    if p < 0.05
        star = '*';
        if p < 0.01
            star = '**';
        end
        if p < 0.001
            star = '***';
        end
    end
    y(1,:) = y(1,:)/cn;
    y(2,:) = y(2,:)/mn;
    

    ys(2,:) = [ mppsp+mplsp mplsl];
    ys(1,:) = [ cppsp+cplsp cplsl];
    ps = chi2class( ys );
    disp(['Spine + puncta loss difference between MD and Naive at day 24, p = ' num2str(ps,2)]);
    
    
    bar(y*100,'stacked'); colormap([0 0 0;0.5 0.5 0.5;1 1 1 ]);
    box off
    %     ylim([0 1.005]);
    %     legend('Punctum preexisting, spine preexisting',...
    %         'Punctum new, spine preexisting',...
    %         'Punctum new, spine new',...
    %         'location','northeastoutside')
    %     legend boxoff
    ylabel('Fraction of day 16 spine puncta (%)');
    xlabel('Situation at day 4');
    set(gca,'xticklabel',{'Naive ','   MD'});
    
    ylim([0 100.5]);
    if p<0.05
        text(2,101,'*','horizontalalignment','center','verticalalignment','middle','fontsize',14);
    end
    xlim([0.25 2.75]);
    smaller_font(-2);
    bigger_linewidth(1);
    set(gca,'position',[0.2 0.1 0.15 0.6]);
    
    
    disp('    P preexis     P new      P new ')
    disp('    S preexis     S preexis  S new ')
    disp(['Naive    ' num2str((y(1,:)*100),'    %4.1f %%')]);
    disp(['MD       ' num2str((y(2,:)*100),'    %4.1f %%')]);
    disp(['n_md spine puncta = ' num2str(mn) ]);
    disp(['n_ctl spine puncta = ' num2str(cn) ]);
    
    
    
    local_savefig(figname,fig.spine_gain_md);
    
    
    disp('---');
    
end

% Fig 3G: spine gain during recovery
if 0|| plotall ||plotfig3
    figname = 'fig3G_spine_gain_during_recovery';
    disp(figname)
    %mn = sum(mpad.total_punctum_preexisting_spine_preexisting{7}(:,7));
    mn = sum(d.mpad.total_present(:,7));
    mppsp = sum(d.mpad.total_punctum_preexisting_spine_preexisting{7}(:,5));
    mplsp= sum(d.mpad.total_punctum_new_spine_preexisting{7}(:,5));
    mplsl= sum(d.mpad.total_punctum_new_spine_new{7}(:,5));
    %cn = sum(cpad.total_punctum_preexisting_spine_preexisting{7}(:,7));
    cn = sum(d.cpad.total_present(:,7));
    cppsp = sum(d.cpad.total_punctum_preexisting_spine_preexisting{7}(:,5));
    cplsp= sum(d.cpad.total_punctum_new_spine_preexisting{7}(:,5));
    cplsl= sum(d.cpad.total_punctum_new_spine_new{7}(:,5));
    
    %temp fix to match earlier fig, (due to changes in analyse_puncta_db);
%     mppsp = round(mn * (381-256 )/(381-209));
%     mplsp = round(mn * (256-215 )/(381-209));
%     mplsl = round(mn * (215-209 )/(381-209));
%     cppsp = round(cn * (381-229 )/(381-209));
%     cplsp = round(cn * (229-211 )/(381-209));
%     cplsl = round(cn * (211-209 )/(381-209));
    mppsp = round(mn * 0.726); % taken from first submission
    mplsp = round(mn * 0.242);
    mplsl = round(mn * 0.032);
    cppsp = round(cn * 0.883);
    cplsp = round(cn * 0.110);
    cplsl = round(cn * 0.007);
    mn = mppsp+mplsp+mplsl;
    cn = cppsp+cplsp+cplsl;


    fig.spine_gain_recovery = figure('numbertitle','off','name','Spine gain during recovery');
    y = [];
    y(1,:)=[ cppsp cplsp cplsl];
    y(2,:)=[ mppsp mplsp mplsl];
    
    
    p = chi2class( y );
    disp(['Spine puncta gain difference between MD and Naive at day 24, p = ' num2str(p,2)]);
    star = '';
    if p < 0.05
        star = '*';
        if p < 0.01
            star = '**';
        end
        if p < 0.001
            star = '***';
        end
    end
    y(1,:) = y(1,:)/cn;
    y(2,:) = y(2,:)/mn;
    
    
        ys(2,:) = [ mppsp+mplsp mplsl];
    ys(1,:) = [ cppsp+cplsp cplsl];
    ps = chi2class( ys );
    disp(['Spine + puncta loss difference between MD and Naive at day 24, p = ' num2str(ps,2)]);

    
    bar(y*100,'stacked'); colormap([0 0 0;0.5 0.5 0.5;1 1 1 ]);
    box off
    %     ylim([0 1.05]);
    %     legend('Punctum preexisting, spine preexisting',...
    %         'Punctum new, spine preexisting',...
    %         'Punctum new, spine new',...
    %         'location','northeastoutside')
    %     legend boxoff
    
    set(gca,'xticklabel',{'Naive      ','     Recovery'});
    
    ylabel('Fraction of day 24 spine puncta (%)');
    xlabel('Situation at day 16');

    ylim([0 100.5]);
    if p<0.05
        text(2,101,'*','horizontalalignment','center','verticalalignment','middle','fontsize',14);
    end
    xlim([0.25 2.75]);
    smaller_font(-2);
    bigger_linewidth(1);
    
    set(gca,'position',[0.2 0.1 0.15 0.6]);
    
    
    disp('    P preexis     P new      P new ')
    disp('    S preexis     S preexis  S new ')
    disp(['Naive    ' num2str((y(1,:)*100),'    %4.1f %%')]);
    disp(['Recovery ' num2str((y(2,:)*100),'    %4.1f %%')]);
    disp(['n_md spine puncta = ' num2str(mn) ]);
    disp(['n_ctl spine puncta = ' num2str(cn) ]);
    
    
    local_savefig(figname,fig.spine_gain_recovery);
    disp('---');
end



if 0 || plotall || plotfig3_spinepuncta_timeline
    figname = 'fig3_spinepuncta_timeline_md';
    disp(figname)
    fig.spinepuncta_timeline = figure('numbertitle','off','name','Spine and puncta timeline (MD)');
    hold on
    p = get(fig.spinepuncta_timeline,'position');
    p(3) = p(3) * 1.5;
    set(fig.spinepuncta_timeline,'position',p);
    
    for t = 1:7
        punctum_present_spine_present(t) = sum(d.mpad.total_punctum_preexisting_spine_preexisting{1}(:,t));
        punctum_persisting_spine_present(t) = sum(d.mpad.total_punctum_persisting_spine_preexisting{1}(:,t));
        
        punctum_absent_spine_present(t) = sum(d.mpad.total_punctum_lost_spine_preexisting{1}(:,t));
        punctum_absent_spine_absent(t) = sum(d.mpad.total_punctum_lost_spine_lost{1}(:,t));
        
        punctum_new_spine_preexisting(t) = sum(d.mpad.total_punctum_new_spine_preexisting{t}(:,1));
        punctum_new_spine_new(t) = sum(d.mpad.total_punctum_new_spine_new{t}(:,1));
    end
    punctum_preexisting_spine_present = punctum_present_spine_present - punctum_persisting_spine_present;
    
    line_a = punctum_absent_spine_absent;
    line_b = line_a + punctum_absent_spine_present;
    line_c = line_b + punctum_persisting_spine_present;
    line_d = line_c + punctum_preexisting_spine_present;
    line_e = line_d + punctum_new_spine_preexisting;
    line_f = line_e + punctum_new_spine_new;
    
    % normalize
    line_a = line_a / line_c(1) *100;
    line_b = line_b / line_c(1)*100;
    line_d = line_d / line_c(1)*100;
    line_e = line_e / line_c(1)*100;
    line_f = line_f / line_c(1)*100;
    line_c = line_c / line_c(1)*100;
    
    % temp_fix
    line_c(2) =100;
    line_d  = 100*ones(size(line_c));
    
    plot([7 19],[140 140],'linewidth',10,'color',[0.5 0.5 0.5]);
    h.f = area( days(1:7),line_f,'facecolor',[0.3 0.8 0.3] );
    h.e = area( days(1:7),line_e,'facecolor',[0.1 0.7 0.1] );
    h.d = area( days(1:7),line_d,'facecolor',[0 0.6 0] );
    h.c = area( days(1:7),line_c,'facecolor',[0 0.3 0] );
    h.b = area( days(1:7),line_b,'facecolor',[0.8 0.3 0.3] );
    h.a = area( days(1:7),line_a,'facecolor',[1 0.7 0.7] );
    legend([h.f,h.e,h.d,h.c,h.b,h.a],...
        {'Spine and punctum new',...
        'Spine familiar, punctum new',...
        'Spine familiar, punctum preexisting',...
        'Spine and punctum persisting',...
        'Spine familiar, punctum lost',...
        'Spine and punctum lost'},'location','northeastoutside');
    legend boxoff
    xlim([0 24]);
    ylim([0 140]);
    ylabel('Spines and puncta history (%)')
    xlabel('Time (Days)');
    set(gca,'XTick',0:4:24);
    local_savefig(figname,fig.spinepuncta_timeline);
    disp('---');
end



if 0 || plotall || plotfig3_spinepuncta_timeline
    figname = 'fig3_spinepuncta_timeline_naive';
    disp(figname)
    fig.spinepuncta_timeline = figure('numbertitle','off','name','Spine and puncta timeline (Naive)');
    hold on
    p = get(fig.spinepuncta_timeline,'position');
    p(3) = p(3) * 1.5;
    set(fig.spinepuncta_timeline,'position',p);
    
    for t = 1:7
        punctum_present_spine_present(t) = sum(d.cpad.total_punctum_preexisting_spine_preexisting{1}(:,t));
        punctum_persisting_spine_present(t) = sum(d.cpad.total_punctum_persisting_spine_preexisting{1}(:,t));
        
        punctum_absent_spine_present(t) = sum(d.cpad.total_punctum_lost_spine_preexisting{1}(:,t));
        punctum_absent_spine_absent(t) = sum(d.cpad.total_punctum_lost_spine_lost{1}(:,t));
        
        punctum_new_spine_preexisting(t) = sum(d.cpad.total_punctum_new_spine_preexisting{t}(:,1));
        punctum_new_spine_new(t) = sum(d.cpad.total_punctum_new_spine_new{t}(:,1));
    end
    punctum_preexisting_spine_present = punctum_present_spine_present - punctum_persisting_spine_present;
    
    line_a = punctum_absent_spine_absent;
    line_b = line_a + punctum_absent_spine_present;
    line_c = line_b + punctum_persisting_spine_present;
    line_d = line_c + punctum_preexisting_spine_present;
    line_e = line_d + punctum_new_spine_preexisting;
    line_f = line_e + punctum_new_spine_new;
    
    % normalize
    line_a = line_a / line_c(1) *100;
    line_b = line_b / line_c(1)*100;
    line_d = line_d / line_c(1)*100;
    line_e = line_e / line_c(1)*100;
    line_f = line_f / line_c(1)*100;
    line_c = line_c / line_c(1)*100;
    
    % temp_fix
    line_c(2) =100;
    line_d  = 100*ones(size(line_c));
    
    h.f = area( days(1:7),line_f,'facecolor',[0.3 0.8 0.3] );
    h.e = area( days(1:7),line_e,'facecolor',[0.1 0.7 0.1] );
    h.d = area( days(1:7),line_d,'facecolor',[0 0.6 0] );
    h.c = area( days(1:7),line_c,'facecolor',[0 0.3 0] );
    h.b = area( days(1:7),line_b,'facecolor',[0.8 0.3 0.3] );
    h.a = area( days(1:7),line_a,'facecolor',[1 0.7 0.7] );
    legend([h.f,h.e,h.d,h.c,h.b,h.a],...
        {'Spine and punctum new',...
        'Spine familiar, punctum new',...
        'Spine familiar, punctum preexisting',...
        'Spine and punctum persisting',...
        'Spine familiar, punctum lost',...
        'Spine and punctum lost'},'location','northeastoutside');
    legend boxoff
    xlim([0 24])
    ylabel('Spines and puncta history (%)')
    xlabel('Time (Days)');
    set(gca,'XTick',0:4:24);
    local_savefig(figname,fig.spinepuncta_timeline);
    disp('---');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fig 3alt_B : Puncta persistance of similarly sized spines and shafts
if 0|| plotall ||plotfig3alt
    figname = 'fig3Aalt_persistance_by_size';
    disp(figname)
    tp = 1;
    persisting = {d.msad.persisting{1,:}};
    spine = d.mpad.right_type;
    shaft = d.mhad.right_type;
    medium = d.msad.medium;
    for i = 1:length(persisting)
        pers_middle_spines(i,:) = sum( persisting{i} & repmat( spine{i}(:,1) & medium{i}(:,1),1,8));
        rel_pers_middle_spines(i,:) = pers_middle_spines(i,:) ./  repmat( pers_middle_spines(i,1),1,8);
        pers_middle_shafts(i,:) = sum( persisting{i} & repmat( shaft{i}(:,1) & medium{i}(:,1),1,8));
        rel_pers_middle_shafts(i,:) = pers_middle_shafts(i,:) ./  repmat( pers_middle_shafts(i,1),1,8);
    end
    [fig.pers_ss,h.pers_p] = show_results( rel_pers_middle_spines(:,tp:n_days)*100,'Persisting puncta (%)',days(tp:n_days),false,true,[],[0 0 0],false,'','-',1,8,'v');
    [fig.pers_ss,h.pers_h] = show_results( rel_pers_middle_shafts(:,tp:n_days)*100,'Persisting puncta (%)',days(tp:n_days),false,true,fig.pers_ss,[0 0 0],false,'md','-',1,8,'s');
    ylim([0 110]);
    set(gca,'position',[0.2 0.2 0.5 0.7]);
    smaller_font(-6);
    bigger_linewidth(2);
    xlabel('Time (days)','fontsize',16);
    ylabel('Persisting medium puncta (%)','fontsize',16);
    legend([h.pers_p h.pers_h],{'Spine','Shaft'});
    legend boxoff
    local_savefig(figname,fig.pers_ss);
    disp('---');
end


% Fig 3altalt_B : Puncta persistance of similarly sized spines and shafts
if 0|| plotall ||plotfig3alt
    figname = 'fig3Aaltalt_persistance_by_size';
    disp(figname)
    tp = 1;
    persisting = {d.msad.persisting{1,:}};
    spine = d.mpad.right_type;
    shaft = d.mhad.right_type;
    medium = d.msad.medium;
    lost=d.msad.lost
    
    % make rank groups
    n_g = 4;
    rank_group = {};
    for i = 1:length(d.msad.lost)
        for j=1:n_g
            rank_group{i,j}= ...
                (d.msad.intensity_rank{i}> (j-1)/n_g & ...
                d.msad.intensity_rank{i}< (j)/n_g);
        end
    end
    % equalize rank groups and combine
    for i = 1:length(d.msad.lost)
        equal_shaft{i} = false(size(lost{i} ));
        equal_spine{i} = false(size(lost{i} ));
        for j=1:n_g
            for tp=1:8
                n_spines = sum(rank_group{i,j}(:,tp)&spine{i}(:,tp));
                n_shafts = sum(rank_group{i,j}(:,tp)&shaft{i}(:,tp));
                spine_rank_group{i,j}(:,tp) = rank_group{i,j}(:,tp)&spine{i}(:,tp);
                shaft_rank_group{i,j}(:,tp) = rank_group{i,j}(:,tp)&shaft{i}(:,tp);
                if  n_spines > n_shafts
                    
                    ind = find(spine_rank_group{i,j}(:,tp));
                    spine_rank_group{i,j}(ind(end - (n_spines-n_shafts)+1:end),tp) = 0;
                else
                    ind = find(shaft_rank_group{i,j}(:,tp));
                    shaft_rank_group{i,j}(ind(end - (n_shafts-n_spines)+1:end),tp) = 0;
                end
            end
            equal_shaft{i} = equal_shaft{i}+ shaft_rank_group{i,j};
            equal_spine{i} = equal_spine{i}+ spine_rank_group{i,j};
        end
    end
    
    tp=1
    for i = 1:length(persisting)
        pers_middle_spines(i,:) = sum( persisting{i} & repmat(equal_spine{i}(:,1),1,8));
        rel_pers_middle_spines(i,:) = pers_middle_spines(i,:) ./  repmat( pers_middle_spines(i,1),1,8);
        pers_middle_shafts(i,:) = sum( persisting{i} & repmat( equal_shaft{i}(:,1) ,1,8));
        rel_pers_middle_shafts(i,:) = pers_middle_shafts(i,:) ./  repmat( pers_middle_shafts(i,1),1,8);
    end
    [fig.pers_ss,h.pers_p] = show_results( rel_pers_middle_spines(:,tp:n_days)*100,'Persisting puncta (%)',days(tp:n_days),false,true,[],[0 0 0],false,'','-',1,8,'v');
    [fig.pers_ss,h.pers_h] = show_results( rel_pers_middle_shafts(:,tp:n_days)*100,'Persisting puncta (%)',days(tp:n_days),false,true,fig.pers_ss,[0 0 0],false,'md','-',1,8,'s');
    ylim([0 110]);
    set(gca,'position',[0.2 0.2 0.5 0.7]);
    smaller_font(-8);
    bigger_linewidth(2);
    xlabel('Time (days)','fontsize',18);
    ylabel('Persist. intensity-matched puncta (%)','fontsize',17);
    legend([h.pers_p h.pers_h],{'Spine','Shaft'});
    legend boxoff
    local_savefig(figname,fig.pers_ss);
    disp('---');
end




% Fig 3alt_B : Puncta loss of similarly sized spines and shafts
if 0|| plotall ||plotfig3alt
    figname = 'fig3altB_loss_by_size';
    disp(figname)
    
    lost = d.msad.lost;
    spine = d.mpad.right_type;
    shaft = d.mhad.right_type;
    medium = d.msad.medium;
    
    for i = 1:length(persisting)
        % medium{i} = true(size(medium{i})); % temp check
        
        total_spines_present(i,:) = sum(d.msad.present{i} & d.mpad.right_type{i} & medium{i});
        lost_middle_spines(i,2:8) = sum( medium{i}(:,1:7) & spine{i}(:,1:7) & lost{i}(:,2:8));
        total_shafts_present(i,:) = sum(d.msad.present{i} & d.mhad.right_type{i} & medium{i});
        lost_middle_shafts(i,2:8) = sum( medium{i}(:,1:7) & shaft{i}(:,1:7) & lost{i}(:,2:8));
    end
    
    min_per_group = 5;
    small_groups = (mean(total_spines_present,2)<min_per_group);
    if any(small_groups)
        total_spines_present = remove_small_groups(total_spines_present,small_groups);
        lost_middle_spines = remove_small_groups(lost_middle_spines,small_groups);
        %small_group_selection = selection{small_groups};
        %selection = {selection{~small_groups} small_group_selection}; %#ok<NASGU>
    end
    
    small_groups = (mean(total_shafts_present,2)<min_per_group);
    if any(small_groups)
        total_shafts_present = remove_small_groups(total_shafts_present,small_groups);
        lost_middle_shafts = remove_small_groups(lost_middle_shafts,small_groups);
        %small_group_selection = selection{small_groups};
        %selection = {selection{~small_groups} small_group_selection}; %#ok<NASGU>
    end
    
    for i = 1:size(total_spines_present,1)
        rel_lost_middle_spines(i,2:8) = lost_middle_spines(i,2:8) ./  total_spines_present(i,1:7);
    end
    for i = 1:size(total_shafts_present,1)
        rel_lost_middle_shafts(i,2:8) = lost_middle_shafts(i,2:8) ./  total_shafts_present(i,1:7);
    end
    
    
    [fig.pers_ss,h.pers_large_md] = show_results( rel_lost_middle_spines(:,2:n_days)*100,'Loss (%)',days(2:n_days),false,true,[],[0 0 0],false,'','-',1,8,'v');
    [fig.pers_ss,h.pers_small_md] = show_results( rel_lost_middle_shafts(:,2:n_days)*100,'Loss (%)',days(2:n_days),false,true,fig.pers_ss,[0 0 0],false,'md','-',1,8,'s');
    
    
    for t = 2:n_days
        x = rel_lost_middle_spines(:,t);
        x = x(~isnan(x));
        y = rel_lost_middle_shafts(:,t);
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Loss of medium spine and shafts is different for MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,28,star,'horizontalalignment','center','verticalalignment','top');
        end
    end
    
    
    
    %    legend([h.pers_large_md,h.pers_small_md,h.pers_large_c,h.pers_small_c],...
    %        {'Large, MD','Small, MD','Large, Naive','Small, Naive'},...
    %        'location','southwest','fontsize',14)
    %    legend boxoff
    ylim([0 30]);
    
    %    disp(['Days    :  ' num2str(days(tp:n_days),' %4d')]);
    %    disp(['Large ctl:  ' num2str(fix(nanmean(d.csld.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    %    disp(['Small ctl:  ' num2str(fix(nanmean(d.cssd.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    %    disp(['Large MD :  ' num2str(fix(nanmean(d.msld.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    %    disp(['Small MD :  ' num2str(fix(nanmean(d.mssd.rel_persisting{tp}(:,tp:n_days)*100)),' % 4d') ]);
    
    %   % correlation between all puncta rank and persistance of day 24 (MD)
    %   persisting = flatten(cellfun(@(x) x(:,7),{d.msad.persisting{1,:}},'uniformoutput',false));
    %   rank = flatten(cellfun(@(x) x(:,7),d.msad.intensity_rank,'uniformoutput',false));
    %   [r,p] = corrcoef(rank,persisting);
    %   disp(['Correlation between all puncta rank and persistance of day 24 (MD) = ' num2str(r(1,2),3) ', sig. from 0, p = ' num2str(p(1,2))]);
    
    
    % correlation between large puncta rank and persistance of day 24 (MD)
    %   persisting = flatten(cellfun(@(x) x(:,7),{d.msld.persisting{1,:}},'uniformoutput',false));
    %   rank = flatten(cellfun(@(x) x(:,7),d.msld.intensity_rank,'uniformoutput',false));
    %   [r,p] = corrcoef(rank,persisting);
    %   disp(['Correlation between large puncta rank and persistance of day 24 (MD) = ' num2str(r(1,2),3) ', sig. from 0, p = ' num2str(p(1,2))]);
    
    set(gca,'position',[0.2 0.2 0.5 0.7]);
    smaller_font(-6);
    bigger_linewidth(2);
    xlabel('Time (days)','fontsize',16);
    ylabel('Loss medium puncta (%)','fontsize',16);
    
    local_savefig(figname,fig.pers_ss);
    disp('---');
end



%%%%%%
% Fig 3altalt_B : Puncta loss of similarly sized spines and shafts
if 0|| plotall ||plotfig3alt
    figname = 'fig3altaltB_loss_by_size';
    disp(figname)
    
    lost = d.msad.lost;
    spine = d.mpad.right_type;
    shaft = d.mhad.right_type;
    medium = d.msad.medium;
    
    % make rank groups
    n_g = 3;
    rank_group = {};
    for i = 1:length(d.msad.lost)
        for j=1:n_g
            rank_group{i,j}= ...
                (d.msad.intensity_rank{i}> (j-1)/n_g & ...
                d.msad.intensity_rank{i}< (j)/n_g);
        end
    end
    % equalize rank groups and combine
    for i = 1:length(d.msad.lost)
        equal_shaft{i} = false(size(lost{i} ));
        equal_spine{i} = false(size(lost{i} ));
        for j=1:n_g
            for tp=1:8
                n_spines = sum(rank_group{i,j}(:,tp)&spine{i}(:,tp));
                n_shafts = sum(rank_group{i,j}(:,tp)&shaft{i}(:,tp));
                spine_rank_group{i,j}(:,tp) = rank_group{i,j}(:,tp)&spine{i}(:,tp);
                shaft_rank_group{i,j}(:,tp) = rank_group{i,j}(:,tp)&shaft{i}(:,tp);
                if  n_spines > n_shafts
                    
                    ind = find(spine_rank_group{i,j}(:,tp));
                    spine_rank_group{i,j}(ind(end - (n_spines-n_shafts)+1:end),tp) = 0;
                else
                    ind = find(shaft_rank_group{i,j}(:,tp));
                    shaft_rank_group{i,j}(ind(end - (n_shafts-n_spines)+1:end),tp) = 0;
                end
            end
            equal_shaft{i} = equal_shaft{i}+ shaft_rank_group{i,j};
            equal_spine{i} = equal_spine{i}+ spine_rank_group{i,j};
        end
    end
    
    for i = 1:length(d.msad.lost)
        % medium{i} = true(size(medium{i})); % temp check
        total_spines_present(i,:) = sum(d.msad.present{i} & equal_spine{i});
        lost_middle_spines(i,2:8) = sum( equal_spine{i}(:,1:7) & lost{i}(:,2:8));
        total_shafts_present(i,:) = sum(d.msad.present{i} & equal_shaft{i});
        lost_middle_shafts(i,2:8) = sum( equal_shaft{i}(:,1:7) & lost{i}(:,2:8));
    end
    
    min_per_group = 5;
    small_groups = (mean(total_spines_present,2)<min_per_group);
    if any(small_groups)
        total_spines_present = remove_small_groups(total_spines_present,small_groups,false);
        lost_middle_spines = remove_small_groups(lost_middle_spines,small_groups,false);
        %small_group_selection = selection{small_groups};
        %selection = {selection{~small_groups} small_group_selection}; %#ok<NASGU>
    end
    
    small_groups = (mean(total_shafts_present,2)<min_per_group);
    if any(small_groups)
        total_shafts_present = remove_small_groups(total_shafts_present,small_groups,false);
        lost_middle_shafts = remove_small_groups(lost_middle_shafts,small_groups,false);
        %small_group_selection = selection{small_groups};
        %selection = {selection{~small_groups} small_group_selection}; %#ok<NASGU>
    end
    
    for i = 1:size(total_spines_present,1)
        rel_lost_middle_spines(i,2:8) = lost_middle_spines(i,2:8) ./  total_spines_present(i,1:7);
    end
    for i = 1:size(total_shafts_present,1)
        rel_lost_middle_shafts(i,2:8) = lost_middle_shafts(i,2:8) ./  total_shafts_present(i,1:7);
    end
    
    [fig.pers_ss,h.pers_large_md] = show_results( rel_lost_middle_spines(:,2:n_days)*100,'Loss (%)',days(2:n_days),false,true,[],[0 0 0],false,'','-',1,8,'v');
    [fig.pers_ss,h.pers_small_md] = show_results( rel_lost_middle_shafts(:,2:n_days)*100,'Loss (%)',days(2:n_days),false,true,fig.pers_ss,[0 0 0],false,'md','-',1,8,'s');
    
    for t = 2:n_days
        x = rel_lost_middle_spines(:,t);
        x = x(~isnan(x));
        y = rel_lost_middle_shafts(:,t);
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Loss of medium spine and shafts is different for MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,28,star,'horizontalalignment','center','verticalalignment','top');
        end
    end
    ylim([0 30]);
    set(gca,'position',[0.2 0.2 0.5 0.7]);
    smaller_font(-8);
    bigger_linewidth(2);
    xlabel('Time (days)','fontsize',18);
    ylabel('Loss of intensity-matched puncta (%)','fontsize',17);
    local_savefig(figname,fig.pers_ss);
    disp('---');
end

%%%%

% Fig 3alt_C : Puncta size histograms day 4
if 0|| plotall ||plotfig3alt
    figname = 'fig3altC_size_histograms_day4';
    disp(figname)
    tsrank = [];
    tprank = [];
    thrank = [];
    tp = 2;
    for i = 1:length(d.msad.intensity_rank)
        srank = d.msad.intensity_rank{i}(:,tp).*d.msad.present{i}(:,tp);
        srank(srank==0) = NaN;
        %    srank = nanmean(srank,2);
        tsrank = [tsrank ;srank(:)];
        prank = d.msad.intensity_rank{i}(:,tp).*d.mpad.present{i}(:,tp);
        prank(prank==0) = NaN;
        %    prank = nanmean(prank,2);
        tprank = [tprank; prank(:)];
        hrank = d.msad.intensity_rank{i}(:,tp).*d.mhad.present{i}(:,tp);
        hrank(hrank==0) = NaN;
        %    hrank = nanmean(hrank,2);
        thrank = [thrank ;hrank(:)];
    end
    tprank = tprank(~isnan(tprank));
    thrank = thrank(~isnan(thrank));
    
    %x = 0.05:0.1:0.95;
    
    x = 0.125:0.25:0.875;
    [np,x]=hist(tprank,x);
    [nh,x]=hist(thrank,x);
    tot = (sum(np(:))+sum(nh(:)));
    np = np/tot;
    nh = nh/tot;
    fig.his = figure('numbertitle','off','name',figname);
    h.bar = bar(x*100,[np' nh']*100,1.5);
    set(h.bar,'linestyle','none')
    xlim([-0.02 1.02]*100)
    box off
    disp('---');
    set(gca,'XTick',0:25:100);
    smaller_font(-6);
    bigger_linewidth(1);
    xlabel('Intensity percentile');
    ylabel('Fraction (%)');
    legend('Spine','Shaft','location','northwest');
    legend boxoff
    %set(gca,'position',[0.2 0.15 0.3 0.75]);
    set(gca,'position',[0.2 0.15 0.3 0.75]);
    colormap([0 0 0;0.7 0.7 0.7])
    local_savefig(figname,fig.his);
end

% Fig 3alt_C : Puncta size histograms day 16
if 0|| plotall ||plotfig3alt
    figname = 'fig3altC_size_histograms_day16';
    disp(figname)
    tsrank = [];
    tprank = [];
    thrank = [];
    tp = 5;
    for i = 1:length(d.msad.intensity_rank)
        srank = d.msad.intensity_rank{i}(:,tp).*d.msad.present{i}(:,tp);
        srank(srank==0) = NaN;
        %    srank = nanmean(srank,2);
        tsrank = [tsrank ;srank(:)];
        prank = d.msad.intensity_rank{i}(:,tp).*d.mpad.present{i}(:,tp);
        prank(prank==0) = NaN;
        %    prank = nanmean(prank,2);
        tprank = [tprank; prank(:)];
        hrank = d.msad.intensity_rank{i}(:,tp).*d.mhad.present{i}(:,tp);
        hrank(hrank==0) = NaN;
        %    hrank = nanmean(hrank,2);
        thrank = [thrank ;hrank(:)];
    end
    tprank = tprank(~isnan(tprank));
    thrank = thrank(~isnan(thrank));
    
    %x = 0.05:0.1:0.95;
    
    x = 0.125:0.25:0.875;
    [np,x]=hist(tprank,x);
    [nh,x]=hist(thrank,x);
    tot = (sum(np(:))+sum(nh(:)));
    np = np/tot;
    nh = nh/tot;
    fig.his = figure('numbertitle','off','name',figname);
    h.bar = bar(x*100,[np' nh']*100,1.5);
    set(h.bar,'linestyle','none')
    xlim([-0.02 1.02]*100)
    box off
    disp('---');
    set(gca,'XTick',0:25:100);
    smaller_font(-6);
    bigger_linewidth(1);
    xlabel('Intensity percentile');
    ylabel('Fraction (%)');
    legend('Spine','Shaft','location','northwest');
    legend boxoff
    set(gca,'position',[0.2 0.15 0.3 0.75]);
    colormap([0 0 0;0.7 0.7 0.7])
    local_savefig(figname,fig.his);
end


if 0 || plotall || computeregainpopulations
    lost_and_regained_during_md = [];
    lost_after_reopening = [];
    persisting_throughout_md = [];
    mprob_lostonce = [];
    mprob_losttwice = [];
    for i = 1:length(d.msad.lost_and_regained_during_md)
        lost_and_regained_during_md = [lost_and_regained_during_md; ...
            d.msad.lost_and_regained_during_md{i} ];
        mprob_losttwice(i) = sum( d.msad.lost_and_regained_during_md{i} & d.msad.lost_after_reopening{i} ) / ...
            sum( d.msad.lost_and_regained_during_md{i});
        
        lost_after_reopening = [lost_after_reopening; ...
            d.msad.lost_after_reopening{i} ];
        persisting_throughout_md = [persisting_throughout_md; ...
            d.msad.persisting_throughout_md{i}];
        
        mprob_lostonce(i) = sum( d.msad.persisting_throughout_md{i} & d.msad.lost_after_reopening{i} ) / ...
            sum( d.msad.persisting_throughout_md{i});
        
    end
    mprob_lostonce = mprob_lostonce(~isnan(mprob_lostonce));
    mprob_losttwice = mprob_losttwice(~isnan(mprob_losttwice));
    
    disp(['MD: Probability of a puncta that was lost and regained during MD period to be lost after reopening = ' ...
        num2str(fix(nanmean(mprob_losttwice)*100) ) '+-' num2str(fix(sem(mprob_losttwice)*100) ) ' %' ]);
    disp(['MD: Probability of a puncta that persisted throughout MD period to be lost after reopening = ' ...
        num2str(fix(nanmean(mprob_lostonce)*100) ) '+-' num2str(fix(sem(mprob_lostonce)*100) ) ' %' ]);
    %    prob_losttwice = sum(lost_and_regained_during_md & lost_after_reopening) / sum(lost_and_regained_during_md);
    %    prob_lostonce = sum(persisting_throughout_md & lost_after_reopening) / sum(persisting_throughout_md);
    %    disp(['MD: Probability of a puncta that was lost and regained during MD period to be lost after reopening = ' num2str(fix(prob_losttwice*100) ) ' %' ]);
    %    disp(['MD: Probability of a puncta that persisted throughout MD period to be lost after reopening = ' num2str(fix(prob_lostonce*100)) ' %']);
    
    
    lost_and_regained_during_md = [];
    lost_after_reopening = [];
    persisting_throughout_md = [];
    cprob_lostonce = [];
    cprob_losttwice = [];
    for i = 1:length(d.csad.lost_and_regained_during_md)
        lost_and_regained_during_md = [lost_and_regained_during_md; ...
            d.csad.lost_and_regained_during_md{i} ];
        cprob_losttwice(i) = sum( d.csad.lost_and_regained_during_md{i} & d.csad.lost_after_reopening{i} ) / ...
            sum( d.csad.lost_and_regained_during_md{i});
        
        lost_after_reopening = [lost_after_reopening; ...
            d.csad.lost_after_reopening{i} ];
        persisting_throughout_md = [persisting_throughout_md; ...
            d.csad.persisting_throughout_md{i}];
        
        cprob_lostonce(i) = sum( d.csad.persisting_throughout_md{i} & d.csad.lost_after_reopening{i} ) / ...
            sum( d.csad.persisting_throughout_md{i});
        
    end
    cprob_lostonce = cprob_lostonce(~isnan(cprob_lostonce));
    cprob_losttwice = cprob_losttwice(~isnan(cprob_losttwice));
    
    disp(['Naive: Probability of a puncta that was lost and regained during MD period to be lost after reopening = ' ...
        num2str(fix(nanmean(cprob_losttwice)*100) ) '+-' num2str(fix(sem(cprob_losttwice)*100) ) ' %' ]);
    disp(['Naive: Probability of a puncta that persisted throughout MD period to be lost after reopening = ' ...
        num2str(fix(nanmean(cprob_lostonce)*100) ) '+-' num2str(fix(sem(cprob_lostonce)*100) ) ' %' ]);
    %    prob_losttwice = sum(lost_and_regained_during_md & lost_after_reopening) / sum(lost_and_regained_during_md);
    %    prob_lostonce = sum(persisting_throughout_md & lost_after_reopening) / sum(persisting_throughout_md);
    %    disp(['Naive: Probability of a puncta that was lost and regained during MD period to be lost after reopening = ' num2str(fix(prob_losttwice*100) ) ' %' ]);
    %    disp(['Naive: Probability of a puncta that persisted throughout MD period to be lost after reopening = ' num2str(fix(prob_lostonce*100)) ' %']);
    
    [h,p]=ttest2(cprob_losttwice,mprob_losttwice);
    disp(['p-value difference naive & md of prob of loss after regaining = ' num2str(p,2)]);
    
    [h,p]=ttest2(cprob_lostonce,mprob_lostonce);
    disp(['p-value difference naive & md of prob of loss after persistence= ' num2str(p,2)]);
    
    
    
    
end



%%%%%%%%%%%%%



% SUPFIG PUNCTA TURNOVER SIZE
if 0|| plotall||plotsupfig_size
    figname = 'supfig_puncta_turnover_size'; % gain and loss together
    disp(figname);
    [supfig.tos,h.loss] = show_results( d.msld.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 1],true);
    [supfig.tos,h.gain] = show_results( d.msld.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.tos,[1 0 0],true,'');
    [supfig.tos,h.loss] = show_results( d.msmd.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.tos,[0 0 1],true);
    [supfig.tos,h.gain] = show_results( d.msmd.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.tos,[1 0 0],true,'');
    [supfig.tos,h.loss] = show_results( d.mssd.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.tos,[0 0 1],true);
    [supfig.tos,h.gain] = show_results( d.mssd.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.tos,[1 0 0],true,'md');
    %line([0 24],[10 10],'color',[0.7 0.7 0.7])
    %line([0 24],[20 20],'color',[0.7 0.7 0.7])
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 35])
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.loss,h.gain],'Loss','Gain','location','northwest','fontsize',8)
    legend boxoff
    local_savefig(figname,supfig.tos);
    disp(['Days   :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost   :  ' num2str(fix(nanmean(d.msld.relative_lost(:,2:n_days)) *100),' % 4d') ]);
    disp(['Gained :  ' num2str(fix(nanmean(d.msld.relative_gained(:,2:n_days)) *100),' % 4d') ]);
end




if 0|| plotall||plotsupfig_size
    figname = 'supfig_puncta_turnover_size_gain';
    disp(figname);
    disp('Large');
    %    [supfig.tos,h.loss] = show_results( d.msld.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 1],true);
    [supfig.gain,h.gainl] = show_results( d.msld.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],true,'');
    set(h.gainl,'linewidth',5);
    %  [supfig.tos,h.loss] = show_results( d.msmd.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.tos,[0 0 1],true);
    disp('Medium');
    [supfig.gain,h.gainm] = show_results( d.msmd.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.gain,[0 0 0],true,'');
    set(h.gainm,'linewidth',3);
    %  [supfig.tos,h.loss] = show_results( d.mssd.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.tos,[0 0 1],true);
    disp('Small');
    [supfig.gain,h.gains] = show_results( d.mssd.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.gain,[0 0 0],true,'md');
    set(h.gains,'linewidth',1);
    %line([0 24],[10 10],'color',[0.7 0.7 0.7])
    %line([0 24],[20 20],'color',[0.7 0.7 0.7])
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 35])
    ylabel('Gain (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.gains,h.gainm,h.gainl],'Dimmest 50%','Middle 50%','Brightest 50%','fontsize',8,'location','northwest')
    legend boxoff
    local_savefig(figname,supfig.gain);
    disp(['Days         :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Gained Large :  ' num2str(fix(nanmean(d.msld.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    disp(['Gained Medium:  ' num2str(fix(nanmean(d.msmd.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    disp(['Gained Small :  ' num2str(fix(nanmean(d.mssd.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    disp('---');
end

if 0|| plotall||plotsupfig_size
    figname = 'supfig_puncta_turnover_size_loss';
    disp(figname);
    disp('Large');
    [supfig.loss,h.lossl] = show_results( d.msld.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],true);
    set(h.lossl,'linewidth',5);
    %[supfig.tos,h.gain] = show_results( d.msld.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.tos,[1 0 0],true,'');
    disp('Medium');
    [supfig.loss,h.lossm] = show_results( d.msmd.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.loss,[0 0 0],true);
    set(h.lossm,'linewidth',3);
    %[supfig.tos,h.gain] = show_results( d.msmd.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.tos,[1 0 0],true,'');
    disp('Small');
    [supfig.loss,h.losss] = show_results( d.mssd.relative_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.loss,[0 0 0],true,'md');
    set(h.losss,'linewidth',1);
    %[supfig.tos,h.gain] = show_results( d.mssd.relative_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,supfig.tos,[1 0 0],true,'md');
    %line([0 24],[10 10],'color',[0.7 0.7 0.7])
    %line([0 24],[20 20],'color',[0.7 0.7 0.7])
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 35])
    ylabel('Loss (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    %legend([h.loss,h.gain],'Loss','Gain','location','northwest','fontsize',8)
    %legend boxoff
    local_savefig(figname,supfig.loss);
    disp(['Days        :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost Large  :  ' num2str(fix(nanmean(d.msld.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    disp(['Lost Medium :  ' num2str(fix(nanmean(d.msmd.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    disp(['Lost Small  :  ' num2str(fix(nanmean(d.mssd.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    %disp(['Gained :  ' num2str(fix(nanmean(d.msld.relative_gained(:,2:n_days)) *100),' % 4d') ]);
    disp('---');
end






if 0 || plotall || plotspinepunctaratio
    draw_plotspinepuncatratio( d );
end



% Fig supplemental: repeated gain
if 0 || plotall||plotfigrepeated
    figname = 'fig_repeated_gain';
    disp(figname);
    hours = 0:0.5:4;
    n_timepoints = 7;
    [fig.rgain,h.rgainp] = show_results( d.rsap.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',hours(2:n_timepoints),false,true,[],[0 0 0],false,'','-',2,8,'o');
    % [fig.rgain,h.rgainp] = show_results( d.rpad.relative_gained(:,2:n_timepoints)*100,'Gain (%)',hours(2:n_timepoints),false,true,[],[0 0 0],false,'','-',2,8,'v');
    %    [fig.rgain,h.rgainh] = show_results( d.rhad.relative_gained(:,2:n_timepoints)*100,'Gain (%)',hours(2:n_timepoints),false,true,fig.rgain,[0 0 0],false,'','-',2,8,'s');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    xlim([0 3])
    ylabel('Gain (%)');
    xlabel('Time (hours)');
    smaller_font(-8);
    bigger_linewidth(2);
    %legend([h.rgainp,h.rgainh],{'Spine','Shaft'},'location','northwest','fontsize',18)
    legend boxoff
    disp(['Hours          :  ' num2str(hours(2:n_days),' %4d')]);
    disp(['Gained Puncta  :  ' num2str(nanmean(d.rsad.relative_gained(:,2:n_days) *100),' % 4d%%') ]);
    disp(['Max ' num2str(max(nanmean(d.rsad.relative_gained(:,2:n_days))*100))]);
    disp(['Mean ' num2str(nanmean(nanmean(d.rsad.relative_gained(:,2:n_days))*100))]);
    
    % disp(['Gained Spine   :  ' num2str(fix(nanmean(d.rpad.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    % disp(['Gained Shaft   :  ' num2str(fix(nanmean(d.rhad.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    
    local_savefig(figname,fig.rgain);
    
    disp('---');
end


% Fig supplemental: repeated loss
if 0 || plotall||plotfigrepeated
    figname = 'fig_repeated_loss';
    disp(figname);
    hours = 0:0.5:4;
    n_timepoints = 7;
    [fig.rloss,h.rlossh] = show_results( d.rsap.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',hours(2:n_timepoints),false,true,[],[0 0 0],false,'','-',2,8,'o');
    %[fig.rloss,h.rlossp] = show_results( d.rpad.relative_lost(:,2:n_timepoints)*100,'Loss (%)',hours(2:n_timepoints),false,true,fig.rloss,[0 0 0],false,'','-',2,8,'v');
    %[fig.rloss,h.rlossh] = show_results( d.rhad.relative_lost(:,2:n_timepoints)*100,'Loss (%)',hours(2:n_timepoints),false,true,fig.rloss,[0 0 0],false,'','-',2,8,'s');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    xlim([0 3])
    ylabel('Loss (%)');
    xlabel('Time (hours)');
    smaller_font(-8);
    bigger_linewidth(2);
    %    legend([h.rlossp,h.rlossh],{'Spine','Shaft'},'location','northwest','fontsize',18)
    %   legend boxoff
    disp(['Hours        :  ' num2str(hours(2:n_days),' %4d')]);
    disp(['Lost Puncta  :  ' num2str(nanmean(d.rsad.relative_lost(:,2:n_days) *100),' % 4d%%') ]);
    disp(['Max ' num2str(max(nanmean(d.rsad.relative_lost(:,2:n_days))*100))]);
    disp(['Mean ' num2str(nanmean(nanmean(d.rsad.relative_lost(:,2:n_days))*100))]);
%    disp(['Lost Spine   :  ' num2str(fix(nanmean(d.rpad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    %    disp(['Lost Shaft:  ' num2str(fix(nanmean(d.rhad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    local_savefig(figname,fig.rloss);
    disp('---');
end




% Fig supplemental: mono gain
if 0 || plotall||plotfig_mono
    figname = 'fig_mono_gain';
    disp(figname);
    n_timepoints = 7;
    [fig.ogain,h.ogainp] = show_results( d.osad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'o');
    [fig.ogain,h.cgainp] = show_results( d.csad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.ogain,[0 0 0],false,'','--',2,8,'o');
    [fig.ogain,h.mgainp] = show_results( d.msad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.ogain,[0 0 0],false,'md','-',2,8,'o');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Gain (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.mgainp,h.ogainp,h.cgainp],{'MD Binocular','MD Monocular','Naive Binocular'},'location','northwest','fontsize',18)
    legend boxoff
    disp(['Days          :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Gained Puncta  :  ' num2str(fix(nanmean(d.osad.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    tp=2;
    local_savefig(figname,fig.ogain);
    disp('---');
end


% Fig supplemental: mono loss
if 0 || plotall||plotfig_mono
    figname = 'fig_mono_loss';
    disp(figname);
    n_timepoints = 7;
    [fig.oloss,h.olossh] = show_results( d.osad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'o');
    [fig.oloss,h.clossh] = show_results( d.csad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.oloss,[0 0 0],false,'','--',2,8,'o');
    [fig.oloss,h.mlossh] = show_results( d.msad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.oloss,[0 0 0],false,'md','-',2,8,'o');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Loss (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    disp(['Days        :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost Puncta  :  ' num2str(fix(nanmean(d.osad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    local_savefig(figname,fig.oloss);
    disp('---');
end


% Fig supplemental: mono gain spine
if 0 || plotall||plotfig_mono
    figname = 'fig_mono_gain_spine';
    disp(figname);
    n_timepoints = 7;
    [fig.ogain,h.ogainp] = show_results( d.opad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'v');
    [fig.ogain,h.mgainp] = show_results( d.mpad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.ogain,[0 0 0],false,'md','-',2,8,'v');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Gain of spine puncta (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    %legend([h.ogainp,h.mgainp],{'Monocular','Binocular'},'location','northwest','fontsize',18)
    % legend boxoff
    disp(['Days          :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Gained Spine Puncta  :  ' num2str(fix(nanmean(d.opad.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    tp=2;
    for t = tp:n_days
        x = d.opad.relative_gained(:,t);
        x = x(~isnan(x));
        y = d.mpad.relative_gained(:,t);
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Gained spine puncta difference for monocular and binocular at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.ogain);
    disp('---');
end


% Fig supplemental: mono loss spine
if 0 || plotall||plotfig_mono
    figname = 'fig_mono_loss_spine';
    disp(figname);
    n_timepoints = 7;
    [fig.oloss,h.olossh] = show_results( d.opad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'v');
    [fig.oloss,h.mlossh] = show_results( d.mpad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.oloss,[0 0 0],false,'md','-',2,8,'v');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Loss of spine puncta (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    disp(['Days        :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost Spine Puncta  :  ' num2str(fix(nanmean(d.opad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    tp=2;
    for t = tp:n_days
        x = d.opad.relative_lost(:,t);
        x = x(~isnan(x));
        y = d.mpad.relative_lost(:,t) ;
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Lost spine puncta difference for monocular and binocular at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.oloss);
    disp('---');
end


% Fig supplemental: mono gain shaft
if 0 || plotall||plotfig_mono
    figname = 'fig_mono_gain_shaft';
    disp(figname);
    n_timepoints = 7;
    [fig.ogain,h.ogainp] = show_results( d.ohad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'s');
    [fig.ogain,h.mgainp] = show_results( d.mhad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.ogain,[0 0 0],false,'md','-',2,8,'s');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Gain of shaft puncta (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    %legend([h.ogainp,h.mgainp],{'Monocular','Binocular'},'location','northwest','fontsize',18)
    % legend boxoff
    disp(['Days          :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Gained Shaft Puncta  :  ' num2str(fix(nanmean(d.ohad.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    tp=2;
    for t = tp:n_days
        x = d.ohad.relative_gained(:,t);
        x = x(~isnan(x));
        y = d.mhad.relative_gained(:,t);
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Gained shaft puncta difference for monocular and binocular at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.ogain);
    disp('---');
end


% Fig supplemental: mono loss shaft
if 0 || plotall||plotfig_mono
    figname = 'fig_mono_loss_shaft';
    disp(figname);
    n_timepoints = 7;
    [fig.oloss,h.olossh] = show_results( d.ohad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'s');
    [fig.oloss,h.mlossh] = show_results( d.mhad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.oloss,[0 0 0],false,'md','-',2,8,'s');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Loss of shaft puncta (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    disp(['Days        :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost Shaft Puncta  :  ' num2str(fix(nanmean(d.ohad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    tp=2;
    for t = tp:n_days
        x = d.ohad.relative_lost(:,t);
        x = x(~isnan(x));
        y = d.mhad.relative_lost(:,t) ;
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Lost shaft puncta difference for monocular and binocular at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.oloss);
    disp('---');
end








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Fig supplemental: mono gain
if 0 || plotall||plotfig_mono_vs_naive
    figname = 'fig_naivemono_gain';
    disp(figname);
    n_timepoints = 7;
    [fig.ogain,h.ogainp] = show_results( d.osad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'o');
    [fig.ogain,h.mgainp] = show_results( d.csad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.ogain,[0 0 0],false,'md','--',2,8,'o');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Gain (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.ogainp,h.mgainp],{'Monocular','Binocular Naive'},'location','northwest','fontsize',18)
    legend boxoff
    disp(['Days          :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Gained Puncta  :  ' num2str(fix(nanmean(d.osad.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    tp=2;
    for t = tp:n_days
        x = d.osad.relative_gained(:,t);
        x = x(~isnan(x));
        y = d.csad.relative_gained(:,t);
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Gained difference for monocular and binocular at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.ogain);
    disp('---');
end


% Fig supplemental: mono loss
if 0 || plotall||plotfig_mono_vs_naive
    figname = 'fig_naivemono_loss';
    disp(figname);
    n_timepoints = 7;
    [fig.oloss,h.olossh] = show_results( d.osad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'o');
    [fig.oloss,h.mlossh] = show_results( d.csad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.oloss,[0 0 0],false,'md','--',2,8,'o');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Loss (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    disp(['Days        :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost Puncta  :  ' num2str(fix(nanmean(d.osad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    tp=2;
    for t = tp:n_days
        x = d.osad.relative_lost(:,t);
        x = x(~isnan(x));
        y = d.csad.relative_lost(:,t) ;
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Lost difference for naive monocular and binocular at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.oloss);
    disp('---');
end



% Fig supplemental: mono gain spine
if 0 || plotall||plotfig_mono_vs_naive
    figname = 'fig_naivemono_gain_spine';
    disp(figname);
    n_timepoints = 7;
    [fig.ogain,h.ogainp] = show_results( d.opad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'v');
    [fig.ogain,h.mgainp] = show_results( d.cpad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.ogain,[0 0 0],false,'md','--',2,8,'v');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Gain of spine puncta (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    %legend([h.ogainp,h.mgainp],{'Monocular','Binocular'},'location','northwest','fontsize',18)
    % legend boxoff
    disp(['Days          :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Gained Spine Puncta  :  ' num2str(fix(nanmean(d.opad.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    tp=2;
    for t = tp:n_days
        x = d.opad.relative_gained(:,t);
        x = x(~isnan(x));
        y = d.cpad.relative_gained(:,t);
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Gained spine puncta difference for monocular and binocular naive at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.ogain);
    disp('---');
end


% Fig supplemental: mono loss spine
if 0 || plotall||plotfig_mono_vs_naive
    figname = 'fig_naivemono_loss_spine';
    disp(figname);
    n_timepoints = 7;
    [fig.oloss,h.olossh] = show_results( d.opad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'v');
    [fig.oloss,h.mlossh] = show_results( d.cpad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.oloss,[0 0 0],false,'md','--',2,8,'v');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Loss of spine puncta (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    disp(['Days        :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost Spine Puncta  :  ' num2str(fix(nanmean(d.opad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    tp=2;
    for t = tp:n_days
        x = d.opad.relative_lost(:,t);
        x = x(~isnan(x));
        y = d.cpad.relative_lost(:,t) ;
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Lost spine puncta difference for monocular and binocular naive at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.oloss);
    disp('---');
end


% Fig supplemental: mono gain shaft
if 0 || plotall||plotfig_mono_vs_naive
    figname = 'fig_naivemono_gain_shaft';
    disp(figname);
    n_timepoints = 7;
    [fig.ogain,h.ogainp] = show_results( d.ohad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'s');
    [fig.ogain,h.mgainp] = show_results( d.chad.relative_gained(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.ogain,[0 0 0],false,'md','--',2,8,'s');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Gain of shaft puncta (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    %legend([h.ogainp,h.mgainp],{'Monocular','Binocular'},'location','northwest','fontsize',18)
    % legend boxoff
    disp(['Days          :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Gained Shaft Puncta  :  ' num2str(fix(nanmean(d.ohad.relative_gained(:,2:n_days)) *100),' % 4d%%') ]);
    tp=2;
    for t = tp:n_days
        x = d.ohad.relative_gained(:,t);
        x = x(~isnan(x));
        y = d.chad.relative_gained(:,t);
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Gained shaft puncta difference for monocular and binocular naive at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.ogain);
    disp('---');
end


% Fig supplemental: mono loss shaft
if 0 || plotall||plotfig_mono_vs_naive
    figname = 'fig_naivemono_loss_shaft';
    disp(figname);
    n_timepoints = 7;
    [fig.oloss,h.olossh] = show_results( d.ohad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,[],[0 0 0],false,'','-.',2,8,'s');
    [fig.oloss,h.mlossh] = show_results( d.chad.relative_lost(:,2:n_timepoints)*100,'Puncta turnover (%)',days(2:n_timepoints),false,true,fig.oloss,[0 0 0],false,'md','--',2,8,'s');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Loss of shaft puncta (%)');
    xlabel('Time (days)');
    smaller_font(-8);
    bigger_linewidth(2);
    disp(['Days        :  ' num2str(days(2:n_days),' %4d')]);
    disp(['Lost Shaft Puncta  :  ' num2str(fix(nanmean(d.ohad.relative_lost(:,2:n_days)) *100),' % 4d%%') ]);
    tp=2;
    for t = tp:n_days
        x = d.ohad.relative_lost(:,t);
        x = x(~isnan(x));
        y = d.chad.relative_lost(:,t) ;
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Lost shaft puncta difference for monocular and binocular naive at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.oloss);
    disp('---');
end



% persistence versus intensity
if 0 || plotall || plotfigintensity_vs_lifetime_naive
    figname = 'fig_intensity_vs_lifetime_naive';
    disp(figname);
    fig.ivln = figure('Name','Persistence vs intensity','NumberTitle','off');
    hold on
    n = size(d.csad.persisting,2);
    age = [];
    intensity = [];
    for i = 1:n
        age = [age; 4*sum(d.csad.persisting{1,i}(d.csad.present{i}(:,1),1:7),2)];
        intensity = [intensity; d.csad.intensity_green{i}(d.csad.present{i}(:,1),1)];
    end
    mean_intensity = [];
    for t = min(age):4:max(age)
        ind = (age == t);
        mean_intensity(end+1) = nanmean(intensity(ind));
    end
    % age = age -0.5+0.9*rand(size(age));
    for t = min(age):4:max(age)
        ind = find(age == t);
        dens = 4*length(ind)/length(age);
        h=plot([mean_intensity(t/4) mean_intensity(t/4)],t+min(3,max(0.8*dens,1))*[-1 1],'-','linewidth',2,'color',0.5*[1 1 1]);
        age(ind) = age(ind) -dens/2+dens*rand(size(age(ind)));
    end
    
    intensity(intensity<0.001) = 0.001;
    plot(intensity,age,'.k');
    hold on
    xlabel('Normalized intensity at day 0');
    ylabel('Lifetime (days)');
    disp('Plot running average');
    set(gca,'ytick',(4:4:28));
    set(gca,'yticklabel',{'< 4','< 8','<12','<16','<20','<24',''});
    text(-0.34,28,'\geq24')
    set(gca,'xtick',0:5);
    axis square
    ylim([2 31])
    xlim([0 5]);
    local_savefig(figname,fig.ivln);
    
    disp('---');
    
end

% persistence versus intensity
if 0 || plotall || plotfigintensity_vs_lifetime_md
    figname = 'fig_intensity_vs_lifetime_md';
    disp(figname);
    fig.ivln = figure('Name','Persistence vs intensity','NumberTitle','off');
    hold on
    n = size(d.msad.persisting,2);
    age = [];
    intensity = [];
    for i = 1:n
        age = [age; 4*sum(d.msad.persisting{1,i}(d.msad.present{i}(:,1),1:7),2)];
        intensity = [intensity; d.msad.intensity_green{i}(d.msad.present{i}(:,1),1)];
    end
    
    mean_intensity = [];
    for t = min(age):4:max(age)
        ind = (age == t);
        mean_intensity(end+1) = nanmean(intensity(ind));
    end
    box off
    
    % age = age -0.5+0.9*rand(size(age));
    for t = min(age):4:max(age)
        ind = find(age == t);
        dens = 1.5*4*length(ind)/length(age)
        h=plot([mean_intensity(t/4) mean_intensity(t/4)],t+min(3,max(0.8*dens,1))*[-1 1],'-','linewidth',2,'color',0.5*[1 1 1]);
        age(ind) = age(ind) -dens/2+dens*rand(size(age(ind)));
    end
    
    intensity(intensity<0.001) = 0.001;
    plot(intensity,age,'.k');
    %    set(gca,'xscale','log');
    xlabel('Normalized intensity at day 0');
    ylabel('Lifetime (days)');
    disp('Plot running average');
    set(gca,'ytick',(4:4:28));
    set(gca,'yticklabel',{'< 4','< 8','<12','<16','<20','<24',''});
    text(-0.34,28,'\geq24')
    set(gca,'xtick',0:5);
    axis square
    
    
    
    %      mean_intensity = [];
    %      median_age = [];
    %      for p =0:10:90
    %          per1=prctile(intensity,p);
    %          per2=prctile(intensity,p+10);
    %          ind = find(intensity>=per1 & intensity<per2);
    %          mean_intensity(end+1) = mean(intensity(ind));
    %          median_age(end+1) = median(round(age(ind)));
    %
    %      end
    %      mean_intensity(end+1) = max(intensity);
    %      median_age(end+1) = 28;
    %      h=plot(mean_intensity,median_age,'-','linewidth',2,'color',0.5*[1 1     1]);
    ylim([2 31])
    xlim([0 5]);
    
    local_savefig(figname,fig.ivln);
    
    disp('---');
    
end

% Fig_spine_gain, not the puncta, the structure
if 0 || plotall || plotfigspinegain
    figname = 'fig_spine_gain';
    disp(figname);
    [fig.closs,h.loss] = show_results( d.cpad.relative_spine_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],false,'','--');
    [fig.closs,h.gain] = show_results( d.mpad.relative_spine_gained(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.closs,[0 0 0],false,'md','-');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Spine gain (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.loss,h.gain],{'Naive','MD'},'location','northwest','fontsize',18)
    legend boxoff
    calc_interactions( d.cpad.relative_spine_gained(:,2:7), d.mpad.relative_spine_gained(:,2:7), 'Gained Spines', days);
    tp=2;
    for t = tp:n_days
        x = d.cpad.relative_spine_gained(:,t);
        y = d.mpad.relative_spine_gained(:,t);
        x = x(~isnan(x));
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Gained Spine difference for Naive and MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.closs);
    disp('---');
end

% Fig_spine_loss, not the puncta, the structure
if 0 || plotall || plotfigspineloss
    figname = 'fig_spine_loss';
    disp(figname);
    [fig.spineloss,h.loss] = show_results( d.cpad.relative_spine_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],false,'','--');
    [fig.spineloss,h.gain] = show_results( d.mpad.relative_spine_lost(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.spineloss,[0 0 0],false,'md','-');
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Spine loss (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.loss,h.gain],{'Naive','MD'},'location','northwest','fontsize',18)
    legend boxoff
    calc_interactions( d.cpad.relative_spine_lost(:,2:7), d.mpad.relative_spine_lost(:,2:7), 'Lost Spines', days);
    tp=2;
    for t = tp:n_days
        x = d.cpad.relative_spine_lost(:,t);
        y = d.mpad.relative_spine_lost(:,t);
        x = x(~isnan(x));
        y = y(~isnan(y));
        p = kruskal_wallis_test(x,y);
        if p<0.05
            disp(['Lost Spine difference for Naive and MD at day ' num2str(4*(t-1)) ', p = ' num2str(p,2)]);
            star = '*';
            if p<0.01
                star = '**';
            end
            if p<0.001
                star = '***';
            end
            text((t-1)*4,29,star,'horizontalalignment','center','verticalalignment','top','fontsize',20);
        end
    end
    local_savefig(figname,fig.spineloss);
    disp('---');
end


% Fig_joint_spine_loss, the puncta and the structure
if 0 || plotall || plotfigjointspineloss
    figname = 'fig_joint_spine_loss';
    disp(figname);
    [fig.jointspineloss,h.absent] = show_results( d.mpad.relative_lost_spine_absent(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],false,'','-',2,8,'v');
    [fig.jointspineloss,h.present] = show_results( d.mpad.relative_lost_spine_present(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.jointspineloss,[0 0 0],false,'','-',2,8,'v');
    set(h.present,'markerfacecolor',[0 0 0]);
    
    [fig.jointspineloss,h.cabsent] = show_results( d.cpad.relative_lost_spine_absent(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.jointspineloss,[0 0 0],false,'','--',2,8,'v');
    [fig.jointspineloss,h.cpresent] = show_results( d.cpad.relative_lost_spine_present(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.jointspineloss,[0 0 0],false,'','--',2,8,'v');
    set(h.cpresent,'markerfacecolor',[0 0 0]);
    
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Spine puncta loss (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    %    legend([h.present,h.absent,h.cpresent,h.cabsent],{'Spine survived, MD','Spine lost, MD','Spine survived, Naive','Spine lost, Naive'},'location','northwest','fontsize',18)
    %    legend boxoff
    
    local_savefig(figname,fig.jointspineloss);
    disp('---');
end


% Fig_joint_spine_gain, the puncta and the structure
if 0 || plotall || plotfigjointspinegain
    figname = 'fig_joint_spine_gain';
    disp(figname);
    [fig.jointspinegain,h.absent] = show_results( d.mpad.relative_gained_spine_absent(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,[],[0 0 0],false,'','-',2,8,'v');
    [fig.jointspinegain,h.present] = show_results( d.mpad.relative_gained_spine_present(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.jointspinegain,[0 0 0],false,'','-',2,8,'v');
    set(h.present,'markerfacecolor',[0 0 0]);
    
    [fig.jointspinegain,h.cabsent] = show_results( d.cpad.relative_gained_spine_absent(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.jointspinegain,[0 0 0],false,'','--',2,8,'v');
    [fig.jointspinegain,h.cpresent] = show_results( d.cpad.relative_gained_spine_present(:,2:n_days)*100,'Puncta turnover (%)',days(2:n_days),false,true,fig.jointspinegain,[0 0 0],false,'','--',2,8,'v');
    set(h.cpresent,'markerfacecolor',[0 0 0]);
    
    set(gca,'ytick',[0 10 20 30]);
    ylim([0 30])
    ylabel('Spine puncta gain (%)');
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.present,h.absent,h.cpresent,h.cabsent],{'Spine preexisting, MD','Spine new, MD','Spine preexisting, Naive','Spine new, Naive'},'location','northwest','fontsize',18)
    legend boxoff
    
    local_savefig(figname,fig.jointspinegain);
    disp('---');
end


if 0 || plotall || computedynamicsasymptote
    figname = 'fig_dynamics_threshold_small';
    disp(figname);
    n_thresholds = 50;
    thresholds = linspace(-0.2,1,n_thresholds);
    for th = 1:n_thresholds
        for i = 1:length(d.csad.present)
            minmat = 0;% repmat( min(d.csad.intensity_green{i}),size(d.csad.intensity_green{i},1),1);
            present = ((d.csad.intensity_green{i}-minmat)>thresholds(th) & d.csad.present{i});
            %present = ((d.csad.intensity_green{i}-minmat)>thresholds(th))
            loss = zeros(size(present));
            gain = zeros(size(present));
            if ndims(loss)==1
                loss = zeros(1,8);
                gain = zeros(1,8);
            end
            loss(:,2:end) = (present(:,1:end-1) & ~present(:,2:end));
            gain(:,2:end) = (~present(:,1:end-1) & present(:,2:end));
            
            
            total_relative_loss(i,2:8) = sum(loss(:,2:end)) ./ sum(present(:,1:end-1));
            total_relative_gain(i,2:8) = sum(gain(:,2:end)) ./ sum(present(:,2:end));
            total_present(i,:) = sum(present);
        end %i
        min_per_group = 9; %
        small_groups = (mean(total_present,2)<min_per_group);
        add_to_end =  sum(mean(total_present(small_groups,:),2)>=min_per_group);
        if any(small_groups)
            total_present = remove_small_groups(total_present,small_groups,add_to_end);
            total_relative_loss = remove_small_groups(total_relative_loss,small_groups,add_to_end);
            total_relative_gain = remove_small_groups(total_relative_gain,small_groups,add_to_end);
        end
        mean_loss(th) = mean(flatten(total_relative_loss(:,2:7)));
        sem_loss(th) =  sem(flatten(total_relative_loss(:,2:7)));
        mean_gain(th) = mean(flatten(total_relative_gain(:,2:7)));
        sem_gain(th) =  sem(flatten(total_relative_gain(:,2:7)));
    end % th
    fig.dynamicsthresholdsmall = figure;
    hold on
    h.mloss = plot(thresholds*100,mean_loss*100,'-b');
    h.mgain = plot(thresholds*100,mean_gain*100,'-r');
    xlabel('Intensity threshold (%)');
    ylabel('Mean turnover (%)');
    hl = line([0 100],[10 10],'color',[0.7 0.7 0.7]);
    hl = line([0 100],[20 20],'color',[0.7 0.7 0.7]);
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.mgain,h.mloss],{'Gain','Loss'},'location','northwest');
    legend boxoff
    xlim([0 16]);
    ylim([0 30])
    local_savefig(figname,fig.dynamicsthresholdsmall);
    disp('---');
end


if 0 || plotall || computedynamicsasymptote
    figname = 'fig_dynamics_threshold_inset';
    disp(figname);
    n_thresholds = 50;
    thresholds = linspace(-0.2,1,n_thresholds);
    for th = 1:n_thresholds
        for i = 1:length(d.csad.present)
            minmat = 0;% repmat( min(d.csad.intensity_green{i}),size(d.csad.intensity_green{i},1),1);
            present = ((d.csad.intensity_green{i}-minmat)>thresholds(th) & d.csad.present{i});
            %present = ((d.csad.intensity_green{i}-minmat)>thresholds(th))
            loss = zeros(size(present));
            gain = zeros(size(present));
            if ndims(loss)==1
                loss = zeros(1,8);
                gain = zeros(1,8);
            end
            loss(:,2:end) = (present(:,1:end-1) & ~present(:,2:end));
            gain(:,2:end) = (~present(:,1:end-1) & present(:,2:end));
            
            
            total_relative_loss(i,2:8) = sum(loss(:,2:end)) ./ sum(present(:,1:end-1));
            total_relative_gain(i,2:8) = sum(gain(:,2:end)) ./ sum(present(:,2:end));
            total_present(i,:) = sum(present);
        end %i
        min_per_group = 9; %
        small_groups = (mean(total_present,2)<min_per_group);
        add_to_end =  sum(mean(total_present(small_groups,:),2)>=min_per_group);
        if any(small_groups)
            total_present = remove_small_groups(total_present,small_groups,add_to_end);
            total_relative_loss = remove_small_groups(total_relative_loss,small_groups,add_to_end);
            total_relative_gain = remove_small_groups(total_relative_gain,small_groups,add_to_end);
        end
        mean_loss(th) = mean(flatten(total_relative_loss(:,2:7)));
        sem_loss(th) =  sem(flatten(total_relative_loss(:,2:7)));
        mean_gain(th) = mean(flatten(total_relative_gain(:,2:7)));
        sem_gain(th) =  sem(flatten(total_relative_gain(:,2:7)));
    end % th
    fig.dynamicsthresholdinset = figure;
    hold on
    h.mloss = plot(thresholds*100,mean_loss*100,'-b');
    h.mgain = plot(thresholds*100,mean_gain*100,'-r');
   % xlabel('Intensity threshold (%)');
   % ylabel('Mean turnover (%)');
    hl = line([0 100],[10 10],'color',[0.7 0.7 0.7]);
    hl = line([0 100],[20 20],'color',[0.7 0.7 0.7]);
    smaller_font(-10);
    bigger_linewidth(2);
   % legend([h.mgain,h.mloss],{'Gain','Loss'},'location','northwest');
   % legend boxoff
    xlim([0 16]);
    x=0:0.1:20;
b=5.6;a=1.2;t=14;plot(x,b+a*exp(x/t),'k--')
ylim([6 10]);
text(5,6.5,'5.6 + 1.2 exp(thres/14%)','fontsize',22)
    local_savefig(figname,fig.dynamicsthresholdinset);
    disp('---');
end

if 0 || plotall || computedynamicsasymptote
    figname = 'fig_dynamics_threshold_large';
    disp(figname);
    n_thresholds = 50;
    thresholds = linspace(-0.2,1,n_thresholds);
    for th = 1:n_thresholds
        for i = 1:length(d.csad.present)
            minmat = 0;% repmat( min(d.csad.intensity_green{i}),size(d.csad.intensity_green{i},1),1);
            present = ((d.csad.intensity_green{i}-minmat)>thresholds(th) & d.csad.present{i});
            %present = ((d.csad.intensity_green{i}-minmat)>thresholds(th))
            loss = zeros(size(present));
            gain = zeros(size(present));
            if ndims(loss)==1
                loss = zeros(1,8);
                gain = zeros(1,8);
            end
            loss(:,2:end) = (present(:,1:end-1) & ~present(:,2:end));
            gain(:,2:end) = (~present(:,1:end-1) & present(:,2:end));
            
            
            total_relative_loss(i,2:8) = sum(loss(:,2:end)) ./ sum(present(:,1:end-1));
            total_relative_gain(i,2:8) = sum(gain(:,2:end)) ./ sum(present(:,2:end));
            total_present(i,:) = sum(present);
        end %i
        min_per_group = 9; %
        small_groups = (mean(total_present,2)<min_per_group);
        add_to_end =  sum(mean(total_present(small_groups,:),2)>=min_per_group);
        if any(small_groups)
            total_present = remove_small_groups(total_present,small_groups,add_to_end);
            total_relative_loss = remove_small_groups(total_relative_loss,small_groups,add_to_end);
            total_relative_gain = remove_small_groups(total_relative_gain,small_groups,add_to_end);
        end
        mean_loss(th) = mean(flatten(total_relative_loss(:,2:7)));
        sem_loss(th) =  sem(flatten(total_relative_loss(:,2:7)));
        mean_gain(th) = mean(flatten(total_relative_gain(:,2:7)));
        sem_gain(th) =  sem(flatten(total_relative_gain(:,2:7)));
    end % th
    fig.dynamicsthresholdlarge = figure;
    hold on
    h.mloss = plot(thresholds*100,mean_loss*100,'-b');
    h.mgain = plot(thresholds*100,mean_gain*100,'-r');
    xlabel('Intensity threshold (%)');
    ylabel('Mean turnover (%)');
    hl = line([0 100],[10 10],'color',[0.7 0.7 0.7]);
    hl = line([0 100],[20 20],'color',[0.7 0.7 0.7]);
    smaller_font(-8);
    bigger_linewidth(2);
    legend([h.mgain,h.mloss],{'Gain','Loss'},'location','northwest');
    legend boxoff
    xlim([0 80]);
    ylim([0 30])
    local_savefig(figname,fig.dynamicsthresholdlarge);
    disp('---');
end


%%%%%%% OTHER FIGURES %%%%%%%%%%%%%


% figure all data
if 0 || plotall
    figname = 'figallspinedata_md';
    disp(figname);
    punctum_present = [];
    spine_present = [];
    for i=1:length(d.mpad.present);
        punctum_present = [punctum_present ; d.mpad.present{i}];
        spine_present = [spine_present; d.mpad.spine_present{i}];
    end
  % punctum_present = punctum_present(any(punctum_present,2),:);
  
  mp = punctum_present + 2*spine_present;
  mp(mp==1) = 3;
  
  mp = mp(:,[2 5 7]);
  mp = mp( any(mp,2),:);
  fig.allspinedatamd = figure;
  
  %mp = mp(:,[1 3 2]);
  smp = sortrows(mp);
 % smp = smp(:,[1 3 2]);
  
  imagesc(smp)
  
  colormap([1 1 1; 0 1 0;1 0 0;0.2 1 0])
   
  set(gca,'xtick',[1 2 3]);
   set(gca,'xticklabel',{'Before MD','End of MD','During recovery'});
   ylabel('Punctum nr.');
    local_savefig(figname,fig.allspinedatamd);
    disp('---');
end


if 0 || plotall
    figname = 'figallspinedata_c';
    disp(figname);
    punctum_present = [];
    spine_present = [];
    for i=1:length(d.cpad.present);
        punctum_present = [punctum_present ; d.cpad.present{i}];
        spine_present = [spine_present; d.cpad.spine_present{i}];
    end
  % punctum_present = punctum_present(any(punctum_present,2),:);
  
  mp = punctum_present + 2*spine_present;
  mp(mp==1) = 3;
  
  mp = mp(:,[2 5 7]);
  mp = mp( any(mp,2),:);
  fig.allspinedatac = figure;
  imagesc(sortrows(mp))
  
  colormap([1 1 1; 0 1 0;1 0 0;0.2 1 0])
   
  set(gca,'xtick',[1 2 3]);
   set(gca,'xticklabel',{'Before MD','End of MD','During recovery'});
   ylabel('Punctum nr.');
    local_savefig(figname,fig.allspinedatac);
    disp('---');
end


% spine number
if 0|| plotall
    tp = 1;
    [fig.number_spine,h.persabs] = show_results( d.mpad.total_present(:,tp:n_days)./repmat(d.mpad.total_present(:,tp),1,n_days-tp+1)   ,'Spine puncta #',days(tp:n_days),false,true,[],[0 0 0],false,'','-',2,8,'v');
    [fig.number_spine,h.newabs] = show_results( d.cpad.total_present(:,tp:n_days)./repmat(d.cpad.total_present(:,tp),1,n_days-tp+1),'Spine puncta #',days(tp:n_days),false,true,fig.number_spine,[0 0 0],false,'md','--',2,8,'v');
    legend([h.persabs,h.newabs],{'MD','Naive'});
    legend boxoff
    savefig('spine_number.png',fig.number_spine,'png');
    savefig('spine_number.eps',fig.number_spine,'eps');
    
end

% shaft number
if 0|| plotall
    tp = 1;
    [fig.number_shaft,h.persabs] = show_results( d.mhad.total_present(:,tp:n_days)./repmat(d.mhad.total_present(:,tp),1,n_days-tp+1)   ,'Shaft puncta #',days(tp:n_days),false,true,[],[0 0 0],false,'','-',2,8,'s');
    [fig.number_shaft,h.newabs] = show_results( d.chad.total_present(:,tp:n_days)./repmat(d.chad.total_present(:,tp),1,n_days-tp+1),'Shaft puncta #',days(tp:n_days),false,true,fig.number_shaft,[0 0 0],false,'md','--',2,8,'s');
    legend([h.persabs,h.newabs],{'MD','Naive'});
    legend boxoff
    savefig('shaft_number.png',fig.number_shaft,'png');
    savefig('shaft_number.eps',fig.number_shaft,'eps');
    
end


%
% draw figures subroutines
%

function draw_plotspinepuncatratio( d )
% spine puncta ratio

disp('GENERATE_ALL_DAAN_FIGURES:');
ind = ~isnan(d.spinecount.density) & ~isnan(d.punctacount.density);
disp(['Spines: ' num2str(mean(d.spinecount.density(ind)),2) ...
    ' +- '  num2str(sem(d.spinecount.density(ind)),2) ' per micron']);
disp(['Puncta: ' num2str(mean(d.punctacount.density(ind)),2) ...
    ' +- '  num2str(sem(d.punctacount.density(ind)),2) ' per micron']);
disp(['Spine puncta: ' num2str(mean(d.spinepunctacount.density(ind)),2) ...
    ' +- '  num2str(sem(d.spinepunctacount.density(ind)),2) ' per micron']);
disp(['Shaft puncta: ' num2str(mean(d.shaftpunctacount.density(ind)),2) ...
    ' +- '  num2str(sem(d.shaftpunctacount.density(ind)),2) ' per micron']);

puncta_spine_density_ratio = d.punctacount.density ./d.spinecount.density;
disp(['Puncta density vs spine density: ' num2str(mean(puncta_spine_density_ratio(ind)),2) ...
    ' +- '  num2str(sem(puncta_spine_density_ratio(ind)),2) ]);

puncta_per_spine = d.spinepunctacount.density ./d.spinecount.density;
disp([ num2str(mean(puncta_per_spine(ind))*100,2) ...
    ' +- '  num2str(sem(puncta_per_spine(ind))*100,2) ' % of spines have puncta']);

figure;
plot(d.spinecount.density(ind),d.spinepunctacount.density(ind),'.');
% xlim([0 1]);
% ylim([0 1]);
xlabel('Spines per micron');
ylabel('Spine puncta per micron');
[r,p]=corrcoef(d.spinecount.density(ind),d.spinepunctacount.density(ind));
disp(['Correlation between spine and spine puncta density, r = ' num2str(r(1,2),2) ', p = ' num2str(p(1,2),2)]);


function [hfig,hplot] = show_results( data,ylab,days,plotpoints,plotmean,fig,clr,plotsig,mouse_type ,line_style,line_width,marker_size,marker,ylims,testtp)
%global savepath

if nargin<15;testtp=[];end
if nargin<14;ylims=[];end
if nargin<13;marker=[];end
if isempty(marker);marker = 'o';end
if nargin<12;marker_size=[];end
if isempty(marker_size);marker_size = 8;end


if nargin<11
    line_width = 2;
end
if nargin<10
    line_style = '-';
end
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
if nargin<9
    mouse_type = '';
end

% take out completely zero rows
nonzero_rows = (nansum(abs(data),2)>0);
data = data(nonzero_rows,:);
%disp(['Days: ' num2str(days)]);
%disp([ylab ': ' num2str(nanmean(data)) ]);

hold on

if ~isempty(findstr(lower(ylab),'turn')) && isempty(fig)
    hl = line([0 24],[10 10],'color',[0.7 0.7 0.7]);
    drawnow
    c = get(gca,'children');
    set(gca,'children',[setdiff(c,hl) ; hl]);
    
    hl = line([0 24],[20 20],'color',[0.7 0.7 0.7]);
    drawnow
    c = get(gca,'children');
    set(gca,'children',[setdiff(c,hl) ; hl]);
end

if plotmean
    if numel(data)~=length(data)
        hplot= errorbar(days,nanmean(data),sem(data),'k','linewidth',2,...
            'linestyle',line_style,'linewidth',line_width);
    else
        hplot = plot(days,data,'k','linewidth',2,'linestyle',line_style,'linewidth',line_width,'markersize',marker_size);
    end
    if ~isempty(clr)
        set(hplot,'color',clr);
    end
    set(hplot,'marker',marker,'MarkerFaceColor',[1 1 1],'MarkerSize',marker_size);
    ax = axis;
    ax(3) = 0;
    ax(4) = ax(4)*1.1;
    axis(ax);
end

disp(ylab)
disp(['Days: ' num2str(days,'%7d')])
disp(['Mean: ' num2str(nanmean(data),' %.2f')])
disp(['Sem : ' num2str(sem(data), ' %.2f')])

if plotpoints
    if ~isempty(clr)
        plot(days,data','color',clr);
    else
        plot(days,data');
    end
end

if ~isempty(ylims)
    ylim(ylims);
end

ax = axis;

% show MD grey background
if ~isempty(findstr(lower(mouse_type),'md'))
    hbar = bar(7+6,ax(4)*2,12);
    set(hbar,'facecolor',0.8*[1 1 1],'linestyle','none');
    drawnow
    c=get(gca,'children');
    set(gca,'children',[sort(setdiff(c,hbar),1,'descend') ; hbar]);
    %  line( [ax(1) ax(3)],[ax(2) ax(4)],'color',[0 0 0]);
    %    text( 13,ax(4),'MD','horizontalalignment','center','verticalalignment','top');
end



axis(ax);

xlabel('Time (days)');
xlim([-0.3 max(days)]);
set(gca,'xtick',days);
ylabel(ylab);

set(gca,'tickdir','out')
box off


if plotmean && plotsig && numel(data)~=length(data)
    if isempty(testtp)
        if isnan(data(1,1))
            testtp = 2;
        else
            testtp = 1;
        end
    end
    
    for i=(testtp+1):length(days)
        [~,p]=ttest( data(:,testtp),data(:,i));
        try
            pf = friedman( [data(:,testtp) data(:,i)],1,'off');
        catch
            pf = NaN;
        end
        p = pf;
        if p<0.1
            disp([ylab ' different from day ' num2str(days(testtp)) ' to day ' num2str(days(i)) ', friedman test p = ' num2str(pf,2)  ]);
            %disp([ylab ' different from baseline at day ' num2str(days(i)) ', paired ttest p = ' num2str(p,2)  ]);
            if p<0.001
                ch = '***';
            elseif p<0.01
                ch = '**';
            elseif p<0.05
                ch = '*';
            elseif p<0.1;
                ch = '';
            end
            if ~isempty(clr)
                text(days(i),nanmean(data(:,i))+sem(data(:,i))+(ax(4)-ax(3))*0.05,ch,...
                    'fontsize',20,'color',clr,'verticalalignment','middle',...
                    'horizontalalignment','center');
            else
                text(days(i),nanmean(data(:,i))+sem(data(:,i))+(ax(4)-ax(3))*0.05,ch,'fontsize',20,'verticalalignment','middle','horizontalalignment','center');
            end
        end
    end
end


%figfilename = ylab;
%save_figure(figfilename,savepath);


function local_savefig(name,fig)
figpath = fullfile(getdesktopfolder,'Figures');
save_figure([name '.png'],figpath,fig);
saveas(fig,fullfile(figpath,[name '.ai']),'ai');
warning('off','MATLAB:print:Illustrator:DeprecatedDevice');

% function x = remove_small_groups(x,small_groups)
% large_groups = true(size(x,1),1)&~small_groups;
%
% if isnumeric(x)
%     small_group_x = sum(x(small_groups,:));
%     x = x(large_groups,:);
%     x(end+1,:) = small_group_x;
% else
%     small_group_x = [x{small_groups}];
%     x = {x{large_groups}};
%     x{end+1} = small_group_x;
% end
function x = remove_small_groups(x,small_groups,add_to_end)
if nargin<3
    add_to_end = true;
end

large_groups = true(size(x,1),1)&~small_groups;

if isnumeric(x)
    x = x(large_groups,:);
    if add_to_end
        small_group_x = sum(x(small_groups,:));
        x(end+1,:) = small_group_x;
    end
else
    x = {x{large_groups}};
    if add_to_end
        small_group_x = [x{small_groups}];
        x{end+1} = small_group_x;
    end
end



function    calc_interactions(group1,group2, dataname,days)
n_days = 7;
disp(['Days   ' char(32*ones(1,length(dataname))) ':  ' num2str(days(2:n_days),' %4d')]);
disp([dataname ' Naive  :  ' num2str(fix(nanmean(group1) *100),' % 4d%%') ]);
disp([dataname ' MD     :  ' num2str(fix(nanmean(group2) *100),' % 4d%%') ]);

p = kruskal_wallis_test(group1(:,1),group1(:,2),group1(:,3),group1(:,4),group1(:,5),group1(:,6));
disp(['Significant influence of time on ' dataname ', Naive: ' num2str(p,2)]);
p = kruskal_wallis_test(group2(:,1),group2(:,2),group2(:,3),group2(:,4),group2(:,5),group2(:,6));
disp(['Significant Influence of time on ' dataname ', MD: ' num2str(p,2)]);
% friedman does column interaction for balanced test, anovan for unbalanced
y = [group1; group2];
time_factor = repmat((2:7), size(group1,1)+ size(group2,1),1);
experience_factor = [repmat(zeros(1,6),size(group1,1),1); repmat(ones(1,6),size(group2,1),1)];
[p,atab] = anovan( y(:),{time_factor(:),experience_factor(:)},'model',2,'display','off','varnames',strvcat('Time','Experience'));
atab
disp(['Interaction of ' dataname ' with Time, two-way anova: ' num2str(p(1),2)]);
disp(['Interaction of ' dataname ' with Experience, two-way anova: ' num2str(p(2),2)]);

%subject_grouping = repmat( (1:size(y,1))',1,size(y,2));
%rm_anova2(y(:),subject_grouping(:),time_factor(:),experience_factor(:),{'time','experience'})

