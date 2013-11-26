%Don't know what it does anymore, neither whether it still works...
clear saveDf res_time res_ampl numpeaks energy;
figure; 
%hold on;
colors='bgrcmyk';
j = 0;
%for mouse = [1 8 6 12 15 5 7 9 16] for exp = 1:2
for mouse = 1:size(data_erg,1) for exp = 1:2
%for mouse = [1 8 6 12 15] for exp = 1:2
%for mouse = 1 for exp = 1
i = 0; j=j+1;
%figure; 
for s = 1:10
%for s = 271 
  i = i + 1; 
%  D = -100*data_erg(mouse,exp).raw(s:s+29,:);
%  D = D-repmat(mean(D(:,1:2000),2),[1,size(D,2)]);
%  Dfull = erg_analysis_avgpulse(D,0);
%  D = Dfull(2000:3000);
  D = data_erg(mouse,exp).avgs(s,2000:3000); 
  versch = 20;
 
  totsamples = size(D);
  hsr = 10000/2;
  [B1, B2] = butter(5,[65/hsr,300/hsr]);
  Df = filtfilt(B1, B2,D);
%  figure;
%  plot(Df); hold on;
%  plot(D,'r:'); hold on;

  NFFT = 2^nextpow2(length(D))*16; % Next power of 2 from length of y
  Df_fft = fft(Df,NFFT)/length(Df);
  Fs = 10000;
  f = Fs/2*linspace(0,1,NFFT/2);
  lala = round((NFFT/10000)*300);
  Y =2*abs(Df_fft(1:lala));
  X = f(1:lala);
  
%  h = spectrum.welch;                          % Create a Welch spectral estimator. 
%  Hpsd = psd(h,Df,'Fs',Fs,'NFFT',NFFT);        % Calculate the PSD 
%  figure; plot(Hpsd);                          % Plot the PSD.
       
  %semilogy(X,Y*(100^i)); hold on;
  %plot(X,Y+(4*i)); hold on;  
  %plot(Df+0.6*i);
  [dummyY, dummyX] = max(2*abs(Df_fft(1:lala)));
  f110(i) = 2*abs(Df_fft(round((NFFT/10000)*110)));
  f75(i) = 2*abs(Df_fft(round((NFFT/10000)*75)));
  fpow(i) = opp(f,2*abs(Df_fft)); 
  fmax(i) = f(dummyX); 
%  all_fmax(j,i,data_erg(mouse, exp).expgroup) = fmax(i);
  data_erg2_f110(mouse,exp,i) = f110(i);
  data_erg2_f75(mouse,exp,i) = f75(i);
  data_erg2_fpow(mouse,exp,i) = fpow(i);
  data_erg2_fmax(mouse,exp,i) = fmax(i);
  %figure; hold on; plot(X,Y)
end 
%hold on; plot(fmax,'r'); 
%hold on; plot(f110,'r'); 
%hold on; plot(f75,'g');
%hold on; plot(f110./fpow,colors(data_erg(mouse,exp).expgroup));
%hold on; plot(f75./fpow,colors(data_erg(mouse,exp).expgroup+3));
end
end
figure;
%A = all_fmax(:,:,1)'; hold on; plot(A(1:8,:),'r'); 
%A = all_fmax(:,:,3)'; hold on; plot(A(9:14,:),'g'); 
%hold off;

