function solvddenormmodel( contrasts)
% test of solving differential delay equation

if nargin<1
	contrasts=linspace(0,1,11);%logspace(-3,2,10)
end
%close all
time=zeros(1,length(contrasts));
rm=zeros(1,length(contrasts));

delay=[5 ];

% calculate spontaneous rate
spont0=0;
spont=-1;
tries=10;
while abs(spont0-spont)/max(spont,spont0)>0.05 &&tries>0
	spont=spont0
	sol = dde23(@ddenormmodel,delay,spont,[0, 400],[],0);
	tint = (0:400);
	yint = deval(sol,tint);
	spont0=yint(end);
	tries=tries-1;
end


for i=1:length(contrasts)
	contrast=contrasts(i);
	sol = dde23(@ddenormmodel,delay,spont0,[0, 400],[],contrast);
	tint = (0:400);
	yint = deval(sol,tint);
	%  plot(tint,[yint; normmodelinput(tint,contrast)]);
	%first_below=find(yint<0,1);
	%if ~isempty(first_below)
	%	yint(first_below:end)=spont0;
	%end
	
	fint=yint.^2;
	[m,time(i)]= max(fint(50:200));
	time(i)=time(i)+50;
	rm(i)=m-spont0^2;
	disp( [num2str(contrast)  ' ' num2str(rm(i)) ' ' num2str(time(i)) ])
end
%figure
%hold on

if length(contrasts)>1
	figure
	subplot(1,2,1)
	plot(contrasts,rm)
	subplot(1,2,2)
	plot(contrasts(2:end),time(2:end));
	ax=axis;axis( [ax([1 2]) 50 150 ])
else
	figure
	plot(tint,[fint; normmodelinput(tint,contrast)]);
end