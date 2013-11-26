function classes=run_autoclass(features,description,basename,parameters)
%RUN_AUTOCLASS runs features through autoclass cluster program
%
%    CLASSES=RUN_AUTOCLASS(FEATURES,DESCRIPTION,BASENAME)
%     and returns list of assignments to clusters 
%     as   CLASSES(SPIKENUMBER,:)=(CLASS1,PROB1,CLASS2,PROB2,...PROB5)
%     assignments ordered by likelihood. CLASS# start at 1 (unlike autocluster).
%
%    Jan 2002, Alexander Heimel

autoclass=which('autocluster');
autoclass=[autoclass(1:end-13) 'private/autoclass'];

if(exist([basename '.log'],'file'))
     delete([basename '.log']);
end
if(exist([basename '.case-data-1'],'file'))
   delete([basename '.case-data-1']);
end
if(exist([basename '.class-data-1'],'file'))
   delete([basename '.class-data-1']);
end
if(exist([basename '.influ-o-data-1'],'file'))
   delete([basename '.influ-o-data-1']);
end
if(exist([basename '.results-bin'],'file'))
   delete([basename '.results-bin']);
end

create_autoclassparamsfile('s-params',basename,parameters);
create_autoclassparamsfile('r-params',basename,parameters);

create_autoclassheaderfile(description,basename);
create_autoclassmodelfile(description,basename);
create_autoclassdatafile(features,basename);

display('Starting cluster engine. This may take several minutes...');

[s,w]=unix([autoclass ' -search ' ...
        basename '.db-bin '...
	basename '.hd2 ' basename '.model ' basename '.s-params'])

classes=results_autoclass(autoclass,basename);
