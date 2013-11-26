function [good,errormsg] = verifyinputs(inputs)

proceed = 1;
errormsg = '';

if proceed,
    % check that all arguments are present and appropriately sized
    fieldNames = {'spikes','st','paramname','title'};
    fieldSizes = {[1 1],[1 -1],[1 -1],[1 -1]};
    [proceed,errormsg] = hasAllFields(inputs, fieldNames, fieldSizes);
end;

if proceed,
    if ~ischar(inputs.title),
        proceed=0;errormsg='spikes not spikedata'; end;
    if ~isa(inputs.spikes,'spikedata'),
        proceed=0;errormsg='spikes not spikedata.';
    end;
    for i=1:length(inputs.st),
        if ~isstimscripttimestruct(inputs.st(i)),
            proceed=0;errormsg='st must be array of stimscripttimestructs';
            break;
        end;
    end;
    if proceed,
        for i=1:length(inputs.st),
            for j=1:length(inputs.st.stimscript),
                ps=getparameters(get(inputs.st.stimscript,1));
                if ~isfield(ps,inputs.paramname),
                    proceed=0;errormsg=['''' inputs.paramname ''' is not a field of stim.'];
                end;
            end;
        end;
    end;
end;

good = proceed;
