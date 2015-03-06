function [data, t] = tpreaddata(records, intervals, pixelinds, mode, channels, options, verbose)
% TPREADDATA - Reads twophon data
%
%  [DATA, T] = TPREADDATA(RECORDS, INTERVALS, PIXELINDS, MODE, CHANNELS, OPT, VERBOSE)
%
%  Reads two photon data blocks.  TPREADDATA
%  allows the user to request data in specific time intervals
%  and at specific locations in the image.
%
%  RECORDS contain experiment info. check HELP TP_ORGANIZATION
%  INTERVALS is a matrix specifying time intervals to read,
%     each row specifies a time interval:
%     e.g., INTERVALS = [ 4 5 ; 6 7] indicates to read data
%     between 4 and 5 seconds and also between 6 and 7 seconds
%     time 0 is relative to the beginning of the scans in the
%     first record
%  PIXELINDS is a cell list specifying pixel indices to read
%     from the images.  Each entry should contain the
%     pixel indices for a given region.
%  MODE is the data mode.  It can be the following:
%     0 : Individidual pixel values are returned.
%     1 : Mean data and time for each frame is returned.
%     2 : Values for each pixel index are returned, and if
%            there are no values for that pixel then NaN
%            is returned at those indices.
%     3 : Mean value of each pixel is returned; no
%            individual frame data is recorded.  Any frames
%            w/o data or w/ NaN are excluded.  Time points
%            will be equal to the mean time recorded as well.
%     10: Individidual pixel values are returned, including
%           frames that only have partial data (i.e., when
%           scan is traversing the points to be read at the
%           beginning or end of an interval).
%     11: Mean data and time for each frame is returned,
%           including frames that have partial data.
%           (Note that this could mean that different numbers
%           of pixels are averaged during each frame.)
%     21: Mean data of all responses over all time intervals
%           is returned.
%
%  CHANNELS is the channel number to be read, from 1 to 2.
%  if there is one channel than tpreaddata_singlechannel will 
%  be called, if there are two channels then tpreaddata_single-
%  channel will be called twice (for ratiometric calcium imaging).
% 
%  OPT imaging processing options
%
%  VERBOSE
% 
%  DATA is an MxN cell list, where M is the number of time
%  intervals and N is the number of pixel regions specified.
%  T is also an MxN cell list that contains the exact sample
%  times of each point in DATA.
%
%  If there is a file in the directory called 'driftcorrect',
%  then it is loaded and the corrections are applied.
%  (See TPDRIFTCHECK.)
%
%  Tested:  only tested for T-series records, not other types
%
% 200X-200X Steve Hooser, Danielle van Versendaal.
% 200X-2015 Alexander Heimel

params = tpprocessparams( records(1) ); 


if nargin<7
    verbose = [];
end
if isempty(verbose)
    verbose = true;
end
if nargin<6
    options = [];
end
if nargin<5
    channels = [];
end
if isempty(channels)
    channels = params.response_channel;
end

switch length(channels)
    case 1 % single channel
        [data,t] = tpreaddata_singlechannel(records, intervals, pixelinds, mode, channels, options, verbose);
    case 2 % ratiometric
        [data_enum,t] = tpreaddata_singlechannel(records, intervals, pixelinds, mode, channels(1), options, verbose );
        [data_denom,t] = tpreaddata_singlechannel(records, intervals, pixelinds, mode, channels(2), options, verbose );
        for i = 1:numel(data_enum)
            if any(data_denom{i}==0)
                logmsg('Measurement on denominator channel contains 0 value');
            end
            data{i} = (data_enum{i})./(data_denom{i});
        end
        data = reshape(data,size(data_enum));
    otherwise
        logmsg('Expects only one or two channels.')
end


        
        
        