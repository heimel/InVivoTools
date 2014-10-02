function tdtread
%tdtread example function to read tdt data
%
% Jaewon

%tev_path = 'path to TEV';
% tsq_path = 'path to TSQ';
% store_id1 = 'Evnt';       % this is just an example
% store_id2 = 'LFPs';       % this is just an example
 
% open the files
tev = fopen(tev_path);
tsq = fopen(tsq_path); fseek(tsq, 0, 'eof'); ntsq = ftell(tsq)/40; fseek(tsq, 0, 'bof');
 
% read from tsq
data.size      = fread(tsq, [ntsq 1], 'int32',  36); fseek(tsq,  4, 'bof');
data.type      = fread(tsq, [ntsq 1], 'int32',  36); fseek(tsq,  8, 'bof');
data.name      = fread(tsq, [ntsq 1], 'uint32', 36); fseek(tsq, 12, 'bof');
data.chan      = fread(tsq, [ntsq 1], 'ushort', 38); fseek(tsq, 14, 'bof');
data.sortcode  = fread(tsq, [ntsq 1], 'ushort', 38); fseek(tsq, 16, 'bof');
data.timestamp = fread(tsq, [ntsq 1], 'double', 32); fseek(tsq, 24, 'bof');
data.fp_loc    = fread(tsq, [ntsq 1], 'int64',  32); fseek(tsq, 24, 'bof');
data.strobe    = fread(tsq, [ntsq 1], 'double', 32); fseek(tsq, 32, 'bof');
data.format    = fread(tsq, [ntsq 1], 'int32',  36); fseek(tsq, 36, 'bof');
data.frequency = fread(tsq, [ntsq 1], 'float',  36);
 
% change the unit of timestamps from sec to millisec
data.timestamp(3:end-1) = (data.timestamp(3:end-1) - data.timestamp(2)) * 1000;
 
% typecast Store ID (such as 'Evnt', 'eNeu', and 'LPFs') to number
name = 256.^(0:3)*double(store_id1)';
 
% select tsq headers by the Store ID
row = (name == data.name);
 
% an example of retrieving strobed events
EVENTCODE = [data.timestamp(row) data.strobe(row)];
 
% an example of reading A/D samples from tev. You can use the same code to read
% the snip-type data (sorted waveforms). Just replace the store ID.
table = { 'float',  1, 'float';
          'long',   1, 'int32';
          'short',  2, 'short';
          'byte',   4, 'schar'; }; % a look-up table
name = 256.^(0:3)*double(store_id2)';
row = (name == data.name);
first_row = find(1==row,1);
format    = data.format(first_row)+1; % from 0-based to 1-based
 
LFP.format        = table{format,1};
LFP.sampling_rate = data.frequency(first_row);
LFP.chan_info     = [data.timestamp(row) data.chan(row)];
% For the snip type, you may want the sortcode additionally.
% SPIKE.chan_info = [data.timestamp(row) data.chan(row) data.sortcode(row)];
 
fp_loc  = data.fp_loc(row);
nsample = (data.size(row)-10) * table{format,2};
LFP.sample_point = NaN(length(fp_loc),max(nsample));
for n=1:length(fp_loc)
    fseek(tev,fp_loc(n),'bof');
    % For the snip type, each row of sample_point corresponds to each waveform.
    LFP.sample_point(n,1:nsample(n)) = fread(tev,[1 nsample(n)],table{format,3});
end
 
% close the files
fclose(tev);
fclose(tsq);