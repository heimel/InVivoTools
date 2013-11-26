%Don't know what it does anymore, neither whether it still works...
clear saveDf res_time res_ampl numpeaks energy;
figure; 
hold on;
colors='bgrcmyk';
%for mouse = [1 8 6 12 15 5 7 9 16] for exp = 1:2
%for mouse = [1 8 6 12 15] for exp = 1:2
for mouse = 1 for exp = 1
i = 0;
for s = 1:30:300 
  i = i + 1; 
  D = -1*data_erg(mouse,exp).raw(s:s+29,:);
  D = D-repmat(mean(D(:,1:2000),2),[1,size(D,2)]);
  Dfull = erg_analysis_avgpulse(D,0);
  D = Dfull(2000:3000);
  versch = 20;
 
  totsamples = size(D);
  hsr = 10000/2;
  [B1, B2] = butter(2,[60/hsr,230/hsr]);
  Df = filter(B1, B2,D);
  saveDf(i,:) = Df';
  V = [zeros(1,versch/2) (Df(1+versch:end)-Df(1:end-versch)) zeros(1,versch/2)]./versch;
  V = [sign(V(1:end-1))-sign(V(2:end)) 0]/2.*abs(Df);
  A = sort(V(V~=0)); 
  peaks = V.*(V>=A(end-3));
  dips = V.*(V<=A(3));
  X = 1:length(Df);
  res_time(i,:) = X(peaks>0); 
  res_ampl(i,:) = Df(res_time(i,:));
  %How many peaks actually between 1st and last?? Max = 4 :)
  numpeaks(i) = sum(V(min(X(peaks>0)):max(X(peaks>0)))>0);
%  figure; hold off; plot(Df,'r'); hold on; plot(dips); h = plot(peaks); title((s+29)/30);
  firstpeak(i) = min(res_time(i,:));
  energy(i) = sum(abs(Df))/length(Df);
  plenergy(i) = sum(abs(Dfull))/length(Dfull);
end 

%X=repmat(1:i,1,4)'; figure; hold off; plot(X(numpeaks==4,:),res_time(numpeaks==4,:))
%X=repmat(1:i,1,4)'; figure; hold off; plot(X(numpeaks==4,:),res_ampl(numpeaks==4,:))
%plot(energy); hold on;
%plot((data_erg(mouse,exp).params(4,1:10)-data_erg(mouse,exp).params(2,1:10))./(plenergy./energy))
plot(sum(res_ampl,2),colors(data_erg(mouse,exp).expgroup))
end
end
hold off;

