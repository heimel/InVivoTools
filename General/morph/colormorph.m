%Takes two composite image files prepared in 'pointinder.m' and morphs from
%one to the other smoothly

clear;
tic
%Read in composite image/vector files prepared in pointfinder=====
[FileName,PathName] = uigetfile('*.*','Choose The Starting Picture Composition');
[FileName2,PathName2] = uigetfile('*.*','Choose The Target Picture Composition');

load(strcat(PathName,FileName));
images=double(pic1);
vectors=vector;

load(strcat(PathName2,FileName2));
imagef=double(pic1);
vectorf=vector;

[x,y,z]=size(images); %adds on corner points to vectors - allows cubic to work
corners=[1,1;1,y;x,1;x,y];
vectors=cat(1,vectors,corners);
vectorf=cat(1,vectorf,corners);
vecdiff=(vectors-vectorf);
[X,Y] = meshgrid(1:x,1:y);

frames=50;

final=zeros(x,y,z);
finalf=zeros(x,y,z);
morph=zeros(x,y,z);

%=====================================

%Interpolate changes across all pixels in image
totaltranx=(griddata(vectorf(:,1),vectorf(:,2),vecdiff(:,1),X,Y,'v4'))';
totaltrany=(griddata(vectorf(:,1),vectorf(:,2),vecdiff(:,2),X,Y,'v4'))';

for n=2:frames
    
    %Apply changes incrementally==========
    transx=round(totaltranx.*(n-1)/frames);
    transy=round(totaltrany.*(n-1)/frames);
    
    tranfx=round(transx-totaltranx);
    tranfy=round(transy-totaltrany);
    %=====================================

    for i=1:x
        for j=1:y

            if (i+transx(i,j)<=x)&&(j+transy(i,j)<=y)&&(i+transx(i,j)>=1)&&(j+transy(i,j)>=1)
                final(i,j,1)=images(i+transx(i,j),j+transy(i,j),1);
                final(i,j,2)=images(i+transx(i,j),j+transy(i,j),2);
                final(i,j,3)=images(i+transx(i,j),j+transy(i,j),3);
            end
            
            if (i+tranfx(i,j)<=x)&&(j+tranfy(i,j)<=y)&&(i+tranfx(i,j)>=1)&&(j+tranfy(i,j)>=1)
                finalf(i,j,1)=imagef(i+tranfx(i,j),j+tranfy(i,j),1);
                finalf(i,j,2)=imagef(i+tranfx(i,j),j+tranfy(i,j),2);
                finalf(i,j,3)=imagef(i+tranfx(i,j),j+tranfy(i,j),3);
            end
        end
    end

morph(:,:,:)=imlincomb((n-1)/frames,finalf(:,:,:),(frames-n+1)./(frames),final(:,:,:));
morph=uint8(morph);

figure(1)    
h=imshow(morph(:,:,:));
saveas(h,['framet' num2str(n) '.tif'])


% final=uint8(final);
% finalf=uint8(finalf);
% h=imshow(final(:,:,:));
% saveas(h,['frametcheese' num2str(n) '.tif'])
% h=imshow(finalf(:,:,:));
% saveas(h,['frametmouse' num2str(n) '.tif'])
end

h=imshow(uint8(images(:,:,:)));
saveas(h,['framet' num2str(1) '.tif'])

h=imshow(uint8(imagef(:,:,:)));
saveas(h,['framet' num2str(frames+1) '.tif'])
toc
