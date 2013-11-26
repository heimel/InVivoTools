clear all;
%%
screens=Screen('Screens');
screenNumber=max(screens);
window=Screen('OpenWindow', screenNumber,255);
Screen('Flip', window);
[screenWidth screenHeight]=WindowSize(window);
frameRate=Screen('NominalFrameRate',window);
screenCenter= [screenWidth/2 screenHeight/2-140];
black=BlackIndex(window);
[ifi nvalid stddev] = Screen('GetFlipInterval', window, 100, 0.005, 20);
Screen(window,'TextSize',12);
priorityLevel=MaxPriority(window);
Priority(priorityLevel);
%%
pixRect = [0 0 200 200];
img_w = 400;
img_h = 400;
timing_start = GetSecs;
for x = 1:100
    img = zeros(img_w,img_h);
    for i=1:img_h
        tmp = randperm(img_w);
        tmp = (mod(tmp,10)==0);%*255
        img(i,:) = tmp;
    end
    Screen('DrawTexture', window, img, [], [screenCenter(1)-(pixRect(3)/2) screenCenter(2)-(pixRect(4)/2) screenCenter(1)+(pixRect(3)/2) screenCenter(2)+(pixRect(4)/2)]);
    img2(:,:,1) = img;
    img2(:,:,2) = img;
    img2(:,:,3) = img;
    M(x) = im2frame(img2);
    %figure(x);
    %imshow(img);
end