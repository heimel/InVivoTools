function b = isstimscripttimestruct(st)
%
%  Part of the NeuralAnalysis package
%
%  B = ISSTIMSCRIPTTIMESTRUCT(ST)
%
%  Returns 1 if ST is a valid stimscripttime struct.  Returns 0 otherwise.
%
%  See also:  STIMSCRIPTTIMESCTRUCT
%
%  Note: This function only checks that the mti is a struct, not a complete
%  record.  Should be fixed.

b = 1;

if isstruct(st),
	fn = {'stimscript','mti'}; fs = {[-1 -1],[-1 -1]};
        [b,e]=hasAllFields(st,fn,fs);
	if b,
		for i=1:length(st),
			if ~isa(st(i).stimscript,'stimscript'), b=0; break; end;
			o = getDisplayOrder(st(i).stimscript);
			if ~iscell(st(i).mti), b = 0; break;
			else,
				for j=1:length(st(i).mti),
				   if ~isstruct(st(i).mti{j}),b=0;break; end;
				   if length(st(i).mti)~=length(o),b=0;break;end
				end;
				if b==0, break; end;
			end;
		end;
	end;
else, b = 0;
end;
