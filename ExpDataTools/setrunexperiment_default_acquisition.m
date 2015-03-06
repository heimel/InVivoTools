function setrunexperiment_default_acquisition( h ,record)
%SETRUNEXPERIMENT_DEFAULT_ACQUISITION creates default runexperiment acquisition record
%
% 2010-2014, Alexander Heimel
%

switch record.datatype
	case {'lfp','ec'}
		set(h,'String',{'ctx : single_EC : ctx : NaN : 1 : 1 : NaN '});
		set(h,'UserData',(struct('name','ctx','type','single_EC','fname','ctx',...
			'samp_dt',NaN,'reps',1','ref',1,'ECGain',NaN)));
	case 'tp' % two-photon
		set(h,'String',{'ctx : two_photon : ctx : NaN : 1 : 1 : NaN '});
		set(h,'UserData',(struct('name','ctx','type','two_photon','fname','ctx',...
			'samp_dt',NaN,'reps',1','ref',1,'ECGain',NaN)));
	case 'wc' % two-photon
		set(h,'String',{'behavior : wc : behavior : NaN : 1 : 1 : NaN '});
		set(h,'UserData',(struct('name','behavior','type','wc','fname','behavior',...
			'samp_dt',NaN,'reps',1','ref',1,'ECGain',NaN)));
	otherwise
		% do nothing
end