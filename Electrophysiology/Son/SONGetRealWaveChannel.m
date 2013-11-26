function[data,h]=SONGetRealWaveChannel(fid,chan)
% Reads an real (floating point) waveform channel form a SON file.
%
% 

% Malcolm Lidierth 02/02
% Modified 15/12/03
% Now returns header correctly if frames are of
% unequal length.  Also, FrameLength calculation changed to reflect unequal
% lengths

Info=SONChannelInfo(fid,chan);
if(Info.kind==0) 
    warning('SONGetChannel: No data on that channel');
    return;
end;

FileH=SONFileHeader(fid);
SizeOfHeader=20;                                            % Block header is 20 bytes long
header=SONGetBlockHeaders(fid,chan);

NumberOfSamples=sum(header(5,:));                           % Sum of samples in all blocks
SampleInterval=(header(3,1)-header(2,1))/(header(5,1)-1);   % Sample interval in clock ticks

if(nargout>1)
h.FileName=Info.FileName;                                   % Set up the header information to return
h.system=['SON' num2str(FileH.systemID)];                   % if it's been requested
h.FileChannel=chan;
h.phyChan=Info.phyChan;
h.kind=Info.kind;
h.blocks=Info.blocks;
h.preTrig=Info.preTrig;
h.comment=Info.comment;
h.title=Info.title;
h.sampleinterval=SONGetSampleInterval(fid,chan);
h.min=Info.min;
h.max=Info.max;
h.units=Info.units;
end;

NumFrames=1;                                                % Number of frames. Initialize to one.
Frame(1)=1;
for i=1:Info.blocks-1                                       % Check for disctontinuities in data record
    IntervalBetweenBlocks=header(2,i+1)-header(3,i);
    if IntervalBetweenBlocks>SampleInterval                 % If true data is discontinuous (triggered)
        NumFrames=NumFrames+1;                              % Count discontinuities (NumFrames)
        Frame(i+1)=NumFrames;                               % Record the frame number that each block belongs to
    else
        Frame(i+1)=Frame(i);                                % Pad between discontinuities
    end;
end;


if NumFrames==1                                             % Continuous sampling - one frame only
    data=single(zeros(1,NumberOfSamples));                   % Pre-allocate memory for data
    pointer=1;
    h.start=header(2,1);                                    % Time of first sample (clock ticks)
    for i=1:Info.blocks
        fseek(fid,header(1,i)+SizeOfHeader,'bof');
        data(pointer:pointer+header(5,i)-1)=fread(fid,header(5,i),'float32=>float32');
        pointer=pointer+header(5,i);
    end;
else                                                        % Frame based data -  multiple frames
    FrameLength=max(histc(Frame,[1:NumFrames]))*max(header(5,:));% Maximum data points to a frame
    data=int16(zeros(NumFrames,FrameLength));               % Pre-allocate array                                                
    start=1;                                                % Pointer into array for each disk data block
    Frame(Info.blocks+1)=-99;                               % Dummy entry to avoid index error in for loop
    
    h.start(1)=header(2,1);                  % Time of first data point in frame #1 (clock ticks)****************15/12/03
    for i=1:Info.blocks                                        
        fseek(fid,header(1,i)+SizeOfHeader,'bof');
        data(Frame(i),start:start+header(5,i)-1)=fread(fid,header(5,i),'float32=>float32');
        if Frame(i+1)==Frame(i)
            start=start+header(5,i);                        % Increment pointer or.....
        else
            start=1; 
            h.stop(Frame(i))=header(3,i);                   % End time for this frame, clock ticks
            if(i<Info.blocks)                               %***************15/12/03
            h.start(Frame(i+1))=header(2,i+1);              % Time of first data point in next frame (clock ticks)*************15/12/03
        end;
    end;
end;
h.start


h.start=SONTicksToSeconds(fid,h.start)            % Convert clock ticks to seconds

