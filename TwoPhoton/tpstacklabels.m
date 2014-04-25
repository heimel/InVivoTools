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
    case {'12.81','14.25','14.26','99.99'}
        labels = {'CR','GFP','L1','L2/3','PV','RLN','Syt2','SOM','VGLUT2','VIP'};
    case {'12.81 mariangela'}
        labels = {'GFP','L1','L2/3','RLN','Syt2','SOM','VGLUT2','VIP'};
    case '11.12'
        labels = {'CFP','YFP'};
    case {'12.76','12.76_GCaMP6'}
        labels = {'','CR','CCK','SST','PV','VIP','Astrocyte'};
    case {'13.29'}
        labels = {'','CR','Tom'};
    otherwise
        labels = {'GFP','RFP'};
end

if ~isempty(strfind(lower(record.comment),'satb2'))
    labels{end+1} = 'Satb2';
end
if ~isempty(strfind(lower(record.comment),'smi32'))
    labels{end+1} = 'SMI32';
end




