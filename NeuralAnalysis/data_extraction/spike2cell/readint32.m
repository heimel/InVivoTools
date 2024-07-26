function x=readint32(fid)
[temp1,c]=fread(fid,1,'int8');
[temp2,c]=fread(fid,1,'int8');
[temp3,c]=fread(fid,1,'int8');
[temp4,c]=fread(fid,1,'int8');
x=temp1+256*temp2+65536*temp3+16777216*temp4;
