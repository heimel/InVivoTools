function labels = tpstacklabels( record )
if nargin<1
    labels = {'OGB','SR101','Rhodamine','GFP'};
    return
end

switch record.experiment
    case {'08.33','10.14','10.38'}
        labels = {'OGB','M65V'};
    case '10.24'
        labels = {'GFP','RFP','lostspine',};
    case '11.21'
        labels = {'L1','L2/3','L4','L5/6','RFP','GFP','VIP','RLN','PV','Syt2','SOM','CR','CB','VGAT','VGLUT2'};
    case {'12.81','14.25','99.99'}
        labels = {'CR','GFP','L1','L2/3','PV','RLN','Syt2','SOM','VGLUT2','VIP'};
    case '14.26' 
        labels = {'GFP','L1','L2/3'};
        if ~isempty(strfind(lower(record.stack),'vip'))
            labels{end+1} = 'VIP';
        end
        if ~isempty(strfind(lower(record.stack),'som'))
            labels{end+1} = 'SOM';
        end
       if  ~isempty(strfind(lower(record.stack),'syt2'))
            labels{end+1} = 'Syt2';
       end
        if ~isempty(strfind(lower(record.stack),'rln')) || ~isempty(strfind(lower(record.stack),'rnl'))
            labels{end+1} = 'RLN';
        end
        if ~isempty(strfind(lower(record.stack),'vgat'))
            labels{end+1} = 'VGAT';
        end
        if ~isempty(strfind(lower(record.stack),'vvip')) ...
                || ~isempty(strfind(lower(record.stack),'vsom'))...
                || ~isempty(strfind(lower(record.stack),'vsyt2')) ...
                || ~isempty(strfind(lower(record.stack),'vrln')) ...
                || ~isempty(strfind(lower(record.stack),'vrnl'))
            labels{end+1} = 'VGLUT2';
        end
    case {'12.81 mariangela'}
        labels = {'GFP','L1','L2/3'};
        if ~isempty(strfind(lower(record.stack),'reelin'))
            labels{end+1} = 'RLN';
        end
        if ~isempty(strfind(lower(record.stack),'syt2'))
            labels{end+1} = 'Syt2';
        end
        if ~isempty(strfind(lower(record.stack),'sst'))
            labels{end+1} = 'SOM';
        end
        if ~isempty(strfind(lower(record.stack),'vglut2'))
            labels{end+1} = 'VGLUT2';
        end
        if ~isempty(strfind(lower(record.stack),'vip'))
            labels{end+1} = 'VIP';
        end
    case '11.12'
        labels = {'CFP','YFP'};
    case {'12.76','12.76_GCaMP6'}
        labels = {'','CR','CCK','SST','PV','VIP','Astrocyte'};
    case {'13.29'}
        labels = {'','CR','Tom','Nogcamp'};
    case {'14.87'}
        labels = {'','CR','Tom','YFP'};
    case {'14.90'}
        labels = {'','SOM'};
    otherwise
        labels = {'GFP','RFP','DRD1','Gad2'};
end

if isfield(record,'comment')
    if ~isempty(strfind(lower(record.comment),'satb2'))
        labels{end+1} = 'Satb2';
    end
    if ~isempty(strfind(lower(record.comment),'smi32'))
        labels{end+1} = 'SMI32';
    end
end


