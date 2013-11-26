function[data,h]=SONGetMarkerChannel(fid,chan)
% Reads an marker channel from a SON file.
% 

% Malcolm Lidierth 02/02

Info=SONChannelInfo(fid,chan);
if(Info.kind==0) 
    warning('SONGetADCMarkerChannel: No data on that channel');
    return;
end;

FileH=SONFileHeader(fid);
SizeOfHeader=20;                                            % Block header is 20 bytes long
header=SONGetBlockHeaders(fid,chan);
NumberOfMarkers=sum(header(5,:));                           % Sum of samples in all blocks

                                                                        

data.timings=zeros(NumberOfMarkers,1);
data.markers=char(zeros(NumberOfMarkers,4));

count=1;
for block=1:Info.blocks
    fseek(fid, header(1, block)+SizeOfHeader, 'bof');                     % Start of block
    for i=1:header(5,block)                                              % loop for each marker
        data.timings(count)=fread(fid,1,'int32=>single');                    % Time
        data.markers(count,:)=fread(fid,4,'uint8=>uint8');                    % 4x marker bytes
        count=count+1;
    end;
end

data.timings=SONTicksToSeconds(fid,data.timings);                % Convert to seconds


if(nargout>1)
    h.FileName=Info.FileName;                                   % Set up the header information to return
    h.system=['SON' num2str(FileH.systemID)];                   % if it's been requested
    h.FileChannel=chan;
    h.phyChan=Info.phyChan;
    h.kind=Info.kind;
    h.comment=Info.comment;
    h.title=Info.title;
end;