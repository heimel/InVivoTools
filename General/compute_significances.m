function h = compute_significances( y,x, test, signif_y, ystd, ny, tail, transform, h)
%COMPUTE_SIGNIFICANCES performs standard set of tests on data, and plots stars
%
% H = COMPUTE_SIGNIFICANCES(X,Y,TEST,SIGNIF_Y,YSTD,NY,TAIL,TRANSFORM,H)
%
%    H is result struct
%
% 2014, Alexander Heimel

if nargin<3
    test = '';
end
if nargin<4
    signif_y = [];
end
if nargin<5
    ystd = {};
end
if nargin<6
    ny = {};
end
if nargin<7
    tail = '';
end
if nargin<8
    transform = '';
end


if strcmp(test,'none')
    return
end

test = lower(subst_specialchars(strtrim(test))); % to substitute spaces by _

if  strcmp(test,'chi2')
    d = zeros(length(y),2);
    for i=1:length(y)
        d(i,1)=sum( y{i}(~isnan(y{i}))==0 );
        d(i,2)=sum( y{i}(~isnan(y{i}))==1 );
    end
    [p_chi2,chi2] = chi2class( d);
    logmsg(['p of chi2class test = ' num2str(p_chi2) ...
        ' over all groups. chi2-statistic = ' num2str(chi2)]);
end

ax=axis;
height=(ax(4)-ax(3))/20;
w=0.1;


for i=1:length(y)
    ind = ~isnan(y{i});
    
    logmsg(['Group ' num2str(i) ':  ' num2str(mean(y{i}(ind)),3) ...
        ' +/- ' num2str(std(y{i}(ind)),2) ...
        ' [' num2str(sem(y{i}(ind)),2) ']' ...
        ' (mean +/- std [sem]), n = ' num2str(length(y{i}(ind))) ' + ' num2str(sum(isnan(y{i}))) ' NaNs']);
end


notnormal = false;

% transform
if ~isempty(transform)
    y = cellfun(str2func(transform),y,'UniformOutput',false);
    logmsg(['Applying ' transform ' transform']);
end


for i=1:length(y)
    if sum(~isnan(y{i}))>2 && ~all(y{i}==y{i}(1))
        [hsw,p] = swtest(y{i}); %#ok<ASGLU>
        if p<0.05
            notnormal = true;
        end
        
        logmsg(['Group ' num2str(i) ':  '  ...
            'Shapiro-Wilk normality p = ' num2str(p,2)]);
    else
        logmsg(['Group ' num2str(i) ' has less than 3 NaN entries. Cannot compute normality']);
    end
end

nonparametric = 0;
switch test
    case {'signrank','wilcoxon'}
        nonparametric = 1;
    case {'ranksum','mann-whitney','mannwhitney'}
        nonparametric = 1;
    case {'kruskal-wallis','kruskal_wallis','kruskal wallis','kruskalwallis'}
        nonparametric = 1;
end

    
    
if notnormal
    logmsg('Detected a not normal group. Do a transform or use Kruskal-Wallis, unless n is high (>30)');   
end

if nonparametric || notnormal
    for i=1:length(y)
        ind = ~isnan(y{i});
        n = ceil(100000/length(y{i}(ind)));
        btsm=std(bootstrp(n,@mean,y{i}(ind)));
        logmsg(['Group ' num2str(i) ':  ' num2str(median(y{i}(ind)),3) ...
            ' +/- ' num2str(btsm,2)  ...
            ' (median +/- bootstrap std (sem)), n = ' num2str(length(y{i}(ind))) ' + ' num2str(sum(isnan(y{i}))) ' NaNs']);
    end
end

