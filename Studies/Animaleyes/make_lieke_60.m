

contrast_sensitivities;

img_low=convert_image('lieke/lieke-jong.jpg',cs_low_human,0,15);
img_low=img_low(229-204:229,1:205);

img_low=img_low-mean(img_low(:));
img_low=img_low/max(abs(img_low(:)));


figure;

img_high=convert_image('lieke/lieke-oud.jpg',cs_high_human,1,15);
img_high=img_high-mean(img_high(:));
img_high=img_high/max(abs(img_high(:)));
% shift left
sl=10;
img_high=img_high(:,[sl:end 1:sl-1]);

close all



figure
imagesc(img_high);colormap gray;axis image
figure
imagesc(img_low);colormap gray;axis image
figure
img_both=img_low+img_high
imagesc(img_both);colormap gray;axis image;axis off;
saveas(gcf,'lieke/lieke_60jaar.png','png')
%imwrite(img_both,'lieke/lieke_60jaar.png','png')
%imwrite(img_both,'lieke/lieke_60jaar.jpg','jpg')

