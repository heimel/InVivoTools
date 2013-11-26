function gephyrin_plot_puncta_gain( d )
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
