

close all;
NewStimInit;
remotecommglobals;
ReceptiveFieldGlobals;

CloseStimScreen;
ShowStimScreen;

warmupps=periodicstim('default');
% alexander
disp('INITSTIMS: working on pre and post time gamma correction and debug');
wp = getparameters(warmupps);
wp.contrast = 0;
wp.windowShape=0;


StimWindowGlobals
r = StimWindowRect; % screen size

%wp.rect = [1024/2-200 768/2-200 1024/2+200 768/2+200];

% wp.rect = [r(3)/2-200 r(4)/2-200 r(3)/2+200 r(4)/2+200];
wp.rect = [0 0 1920 1080];
%wp.background = (0:0.1:1)';
wp.backdrop = 0.5;
wp.dispprefs={'BGpretime',1,'BGposttime',1};
wp.tf = 4;
wp.nCycles = 5*wp.tf;

warmup = StimScript(0);
backgrounds = (0:0.1:1);
for i = 1:length(backgrounds);
    wp.background = backgrounds(i);
    warmupps = periodicstim(wp);
    
    warmup=append(warmup,warmupps);
%     soundsc(rand(1,8444),8444);
end

warmup=loadStimScript(warmup);
MTI=DisplayTiming(warmup);
DisplayStimScript(warmup,MTI,0,0);



CloseStimScreen

