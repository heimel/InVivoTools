function [newac,status] = setupextract(ac,theex1,nameref,cksds,instruc);

%  [NEWAC,STATUS]=SETUPEXTRACT(AC,NAMEREF,THECKSDIRSTRUCT,INSTRUC)
%
%  Perform setup for extraction operation on the data described by NAMEREF in
%  the directorys associated with THECKSDIRSTRUCT according to the instructions
%  given in INSTRUC.
%
%  INSTRUC has the following fields:
%     extractincompletedir (0 or 1)      : 1 means will attempt to extract data
%                                        :   from directory where data is still
%                                        :   coming in
%
%  STATUS is one of -1 (error), 0 (no error but not operation not complete)
%  1 (operation complete).
%
%  See also:  CKSDIRSTRUCT, INSTRUC

status = 0;

  p = getscratchdirectory(cksds,1);
  % needs to be fixed
  scratchin = [p 'ME_' nameref.name '_' sprintf('%.4d',nameref.ref) ...
	'_master'];
  scratchout = [p 'AC_' nameref.name '_' sprintf('%.4d',nameref.ref) ];

  try,
    g = load(scratchin,'-mat');
  catch,
    status = 0; return;
  end;

  % should have data loaded now, now call clustering routines
  csp = g.csp; thecov = g.thecov; spikeloc = g.spikeloc;
  cspn = normalize_data(g.csp,g.thecov,g.normalize);

% get features
% CHANNELS NEEDS TO BE READ FROM SOMEWHERE!!
  channels=4;

[features,description]=feature_extraction(csp,ac.ACparams,4); 


%start to cluster
hwarn=warndlg('Clustering started. This may take several minutes.','Warning');
drawnow;

classes=run_autoclass(features,description,scratchout,ac.ACparams);
if ishandle(hwarn), delete(hwarn); end;

maxclass=max(classes(:,1));

for class=1:maxclass
  waveform(:,class)=mean( csp(:, find( classes(:,1)==class & classes(:,2)>=ac.ACparams.minprob)),2) ;
end

display(['Not sure about clustering ' num2str(length( find( classes(:,2)<ac.ACparams.minprob))) ...
	 ' out of ' num2str(size(csp,2))  ' waveforms.']);

save([scratchout '_master'],'csp','cspn','spikeloc','thecov',....
          'classes','maxclass','waveform','-mat');

save([scratchout '_waveforms.asc'],'waveform','-ascii');

disp(['Did Setting up for 2nd extracting ' nameref.name ':' int2str(nameref.ref) '.']);


rwf=reshape(waveform, size(waveform,1)/channels,channels,size(waveform,2));
plothandles=slideplot(rwf,6,4,...
		      [1 size(waveform,1)/channels -2 2]);

rcsp=reshape(csp,size(csp,1)/channels,channels,size(csp,2));
for r=1:maxclass
  for c=1:channels
    axes(plothandles(r,c));
    hold on;
    plot( squeeze(rcsp(:,c,find( classes(:,1)==r & classes(:,2)>=ac.ACparams.minprob))),'c');
    plot(rwf(:,c,r),'k');
    hold off;
  end
end



status=1;
newac = ac;
