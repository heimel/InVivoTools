function tcn = compute(tc)
% Part of the NeuralAnalysis package
%
%    TCN = COMPUTE(MY_TUNING_CURVE)
%
%  Performs computations for the TUNING_CURVE object MY_TUNING_CURVE and returns
%  a new object.
%
%  See also:  ANALYSIS_GENERIC/compute, TUNING_CURVE
%
% Steve Van Hooser, modified by Alexander Heimel
%

p = getparameters(tc);
I = getinputs(tc);

if isfield(I,'selection')
    selection = I.selection;
else
    selection = '';
end

curve_x = [];
curve_y = [];
interval = [];
cinterval = [];
pst=0;
pre=0;
for i=1:length(I.st) % implementation of this loop seems defunct, AH
    o = getDisplayOrder(I.st(i).stimscript);

    % select stimuli
    stim_pars = cellfun(@getparameters,get(I.st(i).stimscript));
    ind = find_record( stim_pars,selection);
    if isempty(ind)
        errordlg(['No stimuli matching criterion ' selection],'Tuning_curve/compute'); 
        disp(['TUNING_CURVE/COMPUTE: No stimuli matching criterion: ' selection]);
        tcn = tc;
        return
    end
        
    s=1;
    interval = zeros(length(ind),2); % assume length(I.st)==1
    cinterval = zeros(length(ind),2);  
    for j=ind(:)'
        ps = getparameters(get(I.st(i).stimscript,j));
        curve_x(s) = ps.(I.paramname);
        condnames{s} = [I.paramname '=' num2str(curve_x(s))];
        stimlist = find(o==j);
        for k=1:length(stimlist),
            trigs{s}(k)=I.st(i).mti{stimlist(k)}.frameTimes(1);
            spon{1}(stimlist(k))=trigs{s}(k);
        end
        
        df = mean(diff(I.st(1).mti{1}.frameTimes));
        dp = struct(getdisplayprefs(get(I.st(1).stimscript,j)));
        Cinterval(s,:) = ...
            [0 I.st(1).mti{stimlist(1)}.frameTimes(end)-I.st(1).mti{stimlist(1)}.frameTimes(1)+df];
        if length(I.st(1).mti)>=2,
            if dp.BGpretime>0
                pre=pre+1;
                interval(s,:) = [ Cinterval(s,1)-dp.BGpretime Cinterval(s,2)];
            elseif dp.BGposttime>0 
                pst = pst + 1;
                interval(s,:) = [ Cinterval(s,1) Cinterval(s,2)+dp.BGposttime];
            else
                interval(s,:) = Cinterval(s,:);
            end;
        else % if only one stim, really shouldn't happen
            spontlabel='raw activity';
            interval(s,:) = Cinterval(s,:);
        end;
        s = s + 1;
    end % j
end % i


sint = [ min(interval(:,1)) max(interval(:,2)) ];
if pre==0 && pst>0,  %BGposttime used
    spontlabel='stimulus / spontaneous';
    scint = [ max(Cinterval(:,2)) max(interval(:,2))];
elseif pst==0 && pre>0,  % BGpretime used
    spontlabel='spontaneous / stimulus';
    scint = [ min(interval(:,1)) min(Cinterval(:,1)) ];
    processparams = ecprocessparams;
    if (scint(2)-scint(1)) >= (processparams.take_bgpretime_from_offset+0.5)
        scint(1)=scint(1)+processparams.take_bgpretime_from_offset;
    end
else
    spontlabel='trials';
    scint = sint;
end

switch p.int_meth
    case 0
        cinterval = [Cinterval(:,1)+p.interval(1) Cinterval(:,2)-p.interval(2)];
    case 1
        cinterval = [Cinterval(:,1)+p.interval(1) Cinterval(:,1)+p.interval(2)];
end

[curve_x,inds]=sort(curve_x); 
trigs={trigs{inds}}; 
spontval = [];
inp.condnames = {condnames{inds}}; 
inp.spikes = I.spikes; 
inp.triggers=trigs;
RAparams.res = p.res; 
RAparams.interval=interval; 
RAparams.cinterval=cinterval;
RAparams.axessameheight = 1;
RAparams.showcbars=1; 
RAparams.fracpsth=0.5; 
RAparams.normpsth=1; 
RAparams.showvar=0;
RAparams.psthmode = 0; 
RAparams.showfrac = 1; 
tc.internals.rast = raster(inp,RAparams,[]);
if ~isempty(scint)
    RAparams.cinterval=scint;
    RAparams.interval=sint;
    inp.triggers=spon;
    inp.condnames = {spontlabel};
    tc.internals.spont=raster(inp,RAparams,[]);
    sc = getoutput(tc.internals.spont);
    spontval = [mean(sc.ncounts') mean(sc.ctdev')];
else
    tc.internals.spont = [];
end;

c = getoutput(tc.internals.rast);
curve_y=c.ncounts';curve_var=c.ctdev';
if isfield(c,'stderr')
    curve_err=c.stderr';
else
    disp('TUNING_CURVE/COMPUTE: Temporary adding stderr field');
    curve_err=nan * curve_var;
end
curve = [curve_x; curve_y; curve_var; curve_err];




% take mean over remaining varied parameters
uniqx = uniq(sort(curve(1,:)));
newcurve = nan(4,length(uniqx));
for i = 1:length(uniqx)
    ind = find(curve(1,:)==uniqx(i));
    newcurve(1,i) = uniqx(i);
    newcurve(2,i) = mean(curve(2,ind));
    newcurve(3,i) = std(curve(2,ind))+ sqrt(sum(curve(3,ind).^2)/length(ind));
    n = ((curve(3,ind)+0.00000001)./(curve(4,ind)+0.00000001)).^2;
    newn = sum(n);
    newcurve(4,i) = newcurve(3,i) / sqrt(newn);
end
curve = newcurve;

% find maxes and mins
% [dummy,maxes] = max(curve_y); maxes = curve_x(maxes);
% [dummy,mins] = min(curve_y); mins = curve_x(mins);
[dummy,maxes] = max(curve(2,:));  %#ok<ASGLU>
maxes = curve(1,maxes);
[dummy,mins] = min(curve(2,:));  %#ok<ASGLU>
mins = curve(1,mins);


tc.computations=struct('curve',curve,'maxes',maxes,'mins',mins,...
    'spont',spontval,'spontrast',tc.internals.spont,...
    'rast',tc.internals.rast);
tcn = tc;