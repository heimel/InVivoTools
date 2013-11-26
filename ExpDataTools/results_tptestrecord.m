function results_tptestrecord( record )
%RESULTS_TPTESTRECORD returns an overview with image data
%
%RESULTS_TPTESTRECORD ( RECORD )
%
% 2008-2013, Alexander Heimel & Danielle van Versendaal
%

% inf = tpreadconfig( record );
% if isempty(inf)
%     errordlg('No image information found.','Results');
%     disp('RESULTS_TPTESTRECORD: No image information found.');
%     return;
% end
%
% if isfield(inf,'third_axis_name') && ~isempty(inf.third_axis_name) && lower(inf.third_axis_name(1))=='z'
%     zstack = true;
% else
%     zstack = false;
% end
% 

global measures

inf = tpreadconfig( record );
if isfield(inf,'third_axis_name') && strcmpi(inf.third_axis_name,'T') ...
        || ( isfield(record,'measures') && isfield(record.measures,'curve')) 
    results_ectestrecord( record )
else
    try
        tp_show_intensities(record);
    end
    if isfield(record,'measures')
        measures = record.measures;
    else
        measures = [];
    end
    if isempty(measures)
        disp('RESULTS_TPTESTRECORD: Measures is empty.');
        return
    end
    table_measures = measures;
    % remove all nan and all zero, and series fields
    flds = fields( table_measures );
    for field = flds'
        if iscell(table_measures(1).(field{1}))
           table_measures = rmfield(table_measures,field{1});
        elseif all(isnan( [table_measures.(field{1})] ))
           table_measures = rmfield(table_measures,field{1});
       elseif ~(any( [table_measures.(field{1})] ))
           table_measures = rmfield(table_measures,field{1});
       elseif ~isempty(strfind(field{1},'series'))
           table_measures = rmfield(table_measures,field{1});
       end           
    end
    
    % remove all series fields
    
    
    show_table( table_measures );
        
    evalin('base','global measures');
    disp('RESULTS_TPTESTRECORD: Measures available in workspace as ''measures''.');
end