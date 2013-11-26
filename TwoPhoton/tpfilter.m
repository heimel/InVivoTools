function [newdata,meandata]=tpfilter(data, timepoints)

% TPFILTER - Filter two-photon data with high-pass filter
%
%  [NEWDATA,MEANDATA] = TPFILTER(DATA, TIMEPOINTS)
%
% NEWDATA is a filtered version of DATA; the data are passed
% through a high-pass filter with a 240s cut-off time.
% The mean is then added back to the data.
%
% This function assumes that TIMEPOINTS are (roughly) evenly spaced.
%

meandata = nanmean(data);

SR = 1./nanmean(diff(timepoints));
HSR = SR * 0.5; % half sample rate

W = (1/240) / (SR * 0.5);

%[b,a] = cheby1(4,0.8,W,'high');

load myfiltervalues.mat

newdata = myfiltfilt(b,a,data) + meandata;

