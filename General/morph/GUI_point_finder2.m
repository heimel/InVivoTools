%Program for user to identify key points on two images image which will be
%used for a morph. Output vectors of points are "vector1" and "vector2"
%which correspond to the first and second images read in.

clear
[FileName,PathName] = uigetfile('*.*','Choose A Picture');
pic1=(imread(strcat(PathName,FileName)));
[FileName2,PathName2] = uigetfile('*.*','Choose A Picture');
pic2=(imread(strcat(PathName2,FileName2)));


points=5; %number of points on people to use- see instruction file

subplot(1,2,1)
imshow(pic1)

subplot(1,2,2)
imshow(pic2)


for i=1:points
    subplot(1,2,1)
    [x1(i) y1(i)] = ginput(1);
    
    hold on
    plot(x1(i),y1(i),'.r','MarkerSize',10);
    hold off

    subplot(1,2,2)
    [x2(i) y2(i)] = ginput(1);
    hold on
    plot(x2,y2,'.g','MarkerSize',10);
    hold off
    
    subplot(1,2,1)
    hold on
    plot(x1,y1,'.g','MarkerSize',10);
    hold off
end
close

vector=round(cat(2,y1',x1'));
savefile = strcat(FileName,'.mat');
save(savefile, 'pic1', 'vector')

vector=round(cat(2,y2',x2'));
pic1=pic2;
savefile = strcat(FileName2,'.mat');
save(savefile, 'pic1', 'vector')
