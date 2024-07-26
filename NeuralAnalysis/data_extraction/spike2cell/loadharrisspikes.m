function spikes=loadharrisspikes(filename,n_samples_per_spike,n_spikes)
%LOADHARRISSPIKES loads spikes of Harris of Buzsaki lab
%
% SPIKES=LOADHARRISSPIKES(FILENAME,N_SAMPLES_PER_SPIKE,N_SPIKES)

f=fopen(filename,'r');
if(f>2)  % succesful file open

spikest=fread(f,n_spikes*n_samples_per_spike*4,'int16');
spikest=reshape(spikest,4,n_samples_per_spike,n_spikes);  

for i=1:size(spikest,3)
     spikes(:,:,i)=spikest(:,:,i)';
end

end
fclose(f);
