function mouserecord=get_allmeasures(mouserecord,testdb);
%GET_ALLMEASURES get alle values for a mouse from database

if nargin<2
  testdb=load_testdb;
end

verbose=0;

%%

measures(1)=struct('stim_type','od','measure','iodi','eye','');
measures(end+1)=struct('stim_type','od','measure','iodi','eye','');
measures(end+1)=struct('stim_type','od','measure','cbi','eye','');
measures(end+1)=struct('stim_type','od','measure','contra','eye','');
measures(end+1)=struct('stim_type','od','measure','ipsi','eye','');
measures(end+1)=struct('stim_type','retinotopy','measure','screen_center_ml','eye','');
measures(end+1)=struct('stim_type','retinotopy','measure','screen_center_ml_b2l','eye','');
measures(end+1)=struct('stim_type','retinotopy','measure','screen_center_ap','eye','');
measures(end+1)=struct('stim_type','retinotopy','measure','screen_center_ap_b2l','eye','');
measures(end+1)=struct('stim_type','sf','measure','sf_cutoff','eye','contra');
measures(end+1)=struct('stim_type','sf','measure','max_response','eye','contra');


%%
for i=1:length(measures)
  [r,sem,mousenames,age]=...
    get_results([],measures(i).stim_type,measures(i).measure,measures(i).eye,...
    verbose,mouserecord,testdb);
  if isempty(r)
    r=nan;
  end
  if isempty(sem)
    sem=nan;
  end
  if ~isnan(r) && isempty(age)
    disp('unknown age for test');
    mouserecord
  end
  if isempty(age)
    age=nan;
  end

  fieldname=[measures(i).stim_type '_' measures(i).measure];

  mouserecord.(fieldname)=r;
  mouserecord.([fieldname '_sem'])=sem;
  mouserecord=setfield(mouserecord,[fieldname '_age'],age);
end
              