%Takes two composite image files prepared in 'pointinder.m' and morphs from
%one to the other smoothly

clear;

filebasename = '~/Projects/Morphing_dendrites/dend';
ext = 'png'

q=1
% %Read in composite image/vector files prepared in pointfinder=====
% [FileName,PathName] = uigetfile('*.*','Choose The Starting Picture Composition');
% [FileName2,PathName2] = uigetfile('*.*','Choose The Target Picture Composition');

load(strcat(filebasename, [num2str(q,'%02d') '.' ext '.mat']));
images=double(pic1);
vectors=vector;

load(strcat(filebasename, [num2str(q+1,'%02d') '.' ext '.mat']));
imagef=double(pic1);
vectorf=vector;

[x,y,z]=size(images); %adds on corner points to vectors - allows cubic to work
corners=[1,1;1,y;x,1;x,y];
vectors=cat(1,vectors,corners);
vectorf=cat(1,vectorf,corners);
vecdiff=(vectors-vectorf);
[X,Y] = meshgrid(1:x,1:y);

frames=60;

final=zeros(x,y,z,frames+1);final(:,:,:,1)=images;
finalf=zeros(x,y,z,frames+1);finalf(:,:,:,frames+1)=imagef;
morph=zeros(x,y,z,frames+1);


%=====================================

%Interpolate changes across all pixels in image
totaltranx=(griddata(vectorf(:,1),vectorf(:,2),vecdiff(:,1),X,Y,'v4'))';
totaltrany=(griddata(vectorf(:,1),vectorf(:,2),vecdiff(:,2),X,Y,'v4'))';

for n=1:frames    
    %Apply changes incrementally==========
    transx=round(totaltranx.*(n-1)/frames);
    transy=round(totaltrany.*(n-1)/frames);
    
    tranfx=round(transx-totaltranx);
    tranfy=round(transy-totaltrany);
    %=====================================

    for i=1:x
        for j=1:y

            if (i+transx(i,j)<=x)&&(j+transy(i,j)<=y)&&(i+transx(i,j)>=1)&&(j+transy(i,j)>=1)
                final(i,j,1,n)=images(i+transx(i,j),j+transy(i,j),1);
                final(i,j,2,n)=images(i+transx(i,j),j+transy(i,j),2);
                final(i,j,3,n)=images(i+transx(i,j),j+transy(i,j),3);
            end
            
            if (i+tranfx(i,j)<=x)&&(j+tranfy(i,j)<=y)&&(i+tranfx(i,j)>=1)&&(j+tranfy(i,j)>=1)
                finalf(i,j,1,n)=imagef(i+tranfx(i,j),j+tranfy(i,j),1);
                finalf(i,j,2,n)=imagef(i+tranfx(i,j),j+tranfy(i,j),2);
                finalf(i,j,3,n)=imagef(i+tranfx(i,j),j+tranfy(i,j),3);
            end
        end
    end
end


for p=1:frames+1
    morph(:,:,:,p)=imlincomb((p-1)/frames,finalf(:,:,:,p),(frames-p+1)./(frames),final(:,:,:,p));
end
morph=uint8(morph);
figure(1)
    h=imshow(morph(:,:,:,q));
    saveas(h,['framet' num2str(q) '.tif'])
mov = immovie( morph);
implay(mov);
movie2avi(mov,'morphing_dendrite.avi');