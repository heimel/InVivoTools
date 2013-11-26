%Program for user to identify key points on two images image which will be
%used for a morph. Output vectors of points are "vector1" and "vector2"
%which correspond to the first and second images read in.

clear
[FileName,PathName] = uigetfile('*.*','Choose A Picture');
pic1=(imread(strcat(PathName,FileName)));

points=46; %number of points on people to use- see instruction file

vec=[47,259;164,142;156,348;275,133;278,177;282,224;274,385;278,337;282,291;292,93;302,64;419,113;285,426;304,450;418,400;296,170;314,209;335,170;314,130;310,168;314,261;295,342;314,381;333,342;315,303;310,342;443,227;452,258;442,293;487,259;502,317;517,259;502,199;483,134;475,383;576,138;576,375;606,259;673,259;564,180;563,333;173,259;75,169;67,342;157,92;164,431];
y=vec(:,1);
x=vec(:,2);

subplot(1,2,2)
imshow('face-nox.jpg')

for i=1:points
    subplot(1,2,2)
    
    hold on
    plot(x(i),y(i),'xr','MarkerSize',20);
    hold off

    %picture 1
    subplot(1,2,1)
    imshow(pic1)
    [x1(i) y1(i)] = ginput(1);
    
    subplot(1,2,2)
    hold on
    plot(x(i),y(i),'xg','MarkerSize',20);
    hold off
end
close

vector=round(cat(2,y1',x1'));

savefile = strcat(FileName,'.mat');
save(savefile, 'pic1', 'vector')

