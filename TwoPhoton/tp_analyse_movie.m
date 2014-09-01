function record = tp_analyse_movie( record )
%TP_ANALYSE_MOVIE analyses two-photon time series
%
% RECORD = TP_ANALYSE_MOVIE( RECORD )
%
% 2013, Alexander Heimel
%

switch record.datatype
    case 'tp'
        channel = 1; % assuming OGB, GCaMP on first channel
    case 'fret'
        channel = [1 2];
    otherwise
        channel = 1;
end

rois = record.ROIs.celllist([record.ROIs.celllist.present]==1);
n_rois = length(rois);
listofcells = cell(n_rois,1);
listofcellnames = cell(n_rois,1);
for i=1:length(rois)
    listofcells{i} = rois(i).pixelinds;
    listofcellnames{i}=[rois(i).type ' ' int2str(rois(i).index)];
end


if 1
    
    if ~exist(tpdatapath(record),'dir')
        errormsg(['There is no directory ' tpdatapath(record) ]);
        return
    end
    [filename,record] = tpfilename(record);
    if ~exist(filename,'file')
        errordlg([filename ' does not exist.']);
        return
    end
    
    
    [data,t] = tpreaddata(record,[-Inf Inf],listofcells,1,channel);
    
    pixelarg.data = data;
    pixelarg.listofcells = listofcells;
    pixelarg.listofcellnames = listofcellnames;
    pixelarg.t = t;
    
    trialslist = [];
    blankID = [];
    timeint = [];
    sptimeint = [];
    
    record = tptuningcurve(record,channel,[],pixelarg,0,...
        listofcellnames,trialslist,timeint,sptimeint,blankID,0,'max');
    
    disp('TP_ANALYSE_MOVIE: PSTH binsize defaulting to 1s. Should be dependent on acquisition parameters.');
    binsize = 1; % s
    record = tppsth(record,channel,[],pixelarg,0,listofcellnames,binsize,0.1,0,[]);
end


