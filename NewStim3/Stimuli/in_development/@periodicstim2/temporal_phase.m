function tphase = temporal_phase(PSstim)

% TEMPORAL_PHASE - Return temporal phase steps of a periodicstim
%
%   TPHASE = TEMPORAL_PHASE(PSSTIM)
%
%  Returns the temporal phase steps for a complete run of the
%  PERIODICSTIM PSSTIM.  Each phase step is between 0 and 2*pi.
%  The number of phase steps is identical to the number of
%  data frames of the PERIODICSTIM.
%
%  See also: PERIODICSTIM, PERIODICSTIM/LOADSTIM
%


PSparams = PSstim.PSparams;

tphase = [];

StimWindowGlobals;

if isfield(PSparams,'loops'), loops = PSparams.loops; else, loops = 0; end;

loopdir = 1;
while loops>=0, % calculate the temporal phase of each frame to be shown
        if loopdir>0,
                approx_times = 0:1/StimWindowRefresh:(PSparams.nCycles/PSparams.tFrequency-1/StimWindowRefresh);
                temporal_phase = 2*pi*PSparams.tFrequency*mod(approx_times,1/PSparams.tFrequency);
                tphase = [tphase temporal_phase];
        else,
                approx_times = (PSparams.nCycles/PSparams.tFrequency-1/StimWindowRefresh):-1/StimWindowRefresh:0;
                temporal_phase = 2*pi*PSparams.tFrequency*mod(approx_times,1/PSparams.tFrequency);
                tphase = [tphase temporal_phase];
        end;
        loops = loops - 1;
        loopdir = loopdir * -1;
end;

