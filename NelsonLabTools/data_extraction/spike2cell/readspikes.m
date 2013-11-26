function spikes=readspikes(basename)
%READSPIKES read spikes from spike2cell .spikes file
  
  
filename=[basename '.spikes'];
fid=fopen(filename,'r');

spikecount=readint32(fid)
n_channels=readint32(fid)
before=readint32(fid)
after=readint32(fid)

for i=1:300
  spikes(:,:,i)=fread(fid,[before+after n_channels] ,'float32');
end

     fclose(fid);
  
%  fwrite(&spikecount,1,sizeof(int),fspikes);
%  fwrite(&n_channels,1,sizeof(int),fspikes);
%  fwrite(&before,1,sizeof(int),fspikes);
%  fwrite(&after,1,sizeof(int),fspikes);
