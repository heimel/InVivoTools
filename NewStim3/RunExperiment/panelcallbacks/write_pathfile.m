function write_pathfile(filename, datapath)

fid = fopen(filename,'wt');
fprintf(fid,'pathSpec\n%s\n',datapath);
fclose(fid);
