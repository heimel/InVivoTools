function[data,h]=SONGetTextMarkerChannel(fid,chan)
% Reads a text marker channel from a SON file. 
%
%

% Malcolm Lidierth 02/02

Info=SONChannelInfo(fid,chan);
if(Info.kind==0) 
    warning('SONGetTextMarkerChannel: No data on that channel');
    return;
end;

FileH=SONFileHeader(fid);
SizeOfHeader=20;                                            % Block header is 20 bytes long
header=SONGetBlockHeaders(fid,chan);
NumberOfMarkers=sum(header(5,:));                           % Sum of samples in all blocks

data.timings=zeros(NumberOfMarkers,1);
data.markers=char(zeros(NumberOfMarkers,4));
data.text=char(zeros(NumberOfMarkers,Info.nExtra));

count=1;
for block=1:Info.blocks
    fseek(fid, header(1, block)+SizeOfHeader, 'bof');               % Start of block
    for i=1:header(5,block)                                         % loop for each marker
        data.timings(count,1)=fread(fid,1,'int32=>int32');          % Time
        data.markers(count,:)=fread(fid,4,'int8=>int8');            % 4x marker bytes
        data.text(count,:)=fread(fid,Info.nExtra,'char=>char');
        k=findstr(data.text(count,:),0);                            % Look for NULL terminator and clear succeeding characters
        data.text(count,k(1):Info.nExtra)=0;
        count=count+1;
    end;
end

data.timings=SONTicksToSeconds(fid,data.timings); % Convert to seconds

if(nargout>1)
    h.FileName=Info.FileName;                                   % Set up the header information to return
    h.system=['SON' num2str(FileH.systemID)];
    h.FileChannel=chan;
    h.phyChan=Info.phyChan;
    h.kind=Info.kind;
    h.blocks=Info.blocks;
    h.values=Info.nExtra;
    h.preTrig=Info.preTrig;
    h.comment=Info.comment;
    h.title=Info.title;
end;