if length(y)>2 % multigroup comparison
    v = [];
    group = [];
    for i=1:length(y)
        v = cat(1,v,y{i}(:));
        group = cat(1,group,i*ones(length(y{i}),1));
    end
    
    
    
    [h.p_groupkruskalwallis,anovatab,kwstats] = kruskalwallis(v,group,'off');
    logmsg(['Group Kruskal-Wallis: p = ' num2str(h.p_groupkruskalwallis,2) ', df = ' num2str(anovatab{4,3})]);
    [h.p_groupanova,anovatab,stats] = anova1(v,group,'off');
    logmsg(['Group ANOVA: p = ' num2str(h.p_groupanova,2) ', s[' num2str(stats.df) '] = ' num2str(stats.s)]);
    try
        h.p_grouplevene = vartestn(v,group,'display','off');
    catch me
        switch me.identifier
            case 'stats:vartestn:BadDisplayOpt' % older matlab versions R2009b
                h.p_grouplevene = vartestn(v,group,'off');
            otherwise
                rethrow(me)
        end
    end
    logmsg(['Levene test for equality of variances p = ' num2str(h.p_grouplevene,2)]);
    if h.p_grouplevene<0.05
        [h.p_groupwelchanova,f,df] = welchanova([v group],[],'off');
        logmsg(['Welch unequal variance ANOVA p = ' num2str(h.p_groupwelchanova,2) ...
            ', F[' num2str(df) ']=' num2str(f)]);
    end
    if h.p_groupanova<0.05 || (isfield(h,'p_groupwelchanova') && h.p_groupwelchanova<0.05)
        p = dunnett(stats);
        for i=2:length(p)
            logmsg(['Post-hoc parametric Dunnett (first group is common control) group ' num2str(i) ': p = ' num2str(p(i),2)]);
        end
        comparison = multcompare(stats,'ctype','tukey-kramer','display','off');
        try
            for i=1:size(comparison,1) % over all tests
                logmsg(['Post-hoc parametric Tukey-Kramer, groups ' num2str(comparison(i,1)) ...
                    ' vs ' num2str(comparison(i,2)) ': p = ' num2str(comparison(i,6),2)]);
            end
        catch me
            switch me.identifier
                case 'MATLAB:badsubscript' % older matlab versions R2009b
                    logmsg('No post-hoc Tukey-Kramer tests. Update matlab' );
                otherwise
                    rethrow(me)
            end
        end
    end
    if h.p_groupkruskalwallis<0.05
        comparison = multcompare(kwstats,'ctype','bonferroni','display','off');
        try
            for i=1:size(comparison,1) % over all tests
                logmsg(['Post-hoc bonferroni corrected Mann-Whitney U test, groups ' num2str(comparison(i,1)) ...
                    ' vs ' num2str(comparison(i,2)) ': p = ' num2str(comparison(i,6),2)]);
            end
        catch me
            switch me.identifier
                case 'MATLAB:badsubscript' % older matlab versions R2009b
                    logmsg('No post-hoc tests. Update matlab' );
                otherwise
                    rethrow(me)
            end
        end
    end
    
end % multigroup comparison


if ~( length(signif_y)==1 && signif_y==0)
    for i=1:length(y)
        switch test
            case 'ttest'
                % check normality
                if length(y{i})>2 && ~all(y{i}==y{i}(1))
                    [h_norm,p_norm] = swtest(y{i});
                    if h_norm
                        logmsg(['Group ' num2str(i) ' is not normal. Shapiro-Wilk test p = ' num2str(p_norm) '. Change test to kruskal_wallis']);
                    end
                else
                    logmsg(['Too few observation to test normality of group ' num2str(i)]);
                end
            case 'paired_ttest'
                % check normality
                [h_norm,p_norm] = swtest(y{i});
                if h_norm
                    logmsg(['Group ' num2str(i) ' is not normal. Shapiro-Wilk test p = ' num2str(p_norm) '. Change test to signrank.']);
                end
        end
    end
    for i=1:length(y)
        for j=i+1:length(y)
            nsig=(i-1)*length(y)+j;
            
            ind_y=[];
            
            if ~isempty(signif_y)
                if size(signif_y,2)==1 % single column, specify which to do
                    if isempty(find(signif_y==nsig,1))
                        continue
                    end
                else % double column, specify height or which not to do
                    ind_y = find(signif_y(:,1)==nsig);
                    if ~isempty(ind_y) && isnan(signif_y(ind_y,2))
                        continue
                    end
                end
            end
            
            if isempty(ind_y) % no mention in signif_y list
                y_star=ax(4)+height*(j-i-1);
            else
                y_star=signif_y(ind_y(1),2);
            end
            
            % matlab significance test using sample data
            if iscell(ystd) && iscell(ny)
                [h.h_sig{i,j},h.p_sig{i,j},statistic,statistic_name,dof,testperformed]=...
                    compute_pairwise_significance(y{i},y{j},test,...
                    ystd{i},ny{i},ystd{j},ny{j},tail);
            else
                [h.h_sig{i,j},h.p_sig{i,j},statistic,statistic_name,dof,testperformed]=...
                    compute_pairwise_significance(y{i},y{j},test,...
                    [],[],[],[],tail);
                
            end
            plot_significance(x(i),x(j),y_star,h.p_sig{i,j},height,w)
            if h.p_sig{i,j}<1
                if length(y)>2
                    outstat = 'Uncorrected ';
                else
                    outstat = '';
                end
                outstat = [outstat testperformed ', ' num2str(nsig)...
                    ' = grp ' num2str(i) ' vs grp ' num2str(j) ...
                    ', p = ' num2str(h.p_sig{i,j},2)  ]; %#ok<AGROW>
                if ~isempty(statistic_name)
                    if ~isempty(dof) && ~isnan(dof)
                        outstat = [outstat ...
                            ', ' statistic_name ...
                            '[' num2str(dof) '] = ' num2str(statistic) ]; %#ok<AGROW>
                    else
                        outstat = [outstat ...
                            ', ' statistic_name ' = ' num2str(statistic) ]; %#ok<AGROW>
                    end
                end
                logmsg(outstat);
            end
        end
    end
end

