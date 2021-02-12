function record = ec_analyse_xos( record )
%EC_ANALYSE_XOS compute some specific cross orientation suppression measures
%
%  RECORD = EC_ANALYSE_XOS( RECORD )
%
%
% 2021, Alexander Heimel
%


measures = record.measures;


for i=1:length(measures)
    m = measures(i);
    if strcmp(m.variable,'stimnumber')~=1
        logmsg(['Record ' recordfilter(record) ' does not have cross orientation data']);
        return
    end
    
    n_triggers = length(m.rate);
    for t = 1:n_triggers
        measures(i).xos_index{t} = 1 - max(m.response{t}([2 3]))/m.response{t}(4);
        measures(i).xos_linearity{t} = m.response{t}(4) / (m.response{t}(2) + m.response{t}(3));
    end % t
end % measure i

record.measures = measures;