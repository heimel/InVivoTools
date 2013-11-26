function onlinemap(teller,noemer,avg,framezero_avg)
close all

clip=3;

teller=teller+1;
noemer=noemer+1;



%figure;imagesc(avg(:,:,teller)');
%figure;imagesc(avg(:,:,noemer)');


kaart=(avg(:,:,teller)-framezero_avg(:,:,teller))./avg(:,:,noemer);

deviatie=std(kaart(:));
gemiddelde=mean(kaart(:));
% now clip

kaart(find(kaart(:)>gemiddelde+clip*deviatie))=gemiddelde+clip*deviatie;
kaart(find(kaart(:)<gemiddelde-clip*deviatie))=gemiddelde-clip*deviatie;



figure;imagesc(kaart');
colormap gray


