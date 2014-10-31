function [h,p,statistic,statistic_name,dof,testperformed]=plot_significance(r1,x1,r2,x2,y,height,w,test,r1std,n1,r2std,n2,tail)
%PLOT_SIGNIFICANCE calculates significance level and plots stars
%
% [H,P,STATISTIC,STATISTIC_NAME,DOF]=PLOT_SIGNIFICANCE(R1,X1,R2,X2,Y,HEIGHT,W,TEST,
%                   R1STD,N1,R2STD,N2,TAIL)
%
%  R1, R2 data sets to be compared
%  X1, X2 horizontal position of datasets
%  Y height of horizontal line and stars
%  HEIGHT height of vertical lines
%  W extra horizontal width to be added to X1 and X2
%  TEST contains test name, e.g. 'kruskal-wallis', 'ttest', 'ranksum'
%  TAIL can be 'both','right','left'
%
% 2007-2014 Alexander Heimel
%

if nargin<13;tail='';end
if nargin<12;n2=[];end
if nargin<11;r2std=[];end
if nargin<10;n1=[];end
if nargin<9;r1std=[];end
if nargin<8;test=[];end
if nargin<7;w=[];end
if nargin<6;height=[];end

if isempty(test)
    if isnormal(r1) && isnormal(r2)
        if length(r1)==length(r2) % assume paired
            test = 'paired_ttest';
        else
            test = 'ttest';
        end
    else
        if length(r1)==length(r2) % assume paired
            test = 'signrank';
        else
            test = 'ranksum';%'kruskalwallis';%'ranksum';
        end
    end
end
if isempty(tail)
    tail='both';
elseif isempty(findstr(test,'ttest')) && isempty(findstr(test,'t-test'))
    % disp('PLOT_SIGNIFICANCE: TAIL option is only implemented for t-tests.');
end
if isempty(w)
    w=0;
end
if isempty(height)
    height=0;
end

statistic = nan;
statistic_name = '';
dof = nan;
p = 1;
testperformed = '';

r1=r1(~isnan(r1));
r2=r2(~isnan(r2));


h=0;
if length(r1)>1 && length(r2)>1
    switch lower(test)
        case {'paired_ttest','paired ttest'}
            if length(r1)==length(r2)
                [h,p,ci,stats]=ttest(r1,r2,0.05,tail); %#ok<ASGLU>
                statistic=stats.tstat;
                statistic_name = 't';
                dof=stats.df;
                testperformed = 'Paired t-test';
            end
        case {'signrank','wilcoxon'}
            if length(r1)==length(r2)
                [p,h,stats]=signrank(r1,r2,'alpha',0.05);
                if isfield(stats,'signedrank')
                    statistic=stats.signedrank;
                    statistic_name = 'W';
                end
                if isfield(stats,'df')
                    dof = stats.df;
                end
                testperformed = 'Wilcoxon signed rank test';
            end
        case {'ttest','ttest2'}
            [h,p,ci,stats]=ttest2(r1,r2,0.05,tail); %#ok<ASGLU>
            statistic = stats.tstat;
            statistic_name = 't';
            dof=stats.df;
            testperformed = 't-test';
        case {'ranksum','mann-whitney','mannwhitney'}
            [p,h,stats]=ranksum(r1,r2,'alpha',0.05,'tail',tail); 
            statistic = stats.zval;
            statistic_name = 'z';
            testperformed = 'ranksum (Mann-Whitney U test)';
        case {'kruskal-wallis','kruskal_wallis','kruskal wallis','kruskalwallis'}
            [p,statistic,dof] = kruskal_wallis_test(r1,r2);
            statistic_name = 'K';
            h = (p<0.05);
            testperformed = 'Kruskal-Wallis test';
        case {'chi2','chisquare','chi_square'}
            d(1,1)=sum( r1(~isnan(r1))==0 );
            d(1,2)=sum( r1(~isnan(r1))==1 );
            d(2,1)=sum( r2(~isnan(r2))==0 );
            d(2,2)=sum( r2(~isnan(r2))==1 );
            [p,statistic] = chi2class(d);
            statistic_name = 'chi2-stat';
            h = (p<0.05);
            testperformed = 'Chi2 test';
    end
elseif ~isempty(r1std) && ~isempty(r2std) && strcmp(test,'ttest')==1
    s_X1_X2=sqrt( ((n1-1)*r1std^2 + (n2-1)*r2std^2) /...
        (n1+n2-2)*(1/n1+1/n2));
    statistic=-abs(r1-r2)/s_X1_X2;
    statistic_name = 't';
    dof=n1+n2-2;
    p=2*tcdf(t_statistic,dof);
    h=(p<0.05);
    testperformed = 't-test';
end

if h==1 && ~isnan(y)
    pc='*';
    if p<0.01
        pc='**';
    end
    if p<0.001
        pc='***';
    end
    left=x1+w;
    right=x2-w;
    if left~=right
        hl=line([left right],[y y]);
        set(hl,'Color',[0 0 0]);
    end
    hl=text((left+right)/2,y,pc);
    set(hl,'HorizontalAlignment','center')
    set(hl,'FontSize',15);
    if height>0
        hl=line([left left],[y-height/2 y]);
        set(hl,'Color',[0 0 0]);
        hl=line([right right],[y-height/2 y]);
        set(hl,'Color',[0 0 0]);
    end
end

