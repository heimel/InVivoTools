function EVENT = importtdt_linux( EVENT )
%IMPORTTDT_LINUX reads from TDT tank in format of tdt2ml
%
%  EVENT = IMPORTTDT_LINUX( EVENT )
%
%If used in a batch file you must initialize these values:
%input: EVENT.Mytank = full path to the tank you want to read from
%       EVENT.Myblock = name of the block you want to read from
%
%output: EVENT ;  a structure containing a lot of info
%        Trilist ; an array containing timing info about all the trials
%             1st column contains stimulus onset times
%             4th target onset times
%             7th micro stim times
%
% based on code from Jaewon 2013
% http://jaewon.mine.nu/jaewon/2010/10/04/how-to-import-tdt-tank-into-matlab/
%
% 2013-2014, Adapted by Alexander Heimel
%


%E.UNKNOWN = hex2dec('0');  %"Unknown"
E.STRON = hex2dec('101');  % Strobe ON "Strobe+"
%E.STROFF = hex2dec('102');  % Strobe OFF "Strobe-"
%E.SCALAR = hex2dec('201');  % Scalar "Scalar"
E.STREAM = hex2dec('8101');  % Stream "Stream"
E.SNIP = hex2dec('8201');  % Snip "Snip"
%E.MARK = hex2dec('8801');  % "Mark"
%E.HASDATA = hex2dec('8000');  % has associated waveform data "HasDat



if nargin<1
    EVENT.Mytank = '~/Desktop/TDT_invivotools';
    EVENT.Mytank = '/home/data/InVivo/Electrophys/Antigua/2013/12/18/Mouse';
    EVENT.Myblock = 't-2';
end

tank = EVENT.Mytank;
blockname = EVENT.Myblock;

if isempty(tank)
    errormsg('No tank specified');
    return
end
if ~exist(tank,'dir')
    errormsg(['Cannot locate tank at ' tank]);
    return
end
if isempty(blockname)
    errormsg('Not block specified');
    return
end


filebase = fullfile( tank,blockname,['Mouse_' blockname]);
tev_path = [filebase '.tev'];
tsq_path = [filebase '.tsq'];
%  store_id1 = 'PDec';
%  store_id2 = 'LFPs';       % this is just an example
% store_id3 = 'Tick';
% store_id4 = 'tril';
% store_id5 = 'Envl';
% store_id6 = 'LFPs';

if ~exist(tev_path,'file')
    errormsg(['File ' tev_path ' does not exist.']);
    return
end

% open the files

tsq = fopen(tsq_path); fseek(tsq, 0, 'eof'); ntsq = ftell(tsq)/40;

% read from tsq
fseek(tsq, 0, 'bof') ; data.size      = int32(fread(tsq, [ntsq 1], 'int32',  36));
fseek(tsq,  4, 'bof'); data.type      = int32(fread(tsq, [ntsq 1], 'int32',  36));
fseek(tsq,  8, 'bof'); data.namecode  = uint32(fread(tsq, [ntsq 1], 'uint32', 36)); %4
fseek(tsq, 12, 'bof'); data.chan      = uint16(fread(tsq, [ntsq 1], 'ushort', 38));
fseek(tsq, 14, 'bof'); data.sortcode  = uint16(fread(tsq, [ntsq 1], 'ushort', 38));
fseek(tsq, 16, 'bof'); data.timestamp = double(fread(tsq, [ntsq 1], 'double', 32));
fseek(tsq, 24, 'bof'); data.fp_loc    = int64(fread(tsq, [ntsq 1], 'int64',  32));
fseek(tsq, 24, 'bof'); data.strobe    = double(fread(tsq, [ntsq 1], 'double', 32));
fseek(tsq, 32, 'bof'); data.format    = int32(fread(tsq, [ntsq 1], 'int32',  36));
fseek(tsq, 36, 'bof'); data.frequency = double(fread(tsq, [ntsq 1], 'float',  36));
fclose(tsq);

data.timestamp = data.timestamp - data.timestamp(2);

namecodes = unique(data.namecode);
namecodes = namecodes(namecodes>2);

% get streams
s = 1;
for i=1:length(namecodes)
    ind = find(data.namecode==namecodes(i),1);
    if data.type(ind) ~= E.STREAM
        continue
    end
    EVENT.strms(s).name = code2string( namecodes(i) );
    EVENT.strms(s).size = data.size(ind)-10;
    EVENT.strms(s).sampf = data.frequency(ind);
    switch data.format(ind)
        case 0
            bytes_per_sample = 4;
        case 2
            bytes_per_sample = 2;
        case 4
            bytes_per_sample = 4;
    end
    EVENT.strms(s).channels = data.chan(ind); % assume start at top channel
    EVENT.strms(s).bytes = EVENT.strms(s).size *  bytes_per_sample;
    s = s+1;
end % i

