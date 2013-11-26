function data = loaddata(date,trial,rep,n_tetrodes,n_channels_per_tetrode)
%LOADDATA loads tetrode data 
%  
% DATA = LOADDATA(DATE,TRIAL,REP,N_TETRODES,N_CHANNELS_PER_TETRODE)
%
% Alexander Heimel, heimel@brandeis.edu
  
pathname=['/home/data/' date '/'];
if ~isempty(trial)
  pathname=[pathname 't' num2str(trial,'%05d') '/']
end

slot=1;

for tet=1:n_tetrodes
  for ch=1:n_channels_per_tetrode
     filename=[pathname 'r' num2str(rep,'%03d') '_tet' num2str(tet,'%2d') ...
        '_c' num2str(ch,'%02d')]
 
     data(:,slot)=loadIgor(filename);
		   slot=slot+1;
  end
end
