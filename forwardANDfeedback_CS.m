figure;
for k=0:4
plot(squeeze(MFRD(148,119,1+k*420:(k+1)*420)));hold on;
F(:,k+1)=squeeze(MFRD(148,119,1+k*420:(k+1)*420));
end
DF=mean(F');
figure;plot(DF);
figure;plot(DF(1+0*84:0*84+84))

% Forward Peak to Feedback Peak
PEAKS=[2494 2483;2557 2514;2547 2517;2547 2530;2534 2517];
figure;plot(PEAKS(:,1)./PEAKS(:,2))
RESPONSE_TIME_firstPeak=[0.64 1.04 1.04 1.36 1.28];
figure;plot(RESPONSE_TIME_firstPeak)
RESPONSE_TIME_firstPeak2=[.56 .88 1.12 1.2 1.44];
figure;plot(RESPONSE_TIME_firstPeak2)