function pp = posthoc_poweranalysis(control,y,dy,test,n_samplings)
%POSTHOC_POWERANALYSIS computes the power for a test after getting the data
%
% PP = POSTHOC_POWERANALYSIS(CONTROL,Y,DY,TEST,N_SAMPLINGS)
%  CONTROL, Y are the measured values for 2 groups
%  DY is the difference between the control and test group given the measured
%      variation 
%  N_SAMPLINGS=10000 is the number of times to computer the signifance 
%
% 2021, Alexander Heimel

if nargin<5 || isempty(n_samplings)
    n_samplings = 10000;
end
if nargin<4 || isempty(test)
    test = @ttest2;
end

n_c = length(control);
n_y = length(y);
ny =  y - mean(y) + mean(control) + dy;

h = zeros(n_samplings,1);
p = zeros(n_samplings,1);

for i = 1:n_samplings
    sy = ny(randi(n_y,n_y,1));
    [h(i),p(i)] = test(control,sy);

end

pp = sum(h)/n_samplings;
disp(['Post-hoc power to see abs change of ' num2str(dy) ' is ' num2str(pp*100) '%']);
    
    

