figure;
for k=0:4
plot(squeeze(MFRD(150,65,1+k*486:(k+1)*486)));hold on;
F(:,k+1)=squeeze(MFRD(150,65,1+k*486:(k+1)*486));
end
DF=mean(F');
figure;plot(DF);
figure;plot(DF(1+4*81:4*81+81))

% Forward Peak to Feedback Peak
% PEAKS=[3063 3132 3143 3133 3107 3124];
% figure;plot(PEAKS(:,1)./PEAKS(:,2))
% RESPONSE_TIME_firstPeak=[0.64 1.04 1.04 1.36 1.28];
% figure;plot(RESPONSE_TIME_firstPeak)
% RESPONSE_TIME_firstPeak2=[.56 1.12 1.12 0.96 1.36];
% figure;plot(RESPONSE_TIME_firstPeak2)