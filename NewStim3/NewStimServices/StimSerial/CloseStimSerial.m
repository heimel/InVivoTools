StimSerialGlobals

if StimSerialSerialPort,

	if ~isempty(StimSerialScript)&~isempty(StimSerialStim),
		if StimSerialScript==StimSerialStim,
			StimSerial('close',StimSerialScript);
			StimSerialScript=[];StimSerialStim=[];
		end;
	end;

	if ~isempty(StimSerialScript),
		StimSerial('close',StimSerialScript); StimSerialScript=[];
	end;

	if ~isempty(StimSerialStim),
	    StimSerial('close',StimSerialStim); StimSerialStim=[];
	end;

end;
