function record = compute_odi_measures( record, db)
%COMPUTE_ODI_MEASURES finds matching tests for other eyes and compute ODIs
%
%  RECORD = COMPUTE_ODI_MEASURES( RECORD, DB)
%
% 2012-2015, Alexander Heimel

comment = record.comment;

switch record.datatype
    case {'ec','lfp'}
        filter_base = ['mouse=' record.mouse ',date=' record.date ...
            ',surface=' num2str(record.surface) ',depth=' num2str(record.depth) ...
            ',hemisphere=' record.hemisphere ',stim_type=' record.stim_type ...
            ',comment=' comment  ...
            ',datatype=' record.datatype ];
    case 'tp'
        location = record.location;
        location(location==',')='*';
        filter_base = ['mouse=' record.mouse ',date=' record.date ...
            ',experiment=' record.experiment ',ref_epoch=' record.ref_epoch ...
            ',hemisphere=' record.hemisphere ',stim_type=' record.stim_type ...
            ',location=' location  ];
        
    otherwise
        logmsg(['OD analysis not implemented for datatype ' record.datatype]);
        return
end        

[ipsi_measures,ipsi_tests] = average_measures( db, [ filter_base ',eye=*ipsi*'] );

if strcmpi(record.eye,'ipsi')
    logmsg(['Filter is ' filter_base]);
end

if isempty(ipsi_measures) 
    if strcmpi(record.eye,'ipsi')
        logmsg('No *reliable* ipsi eye records. Check whether hemisphere,surface,depth,stim_type and reliable are set. Only taking records with identical comments.');
    end
    return
end

[contra_measures,contra_tests] = average_measures( db, [ filter_base ',eye=*contra*'] );
if isempty(contra_measures)  && strcmpi(record.eye,'ipsi')
    logmsg(['Filter is ' filter_base]);
    logmsg('No *reliable* contra eye records. Check whether hemisphere,surface,depth,stim_type and reliable are set. Only taking records with identical comments up to first comma.');
    return
end

if length(contra_measures)~=length(ipsi_measures)
    errormsg(['COMPUTE_ODI_MEASURES: Not recorded an equal number of cells for ipsi and contra records. Filter is ' filter_base]);
    return
end

% ODI = (contra - ipsi)/(contra + ipsi)
%odi = get_odi_measures( contra_measures, ipsi_measures );

if isfield(record.measures,'response')
    for i=1:length(record.measures)
        record.measures(i).odi_tests = sort([contra_tests ipsi_tests]);
        if ~isfield(contra_measures,'response')
            errormsg('No response field for contra test. Please re-evaluate contra test.');
            return
        end

         if ~isfield(ipsi_measures,'response')
            errormsg('No response field for ipsi test. Please re-evaluate ipsi test.');
            return
         end
       
        if isfield(contra_measures,'rate')
            record.measures(i).odi_rate_based =  compute_odi( contra_measures(i).rate,ipsi_measures(i).rate);
        end
        record.measures(i).odi_response_based =  compute_odi( contra_measures(i).response,ipsi_measures(i).response);
        record.measures(i).odi =  record.measures(i).odi_response_based;
        record.measures(i).computed_odi = 1;

        % odi of rate/response difference
        if isfield(contra_measures,'rate_difference') && isfield(ipsi_measures,'rate_difference')
            record.measures(i).odi_rate_difference =  compute_odi( contra_measures(i).rate_difference,ipsi_measures(i).rate_difference);
        else
            record.measures(i).odi_rate_difference =  cellfun(@(y) y*nan,record.measures(i).odi,'uniformoutput',false);
        end
        if isfield(contra_measures,'response_difference') && isfield(ipsi_measures,'response_difference')
            record.measures(i).odi_response_difference =  compute_odi( contra_measures(i).rate_difference,ipsi_measures(i).response_difference);
        else
            record.measures(i).odi_response_difference =  cellfun(@(y) y*nan,record.measures(i).odi,'uniformoutput',false);
        end
        if isfield(contra_measures,'rate_spont')
            record.measures(i).rate_spont_binoc_mean = num2cell(mean([contra_measures(i).rate_spont{:};ipsi_measures(i).rate_spont{:}]));
            record.measures(i).rate_spont_binoc_rel_diff = ...
                num2cell(abs([contra_measures(i).rate_spont{:}]-[ipsi_measures(i).rate_spont{:}]) ./ ...
                [record.measures(i).rate_spont_binoc_mean{:}]);
        end
        if isfield(contra_measures,'rate_max')
            record.measures(i).rate_max_binoc = num2cell(max([contra_measures(i).rate_max{:};ipsi_measures(i).rate_max{:}]));
            record.measures(i).rate_max_contra = num2cell(mean([contra_measures(i).rate_max{:}],1));
            record.measures(i).rate_max_ipsi = num2cell(mean([ipsi_measures(i).rate_max{:}],1));
        end
        record.measures(i).response_max_binoc = num2cell(max([contra_measures(i).response_max{:};ipsi_measures(i).response_max{:}]));

        if isfield(ipsi_measures,'rate_max_normalized')
            record.measures(i).rate_max_normalized_ipsi = num2cell(mean([ipsi_measures(i).rate_max_normalized{:}],1));
        end
        if isfield(contra_measures,'rate_max_normalized')
            record.measures(i).rate_max_normalized_binoc = num2cell(max([contra_measures(i).rate_max_normalized{:};ipsi_measures(i).rate_max_normalized{:}]));
            record.measures(i).rate_max_normalized_contra = num2cell(mean([contra_measures(i).rate_max_normalized{:}],1));
            record.measures(i).response_max_normalized_binoc = num2cell(max([contra_measures(i).response_max_normalized{:};ipsi_measures(i).response_max_normalized{:}]));
        end
        
    end
