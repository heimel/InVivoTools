function [TChannel]= SONChannelInfo(fid,chan)
% Reads the SON file channel header for channel chan
% Output follows the CED disk header structure but a FileName field is added to tag
% the returned structure with its source file.
% Malcolm Lidierth 02/02

FileH=SONFileHeader(fid);           % Get file header
if(FileH.channels<chan)
    warning('SONChannelInfo: Channel number too large for this file');
end;


base=512+(140*(chan-1));            % Offset due to file header and preceding channel headers
fseek(fid,base,'bof');
TChannel.FileName=fopen(fid);
TChannel.delSize=fread(fid,1,'int16');
TChannel.nextDelBlock=fread(fid,1,'int32');
TChannel.firstblock=fread(fid,1,'int32');
TChannel.lastblock=fread(fid,1,'int32');
TChannel.blocks=fread(fid,1,'int16');
TChannel.nExtra=fread(fid,1,'int16');
TChannel.preTrig=fread(fid,1,'int16');
TChannel.free0=fread(fid,1,'int16');
TChannel.phySz=fread(fid,1,'int16');
TChannel.maxData=fread(fid,1,'int16');
bytes=fread(fid,1,'uint8');
pointer=ftell(fid);
TChannel.comment=fread(fid,bytes,'char=>char')';
fseek(fid,pointer+71,'bof');
TChannel.maxChanTime=fread(fid,1,'int32');
TChannel.lChanDvd=fread(fid,1,'int32');
TChannel.phyChan=fread(fid,1,'int16');
bytes=fread(fid,1,'uint8');
pointer=ftell(fid);
TChannel.title=fread(fid,bytes,'char=>char')';
fseek(fid,pointer+9,'bof');
TChannel.idealRate=fread(fid,1,'float32');
TChannel.kind=fread(fid,1,'uint8');
TChannel.pad=fread(fid,1,'int8');               

   switch TChannel.kind
   case {1,6}
       TChannel.scale=fread(fid,1,'float32');
       TChannel.offset=fread(fid,1,'float32');
       bytes=fread(fid,1,'uint8');
       pointer=ftell(fid);
       TChannel.units=fread(fid,bytes,'char=>char')';
       fseek(fid,pointer+5,'bof');
       if (FileH.systemID<6)
           TChannel.divide=fread(fid,1,'int16');
       else
           TChannel.interleave=fread(fid,1,'int16');
       end;
   case {7,9}
       TChannel.min=fread(fid,1,'float32');        % With test data from Spike2 v4.05 min=scale and max=offset
       TChannel.max=fread(fid,1,'float32');        % as for ADC data
       bytes=fread(fid,1,'uint8');
       pointer=ftell(fid);
       TChannel.units=fread(fid,bytes,'char=>char')';
       fseek(fid,pointer+5,'bof');
       if (FileH.systemID<6)
           TChannel.divide=fread(fid,1,'int16');
       else
           TChannel.interleave=fread(fid,1,'int16');
       end;
   case 4
       TChannel.initLow=fread(fid,1,'uchar');
       TChannel.nextLow=fread(fid,1,'uchar');
   end
                                                

