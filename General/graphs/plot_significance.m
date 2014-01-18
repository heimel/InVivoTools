function [h,p,statistic,statistic_name,dof]=plot_significance(r1,x1,r2,x2,y,height,w,test,r1std,n1,r2std,n2,tail)
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
%  TEST contains test name, e.g. 'kruskal-wallis' or 'ttest'
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
    test='ttest';
    %test='kruskal-wallis';
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

r1=r1(~isnan(r1));
r2=r2(~isnan(r2));


h=0;
if length(r1)>1 && length(r2)>1
    switch test
        case {'paired_ttest'}
            if length(r1)==length(r2)
                [h,p,ci,stats]=ttest(r1,r2,0.05,tail); %#ok<ASGLU>
                statistic=stats.tstat;
                statistic_name = 't';
                dof=stats.df;
            end
        case {'wilcoxon','signrank'}
            if length(r1)==length(r2)
                [p,h,stats]=signrank(r1,r2,'alpha',0.05);
                if isfield(stats,'signedrank')
                    statistic=stats.signedrank;
                    statistic_name = 'W';
                end
                if isfield(stats,'df')
                    dof = stats.df;
                end
            end
        case {'ttest','ttest2'}
            [h,p,ci,stats]=ttest2(r1,r2,0.05,tail); %#ok<ASGLU>
            statistic = stats.tstat;
            statistic_name = 't';
            dof=stats.df;
        case {'kruskal-wallis','kruskal_wallis'}
            p = kruskal_wallis_test(r1,r2);
            h = (p<0.05);
        case {'chi2','chisquare','chi_square'}
            disp('PLOT_SIGNIFICANCE: Chi2 not implemented yet.');
    end
elseif ~isempty(r1std) && ~isempty(r2std) && strcmp(test,'ttest')==1
    s_X1_X2=sqrt( ((n1-1)*r1std^2 + (n2-1)*r2std^2) /...
        (n1+n2-2)*(1/n1+1/n2));
    statistic=-abs(r1-r2)/s_X1_X2;
    statistic_name = 't';
    dof=n1+n2-2;
    p=2*tcdf(t_statistic,dof);
    h=(p<0.05);
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

