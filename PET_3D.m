clear
clc
I2=zeros(170,144);
WW=zeros(144,1);
for i=1:144
WW(i,1) = exp(-((i-65)^2)/100);
end;
W=int16(repmat(WW,[1,144]));
for f=1:9
F=['0000',num2str(f),'_1.3.46.670589.28.2.15.21.6000.61812.3.3064.',num2str(170-f),'.1246978439','.dcm'];
I = dicomread(F);
I2(f,:)=(1/144)*sum(W.*I);
end;
for f=10:99
F=['000',num2str(f),'_1.3.46.670589.28.2.15.21.6000.61812.3.3064.',num2str(170-f),'.1246978439','.dcm'];
I = dicomread(F);
I2(f,:)=(1/144)*sum(W.*I);
end;
for f=100:170
F=['00',num2str(f),'_1.3.46.670589.28.2.15.21.6000.61812.3.3064.',num2str(170-f),'.1246978439','.dcm'];
I = dicomread(F);
I2(f,:)=(1/144)*sum(W.*I);
end;
% II=zeros(144,1,170);
% for i=1:144
% II = (1/144)*I3(:,i,:);
% end;
I3=zeros(170,144,144);
for f=1:9
F=['0000',num2str(f),'_1.3.46.670589.28.2.15.21.6000.61812.3.3064.',num2str(170-f),'.1246978439','.dcm'];
I = dicomread(F);
I3(f,:,:)=I;
end;
for f=10:99
F=['000',num2str(f),'_1.3.46.670589.28.2.15.21.6000.61812.3.3064.',num2str(170-f),'.1246978439','.dcm'];
I = dicomread(F);
I3(f,:,:)=I;
end;
for f=100:170
F=['00',num2str(f),'_1.3.46.670589.28.2.15.21.6000.61812.3.3064.',num2str(170-f),'.1246978439','.dcm'];
I = dicomread(F);
I3(f,:,:)=I;
end;
II=zeros(170,144,1);
for i=1:144
II = (exp(-(((i-60)^2)/360))*I3(:,:,i))+II;
end;
% figure
subplot(2,3,3)
imshow(max(max(I2(170:-1:1,:)))-I2(170:-1:1,:),[])
subplot(2,3,2)
imshow(max(max(II(170:-1:1,:)))-II(170:-1:1,:),[])
% %%%%%%%%
% clear
% clc
% % info =
% % dicominfo('00005_1.3.46.670589.28.2.15.21.6000.61812.3.3064.165.1246978439.dcm')
% Ic=zeros(170,144,144);
% Is=zeros(170,144,144);
% It=zeros(144,144,170);
% for f=1:9
% F=['0000',num2str(f),'_1.3.46.670589.28.2.15.21.6000.61812.3.3064.',num2str(170-f),'.1246978439','.dcm'];
% I = dicomread(F);
% Ic(f,1:144,1:144)=I';
% Is(f,1:144,1:144)=I;
% end;
% for f=10:99
% F=['000',num2str(f),'_1.3.46.670589.28.2.15.21.6000.61812.3.3064.',num2str(170-f),'.1246978439','.dcm'];
% I = dicomread(F);
% Ic(f,1:144,1:144)=I';
% Is(f,1:144,1:144)=I;
% end;
% for f=100:170
% F=['00',num2str(f),'_1.3.46.670589.28.2.15.21.6000.61812.3.3064.',num2str(170-f),'.1246978439','.dcm'];
% I = dicomread(F);
% Ic(f,1:144,1:144)=I';
% Is(f,1:144,1:144)=I;
% end;
% for f=1:170
%     It(1:144,1:144,f)=Ic(f,1:144,1:144);
% end;
% save('Ic.mat','Ic');
% save('It.mat','It');
% save('Is.mat','Is');

%%

load It
load Ic
load Is


II=zeros(144,144,1);
for i=1:170
    II3 = (exp(-(((i-150)^2)/50))*It(:,:,i))+II;
end;
subplot(2,3,1)
imshow(max(max(II3(:,:)))-II3(:,:),[])


subplot(2,3,4)
imshow(It(1:144,1:144,60),[]);
subplot(2,3,5)
imshow(Is(170:-1:1,1:144,60),[]);
subplot(2,3,6)
imshow(Ic(170:-1:1,1:144,60),[]);

%%%%%%%%%%%%%%%%%%%%%%%

labelStr='tv';
btnPos1=[60 70 7 100];
tv=uicontrol( ...
    'Style','slider', ...
    'Position',btnPos1, ...
    'String',labelStr, ...
    'max',165,...
    'min',5,...
    'Value',50);

labelStr='sv';
btnPos2=[0.45 0.05 0.15 0.02];
sv=uicontrol( ...
    'Style','slider', ...
    'Units','normalized', ...
    'Position',btnPos2, ...
    'String',labelStr, ...
    'min',1,...
    'max',142,...
    'Value',50,...
    'Interruptible','on');

labelStr='cv';
btnPos3=[0.73 0.05 0.15 0.02];
cv=uicontrol( ...
    'Style','slider', ...
    'Units','normalized', ...
    'Position',btnPos3, ...
    'String',labelStr, ...
    'min',1,...
    'max',142,...
    'Value',50,...
    'Interruptible','on');

labelStr='OK';
callbackStr='good=1;';
pH=uicontrol( ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',[0.93 0.05 0.05  0.05], ...
    'String',labelStr, ...
    'Interruptible','on', ...
    'Callback',callbackStr);

good=0;

while good ==0
    t0=get(tv,'Value');
    c0=get(cv,'Value');
    s0=get(sv,'Value');
    t0=floor(t0);
    c0=floor(c0);
    s0=floor(s0);
    subplot(2,3,4)
    imshow(max(max(It(:,:,t0)))-It(1:144,1:144,t0),[]);
    subplot(2,3,5)
    imshow(max(max(Is(170:-1:1,:,s0)))-Is(170:-1:1,1:144,s0),[]);
    subplot(2,3,6)
    imshow(max(max(Ic(170:-1:1,:,c0)))-Ic(170:-1:1,1:144,c0),[]);
    drawnow;
end;

%%%%%%
    subplot(2,3,4)
    imshow(max(max(It(:,:,t0)))-It(1:144,1:144,t0),[]);imcontrast(gca);[aT,bT,valsT] = impixel
    subplot(2,3,5)
    imshow(max(max(Is(170:-1:1,:,s0)))-Is(170:-1:1,1:144,s0),[]);imcontrast(gca);[aS,bS,valsS] = impixel
    subplot(2,3,6)
    imshow(max(max(Ic(170:-1:1,:,c0)))-Ic(170:-1:1,1:144,c0),[]);imcontrast(gca);[aC,bC,valsC] = impixel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% seed inputs
m=40;
if sum(isfinite(aT))~=0
    aT=aT(isfinite(aT));
    seedT = [aT(end),bT(end),t0];
    TUMORT=reggrow_3D(It,seedT,m);
end;
if sum(isfinite(aS))~=0
    aS=aS(isfinite(aS));
    seedS = [aS(end),bS(end),s0];
    TUMORS=reggrow_3D(Is,seedS,m);
end;
if sum(isfinite(aC))~=0
    aC=aC(isfinite(aC));
    seedC = [aC(end),bC(end),c0];
    TUMORC=reggrow_3D(Ic,seedC,m);
end;


