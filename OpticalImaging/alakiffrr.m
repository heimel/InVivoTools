load spontaneous_frames1   % prestim data
ffrr0=ffrr;
load spontaneous_frames2   % evoked data
m = [size(ffrr{1,1}),length(ffrr)];
n=length(ffrr0);
blocksnum = 10;
stimnum = 30;
stimlength = m(3)/(stimnum*blocksnum);
prestimlength = n/(stimnum*blocksnum);
FR = zeros(m(1),m(2),stimnum*blocksnum);

for i=1:stimnum*blocksnum
    D = 0;
    for k=1:stimlength
        D = D+ffrr{1,stimlength*(i-1)+k};
    end
    E = 0;
    for j=1:prestimlength
        E = E+ffrr0{1,prestimlength*(i-1)+j};
    end
    normRESP = (D/stimlength)-(E/prestimlength);
    FR(:,:,i) = normRESP / abs((mean(mean(normRESP(190:end,170:end))) + mean(mean(normRESP(1:30,1:30))))/2);
end;

clear ffrr ffrr0

% figure;imagesc(FR(:,:,50)',[0 3])

TFR = zeros(m(1),m(2),6);
figure;
for i=1:6
    TFR(:,:,i) = mean(FR(:,:,(i*5:stimnum:stimnum*blocksnum)),3);
    subplot(floor(sqrt(stimnum))+1,floor(sqrt(stimnum))+1,i);imagesc(TFR(:,:,i)',[0 1])
end


TFfig1=zeros(m(2),m(1));
TFfig2=zeros(m(2),m(1));
for i=1:m(1)
    for j=1:m(2)
        fitobject = fit(log([4 7 10])',squeeze(TFR(i,j,3:5)),'poly1');
        TFfig1(j,i) = fitobject.p1;
        TFfig2(j,i) = fitobject.p2;
    end
    i
end

save('TFmap.mat','TFfig1','TFfig2');

TFpixmap=zeros(m(2),m(1));
for i=1:m(1)
    for j=1:m(2)
        [TFpixmap(j,i),aa] = max(abs(squeeze(TFR(i,j,1:end))));
    end
    i
end


%%

meandata = meandata(30:180,30:180,:);
n_x = size(meandata,1);n_y = size(meandata,2);
TFp=zeros(n_y,n_x,7);
for i=1:n_x
for j=1:n_y
TFp(j,i,:) = double(im2bw((squeeze(meandata(i,j,1:end))-min(squeeze(meandata(i,j,1:end))))/(max(squeeze(meandata(i,j,1:end)))-min(squeeze(meandata(i,j,1:end)))),.401));
end
i
end

TFTF=[1 2 4 7 10 13 18];
figure;
for i=1:7
subplot(4,2,i);imagesc(squeeze(TFp(:,:,i)));title(['threshold = 1/radical(2) with TF of ',num2str(TFTF(i))]);
end

data = reshape(TFp,n_x*n_y,numel(TFp)/(n_x*n_y));
fata=data(:,1:7);
[bb,mm1,mm2] = unique(fata, 'rows');
cols = rand(max(mm2),3);
xs = reshape(mm2,n_y,n_x);
% xs = reshape(mm2==32,n_y,n_x);
figure
image(xs);
axis image; colormap(cols);
title(pwd)
colorbar
figure;hold on;for i=1:max(mm2)
plot(bb(i,:)+(i*2),'color',rand(1,3))
end
% cols = retinotopy_colormap(4,1);data = reshape(TFp,n_x*n_y,numel(TFp)/(n_x*n_y));
% clear ind; ind = kmeans(data,4);
% [inds,ii]=sort(ind);
% figure;
% imagesc([inds data(ii,:)])
% ind = reshape(ind,n_y,n_x);
% figure
% image(ind');
% axis image; colormap(cols);
% title(pwd)
% colorbar