function setrunexperiment_default_acquisition( h )
%SETRUNEXPERIMENT_DEFAULT_ACQUISITION creates default runexperiment acquisition record
%
% 2010, Alexander Heimel
%

switch host
	case {'nori001','nin380','daneel','antigua'}% ephys
		set(h,'String',{'ctx : single_EC : ctx : NaN : 1 : 1 : NaN '});
		set(h,'UserData',(struct('name','ctx','type','single_EC','fname','ctx',...
			'samp_dt',NaN,'reps',1','ref',1,'ECGain',NaN)));
	case {'olympus-0603301','wall-e','nin343'} % two-photon
		set(h,'String',{'ctx : two_photon : ctx : NaN : 1 : 1 : NaN '});
		set(h,'UserData',(struct('name','ctx','type','two_photon','fname','ctx',...
			'samp_dt',NaN,'reps',1','ref',1,'ECGain',NaN)));
		
	otherwise
		% do nothing
end