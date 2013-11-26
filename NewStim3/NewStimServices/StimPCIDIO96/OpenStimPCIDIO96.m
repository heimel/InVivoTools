% OPENSTIMPCIDIO96   Initializes PCIDIO96 for use with NewStim
%
%
%   OPENSTIMPCIDIO96 - Initializes PCIDIO96 for use with NewStim and reports any errors.
%  		
%       This function requires that Allen Ingling's pci_dio_toolbox is installed
%       and on the path.
% 
%       If the card is already marked as successfully initialized then nothing is done.
%  
%       If the option UseStimPCIDIO96 is 0 (see STIMPCIDIO96GLOBALS) then
%       nothing is done.
%    


StimPCIDIO96Globals;

if UseStimPCIDIO96,
	A = isempty(NSPCIDIO96);
	if ~A, B = ~NSPCIDIO96.initialized; else B = 1; end;

	if B,
		if isempty(which('FindCard'))
			error(['Cannot find functon ''FindCard'' -- is pci_dio_toolbox installed and on the path?']);
		else,  % open and initialize the port
			NSPCIDIO96.deviceNumber = FindCard(352,1:4);
			InitializeFMRI(NSPCIDIO96.deviceNumber);
			
			% set constants
			
			NSPCIDIO96.VdaqStimOutPort = 0;
			NSPCIDIO96.VdaqUserInPort = 1;
			NSPCIDIO96.VdaqUserOutAPort = 6;
			NSPCIDIO96.VdaqUserOutBPort = 7;
			NSPCIDIO96.CEDdigitalInAPort = 2;
			NSPCIDIO96.CEDdigitalInBPort = 3;
			NSPCIDIO96.CEDdigitalInCPort = 4;
			NSPCIDIO96.CEDdigitalOutAPort = 8;
			NSPCIDIO96.CEDdigitalOutBPort = 9;
			NSPCIDIO96.CEDdigitalOutCPort = 10;
			
			NSPCIDIO96.sontrigger = 8;
			NSPCIDIO96.vontrigger = 16;
			NSPCIDIO96.sandvtrigger = NSPCIDIO96.vontrigger + NSPCIDIO96.sontrigger;
			NSPCIDIO96.vofftrigger = 0;
			NSPCIDIO96.CEDeventtriggeron = 18;
			NSPCIDIO96.CEDeventtriggeroff = 0;
			NSPCIDIO96.CEDstimtrigger = 128;
			
			% initialize ports			
			inputport = 0; outputport = 1; nohandshake = 0;
			fn = fieldnames(NSPCIDIO96);
			for i=1:length(fn),
				ln = length(fn{i});
				if ln>=7,
					if strcmp(fn{i}(ln-5:ln),'InPort')|strcmp(fn{i}([ln-6:ln-5 ln-3:ln]),'InPort'),
						%disp(['In: ' fn{i} '.']);
						err=DIG_Prt_Config(NSPCIDIO96.deviceNumber,getfield(NSPCIDIO96,fn{i}),outputport,nohandshake);
						if err, error(['Error in initializing port ' fn{i} ' on PCI DIO 96 -- ' int2str(err) '.']); end;
					elseif strcmp(fn{i}(ln-6:ln),'OutPort')|strcmp(fn{i}([ln-7:ln-5 ln-3:ln]),'OutPort'),
						%disp(['Out: ' fn{i} '.']);
						err=DIG_Prt_Config(NSPCIDIO96.deviceNumber,getfield(NSPCIDIO96,fn{i}),inputport,nohandshake);
						if err, error(['Error in initializing port ' fn{i} ' on PCI DIO 96 -- ' int2str(err) '.']); end;
					end;
				end;					
			end;
			NSPCIDIO96.initialized = 1;
		end;
	end;
end;
