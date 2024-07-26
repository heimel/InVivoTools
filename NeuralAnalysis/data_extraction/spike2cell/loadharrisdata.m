function data=loadharrisdata(filename,n_samples)
%LOADHARRISDATA loads data of Harris of Buzsaki lab
%
% DATA=LOADHARRISDATA(FILENAME,N_SAMPLES)

f=fopen(filename,'r');
if(f>2)  % succesful file open

data=fread(f,n_samples*4,'int16');
data=reshape(data,4,n_samples)';  

end
fclose(f);
