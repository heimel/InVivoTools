function nrc = setparameters(rc, parameters)

%  Part of the NeuralAnalysis package
%
%  NEWRCOBJ = SETPARAMETERS(REVERSE_CORROBJ, PARAMETERS)
%
%  Sets PARAMETERS for the REVERSE_CORR object REVERSE_CORROBJ.  It will return
%  an error if the parameters are not in the proper form.  See
%  'help reverse_corr' for information on the parameters.
%
%  See also:  REVERSE_CORR

I = getinputs(rc);
p = getparameters(I.stimtime(1).stim);
if isfield(p,'value') && ~isfield(p,'values')
    p.values=p.value;
end
bg = 1;
try
    for i=1:length(p.values),
        if eqlen(p.BG,p.values(1,:)),
            bg = i;
            break
        end
    end
catch
    bg = 1;
end

feamean = sum(repmat(p.dist,1,3).*p.values,1)/sum(p.dist);
%flatten feature mean and sem, only works for gray levels
feamean = mean(feamean);


default_p = struct(...
    'interval',[0.000 0.080],...
    'timeres',0.040,...
    'showrast',1,...
    'show1drev',1,...
    'normalize',0,...
    'chanview',0,...
    'colorbar',1,...
    'clickbehav',0,...
    'pseudoscreen',p.rect,...
    'datatoview',[1 1],...
    'showdata',1,...
    'show1drevprs',[ 1 0.001 -0.050 +0.050 0],...
    'bgcolor',bg,...
    'feature',0,...
    'gain',1,...
    'immean',128,...
    'feamean',feamean,...
    'crcpixel',-1,...
    'crctimeres',0.001,...
    'crcproj',[(255/2)*[1 1 1];[1 1 1]/(3*255/2)],...
    'crccalcint',[-0.5 0.5],'crctimeint',[-1 1]);

default_p.crcproj(1,:) = feamean;

rc.RCparams = default_p;
if ~isempty(parameters) && isstruct(parameters)
    flds = fieldnames(parameters);
    for i=1:length(flds)
        rc.RCparams.(flds{i}) = parameters.(flds{i});
    end
end

configuremenu(rc);
rc = compute(rc); 
draw(rc);
nrc = rc;
