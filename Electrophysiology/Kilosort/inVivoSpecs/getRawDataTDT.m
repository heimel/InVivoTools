function [vecTimestamps,matData,vecChannels] = getRawDataTDT(sMetaData,vecTimeRange)
	%getRawDataTDT Extracts raw data from TDT data tank
	%	[vecTimestamps,matData,vecChannels] = getRawDataTDT(sMetaData,vecTimeRange)
	%
	%Input 1 (sMetaData) can be retrieved with getMetaDataTDT(); it also
	%			requires two fields you can change yourself:
	%			- sMetaData.CHAN: vector of channels to retrieve
	%			- sMetaData.Myevent: string of which data type (e.g., dRAW)
	%			
	%Input 2 (vecTimeRange) is optional and specifies which time range you
	%			wish to retrieve the data for: [start-time stop-time]
	%			Note that this retrieval is border-inclusive (e.g., if
	%			start-time is 0, it will include samples with time stamp 0)
	%
	%Output 1 (vecTimeStamps) supplies the sample-time per data point in
	%			the raw data matrix (output 2)
	%Output 2 (matData) contains data in a [channel x time-point] format (int16)
	%Output 3 (vecChannels) contains channel indices
	%
	%Data can be accessed wrt trials using sMetaData.Trials
	%
	%Version History:
	%2019-02-01 Created TDT data retrieval function, based on Chris van der
	%			Togt's Exd4() function. This function returns the full
	%			continuous trace (or a subset specified by vecTimeRange)
	%			rather than trial epochs like Exd4() [by Jorrit Montijn]    
	
	%% check for optional arguments
	%#ok<*SPERR>
	% Get raw, env or lfp data
	if ~isfield(sMetaData,'Myevent') || isempty(sMetaData.Myevent),sMetaData.Myevent = 'dRAW';end
	
	%% initialize
	%define which event to use
	strEvCode = sMetaData.Myevent;
	intEvType = find(strcmpi(strEvCode, {sMetaData.strms(:).name} ));
	if isempty(intEvType)
		error([mfilename ':WrongEventType'],sprintf('Requested event %s is not a valid data stream type',strEvCode));
	end
	
	%load libraries
	ptrFig = figure('visible','off');
	ptrLib = actxcontrol('TTANK.X',[0 0 20 20],ptrFig);
	ptrLib.ConnectServer('local', 'me');
	
	%check if data tank exists
	if 0 == ptrLib.OpenTank(sMetaData.Mytank, 'R')
		ptrLib.CloseTank;
		ptrLib.ReleaseServer;
		error([mfilename ':TankMissing'],sprintf('Data tank %s does not exist',sMetaData.Mytank)); 
	end
	
	%select block and create epochs
	ptrLib.SelectBlock(sMetaData.Myblock);
	ptrLib.CreateEpocIndexing;
	
	%retrieve meta data
	dblSampFreq = sMetaData.strms(intEvType).sampf; %sample frequency for this event
	intEventLength = sMetaData.strms(intEvType).size; %number of samples in each epoch
	dblEventDur = intEventLength/dblSampFreq; %timespan of one event epoch plus one for safety
	vecEventTimestamps = (0:(intEventLength-1))./dblSampFreq;
	intNumChans = sMetaData.strms(intEvType).channels; %channels in block
	dblApproxEventNumPerSec = intNumChans*dblSampFreq/intEventLength; %#ok<NASGU> %more event epochs than needed
	%retrieve time range of entire stream if none is supplied
	if ~exist('vecTimeRange','var') || isempty(vecTimeRange)
		vecTimeRange = sMetaData.strms(intEvType).timerange; %start and stop time of recording
	end
	
	%check channels
	if isfield(sMetaData, 'CHAN') && length(sMetaData.CHAN) <= intNumChans
		vecChannels = sMetaData.CHAN;  %SELECTED CHANNELS
	else
		vecChannels = 1:intNumChans;
	end
	intChannelNum = numel(vecChannels);
	
	%% pre-allocate data array
	dblTotDur = vecTimeRange(2)-vecTimeRange(1);
	dblMaxT = dblSampFreq*(dblTotDur+1); %add one second, just to be sure
	intTotalBins = round(dblMaxT*1.1); %upper estimate of required number of frames
	matData = zeros(intChannelNum,intTotalBins,'int16');
	vecTimestamps = nan(1,intTotalBins);
	dblApproxTotEvents = intTotalBins/intEventLength;
	vecEventStartTracker = nan(1,round(1.1*dblApproxTotEvents));
	
	%% run stream loop to extract trace
	boolAtEndOfStream = false;
	dblReadSizeSecs = 1;
	dblCurSecs = vecTimeRange(1);
	intTimeBin = 0;
	while ~boolAtEndOfStream
		%check if we're beyond the requested time range
		if dblCurSecs > vecTimeRange(2)
			boolAtEndOfStream = true; %#ok<NASGU>
			break;
		end
		
		%increment counter
		dblCurSecs = dblCurSecs + dblReadSizeSecs;
		
		%define current epoch
		dblStartT = dblCurSecs-dblReadSizeSecs-dblEventDur; %retrieve somewhat more to be sure
		dblStopT = dblCurSecs+dblEventDur; %retrieve somewhat more to be sure
		
		%retrieve events and check if we're at the end of the stream
		intEvNum = ptrLib.ReadEventsV(100000, strEvCode, 0, 0,dblStartT, dblStopT, 'ALL');
		if isnan(intEvNum) || intEvNum == 0 %check if we're at the end of the stream
			boolAtEndOfStream = true; %#ok<NASGU>
			break;
		end
		
		%retrieve data
		vecChanIdx = ptrLib.ParseEvInfoV(0, intEvNum, 4);      %channel number corresponding to event epoch
		vecEvStartSecs = ptrLib.ParseEvInfoV(0, intEvNum, 6);
		matEvData = ptrLib.ParseEvV(0, intEvNum);   %event epoch data [samples (time) x event epoch (listed above)]
		
		%remove data that has already been used
		indRemove = ismember(vecEvStartSecs,vecEventStartTracker);
		vecEvStartSecs(indRemove) = [];
		matEvData(:,indRemove) = [];
		intFirstNan = find(isnan(vecEventStartTracker),1);
		
		%get unique starts and assign to tracker
		vecUniqueStarts = unique(vecEvStartSecs);
		vecEventStartTracker(intFirstNan:(intFirstNan+numel(vecUniqueStarts)-1)) = vecUniqueStarts;
		
		%loop through events
		for intEvent=1:numel(vecUniqueStarts)
			%get start seconds
			dblStartSecs = vecUniqueStarts(intEvent);
			indThisEventBins = vecEvStartSecs==dblStartSecs;
			matThisData = matEvData(:,indThisEventBins);
            %built in conversion to be compatible with int16-storage
            %(adaptation for invivotools by Leonie)
            matThisData = matThisData.*10^6;
			vecThisChanIdx = vecChanIdx(indThisEventBins);
			indRetrieveChans = ismember(vecThisChanIdx,vecChannels);
			indAssignChans = ismember(vecChannels,vecThisChanIdx);
			
			%select channels
			matThisData(:,vecChannels(indAssignChans)) = matThisData(:,vecThisChanIdx(indRetrieveChans));
			
			%get timestamps
			intThisBinNum = size(matThisData,1);
			vecAssignBins = (intTimeBin + (1:intThisBinNum));
			intTimeBin = intTimeBin + intThisBinNum;
			vecTimestamps(vecAssignBins) = vecEventTimestamps+dblStartSecs;
		
			%check if matrix is empty
			if any(matData(1,vecAssignBins) ~=0)
				error([mfilename ':AssignmentError'],'Timestamp error! Time bins are already filled in output data structure');
			end
			
			%assign to aggregate matrix
			matData(:,vecAssignBins) = matThisData';
		end
	end
	
	%remove pre-allocated end
	intFirstNan = find(isnan(vecTimestamps),1);
	vecTimestamps(intFirstNan:end) = [];
	matData(:,intFirstNan:end) = [];
	
	%remove samples outside requested epoch
	indRemoveSamples = vecTimestamps < vecTimeRange(1) | vecTimestamps > vecTimeRange(2);
	vecTimestamps(indRemoveSamples) = [];
	matData(:,indRemoveSamples) = [];
	
	%% close libraries
	ptrLib.CloseTank;
	ptrLib.ReleaseServer;
	close(ptrFig);

