function [spikes, before, after]=loadspikes(filename,first,last)
%LOADSPIKES Load spikes from spike2cell file
%
%   [SPIKES, BEFORE, AFTER]=LOADSPIKES(FILENAME,FIRST,LAST)
%
%  (first record is 1) inclusive last
%
% June 2002, Alexander Heimel (heimel@brandeis.edu)


fspikes=fopen(filename,'r');
spikecount=fread(fspikes,1,'int');    
n_channels=fread(fspikes,1,'int');    
before=fread(fspikes,1,'int');
after=fread(fspikes,1,'int');

if nargin==1
  spikes=fread(fspikes,'float');
  spikes=reshape(spikes,before+after,n_channels,spikecount);
  return
end

if nargin==2
  last=spikecount;
end

n_records=last-first+1;
spikewindow=before+after;
recordsize=spikewindow*n_channels;
fseek(fspikes,recordsize*(first-1)*4,'cof');
spikes=fread(fspikes,n_records*recordsize,'float');
spikes=reshape(spikes,spikewindow,n_channels,n_records);

