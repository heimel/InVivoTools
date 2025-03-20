function [P,FW,v1] = welchanova(x,alpha,dispopt)
%WELCHANOVA Welch ANOVA Test for Unequal Variances.
%
%  [P,F,df] = WELCHANOVA( X, ALPHA, DISPOPT )
%
%  X data
%  ALPHA is alpha-level (default 0.05)
%  if DISPOPT is 'on' (default) some information graphs are shown, 'off' 
%  is the alternative
%
% The ANOVA F-test to compare the means of k normally distributed
%  populations is not applicable when the variances are unknown, and not
%  known to be equal. A spacial case, k=2, is the famous Behrens-Fisher
%  problem (Behrens, 1929; Fisher, 1935). Welch (1951) test was proposed to
%  fill this void, a generalization to his 1947 previous paper (Welch,
%  1947).
%
%  The Welch test for general k compares the statistic
%
%                  __
%                 \
%                 /__ w_i*(m_i - M)^2/(k - 1)
%           FW = -----------------------------
%                      1 + 2/3*(k - 2)*L
%
%  to the F_[(k - 1),1/L] distribution. Where:
%                      __                 __
%                     \                  \
%  w_i = n_i/v_i; M = /__ w_i*m_i/W; W = /__ w_i; f_i = n_i - 1;
%          __
%         \
%      3* /__(1 - w_i/W)^2/f_i
%  L = ------------------------
%             (k^2 - 1)
%
%  [m_i = sample mean; v_i = sample variance; n_i = sample size]
%
%
%  Syntax: function welchanova(x,alpha)
%
%  Inputs:
%       x � data nx2 matrix (Col 1 = data; Col 2 = sample code)
%   alpha - significance level (default=0.05)
%
%  Outputs:
%       - Summary statistics from the samples
%       - Decision on the null-hypothesis tested
%
%  Taking the numerical example given at Research and Faculty Development,
%  University of Oregon, in his internet site [http://rfd.uoregon.edu/
%  files/rfd/StatisticalResources/glm10_homog_var.txt].
%  2. Testing Means with the Unequal Variance Model. For the testing for
%  equality of variances for an ANOVA, first consider the following small
%  dataset which are measurements collected from 24 subjects randomly
%  divided into one of three groups. Group 1 receives the standard
%  treatment, group 2 receives a treatment similar to the standard, and
%  group 3 gets a new and different treatment. The objective is to
%  determine if the new treatment from group 3 is better than the
%  treatments received by groups 1 and 2.
%
%  Data are:
%
%                  -----------------------------
%                              Group
%                  -----------------------------
%                     1          2          3
%                  -----------------------------
%                   3.791      3.122      4.761
%                   5.174      2.514      3.884
%                   3.019      3.850      6.840
%                   3.218      2.564      9.150
%                   3.079      4.486      2.776
%                   4.054      3.199      5.398
%                   3.131      3.406      6.405
%                   2.822      3.986      2.115
%                  -----------------------------
%
%  Input data:
%
%  x=[3.791 1;5.174 1;3.019 1;3.218 1;3.079 1;4.054 1;3.131 1;2.822 1;
%  3.122 2;2.514 2;3.850 2;2.564 2;4.486 2;3.199 2;3.406 2;3.986 2;
%  4.761 3;3.884 3;6.840 3;9.150 3;2.776 3;5.398 3;6.405 3;2.115 3];
%
%  Calling on Matlab the function:
%               welchanova(x,0.05)
%
%  Answer is:
%
%  Summary statistics from the samples.
%  --------------------------------------------------
%  Sample       Size        Mean           Variance
%  --------------------------------------------------
%     1           8         3.5360           0.6096
%     2           8         3.3909           0.4752
%     3           8         5.1661           5.2988
%  --------------------------------------------------
%
%  Welch's Analysis of Variance Table.
%  ----------------------------------------
%  SOV       df              F       P
%  ----------------------------------------
%  Treat.    2             2.075   0.1659
%  Error    12.7641
%  ----------------------------------------
%  The associated probability for the Welch's F test is equal or larger
%  than 0.05. So, the assumption of sample means are equal was met.
%
%  Created by A. Trujillo-Ortiz and R. Hernandez-Walls
%            Facultad de Ciencias Marinas
%            Universidad Autonoma de Baja California
%            Apdo. Postal 453
%            Ensenada, Baja California
%            Mexico.
%            atrujo@uabc.edu.mx
%
%  Copyright (C) May 15, 2012.
%
%  --We thank Abdullah Chisti, University of Saskatchewan, Bangladesh, for
%   encourage us to produce this m-file.--
%
%  To cite this file, this would be an appropriate format:
%  Trujillo-Ortiz, A. and R. Hernandez-Walls. (2012). welchanova: Welch
%     ANOVA Test for Unequal Variances. [WWW document]. URL http://
%     www.mathworks.com/matlabcentral/fileexchange/37121-welchanova
%
%  References:
%  Behrens, W. V. (1929), Ein beitrag zur Fehlerberechnung
%             bei wenigen Beobachtungen. (transl: A contribution to error
%             estimation with few observations). Landwirtschaftliche
%             Jahrb�cher, 68:807�37.
%  Fisher, R. A. (1935), The fiducial argument in statistical inference.
%             Annals of Eugenics, 8:391�398.
%  Welch, B. L. (1947), The generalization of Student's problem when
%             several different population variances are involved.
%             Biometrika, 34(1�2):28�35
%  Welch, B. L. (1951), On the comparision of several mean values: an
%             alternative approach. Biometrika, 38:330-336.
%

