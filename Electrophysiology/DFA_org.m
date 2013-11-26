function M = DFA(SIG)
% detrended fluctuation analysis: for measuring long-range
% correlation and memory of a signal
% written by Mehran Ahmadlou
Tt=length(SIG);
N=floor(log2(Tt));
for k=2:N
    FFY=[];
    x=1:2^k;
    while x(2^k)<Tt
        y=SIG(x);
        F=polyfit(x,y,1);
        f=polyval(F,x);
        FY=(1/(2^k))*sum((y-f).^2);
        FFY=[FFY,FY];
        x=x+(2^k);
    end;
    x=x-(2^k);
    xx=x(1):Tt;   % AH: so entire last interval and the remainder?
    y=SIG(xx);
    F=polyfit(xx,y,1);
    f=polyval(F,xx);
    FY=sum((y-f).^2);  % AH: division by length(y) is missing here? 
    FFY=[FFY,FY];
    FD(k)=sqrt((1/Tt)*sum(FFY));
end;
S=log2(FD(1,2:length(FD(1,:))));
M=polyfit(1:length(S),S,1);
