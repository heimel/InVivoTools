function strains=neurobsik_strains

mousedb=load_mousedb;

if 0 % only use strains in database
  bxdind=find_record(mousedb,'strain=BXD*');
  bxdstrains={mousedb(bxdind).strain};
  bxdstrains=sort(bxdstrains);
  bxdstrains=uniq(bxdstrains);
  strains={'C57Bl/6J','DBA/2J',bxdstrains{:}};
else % use all known strains
  strains={};
  fid=fopen('bxd-strain-list.txt','r');
  while ~feof(fid)
    strains{end+1}=fgetl(fid);
  end
  fclose(fid);
end

%strains={strains{1:5}}; % for testing
  