% get snips
ind = find(data.type == E.SNIP);
EVENT.snips.Snip.size = data.size(ind(1))-10;
EVENT.snips.Snip.sampf = data.frequency(ind(1));
switch data.format(ind(1))
    case 0
        bytes_per_sample = 4;
    case 2
        bytes_per_sample = 2;
    case 4
        bytes_per_sample = 4;
end
EVENT.snips.Snip.channels = max(data.chan(ind)); % assume start at top channel
EVENT.snips.Snip.bytes = EVENT.snips.Snip.size *  bytes_per_sample;
EVENT.snips.Snip.name = code2string( data.namecode(ind(1)) );
for c = 1: EVENT.snips.Snip.channels
    EVENT.snips.Snip.times{c,1} = data.timestamp(ind(data.chan(ind)==c))';
end

% get strons
ind = find(data.type == E.STRON);
EVENT.strons.(code2string(data.namecode(ind))) = data.timestamp(ind);

EVENT.timerange = [data.timestamp(2) data.timestamp(end)]; 

logmsg(['Finished reading ' blockname ' in tank ' tank]);

% % an example of reading A/D samples from tev. You can use the same code to read
% % the snip-type data (sorted waveforms). Just replace the store ID.
% table = { 'float',  1, 'float';
%           'long',   1, 'int32';
%           'short',  2, 'short';
%           'byte',   4, 'schar';
%           'unknown', 4, 'unknown';
%           }; % a look-up table
%
%
%
% tev = fopen(tev_path);
%
% % typecast Store ID (such as 'Evnt', 'eNeu', and 'LPFs') to number
% namecode = 256.^(0:3)*double('PDec')';
%
% % select tsq headers by the Store ID
% row = (namecode == data.namecode);
%
% % an example of retrieving strobed events
% EVENTCODE = [data.timestamp(row) data.strobe(row)];
%
% namecode = 256.^(0:3)*double('LFPs')';
% row = (namecode == data.namecode);
% first_row = find(1==row,1);
% format    = data.format(first_row)+1; % from 0-based to 1-based
%
% LFP.format        = table{format,1};
% LFP.sampling_rate = data.frequency(first_row);
% LFP.chan_info     = [data.timestamp(row) data.chan(row)];
% % For the snip type, you may want the sortcode additionally.
% % SPIKE.chan_info = [data.timestamp(row) data.chan(row) data.sortcode(row)];
%
% fp_loc  = data.fp_loc(row);
% nsample = (data.size(row)-10) * table{format,2};
% LFP.sample_point = NaN(length(fp_loc),max(nsample));
% for n=1:length(fp_loc)
%     fseek(tev,fp_loc(n),'bof');
%     % For the snip type, each row of sample_point corresponds to each waveform.
%     LFP.sample_point(n,1:nsample(n)) = fread(tev,[1 nsample(n)],table{format,3});
% end
%
% % close the files
% fclose(tev);

% data =
%
%          size: [176378x1 int32]
%          type: [176378x1 int32] = [0  34817 48x33025 513  XXx33025  ...
%           0 257=101x=STRON  513=201x=SCALAR 33025=8101x=STREAM 33281=8201x=SNIP  34817=8801x
%
%          name: [176378x1 uint32]  = [0 1 16x1934640716 16x1819700805
%               16x1667581008 XX XX 16x... 16x... ...
%      0           1           2  1667581008  1801677140  1818849908  1819700805  1885957715
%                        1934640716
%
%          chan: [176378x1 uint16]   = [0 0 16:-1:1 ... 16:-1:1 ]
%      sortcode: [176378x1 uint16]  = 0
%     timestamp: [176378x1 double] = [ 0 timestamp1 timestamp2x48 ts3x32 ts4x48 ...
%        fp_loc: [176378x1 int64] = filelocation? increasing with sometimes jump to 10^18
%        strobe: [176378x1 double]  ??
%        format: [176378x1 int32] [ 0 0 16x2 32x0 4 32x0 16x2 32x0 0 32x0 16x2 ...]
%     frequency: [176378x1 double] [ 0 0 48x763 0 4x48x763 0 XXx763 ..     24414 ...


% for debugging
if 0
    tdt2ml = load('/home/data/InVivo/Electrophys/Antigua/2013/12/18/Mouse/t-2/t-2.mat');
    for i=1:length(EVENT.strms)
        disp('tdtread')
        EVENT.strms(i)
        disp('tdt2ml')
        tdt2ml.EVENT.strms(i)
    end
    disp('tdtread')
    EVENT.snips.Snip
    disp('tdt2ml')
    tdt2ml.EVENT.snips.Snip
    
    disp('tdtread')
    EVENT.strons
    disp('tdt2ml')
    tdt2ml.EVENT.strons
end




function str = code2string( code )
str(4) = floor(code/(256^3));
code = code - str(4)*256^3;
str(3) = floor(code/(256^2));
code = code - str(3)*256^2;
str(2) = floor(code/(256^1));
code = code - str(2)*256^1;
str(1) = floor(code/(256^0));
code = code - str(1)*256^0;
str = char(str);