end


function odi = compute_odi( contra, ipsi)
try
    for t=1:length(contra)
        co = thresholdlinear(contra{t});
        ip = thresholdlinear(ipsi{t});
        odi{t} = (co-ip)./(co+ip);
    end
catch
    odi = [];
end

function [meanmeasures,tests] = average_measures( db, filtercrit )
% get measures from all trials and perform an average
ind = find_record(db,filtercrit);

if isfield(db,'test')
   testfield = 'test';
else
    testfield = 'epoch';
end
    
tests = {db(ind).(testfield)};


if isempty(ind)
    meanmeasures = [];
    return
end

meanmeasures = db(ind(1)).measures;
if isempty(meanmeasures)
    logmsg(['Record  ' recordfilter(db(ind(1))) ' should be analysed first.']);
    return
end


flds = fieldnames(meanmeasures);
for c=1:length(meanmeasures) % cell
    for f=1:length(flds) % field
        field = flds{f};
        if strcmp(field(1:min(end,4)),'odi_')
            continue
        end
        try
            if isnumeric(meanmeasures(c).(field))
                count = 1;
                for t=2:length(ind)
                    measures = db(ind(t)).measures;
                    if length(measures)~=length(meanmeasures)
                        errormsg(['Not an equal number of cells in all records. Filter is ' filtercrit]);
                        meanmeasures = [];
                        return
                    end
                    if isfield(measures(c),field)
                        meanmeasures(c).(field) = meanmeasures(c).(field) + measures(c).(field);
                        count = count+1;
                    end
                end % trial t
                meanmeasures(c).(field) = meanmeasures(c).(field) /  count;
            elseif iscell(meanmeasures(c).(field))
                for trig = 1:length(meanmeasures(c).(field))
                    count = 1;
                    for t=2:length(ind)
                        measures = db(ind(t)).measures;
                        if length(measures)~=length(meanmeasures)
                            errormsg(['Not an equal number of cells in all records. Filter is ' filtercrit]);
                            meanmeasures = [];
                            return
                        end
                        if isfield(measures(c),field)
                            meanmeasures(c).(field){trig} = meanmeasures(c).(field){trig} + measures(c).(field){trig};
                            count = count+1;
                        end
                    end % trial t
                    meanmeasures(c).(field){trig} = meanmeasures(c).(field){trig} / count;
                end
            end
        end
    end % field f
end % cell c


