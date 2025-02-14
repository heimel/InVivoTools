function create_autoclassmodelfile(description,basename)
% creates autoclass c header file


filename=[basename '.model'];

n=size(description,2);

fid=fopen(filename,'w');
fprintf(fid,'; AutoClass C model file -- extension .model\n');
fprintf(fid,';; model_index <zero_based index> <# model def. lines>\n');

multinormalcn='';
singlemultinomial='';
for i=1:n
  d=description(i);
  if strcmp(d.type,'real')
    multinormalcn=[multinormalcn ' ' int2str(i-1)];
  elseif strcmp(d.type,'discrete')
     singlemultinomial=[singlemultinomial ' '   int2str(i-1)];    
  end
end

fprintf(fid,'model_index 0 3\n');
fprintf(fid,'multi_normal_cn %s\n',multinormalcn);
fprintf(fid,'single_multinomial %s\n',singlemultinomial);
fprintf(fid,'multi_normal_cn default\n');


fclose(fid);
