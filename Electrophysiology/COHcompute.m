function [COH,period] = COHcompute(X,Y,waves_time)

COH=[];
for i=1:size(X,1)
    for j=1:size(Y,1)
        d1=[waves_time(1,:);X(i,:)]';
        d2=[waves_time(1,:);Y(j,:)]';
        [Rsq,period,scale,coi,sig95]=wtc(d1,d2,'mcc',0);
        COH=[COH;Rsq];
    end
end