if nargin < 2 || isempty(alpha)
    alpha = 0.05; %default
elseif numel(alpha) ~= 1 || alpha <= 0 || alpha >= 1
    error('welchanova:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

if nargin<3
    dispopt = '';
end
if isempty(dispopt)
    dispopt = 'on';
end

X = x;
c = size(X,2);
if c ~= 2
    error('stats:welchanova:BadData','X must have two colums.');
end

%Remove NaN values, if any
X = X(~any(isnan(X),2),:);

k = max(X(:,2));

indice = X(:,2);
for i = 1:k
    Xe = indice == i;
    d(i).X = X(Xe,1);
    d(i).m = mean(d(i).X);
    d(i).v = var(d(i).X);
    d(i).n = length(d(i).X);
    d(i).f = d(i).n - 1;
    d(i).W = d(i).n/d(i).v;
    d(i).N = d(i).W*d(i).m;
end
m=cat(1,d.m);v=cat(1,d.v);n=cat(1,d.n);f=cat(1,d.f);W=cat(1,d.W);
N=cat(1,d.N);

M = sum(N)/sum(W);

for i = 1:k
    Xe = indice == i;
    d(i).A = ((1 - d(i).W/sum(W))^2)/d(i).f;
    d(i).B = d(i).W*(d(i).m - M)^2;
end
A=cat(1,d.A);B=cat(1,d.B);

L = 3*sum(A)/(k^2 - 1);

FW = (sum(B)/(k - 1))/(1 + 2/3*(k - 2)*L);  %Welch's F-statistic

v1 = k-1;  %numerator degrees of freedom
v2 = 1/L;  %denominator degrees of freedom

P = 1-fcdf(FW,v1,v2);  %P-value

if strcmpi(dispopt,'on')
    
    disp(' ')
    disp('Summary statistics from the samples.')
    disp('--------------------------------------------------')
    disp(' Sample       Size        Mean           Variance ')
    disp('--------------------------------------------------')
    for i = 1:k
        fprintf('   %d           %i        %7.4f          %7.4f\n',i,n(i),m(i),v(i))
    end
    disp('--------------------------------------------------')
    disp(' ')
    disp(' ')
    disp('Welch''s Analysis of Variance Table.')
    fprintf('----------------------------------------\n');
    disp('SOV       df              F       P')
    fprintf('----------------------------------------\n');
    fprintf('Treat.  %3i%18.3f%9.4f\n\n',v1,FW,P);
    fprintf('Error%11.4f\n',v2);
    fprintf('----------------------------------------\n');
    
    if P >= alpha;
        fprintf('The associated probability for the Welch''s F test is equal or larger than% 3.2f\n', alpha);
        fprintf('So, the assumption of sample means are equal was met.\n');
    else
        fprintf('The associated probability for the Welch''s F test is smaller than% 3.2f\n', alpha);
        fprintf('So, the assumption of sample means are equal was not met.\n');
    end
end
return