function [h,p,statistic,statistic_name,dof,testperformed]=compute_pairwise_significance(r1,r2,test,r1std,n1,r2std,n2,tail)
%COMPUTE_PAIRWISE_SIGNIFICANCE calculates significance level and plots stars
%
% [H,P,STATISTIC,STATISTIC_NAME,DOF]=PLOT_SIGNIFICANCE(R1,X1,R2,X2,Y,HEIGHT,W,TEST,
%                   R1STD,N1,R2STD,N2,TAIL)
%
%  R1, R2 data sets to be compared
%  TEST contains test name, e.g. 'kruskal-wallis', 'ttest', 'ranksum'
%  TAIL can be 'both','right','left'
%
% 2007-2014 Alexander Heimel
%

if nargin<8;tail='';end
if nargin<7;n2=[];end
if nargin<6;r2std=[];end
if nargin<5;n1=[];end
if nargin<4;r1std=[];end
if nargin<3;test=[];end

if isempty(test)
    if isnormal(r1) && isnormal(r2)
        if length(r1)==length(r2) % assume paired
            test = 'paired_ttest';
            logmsg('Data is normal, and assuming to be paired. Use test=ttest otherwise.');
        else
            test = 'ttest';
        end
    else
        if length(r1)==length(r2) % assume paired
            test = 'signrank';
            logmsg('Data is not normal, and assuming to be paired. Use test=ranksum otherwise.');
        else
            test = 'ranksum';%'kruskalwallis';%'ranksum';
        end
    end
end

test = lower(subst_specialchars(strtrim(test))); % to substitute spaces by _

if isempty(tail)
    tail='both';
elseif isempty(strfind(test,'ttest')) && isempty(strfind(test,'t-test'))
    % disp('PLOT_SIGNIFICANCE: TAIL option is only implemented for t-tests.');
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
    switch test
        case 'paired_ttest'
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
            [h,p] = vartest2(r1,r2); %#ok<ASGLU>
            if p<0.05 
                vartype = 'unequal';
            else
                vartype = 'equal';
            end
            try
                [h,p,ci,stats]=ttest2(r1,r2,'alpha',0.05,'tail',tail,'vartype',vartype);  %#ok<ASGLU>
            catch me
                switch me.identifier
                    case 'MATLAB:TooManyInputs' % older matlab versions R2009b
                        [h,p,ci,stats]=ttest2(r1,r2,0.05,tail,vartype);  %#ok<ASGLU>
                    otherwise
                        rethrow(me)
                end
            end
            
            statistic = stats.tstat;
            statistic_name = 't';
            dof=stats.df;
            if strcmp(vartype,'unequal')
                
                testperformed = [vartype ' variances t-test'];
            else
                testperformed = 't-test';
            end
        case {'ranksum','mann-whitney','mannwhitney'}
            try
                [p,h,stats]=ranksum(r1,r2,'alpha',0.05,'tail',tail);
            catch me
               switch me.identifier
                   case {'stats:ranksum:BadParamName','stats:internal:parseArgs:BadParamName'}
                       [p,h,stats]=ranksum(r1,r2,'alpha',0.05);
                   otherwise
                       rethrow(me)
               end
            end            
            if isfield(stats,'zval') % for too few numbers it is missing
                statistic = stats.zval;
                statistic_name = 'z';
            end
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
elseif ~isempty(r1std) && (n1+n2-2)>0 && ~isempty(r2std) && strcmp(test,'ttest')==1
    s_X1_X2=sqrt( ((n1-1)*r1std^2 + (n2-1)*r2std^2) /...
        (n1+n2-2)*(1/n1+1/n2));
    statistic=-abs(r1-r2)/s_X1_X2;
    statistic_name = 't';
    dof=n1+n2-2;
    p=2*tcdf(t_statistic,dof);
    h=(p<0.05);
    testperformed = 't-test';
end
