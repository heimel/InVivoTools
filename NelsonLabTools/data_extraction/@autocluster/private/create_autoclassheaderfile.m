function create_autoclassheaderfile(description,dataname)
% creates autoclass c header file

filename=[dataname '.hd2'];

n=size(description,2);

fid=fopen(filename,'w');
fprintf(fid,'; AutoClass C header file -- extension .hd2\n');
fprintf(fid,'; num_db2_format_defs <num of def lines -- min 1, max 4>\n');
fprintf(fid,'num_db2_format_defs 2\n');
fprintf(fid,'number_of_attributes %d\n',n);
fprintf(fid,'separator_char  %c,%c\n',39,39);
fprintf(fid,';; <zero-based att#>  <att_type>  <att_sub_type> ');
fprintf(fid,' <att_description>  <att_param_pairs>\n');

for i=1:n
  d=description(i);
  fprintf(fid,'%d %s %s %s %s\n',d.index-1,d.type,d.subtype,...
  d.description,d.parameter);
end


fclose(fid)
