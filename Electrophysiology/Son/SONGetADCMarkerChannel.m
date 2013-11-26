function[data,h]=SONGetADCMarkerChannel(fid,chan)
% Reads an ADC marker channel from a SON file.
% 
%

% Malcolm Lidierth 02/02

FileH=SONFileHeader(fid);
Info=SONChannelInfo(fid,chan);
SizeOfHeader=20;                                            % Block header is 20 bytes long
header=SONGetBlockHeaders(fid,chan);
if isempty(header)
    data = [];
    h = [];
    return
end
NumberOfMarkers=sum(header(5,:));                           % Sum of samples in all blocks

                                                                        

nValues=Info.nExtra/2;                                                    % 2 because 2 bytes per int16 value
data.timings=zeros(NumberOfMarkers,1);
data.markers=char(zeros(NumberOfMarkers,4));
data.adc=int16(zeros(NumberOfMarkers,nValues)); 

count=1;
for block=1:Info.blocks
    fseek(fid, header(1, block)+SizeOfHeader, 'bof');                         % Start of block
    for i=1:header(5,block)                                                   % loop for each marker
        data.timings(count)=fread(fid,1,'int32=>int32');                    % Time
        data.markers(count,:)=fread(fid,4,'uint8=>uint8');                    % 4x marker bytes
        data.adc(count,:)=fread(fid,nValues ,'int16=>int16');
        count=count+1;
    end;
end

data.timings=SONTicksToSeconds(fid,data.timings);                % Convert to seconds

if(nargout>1)
h.FileName=Info.FileName;                                   % Set up the header information to return
h.system=['SON' num2str(FileH.systemID)];
h.FileChannel=chan;
h.phyChan=Info.phyChan;
h.kind=Info.kind;
h.values=Info.nExtra/2;
h.preTrig=Info.preTrig;
h.comment=Info.comment;
h.title=Info.title;
h.sampleinterval=SONGetSampleInterval(fid,chan);
h.scale=Info.scale;
h.offset=Info.offset;
h.units=Info.units;
if(isfield(Info,'interleave'))
    h.interleave=Info.interleave;
end;
end;
