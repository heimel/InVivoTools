function [Head]=SONFileHeader(fid)
% Reads the file header for a SON file returning data as a matlab structure
% See CED documentation of SON system for details.
%

% Malcolm Lidierth 02/02
frewind(fid);
Head.FileIdentifier=fopen(fid);
Head.systemID=fread(fid,1,'int16');
Head.copyright=fscanf(fid,'%c',10);
Head.Creator=fscanf(fid,'%c',8);
Head.usPerTime=fread(fid,1,'int16');
Head.timePerADC=fread(fid,1,'int16');
Head.filestate=fread(fid,1,'int16');
Head.firstdata=fread(fid,1,'int32');
Head.channels=fread(fid,1,'int16');
Head.chansize=fread(fid,1,'int16');
Head.extraData=fread(fid,1,'int16');
Head.buffersize=fread(fid,1,'int16');
Head.osFormat=fread(fid,1,'int16');
Head.maxFTime=fread(fid,1,'int32');
Head.dTimeBase=fread(fid,1,'float64');
Head.timeDate.Detail=fread(fid,6,'uint8');
Head.timeDate.Year=fread(fid,1,'int16');
Head.pad=char(fread(fid,52,'char'));
Head.fileComment=cell(5);    

pointer=ftell(fid);
for i=1:5
    bytes=fread(fid,1,'uint8');
    Head.fileComment{i}=fread(fid,bytes,'char=>char')';
    pointer=pointer+80;
    fseek(fid,pointer,'bof');
end;







