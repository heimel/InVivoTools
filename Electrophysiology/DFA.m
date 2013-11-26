function M = DFA(SIG)
%DFA detrended fluctuation analysis
%
%    M = DFA( SIG )
%        measuring long-range correlation and memory of a signal
%
% written by Mehran Ahmadlou & Alexander Heimel
%

Tt=length(SIG);
N=floor(log2(Tt));
FD = zeros(1,N);


for k=2:N
    M = 2^k; % window length
    x0=(1:M) - (1+M)/2; % center at zero
    cx0 = x0*x0' ;
    
    n_windows = floor(Tt/M);
    period = n_windows * M; 
    SIGr = reshape( SIG(1:period)', [M n_windows])';
    yy = sum(SIGr.^2,2);
    a_ = SIGr*x0';
    sy = sum(SIGr,2);
    FFY = (yy-a_.^2/cx0-sy.^2/M)/M; % squared difference from linear fit over interval
        
    % last window again plus remainder of SIG
    % is a little weird because the last window is counted twice this way
    % in original version division by M was missing in last separate FY
    xx = (period-M+1):Tt;
    
    y=SIG(xx);
    xx = xx-   (period-M+1+Tt)/2; % center interval 
    Mt = length(y);
    a = (y*xx') / (xx*xx');
    fy = a*xx+(sum(y)/Mt)-y;
    FFY(end+1) = fy*fy'/ Mt; % in original version this division was missing
         
    FD(k)=sqrt((1/Tt)*sum(FFY));
end;

S = log2(FD(2:length(FD)));

% make a linear fit a return coefficients M
MS =length(S);
x = 1:MS;
x = x-(1+MS)/2;
a = (S*x') / (x*x');
b = mean(S) - a*(1+MS)/2;
M = [a b];
