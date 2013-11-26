function[data,h]=SONGetRealMarkerChannel(fid,chan)
% Reads a RealMarker channel from a SON file 
% 

% Malcolm Lidierth 02/02

Info=SONChannelInfo(fid,chan);
if(Info.kind==0) 
    warning('SONGetRealMarkerChannel: No data on that channel');
    return;
end;

FileH=SONFileHeader(fid);
SizeOfHeader=20;                                            % Block header is 20 bytes long
header=SONGetBlockHeaders(fid,chan);
NumberOfMarkers=sum(header(5,:));                           % Sum of samples in all blocks

nValues=Info.nExtra/4;                                      % Each value has 4 bytes (single precision)
data.timings=zeros(NumberOfMarkers,1);
data.markers=char(zeros(NumberOfMarkers,4));
data.real=single(zeros(NumberOfMarkers,nValues));

count=1;
for block=1:Info.blocks
    fseek(fid, header(1, block)+SizeOfHeader, 'bof');                  % Start of block
    for i=1:header(5,block)                                            % loop for each marker
        data.timings(count)=fread(fid,1,'int32=>single');            % Time
        data.markers(count,:)=fread(fid,4,'uint8=>uint8');             % 4x marker bytes
        data.real(count,:)=fread(fid,nValues,'single=>single');
        count=count+1;
    end;
end;

data.timings=SONTicksToSeconds(fid,data.timings);             % Convert to seconds

if(nargout>1)
    h.FileName=Info.FileName;                                   % Set up the header information to return
    h.system=['SON' num2str(FileH.systemID)];
    h.FileChannel=chan;
    h.phyChan=Info.phyChan;
    h.kind=Info.kind;
    h.values=Info.nExtra/4;
    h.comment=Info.comment;
    h.title=Info.title;
    h.sampleinterval=SONGetSampleInterval(fid,chan);
    h.min=Info.min;
    h.max=Info.max;
    h.units=Info.units;
    if(isfield(Info,'interleave'))
        h.interleave=Info.interleave;
    end;
end;