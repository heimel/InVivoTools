function [hc_response,lc_response,sf]=heeger_modelfit(param,lc)
%implementation of Heeger model for T1 paper

if nargin<1
	param=[];
end
if nargin<2
  lc =[];
end
  

if isempty(param);
	param=[2 1.08];
end
n=param(1);
k=param(2);

if nargout>0
	show=0;
else
	show=1;
end

if show
	figure;
end

sf=linspace(0.1,0.8,500);
	
hc=1;

if isempty(lc)
  lc=0.6/0.9;
end

if show
%	plot(sf,sftuninginput(sf,n,k))
end




if show
	contrasts=linspace(0.1,1,20);
	rlowsf=[];rhighsf=[];
	sigma_r=1; %relative sigma after adaptation
	for c=contrasts
		rlowsf(end+1)=sfresponse(0.1,c,n,k,sigma_r);
		rhighsf(end+1)=sfresponse(0.5,c,n,k,sigma_r);
	end

figure
	plot(contrasts,rlowsf,'r');hold on;
	plot(contrasts,rhighsf,'g');hold on;
	set(gca,'XScale','log');
	xlabel('Contrast');
	legend('Low SF','High SF');
	ylabel('Response');
	
	[rm,b,n]=naka_rushton(contrasts,rlowsf)
end


sigma_r=1; %relative sigma after adaptation
hc_response=real(sfresponse(sf,hc,n,k,sigma_r));
sigma_r=1; %relative sigma after adaptation
lc_response=real(sfresponse(sf,lc,n,k,sigma_r));

measured_response=[0.955 0.500 0.290 -0.010 0.086];
measured_ind=findclosest(sf,[0.1 0.2 0.3 0.4 0.5]);
model_response=lc_response(measured_ind);

rms_error=sqrt( sum((measured_response-model_response).^2 ));

if nargout==1
	hc_response=rms_error;
end

%sf=sf+0.1;

if 0
	sigma=0; %1000;
	rhc=hc^2/(sigma^2+hc^2);
	rlc=lc^2/(sigma^2+lc^2);
	graph({hc_response,hc_response*rlc/rhc},{sf,sf},'style','xy',...
		'color',{[0.7 0 0],[1 0.7 0.7]},...
		'extra_options','fit,threshold_linear','ylab','Response','xlab','Spatial frequency (cpd)')
	saveas(gcf,'heeger_flatnormalization.png','png');
end

if show
graph({hc_response,lc_response},{sf,sf},'style','xy',...
	'color',{[0.7 0 0],[1 0.7 0.7]},'prefax',[0.1 0.7 0 1.2],...
	'extra_options','fit,threshold_linear','ylab','Response','xlab','Spatial frequency (cpd)')
saveas(gcf,'heeger_inputsftuned.png','png');
end


return


function r=sfresponse(sf,c,n,k,sigma_r)
r=heegersfresponse(sf,c,n,k,sigma_r);
%r=heegersfresponsefb(sf,c,10);
%r=depressionsfresponse(sf,c);
return

function r=heegersfresponse(sf,c,n,k,sigma_r)
r=k*((c*sftuninginput(sf,n,k)).^n)./(sigma_r^n+(c*sftuninginput(sf,n,k)).^n);
return

function r=heegersfresponsefb(sf,c,sigma)
n=1;
%sigmat=sigma/0.9; % to make tuned input into a straight line at c=0.9;
sigmat=sigma; % to make tuned input into a straight line at c=1;
r=1*((c*sigmat*sftuninginput(sf,n)).^n)
r=r./(sigma^n+r.^n);

r=r/0.81;
return

function r=depressionsfresponse(sf,c)
% from Carandini, Heeger & Senn 2002
% stat state of dp/dt = (u-p)/tau_s - u p f
n=2;
u=0.75;
tau=200/1000;
rate=100;
input=c*rate*sftuninginput(sf);
p=u./(tau*(1/tau+u*input));
r=(p.*input).^n;
return

function r=highc_sffit(sf)
sf_high=0.53;
sf_low=0.1;
r=min(1, (sf_high-sf)/(sf_high-sf_low));



function r=sftuninginput(sf,n,k)
%r=thresholdlinear(0.5-sf)/0.5;
%for depression model
%r=exp(-sf/0.15);
%r=exp(-(max(0.05,sf).^0.8)/0.1);

%r=( (1-sf/acuity)./( (sf)/acuity)).^(1/n);



r=( highc_sffit(sf)./(k - highc_sffit(sf))).^(1/n);

%r=sfcurve(sf,0.01,0.15,0.01);
return

function r=sftuningneuron(sf)
r=sftuninginput(sf);

