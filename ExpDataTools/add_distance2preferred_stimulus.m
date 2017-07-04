function record = add_distance2preferred_stimulus( record )
%ADD_DISTANCE2PREFERRED_STIMULUS add as measures distance of cur to pref stimulus
%
% RECORD = ADD_DISTANCE2PREFERRED_STIMULUS( RECORD )
%
% 2013, Alexander Heimel
%

db = getdb( record.datatype );
curr_record_crit = recordfilter( record,db);
curr_ind = find_record(db,curr_record_crit);
if length(curr_ind)~=1
    logmsg('Could not uniquely identify current record.');
    return
end
switch record.datatype
    case {'tp','fret'}
        similar_record_crit = [ ...
            'mouse=' record.mouse ',' ...
            'date=' record.date ',' ...
            'experiment=' record.experiment ',' ...
            'reliable!0'];
        location = record.location;
        location(location==',')='*'; % otherwise find_record gets confused
        cln = find(location==':',1);
        
        if ~isempty(cln)
            similar_record_crit = [similar_record_crit ',location=' location(1,cln) '*'];
        else
            similar_record_crit = [similar_record_crit ',location=' location];
        end
        ind = setdiff(  find_record(db,similar_record_crit),curr_ind);
        
        if isempty(ind)
            logmsg(['No other reliable records matching: ' similar_record_crit]);
            return
        end
    case 'ec'
        similar_record_crit = [ ...
            'mouse=' record.mouse ',' ...
            'date=' record.date ',' ...
            'datatype=' record.datatype ',' ...
            'surface=' num2str(record.surface) ',' ...
            'depth=' num2str(record.depth) ',' ...
            'reliable!0'];
        if ~isempty(record.location)
            similar_record_crit = [similar_record_crit  ',location=' record.location ];
        end
        ind = setdiff(  find_record(db,similar_record_crit),curr_ind);
        
        if isempty(ind)
            logmsg(['No other reliable records matching: ' similar_record_crit]);
            return
        end
    otherwise
        logmsg(['Datatype ' record.datatype ' is not implemented.']);
        return
end

if isempty(record.measures)
    return % i.e. no cells 
end

stims = getstimsfile( record );
if isempty(stims)
   errormsg(['No stimulus file found for ' recordfilter(record)]);
   return
end
stimparams = getparameters(stims.saveScript);

if isempty(stimparams)
    logmsg('No stimulus parameters found.');
    return
end

% overall maximum response
if isfield(record.measures,'response_max')
    for c = 1:length(record.measures)
        record.measures(c).response_max_overall = record.measures(c).response_max;
        if ~iscell(record.measures(c).response_max_overall)
            record.measures(c).response_max_overall = {record.measures(c).response_max_overall};
        end
        for i=ind
            prevrec = db(i);
            if ~isfield(prevrec.measures,'index')
                continue
            end
            prevcell = find( [prevrec.measures.index]==record.measures(c).index,1);
            if isempty(prevcell) || ~isfield(prevrec.measures,'response_max')
                continue
            end
            prevresponse_max = prevrec.measures(prevcell).response_max;
            if ~iscell(prevresponse_max)
                prevresponse_max = {prevresponse_max};
            end
            for t=1:length(prevresponse_max)
                if t>length(record.measures(c).response_max_overall)
                    record.measures(c).response_max_overall{t} = prevresponse_max{t};
              elseif prevresponse_max{t} > record.measures(c).response_max_overall{t}
                  record.measures(c).response_max_overall{t} = prevresponse_max{t};
                end
            end
        end
    end
end


for i=ind
    prevrec = db(i);
    if isempty(prevrec.measures)
        continue
    end
    if isempty(prevrec.measures)
        continue
    end
    
    if ~isfield(prevrec.measures,'variable')
        continue
    end
    prevvariable = prevrec.measures(1).variable;
    if isfield(record.measures,'variable') && strcmp(prevvariable,record.measures(1).variable)
        continue % if current test is over same variable
    end
    if length(prevrec.measures(1).range{1})==1
        continue % i.e. not varied in prevrec
    end
    if ~isfield(record.measures,'index')
        errormsg(['Measures lacks index field. ' recordfilter(record)]);
        continue
    end
    if ~isfield(prevrec.measures,'index')
        errormsg(['Measures lacks index field. ' recordfilter(prevrec)]);
        continue
    end
    if (isfield(stimparams,prevvariable) && length(stimparams.(prevvariable))==1)...
            || strcmp(prevvariable,'position') ||( strcmp(prevvariable,'size') && isfield(stimparams,'figsize' ))
        for c = 1:length(record.measures)
            prevcell = find( [prevrec.measures.index]==record.measures(c).index,1);
            if isempty(prevcell)
                continue
            end
            for t=1:length(prevrec.measures(prevcell).preferred_stimulus)
                prefstim = prevrec.measures(prevcell).preferred_stimulus{t};
                switch prevvariable
                    case 'position'
                        if isfield(stimparams,'figcenter')
                            center = stimparams.figcenter;
                        else
                            center = [(stimparams.rect(1)+stimparams.rect(3))/2 ...
                                (stimparams.rect(2)+stimparams.rect(4))/2];
                        end
                        record.measures(c).dist2rf_center_pxl{t} =  ...
                           norm( prevrec.measures(prevcell).rf_center{t} - center);
                    case 'size'
                        if isfield(stimparams,'figsize')
                            size = norm(stimparams.figsize)/sqrt(2);
                        else
                            size = stimparams.size;
                        end
                        record.measures(c).dist2pref_size{t} =  ...
                           prevrec.measures(prevcell).preferred_stimulus{t} - size;
                        
                    case 'angle'
                        record.measures(c).dist2pref_orientation{t} = ...
                            round(abs(angle(exp(2*sqrt(-1)*(stimparams.(prevvariable)-prefstim)/180*pi))/pi*180/2));
                        record.measures(c).dist2pref_direction{t} = ...
                            round(abs(angle(exp(sqrt(-1)*(stimparams.(prevvariable)-prefstim)/180*pi))/pi*180));
                    otherwise
                        record.measures(c).(['dist2pref_' prevvariable ]){t} = stimparams.(prevvariable)-prefstim;
                end
                
            end
        end
    end
end

function db = getdb( datatype )
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
