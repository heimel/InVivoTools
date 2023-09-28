
dt = 10;  % in ms 
T = 0:dt:10000;  % in ms 
sigsquare = 10; 
%rs = sigsquare/dt * randn(1,length(T)); 
rs = 2*(rand(1,length(T))>0.5)-1;
ac = []; 
for n=0:10, % 10 steps is 100ms of time 
  ac(n+1) = mean(rs(1+n:end).*rs(1:end-n)); 
end; 
tau = 0:10:100; 
subplot(3,1,2); 
plot(T,rs); 
A=axis; axis([0 1000 A(3) A(4)]); % set xaxis to 0...1000ms, y to whatever it was 
title('Fig 2-1.  White noise stimulus'); xlabel('Time (ms)'); 
ylabel('stimulus value'); 
subplot(3,1,3); 
bar(tau,ac); 
title('Fig 2-2.  Autocorrelation of white noise'); xlabel('\tau (ms)'); 
ylabel('Correlation'); 

% number 3, part 1 
tau=0:400;  % we will integrate equation 1 only from 0 to 400ms 
D=-cos(2*pi*(tau-20)/140).*exp(-tau/60); 
sinds=0:-1:-400; % at each t, we want to look at stim from t-tau back 400 points 
                 % and in the reverse order 
r0=50; % background rate, in Hz 
dtau = 1;  % integrating in steps of 1ms; could also use some other value 
% convert rs to 1ms version since I will work in ms, but I was working in 
% 10ms above 
rs_1ms=[]; 
for i=1:length(rs)-1, % take one point out so will go to 10000ms, not 10010ms 
   for j=1:10, % need to add ten points for every one before 
      rs_1ms(end+1) = rs(i); 
   end; 
end; 
rs_1ms(end+1)=rs(end); % make a 10001st point 
% now actually compute the spike rate 
% make spike rate before 400ms zero since we don't have sufficient data 
r=zeros(1,400); 
for t=400:10000, % simulate 9.6s of data, starting at t=400ms 
  r(t+1)=(dtau*D*rs_1ms(t+sinds+1)')+r0; % do integral, answer in Hz 
end; 
t=0:10000; % in ms 
figure(2); 
subplot(3,1,1); 
plot(t,rs_1ms); title('Fig 3-1.  Stimulus'); xlabel('Time (ms)'); 
ylabel('Stimulus'); 
a=axis; axis([400 1400 a(3) a(4)]); 
subplot(3,1,2); 
plot(t,r); title('Fig 3-2.  Firing rate of neuron'); xlabel('Time (ms)'); 
ylabel('Firing rate (Hz)'); a=axis; axis([400 1400 a(3) a(4)]); 

% number 3, part 2 
% now go backwards to find Q (and thus find the image of D) 
dt = 1; % 1ms 
q = zeros(1,400); % make an empty matrix q to store our values 
for tau=-400:0, % find Q(tau) for tau=-400ms to 0ms in 1ms steps 
  q(-tau+1) = 1/9600 * sum(dt*(r(401-tau:end)).*rs_1ms(401:end+tau)); 
end; 
qtau = 0:400; % for plotting q(-tau) 
subplot(3,1,3); hold off; 
plot(qtau,D,'linewidth',2); 
hold on; plot(qtau,q/sigsquare,'rx'); 
title('Fig 3-3.  Kernel, generating and measured'); 
ylabel('kernel value (Hz/stimulus/ms)');xlabel('\tau (ms)'); 
legend('D(\tau)','Q(-\tau)/{\sigma^2}'); 

%p = rand(1,length(r))

