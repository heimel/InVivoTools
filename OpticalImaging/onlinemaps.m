function onlinemaps(avg,framezero_avg,n_x,fname,ledtest)
%ONLINEMAPS
%
%
% 2004, Alexander Heimel
%

if nargin<5
  ledtest=[];
end
if isempty(ledtest)
  ledtest=0;
end

if nargin<4
	fname=[];
end

if nargin<2
	framezero_avg=[];
end
if isempty(framezero_avg)
	framezero_avg=0*avg;
end
if nargin<3
	n_x=2;
end


clip=5;

noemer=1;

h1=figure;


%figure;imagesc(avg(:,:,teller)');
%figure;imagesc(avg(:,:,noemer)');

% normalize all the same as map 1
%kaart=(avg(:,:,2)-framezero_avg(:,:,2))./avg(:,:,noemer);
%maxkaart=max(kaart(:));
%minkaart=min(kaart(:));
%col=colormap(gray);

n_stims=size(avg,3);
maxavg=-inf;
minavg=+inf;

% subtract zero-frames
if ledtest
  avg(:,:,2)=avg(:,:,2)-avg(:,:,1);
else

  for stim=1:n_stims
	avg(:,:,stim)=avg(:,:,stim)-framezero_avg(:,:,stim);
  end
end

%avg=dccorrection(avg);

% clipping range
  deviatie=std(avg(:));
  gemiddelde=median(avg(:));

for stim=1:n_stims
	h_image(stim)=subplot(n_x,ceil((n_stims)/n_x),stim);
	kaart=avg(:,:,stim);

	% clip
	%deviatie=std(kaart(:))
	%gemiddelde=median(kaart(:))

	  kaart(find(kaart(:)>gemiddelde+clip*deviatie))=gemiddelde+clip*deviatie;
	  kaart(find(kaart(:)<gemiddelde-clip*deviatie))=gemiddelde-clip*deviatie;
%    disp( ['stim: ' num2str(stim-1) ' mean: ' num2str(mean(kaart(:)),2)]);
	
        kaart=(kaart -(gemiddelde-clip*deviatie))/2./(gemiddelde+clip*deviatie);
	imgmap{stim}=image(kaart'*64);
	%    imgmap{stim}=imagesc(kaart');
	%	 set(h_image(stim),'Clim',[gemiddelde-clip*deviatie,gemiddelde+clip*deviatie]);
	axis equal off;
	colormap gray

	maxkaart=max(kaart(:));
	if maxkaart>maxavg
		maxavg=maxkaart;
	end
	minkaart=min(kaart(:));
	if minkaart<minavg
		minavg=minkaart;
	end
	maps{stim}=kaart;
	text(0,0,num2str(stim),'HorizontalAlignment','right');

end
close(h1)



if ~isempty(fname)
	hh=figure;
	for stim=1:n_stims
		image(maps{stim}'*64);
		axis image;axis off;colormap gray
		%		set(gca,'Clim',[gemiddelde-clip*deviatie,gemiddelde+clip*deviatie]);
		filename=[fname 'single_cond' num2str(stim) '.png'];
		%		saveas(gcf,filename,'png');
		imwrite(maps{stim}',filename,'png')
	end
	close(hh);
end


return




