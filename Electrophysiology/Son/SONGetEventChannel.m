function[data,h]=SONGetEventChannel(fid,chan)
% Reads an event channel form a SON file - Updated 01/03.
%
% Malcolm Lidierth 02/02
%
% 01/03 Bug fix (line 43 changed)
% Now deals with event channels of type 4 (EventBoth) correctly
% Initial state of channel contained in header.
% If h.initLow=1 start state has TTL low level so first event is a low to high transition. 
% If h.initLow=0 start state has TTL high level so first event is a high to low transition. 
% ML


Info=SONChannelInfo(fid,chan);
if(Info.kind==0) 
    data = [];
    h = [];
    warning('SONGetEventChannel: No data on that channel');
    return;
end;

FileH=SONFileHeader(fid);
SizeOfHeader=20;                                            % Block header is 20 bytes long
header=SONGetBlockHeaders(fid,chan);

if isempty(header)
    data = [];
    h = [];
    warning('SONGetEventChannel: No data on that channel');
    return
end

NumberOfSamples=sum(header(5,:));                           % Sum of samples in all blocks

data=zeros(NumberOfSamples,1);                              % Pre-allocate memory for data
pointer=1;
for i=1:Info.blocks                                         
    fseek(fid,header(1,i)+SizeOfHeader,'bof');
    data(pointer:pointer+header(5,i)-1)=fread(fid,header(5,i),'int32=>single');
    pointer=pointer+header(5,i);
end;

data=SONTicksToSeconds(fid,data);                              % Convert to seconds

if(nargout>1)
    h.FileName=Info.FileName;                                   % Set up the header information to return
    h.system=['SON' num2str(FileH.systemID)];                   % if it's been requested
    h.FileChannel=chan;
    h.phyChan=Info.phyChan;
    h.kind=Info.kind;
    h.comment=Info.comment;
    h.title=Info.title;
    if (Info.kind==4)
        h.initLow=Info.initLow;
        h.nextLow=Info.nextLow;                                 % Bug Fix 01/03. Reference to non-existant initMax deleted. 
                                                                % h.nextLow now properly assigned 
    end;
end;