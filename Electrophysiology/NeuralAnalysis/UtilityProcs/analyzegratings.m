function [spikes] = analysizegratings(stimScript, parameter, MTI, spikedata, ...
				interval,res, plotinterval);

o = getDisplayOrder(stimScript);
n = numStims(stimScript);

paramlist = {};
paramind = [];
timelist = [];
spikes = [];

for i=1:n,
	stimstruct = struct(get(stimScript,i));
	eval(['paramind(i) = stimstruct.PSparams.' parameter ';']);
	paramlist{i} = find(o==i);
	theseTrigs = [];
	for j=1:length(paramlist{i}),
		theseTrigs = [ theseTrigs MTI{paramlist{i}(j)}.frameTimes(1)];
	end;
	timelist = [timelist theseTrigs ];
	[N,X,rast]=make_psth(spikedata, theseTrigs, interval, res, 1);
	spikes(i) = sum(N);
end;

 % now draw histogram

subplot(2,1,1);

[N,X,rast]=make_psth(spikedata,timelist,plotinterval,res,1);
[hp,hr]=plot_psth(N,X,rast,length(timelist),0.3,2,gca,'Gratings','trials');
set(hp,'Linewidth',2);
set(hr,'Linewidth',2)
set(hr,'YTick',1:length(theseTrigs):length(timelist)-1);

subplot(2,2,3);

plot(paramind,spikes,'ro');
set(gca,'Linewidth',2,'fontweight','bold','fontsize',16);
ylabel('Spikes','fontsize',16,'fontweight','bold');
xlabel(parameter,'fontsize',16,'fontweight','bold');

