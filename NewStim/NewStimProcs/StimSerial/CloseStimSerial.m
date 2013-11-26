StimSerialGlobals

if ~isempty(StimSerialScript)&~isempty(StimSerialStim),
	if StimSerialScript==StimSerialStim,
		stimserial('close',StimSerialScript);
		StimSerialScript=[];StimSerialStim=[];
	end;
end;

if ~isempty(StimSerialScript),
	stimserial('close',StimSerialScript); 
    StimSerialScript=[];
end;

if ~isempty(StimSerialStim),
    stimserial('close',StimSerialStim); 
    StimSerialStim=[];
end;
