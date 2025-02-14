function resp=make_resp_from_output(co)

resp.struct = 0;

fn = fieldnames(co);
for i=1:length(fn),
    val = getfield(co,fn{i});
    if iscell(val),
        val_ = val{1};

        b=1;
        if iscell(val_)&isa(val_{1},'analysis_generic'), b = 0; end;
        if isa(val{1},'analysis_generic'), b = 0; end;
        if b,
            resp = setfield(resp,fn{i},getfield(co,fn{i}));
        end;
    elseif isa(val,'analysis_generic'),
    else, resp = setfield(resp,fn{i},getfield(co,fn{i}));
    end;
    if strcmp(fn{i},'rast'), % add values
        co2 = getoutput(val);
        dt = mean(co2.bins{1});
        ind = {};
        for j=1:length(co2.values),
            ind{j} = sum(co2.values{j})'/dt;
        end;
        resp = setfield(resp,'ind',ind);
    end;    
end;

