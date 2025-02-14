function [outstims,N,X,rast,hp,hr] = plot_revcor_psth(spikedata, ...
			stim, trigs, intvrc, rcnormal, intvrs, res, ...
                        normal, hiliteTrial, sym);

colormap(gray(256));

   % hiliteTrial = 0 => no hilite

if ~isa(stim,'stochasticgridstim'),
	error('stim must be a stochasticgridstim.');
end;

outstims=reverse_corr(stim,trigs,spikedata,intvrc,hiliteTrial);

[N,X,rast] = make_psth(spikedata, trigs, intvrs, res, normal);

subplot(2,1,1);

[hp,hr]=plot_psth(N,X,rast,length(trigs),0.3,10,gca, ...
			'PSTH and Reverse Corr','Spikes/frame');
set(gca,'Linewidth',2);

subplot(2,1,2);

str = struct(stim);
rect = str.SGSparams.rect;


imagesc([rect(1) rect(3)],[rect(2) rect(4)],outstims{1,1}/rcnormal);
axis([0 1000 0 1000]); set(gca,'Linewidth',2,'fontsize',16,'fontweight','bold');
colorbar;set(gca,'Linewidth',2,'fontsize',16,'fontweight','bold');


if (hiliteTrial),
	g = find(outstims{1,4}(:,hiliteTrial)==sym);
	hilite_rast(hr,rast,g,'b.');
end;
