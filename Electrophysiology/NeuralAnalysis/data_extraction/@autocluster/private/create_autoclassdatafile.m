function create_autoclassdatafile(features,basename)

% creates autoclass c binary data file

filename=[basename '.db2-bin'];

n=size(features,1);

fid=fopen(filename,'wb');
fprintf(fid,'.db2-bin');
fwrite(fid,n*4,'int32');  %byte length of each data case

for sp=1:size(features,2)
  for feat=1:n
    fwrite(fid,features(feat,sp),'float32');
  end
end


fclose(fid);
