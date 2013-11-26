function A = cksmultipleunit(intervals,desc_long,desc_brief, ...
				data,detector_params);

%  CKSMULTOBJ = CKSMULTIPLEUNIT(INTERVALS,DESC_LONG,DESC_BRIEF, ...
%                                     DATA,DETECTOR_PARAMS);
%
%  Creates a new object for reading multiple unit data in the CKS format.  Here,
%  multiple unit data refers to a single-channel neural recording where one or
%  more neurons is being heard and these units cannot be (or are not)
%  distinguished.  The CKSMULTIPLEUNIT object is a child of the SPIKEDATA
%  object, which itself is a child of the MEASUREDDATA object.  INTERVALS,
%  DESC_LONG, and DESC_BRIEF are the same as for any MEASUREDDATA object.
%  See 'help measureddata' for more information on these parameters.
%  DATA contains spike times for the spikes, and DETECTOR_PARAMS is a user
%  field for storing any parameters used to detect these spikes from raw data.
%

   sd = spikedata(intervals, desc_long, desc_brief);

   g = struct('data',data,'detector_params',detector_params);

   A = class(g,'cksmultipleunit',sd);

