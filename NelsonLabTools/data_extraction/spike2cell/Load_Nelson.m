function [t, wv]=Load_Nelson(fn,records_to_get,record_units)
%LOAD_NELSON MClust loadingengine for igordata in Nelsonlab format
% 
%[T,WV]=LOADNELSON(FN)
%[T]=LOADNELSON(FN)
%[T,WV]=LOADNELSON(FN,RECORDS_TO_GET,RECORD_UNITS)
%
% input:
%    FN = file name string
%    RECORDS_TO_GET = an array that is either a range of values
%    RECORD_UNITS 
%      1: timestamp list
%      2: record number list
%      3: range of timestamps 
%      4: range of records 
%      5: return the count of spikes 
%    if only fn is passed in then the entire file is opened.
%    if only fn is passed AND only t is provided as the output, then all 
%       of the timestamps for the entire file are returned.
%
% output:
%    T = N x 1: timestamps of each spike in file
%    WV = N x 4 x 32 waveforms
%
% June 2002, Alexander Heimel
   
fnspikes=[fn '.spikes'];
fnspiketimes=[fn '.spikestimes'];

if nargin==1 
   record_units=0;
end

fpspikes=fopen([fn '.spikes'],'r');
if fpspikes==-1
keyboard
   disp(['Load_Nelson: Error opening ' fn '.spikes' ])
   return
end

n_spikes=fread(fpspikes,1,'int');    
n_channels=fread(fpspikes,1,'int');    
before=fread(fpspikes,1,'int');
after=fread(fpspikes,1,'int');
spikewindow=before+after;
samp_dt=3.1807627469e-05; %should be read in


fclose(fpspikes);



%load spiketimes
spiketimes=load([fn '.spiketimes'],'-ascii');


if ~(record_units==5)
     timeresamp=samp_dt/0.0001; %resamp 10kHz
     t=round(spiketimes*timeresamp);
end


switch record_units
case 0 %ENTIRE FILE
     if nargout==2
       spikes=loadspikes(fnspikes);
     end
case 1 %TIMESTAMP LIST
     records_to_get=binsearch(t,records_to_get);
     spikes=getrecordselection(fnspikes,records_to_get);
     t=t(records_to_get);
case 2 %RECORD NUMBER LIST
     spikes=getrecordselection(fnspikes,records_to_get);
     t=t(records_to_get);
case 3 %RANGE OF TIMESTAMPS
     records_to_get=binsearch(t,records_to_get);
     spikes=loadspikes(fnspikes,records_to_get(1),records_to_get(2));
     t=t(records_to_get(1):records_to_get(2));
case 4 %RANGE OF RECORDS
     spikes=loadspikes(fnspikes,records_to_get(1),records_to_get(2));
     t=t(records_to_get(1):records_to_get(2));
case 5 %SPIKECOUNT
     t=n_spikes;
end



if nargout==2 
     wv=resample(spikes,32);
end


return

%_________________________________________________________________
function index=binsearch(data,key)

for i=1:length(key)

  if(key(i)>data(end))
     index(i)=length(data)
  else
    low = 1;
    mid = 1;
    high = length(data);                    
    while (low < (high-1))
        mid = floor( (low + high)/2);
        tmp = floor(data(mid));
        if key(i) == tmp
  	 low = mid;
           high = mid;
        end
        if key(i) < tmp
  	 high = mid;
        end
        if key(i) > tmp
  	low = mid;
        end
    end
    index(i)=low;  
  end
end
return



%________________________________________________________________
function spikes=getrecordselection(fnspikes,records_to_get)

for i=1:length(records_to_get)
    spikes(:,:,i)=loadspikes(fnspikes,records_to_get(i),records_to_get(i));
end

return


%_________________________________________________________________
function rspikes=resample(spikes,points)


orgt=linspace(0,1,size(spikes,1));
resampt=linspace(0,1,points); 

for i=1:size(spikes,3)
  rspikes(i,:,:)=spline(orgt,spikes(:,:,i)',resampt);
end

