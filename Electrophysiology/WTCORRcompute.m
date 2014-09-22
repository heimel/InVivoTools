function [COH,period] = WTCORRcompute(X,Y,a1,b1,a2,b2,waves_time)

COH=[];
for i=1:size(X,1)
    for j=1:size(Y,1)
    d1=[waves_time(1,:);X(i,:)]';
    [Rsq1,period,scale,coi,sig95]=wt(d1,'MaxScale',64);
    period=floor(1./period);
    [aa1,bb1]=find(period>a1 & period<b1);
    d2=[waves_time(1,:);Y(j,:)]';
    [Rsq2,period,scale,coi,sig95]=wt(d2,'MaxScale',64);
    period=floor(1./period);
    [aa2,bb2]=find(period>a2 & period<b2);
    C1=corrcoef(mean(Rsq1(bb1,1112:2224)),mean(Rsq2(bb2,1112:2224)))-corrcoef(mean(Rsq1(bb1,1:1100)),mean(Rsq2(bb2,1:1100)));
    C2=corrcoef(mean(Rsq1(bb2,1112:2224)),mean(Rsq2(bb1,1112:2224)))-corrcoef(mean(Rsq1(bb2,1:1100)),mean(Rsq2(bb1,1:1100)));
    C = abs([C1(1,2),C2(1,2)]);
    COH=[COH;C];
    end
end