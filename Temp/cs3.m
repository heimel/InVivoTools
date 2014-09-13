m=[size(ffrr{1,1},1),size(ffrr{1,1},2)];
MFRD=zeros(m(1),m(2),4140);
for i=1:4140
    MFRD(:,:,i)=ffrr{1,i};i
end;

figure;
for k=3:19
    plot(squeeze(MFRD(139,57,1+k*207:(k+1)*207)));hold on;
    F(:,k-3+1)=squeeze(MFRD(139,57,1+k*207:(k+1)*207));
end
DF=mean(F');
figure;plot(DF);
t=0;
figure;plot(DF(1+t*62:t*62+62))