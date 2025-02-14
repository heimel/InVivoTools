
sdt = 0.010;  % in s 
T = 0:sdt:100;  % in s 
sigsquare =1*1;
%rs = sigsquare * randn(1,length(T)); 
%rs = sigsquare*(2*(rand(1,length(T))>0.5)-1);
dt = 0.001;

% number 3, part 1 
tauind = 0:400;
tau=0:0.001:0.400;  % we will integrate equation 1 only from 0 to 400ms 
D=-1000*cos(2*pi*(tau-0.020)/0.140).*exp(-tau/0.060); 
sinds=0:-1:-400; % at each t, we want to look at stim from t-tau back 400 points 
                 % and in the reverse order 
r0=50; % background rate, in Hz 
dtau = 0.001;  % integrating in steps of 1ms; could also use some other value 
% convert rs to 1ms version since I will work in ms, but I was working in 
% 10ms above 
tinds = (0:dt/sdt:(length(T)-1))';
rs_1ms=rs(fix(tinds)+1);
%for i=1:length(rs)-1, % take one point out so will go to 10000ms, not 10010ms 
%   for j=1:10, % need to add ten points for every one before 
%      rs_1ms(end+1) = rs(i); 
%   end; 
%end; 
%rs_1ms(end+1)=rs(end); % make a 10001st point 
% now actually compute the spike rate 
% make spike rate before 400ms zero since we don't have sufficient data 
t = 0:dt:T(end);
%r=zeros(1,400); 
%for tt=400:length(t)-1, % simulate 9.6s of data, starting at t=400ms 
%  r(tt+1)=(dtau*D*rs_1ms(tt+sinds+1)')+r0; % do integral, answer in Hz 
%end; 
figure(2); 
subplot(5,1,1); 
plot(t,rs_1ms); title('Fig 3-1.  Stimulus'); xlabel('Time (ms)'); 
ylabel('Stimulus'); 
a=axis; axis([0.400 1.400 a(3) a(4)]); 
subplot(5,1,2); 
plot(t,r); title('Fig 3-2.  Firing rate of neuron'); xlabel('Time (ms)'); 
ylabel('Firing rate (Hz)'); a=axis; axis([0.400 1.400 a(3) a(4)]); 

% number 3, part 2 
% now go backwards to find Q (and thus find the image of D) 
q = zeros(1,400); % make an empty matrix q to store our values 
for tauind=-400:0, % find Q(tau) for tau=-400ms to 0ms in 1ms steps 
  q(-tauind+1) = 1/99.600 * sum(dt*(r(401-tauind:end)).*rs_1ms(401:end+tauind)); 
end; 
qtau = 0:0.001:0.400; % for plotting q(-tau) 
subplot(5,1,3); hold off; 
plot(qtau,dt*D,'linewidth',2); 
v = var(rs); 
hold on; plot(qtau,dt*q/(v*sdt),'rx'); 
title('Fig 3-3.  Kernel, generating and measured'); 
ylabel('kernel value (Hz/stimulus/s)');xlabel('\tau (s)'); 
legend('D(\tau)','Q(-\tau)/{\sigma^2}'); 

p = rand(1,length(r))<=r.*dt;mfr = sum(p)/T(end);
subplot(5,1,4); bar(t,p); axis([0.400 1.400 0 1]);
subplot(5,1,5);
tauind=-400:1:0; 
sta = [];
for n=-400:0, % compute spike triggered average for many different lags 
   sta(end+1)=p(1-n:end)*rs_1ms(1:end+n)'/sum(p(1-n:end)); 
end; 
plot(qtau,mfr*sta(end:-1:1)/(v/sdt)); 

