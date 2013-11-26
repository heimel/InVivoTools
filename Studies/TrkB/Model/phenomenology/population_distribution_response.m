function population_distribution_response
%POPULATION_DISTRIBUTION_RESPONSE shows than sigma and n of population mean
%    are below population mean of sigma and n
%
% 2008, Alexander Heimel

N=1000;
n_c=50;

rm=1+0*rand(N,1); 
n=random('gamma',3,1,N,1);
sigma=0.1+random('gamma',1,1,N,1);
a=.001;

c=linspace(0,1,n_c);

c=repmat(c,N,1);
n=repmat(n,1,n_c);
sigma=repmat(sigma,1,n_c);
rm=repmat(rm,1,n_c);

y=rm.*(a*c).^n./(sigma.^n+(a*c).^n);

figure
plot(c(1,:), y','k');
hold on;
my=mean(y,1);
plot(c(1,:),my,'r');
[rm_fit,b_fit,n_fit]=naka_rushton(c(1,:),my)
disp(['mean rm,n,sigma    = ' ...
	mat2str([mean(rm(:,1)) mean(n(:,1)) mean(sigma(:,1))],2) ]);
disp(['rm,n,sigma of mean = ' ...
	mat2str([rm_fit n_fit b_fit],2) ]);

c=c(1,:);
y_fit=rm_fit*c.^n_fit./(b_fit.^n_fit + c.^n_fit);
plot(c,y_fit,'g');

disp( [' response at 60% over 90% : ' ...
	num2str( y_fit(round(end*6/10))/y_fit(round(end*9/10)),2)]);
