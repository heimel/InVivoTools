function [info,N] = log_surround2sz

N = 0;

%%%%%%%
%OPTO_RECORDINGS FROM HERE ONE
%%%%%%
%1
N = N+1;
info(N).name = '20121129';
info(N).Opto = 1;
info(N).sizetuneblock = 15;  %OptoSize, 1s 
info(N).L4 = 8; %CHECKED
info(N).flashblock =7;
info(N).RFx = -75;
info(N).RFy = 0;
info(N).RFblock = 8;
info(N).surroundblocks = [19];  %#ok<*NBRAK> %Also onset version on B12
info(N).oriblock = 14; %1s on 1s off (OPTOORI)
info(N).oritime = 1; %1s on 1s off
%sua size-tune
% info(N).SUAchn =  [3 3 5 6 6 7 8 11 11 12];
% info(N).SUAclus = [1 3 1 1 3 1 1 2  3  3];
% info(N).SUAqual = [2 2 3 2 2 1 1 2  2  1];
%2sz surround
info(N).SUAchn =  [3 5 6 6 7 8 9 10];
info(N).SUAclus = [2 1 1 2 2 2 3 2];
info(N).SUAqual = [3 1 3 1 2 3 3 3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2
N = N+1;
info(N).name = '20121129B';
info(N).Opto = 1;
info(N).sizetuneblock = 10;  %OptoSize, 1s 
info(N).L4 = 8;  %CHECKED
info(N).flashblock =4;
info(N).RFx = -85;
info(N).RFy = -75;
info(N).RFblock = 5;
info(N).surroundblocks = [12];  %Also onset version on B12
info(N).oriblock = 8; %1s on 1s off (OTOORI)
info(N).oritime = 1; %1s on 1s off
%sua size-tune
% info(N).SUAchn =  [3 3 5 6 6 7 8 11 11 12];
% info(N).SUAclus = [1 3 1 1 3 1 1 2  3  3];
% info(N).SUAqual = [2 2 3 2 2 1 1 2  2  1];
%2sz surround
info(N).SUAchn =  [3 3 4 5 5 5 6 7 11];
info(N).SUAclus = [1 2 2 1 2 3 1 2 1];
info(N).SUAqual = [3 3 3 3 3 3 1 1 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3 - all good - could add extra pen here
N = N+1;
info(N).name = '20121211';
info(N).Opto = 1;
info(N).sizetuneblock = 12;  %OptoSize, 1s 
info(N).L4 = 9;  %CHECKED
info(N).flashblock =8;
info(N).RFx = 110;
info(N).RFy = -50;
info(N).RFblock = 7;
info(N).surroundblocks = [13];  %Also onset version on B12
info(N).oriblock = 11; %1s on 1s off (OTOORI)
info(N).oritime = 1; %1s on 1s off
%sua size-tune
% info(N).SUAchn =  [3 3 5 6 6 7 8 11 11 12];
% info(N).SUAclus = [1 3 1 1 3 1 1 2  3  3];
% info(N).SUAqual = [2 2 3 2 2 1 1 2  2  1];
%2sz surround
info(N).SUAchn =  [3 3 5 5 7 7 8 8 9 9 10 10 11 12 13];
info(N).SUAclus = [1 2 1 2 1 2 2 3 1 2 2  3  1  2  2 ];
info(N).SUAqual = [3 3 2 3 2 3 3 2 1 3 2  1  1  3  1];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%4 all good (anterior)
N = N+1;
info(N).name = '20130122';
info(N).Opto = 1;
info(N).sizetuneblock = 7;
info(N).L4 = 13;  %CHECKED
info(N).flashblock =2;
info(N).surroundblocks = [9];  %Also onset version on B12
info(N).SUAchn =  [4 4 8 8 9 11 11 12 12 12 14];
info(N).SUAclus = [1 3 1 3 2 1  2  2  3  4  2];
info(N).SUAqual = [3 2 2 2 3 1  2  3  1  1  0];

% return
N = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%5
N = N+1;
info(N).name = '20130124B';
info(N).Opto = 1;
info(N).sizetuneblock = 18;
info(N).L4 = 9;  %CHECKED
info(N).flashblock = 13;
info(N).surroundblocks = [19];  %Also onset version on B12

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%6
N = N+1;
info(N).name = '20130124B';
info(N).Opto = 1;
info(N).sizetuneblock = 26;
info(N).L4 = 9;  %CHECKED
info(N).flashblock =21;
info(N).surroundblocks = [28];  %Also onset version on B12

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%7
N = N+1;
info(N).name = '20130124B';
info(N).Opto = 1;
info(N).sizetuneblock = 35;
info(N).L4 = 9;  %CHECKED
info(N).flashblock =31;
info(N).surroundblocks = [36];  %Also onset version on B12

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%8 - good in general
N = N+1;
info(N).name = '20130205';
info(N).Opto = 1;
info(N).sizetuneblock = 17;
info(N).L4 = 10;  %CHECKED
info(N).flashblock =12;
info(N).surroundblocks = [21];  %Also onset version on B12

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%9
N = N+1;
info(N).name = '20130205';
info(N).Opto = 1;
info(N).sizetuneblock = 40;
info(N).L4 = 11;  %CHECKED
info(N).flashblock =37;
info(N).surroundblocks = [41];  %Also onset version on B12

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%10 - good
N = N+1;
info(N).name = '20130220';
info(N).Opto = 1;
info(N).sizetuneblock = 23;
info(N).L4 = 9;  %CHECKED
info(N).flashblock =20;
info(N).surroundblocks = [25];  %Also onset version on B12

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%11 - no fluoro
N = N+1;
info(N).name = '20130222';
info(N).Opto = 1;
info(N).sizetuneblock = 8;
info(N).L4 = 9;  %CHECKED
info(N).flashblock =4;
info(N).surroundblocks = [10];  %Also onset version on B12

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%12 - no fluro
N = N+1;
info(N).name = '20130222C';
info(N).Opto = 1;
info(N).sizetuneblock = 9;
info(N).L4 = 9;  %CHECKED
info(N).flashblock =5;
info(N).surroundblocks = [10];  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%13 - all good
N = N+1;
%Noisy
info(N).name = '20130226';
info(N).Opto = 1;
info(N).sizetuneblock = 10;
info(N).L4 = 8;  %CHECKED
info(N).flashblock =4;
info(N).surroundblocks = [11];  

%%%%%%all good
%14
N = N+1;
info(N).name = '20130226';
info(N).Opto = 1;
info(N).sizetuneblock = 21;
info(N).L4 = 8;  %CHECKED
info(N).flashblock =18;
info(N).surroundblocks = [23];  

if 0
%ARCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%15
N = N+1;
info(N).name = '20130305';
info(N).Opto = 1;
info(N).sizetuneblock = 6;
info(N).L4 = 7;  %CHECKED
info(N).flashblock =3;
info(N).surroundblocks = [7];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%16
N = N+1;
%FIBER TEST (ARCH injected, light over V1)
info(N).name = '20130305';
info(N).Opto = 1;
info(N).sizetuneblock = 9;
info(N).L4 = 7;  %CHECKED
info(N).flashblock =3;
info(N).surroundblocks = [11];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ARCH in KazuCre
%Very late responses
N = N+1;
info(N).name = '20130307';
info(N).Opto = 1;
info(N).sizetuneblock = 15;
info(N).L4 = 9;  %CHECKED
info(N).flashblock =9;
info(N).surroundblocks = [17];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = N+1;
%FIBER TEST IN SAME PEN AS ABOVE
info(N).name = '20130307';
info(N).Opto = 1;
info(N).sizetuneblock = 21;
info(N).L4 = 9;  %CHECKED
info(N).flashblock =9;
info(N).surroundblocks = [17];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = N+1;
%Super noisy
info(N).name = '20130307C';
info(N).Opto = 1;
info(N).sizetuneblock = 7;
info(N).L4 = 7;  %CHECKED
info(N).flashblock =4;
info(N).surroundblocks = [8];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ChR in GAD2Cre
%17
N = N+1;
info(N).name = '20130405';
info(N).Opto = 1;
info(N).sizetuneblock = 21;
info(N).L4 =8;  %CHECKED (nice)
info(N).flashblock =14;
info(N).surroundblocks = [22];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ChR in GAD2Cre
%18 - all good
N = N+1;
info(N).name = '20130409';
info(N).Opto = 1;
info(N).sizetuneblock = 14;
info(N).L4 =9;  %CHECKED
info(N).flashblock =9;
info(N).surroundblocks = [15];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%19 - all good
N = N+1;
info(N).name = '20130409B';
info(N).Opto = 1;
info(N).sizetuneblock = 6;
info(N).L4 =12;  %CHECKED
info(N).flashblock =4;
info(N).surroundblocks = [8];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%20 -all good
N = N+1;
info(N).name = '20130411';
info(N).Opto = 1;
info(N).sizetuneblock = 10;
info(N).L4 =7;  %CHECKED
info(N).flashblock =7;
info(N).surroundblocks = [11];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%21 - all good
N = N+1;
info(N).name = '20130416';
info(N).Opto = 1;
info(N).sizetuneblock = 12;
info(N).L4 =8;  %CHECKED, nice!
info(N).flashblock =4;
info(N).surroundblocks = [14];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%22 - all good
N = N+1;
info(N).name = '20130416B';
info(N).Opto = 1;
info(N).sizetuneblock = 6;
info(N).L4 =10;  %CHECKED, noisy
info(N).flashblock =3;
info(N).surroundblocks = [8];


return

