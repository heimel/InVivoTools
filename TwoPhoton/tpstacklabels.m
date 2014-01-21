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
    case '12.81'
        labels = {'L1','L2/3','GFP','VIP','PV','Syt2','SOM','CR','VGLUT2'};
    case '11.12'
        labels = {'CFP','YFP'};
    case {'12.76','12.76_GCaMP6','13.29'}
        labels = {'','CCK','CR','SST','PV','VIP','Astrocyte'};
    case {'13.29'}
        labels ={'','CR','Tom'}
    otherwise
        labels = {'GFP','RFP'};
end

