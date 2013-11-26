load ffrr
% figure;
m=size(ffrr{1,1},1)*size(ffrr{1,1},2);
FR=zeros(length(ffrr),m-26000+1);
MFR=0;
for i=1:length(ffrr)
%     imshow(ffrr{1,i},[]);
%     colormap prism;
%     pause(0.5)
    FR(i,:)=ffrr{1,i}(1:m-26000+1);
    MFR=MFR+ffrr{1,i};
end;
MFR=MFR/length(ffrr);
corfr=zeros(m-26000+1,m-26000+1);
for i=1:m-26000
    for j=i+1:m-26000+1
        f=corrcoef(FR(:,i),FR(:,j));
    corfr(i,j) = f(1,2);
    end
end