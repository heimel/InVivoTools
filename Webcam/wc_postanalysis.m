function record = wc_postanalysis( record, verbose )
%WC_POSTANALYSIS adds some info to measures based on earlier analysis
%
%  RECORD = WC_POSTANALYSIS( RECORD, VERBOSE)
%
%  2019, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end


logmsg(['Doing postanalysis for ' recordfilter(record)]);

if isfield(record.measures,'freezetimes') % manually analyzed
    record.measures.reliable = 1;
else
    record.measures.reliable = 1;
end

if ~isempty(strfind(record.comment,'stim didn''t run'))
    record.measures.reliable = 0;
end

if iscell(record.comment)
    record.comment = [record.comment{:}];
end
[~,p] = regexp(record.comment, 'frz|indetr');
freezing_comment = ~isempty(p);
if ~isempty(freezing_comment) && freezing_comment~= 0
    man_frzs = true;
    frz = record.comment(p-5:p);
    if strcmp(frz,'detfrz')
        man_frz_dur = 1;
    elseif strcmp(frz, 'indetr')
        man_frzs = NaN;
        man_frz_dur = NaN;
    else
        man_frz_dur = str2num(frz(1:3)); %#ok<ST2NM>
    end
else
    man_frzs = false;
    man_frz_dur = 0;
end

record.measures.freeze_duration_from_comment = man_frz_dur;
record.measures.freezing_from_comment = man_frzs;

if 1 %~isfield(record.measures,'session') || isempty(record.measures.session) || ...
   % ~isfield(record.measures,'stim_seqnr') || isempty(record.measures.stim_seqnr)
    [db,h_db] = getdb( record.datatype );
    if isempty(h_db)
        logmsg('Cannot find open wctestdb');
    end
    if isempty(db)
        logmsg('Could not open wctestdb. Not setting session and stim_seqnr info');
    end

    % getting session
    ind_mouse = find_record(db,['mouse=' record.mouse]);
    records = db(ind_mouse);
    dates = unique({records.date});
    record.measures.session =  strmatch(record.date,dates(:),'exact');

    % getting stim_seqnr
    [~,ind] = sort({records.date});
    records = records(ind);
    stim_types = {};
    for i=1:length(records)
        stim_type = strtrim(records(i).stim_type);
        switch stim_type
            case 'gray_screen'
                continue % ignoring
            case ''
                continue % ignoring
        end
        stim_type = strip_direction( stim_type);
        if isempty(strmatch(stim_type,stim_types(:),'exact'))
            stim_types{end+1} = stim_type;
        end
    end % record i
    record.measures.stim_seqnr = strmatch(strip_direction(record.stim_type),stim_types,'exact');
    if isempty(record.measures.stim_seqnr)
        switch record.stim_type
            case 'gray_screen'
                record.measures.stim_seqnr = 0;
            otherwise
                record.measures.stim_seqnr = NaN;
                logmsg(['Could not find stim_seqnr for ' record.stim_type ' in ' recordfilter(record)]);
        end
    end
end


function stim_type = strip_direction( stim_type)
directions = {'_L','_R','_left','_right','_left_106deg','_right_106deg','left','right'};
for i = 1:length(directions)
    len = length(directions{i});
    if strcmp(stim_type( max(1,(end-len+1)):end),directions{i})
        stim_type( (end-len+1):end) = [];
        break
    end
end

function [db,h_db] = getdb( datatype )
if strcmp(datatype,'fret')
    datatype = 'tp';
end
% check to see if it is open
h_db = get_fighandle([datatype ' database*']);
if isempty( h_db ) % not open, load from disk
    db = load_testdb(datatype);
else
    ud = get(h_db,'userdata');
    db = ud.db;
end

