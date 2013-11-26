function db = insert_matching_lfp_records( db ,crit)
%INSERT_MATCHING_LFP_RECORDS creates for each ectestrecord an lfp record
%
% DB = INSERT_MATCHING_LFP_RECORDS
%        loads default ec database and saves it
%
% DB = INSERT_MATCHING_LFP_RECORDS( DB, CRIT )
%
% 2013, Alexander Heimel
%

if nargin<1
    db = [];
end
if isempty(db)
    [testdb, experimental_pc] = expdatabases( 'ec', host );
    [db,filename]=load_testdb(testdb);
end

if nargin<2
    crit = '';
end
crit = trim(crit);
if isempty(crit)
    crit ='';% 'experimenter=hs,';
elseif crit(end)~=','
    crit(end+1) = ',';
end

ind_ec  = find_record( db, [crit 'datatype=ec']);

for i=ind_ec(:)'
   % disp(['Matching ' num2str(i) ' from ' num2str(length(ind_ec)) ' ecrecords.']);
    ecrecord = db(i);
    match_crit = ['datatype=lfp,mouse=' ecrecord.mouse ...
        ',date=' ecrecord.date ',test=' ecrecord.test ];
    ind_lfp_match = find_record( db, match_crit );
    if ~isempty(ind_lfp_match)
        continue
    end
    if ~has_lfp_channel( ecrecord)
        continue
    end

    disp(['Adding ecrecord ' num2str(i) ]); 
    lfprecord = ecrecord;
    lfprecord.datatype = 'lfp';
    try
        if lfprecord.reliable
            lfprecord = analyse_lfptestrecord( lfprecord, 0);
        end
    catch
        errordlg(['Could not analyse record: mouse=' lfprecord.mouse ...
            ',date=' lfprecord.date ',test=' lfprecord.test]);
        disp(['INSERT_MATCHING_LFP_RECORDS: Could not analyse record mouse=' lfprecord.mouse ...
            ',date=' lfprecord.date ',test=' lfprecord.test]);
    end
    db(end+1) = lfprecord;
end

if ~isempty(filename)
     [filename,lockfile] = save_db(db, filename);
end

function result = has_lfp_channel( record )
result = false;

smrfilename=fullfile(ecdatapath(record),record.test,'data.smr');
if ~exist(smrfilename,'file')
    disp(['INSERT_MATCHING_LFP_RECORDS: ' smrfilename  ' does not exist.']);
end
fid=fopen(smrfilename);
if fid==-1
    errordlg(['INSERT_MATCHING_LFP_RECORDS: Failed to open  ' smrfilename],'Insert matching LFP records');
    return
end
lfpchannelname='LFP';
list_of_channels = SONChanList(fid);
    
lfpchannel=findchannel(list_of_channels,lfpchannelname);
if lfpchannel ~= -1
    result = true;
end

    



function channel=findchannel(list_of_channels,channelname)
ch=1;
channel=-1;
while ch<=length(list_of_channels)
    if strcmp(list_of_channels(ch).title,channelname)==1
        channel=list_of_channels(ch).number;
        break;
    else
        ch=ch+1;
    end
end
return

