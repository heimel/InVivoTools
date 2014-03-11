function [info,N] = log_surround2sz_STATIC
clear info
N = 0;

%1
N = N+1;
info(N).name = '20121129';
info(N).static = 20;
info(N).L4 = 8;
info(N).Opto = 1; 
info(N).nstims = 5;

%2
N = N+1;
info(N).name = '20121211';
info(N).static = 36;
info(N).L4 = 9;
info(N).Opto = 1; 
info(N).nstims = 5;

%3
N = N+1;
info(N).name = '20130220';
info(N).static = 26;
info(N).L4 = 9;
info(N).Opto = 1; 
info(N).nstims = 2;

%4
N = N+1;
info(N).name = '20130222';
info(N).static = 11;
info(N).L4 = 9;
info(N).Opto = 1; 
info(N).nstims = 2;

%5
N = N+1;
info(N).name = '20130226';
info(N).static = 12;
info(N).L4 = 8;
info(N).Opto = 1; 
info(N).nstims = 2;

%6
N = N+1;
info(N).name = '20130307';
info(N).static = 23;
info(N).L4 = 9;
info(N).Opto = 2; %ARCH
info(N).nstims = 2;

%7
N = N+1;
info(N).name = '20130307C';
info(N).static = 9;
info(N).L4 = 8;
info(N).Opto = 2; %ARCH
info(N).nstims = 2;

%8
N = N+1;
info(N).name = '20130405';
info(N).static = 23;
info(N).L4 = 9;
info(N).Opto = 1; 
info(N).nstims = 2;

%9
N = N+1;
info(N).name = '20130409';
info(N).static = 16;
info(N).L4 = 8;
info(N).Opto = 1; 
info(N).nstims = 2;

%10
N = N+1;
info(N).name = '20130409B';
info(N).static = 9;
info(N).L4 = 12;
info(N).Opto = 1; 
info(N).nstims = 2;

%11
N = N+1;
info(N).name = '20130411';
info(N).static = 12;
info(N).L4 = 8;
info(N).Opto = 1; 
info(N).nstims = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CHECK THESE
%WEIRD RESPONSES 
% N = N+1;
% info(N).name = '20130416B';
% info(N).static = 9; %26 conds
% info(N).L4 = 10; %check
% info(N).Opto = 1; 
% info(N).nstims = 2;
% info(N).flash = 3;


%12
N = N+1;
info(N).name = '20130514';
info(N).static = 16; %Also 17 with diff timings
info(N).L4 = 10; %checked
info(N).Opto = 1; 
info(N).nstims = 2;
info(N).flash = 8;

%!3
N = N+1;
info(N).name = '20130514B';
info(N).static = 7; %Also 8 with diff timings
info(N).L4 = 11; %checked
info(N).Opto = 1; 
info(N).nstims = 2;
info(N).flash = 2;

%14
%Responses are pretty crappy
%Could exclude
N = N+1;
info(N).name = '20130527';
info(N).static = 10; %check timings
info(N).L4 = 11; %checked
info(N).Opto = 1; 
info(N).nstims = 2;
info(N).flash = 5;

%15
%Also crappy responses 15
N = N+1;
info(N).name = '20130527B';
info(N).static = 10; %Also 17 with smaller stims. %check timings
info(N).L4 = 12; %check
info(N).Opto = 1; 
info(N).nstims = 2;
info(N).flash = 5;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ARCH/KAZU
%little strange
%Can be excluded 16
%16
N = N+1;
info(N).name = '20130624';
info(N).static = 13; %[13 14]; %14 had weaker laser
info(N).L4 = 12;
info(N).Opto = 2; 
info(N).nstims = 2;
info(N).flash = 5;


% %ARCH/KAZU
% %LOOKS WORNG exclude
% N = N+1;
% info(N).name = '20130627';
% info(N).static = [20 21];
% info(N).L4 = 11;
% info(N).Opto = 2; 
% info(N).nstims = 2;
% info(N).flash = 13;


%%%CHECK THESE %%%%%%%%%%%%%%%%%%%%%%%%%%%
%ARCH/KAZU
%VERY DEEP!
%17
N = N+1;
info(N).name = '20130920B';
info(N).static = 12 ; %[12 15];
info(N).L4 = 14; %Checked
info(N).Opto = 2; 
info(N).nstims = 2;
info(N).flash = 7;

%ARCH/KAZU
%18
N = N+1;
info(N).name = '20130926A';
info(N).static = [10];
info(N).L4 = 7; %Checked
info(N).Opto = 2; 
info(N).nstims = 2;
info(N).flash = 6;
