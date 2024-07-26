function create_autoclassparamsfile(ext,basename,parameters)
% copies the default.ext file to file dataname.ext in current dir
% 
% implemented parameters: 
%   s-params: max_duration, max_n_tries, n_save, n_data, rel_delta_range, force_new_search_p
%   r-params: -
%
% Jan 2002, Alexander Heimel

%remove dot if present
if ext(1)=='.'
  ext=ext(2:size(ext,2));
end


defaultfile=which([ 'default.' ext]);
if isempty(defaultfile)
  error(['Cannot find default.' ext '. Please find and put in path.'])
end

copyfile(defaultfile,[basename '.' ext]);


fid=fopen([basename '.' ext],'a');

if ext=='s-params' 
  if ~isnan(parameters.max_duration) 
    fprintf(fid,'max_duration = %d\n',parameters.max_duration);
  end
  if ~isnan(parameters.max_n_tries) 
    fprintf(fid,'max_n_tries = %d\n',parameters.max_n_tries);
  end
  if ~isnan(parameters.n_save) 
    fprintf(fid,'n_save = %d\n',parameters.n_save);
  end
  if ~isnan(parameters.n_data) 
    fprintf(fid,'n_data = %d\n',parameters.n_data);
  end
  if ~isnan(parameters.rel_delta_range) 
    fprintf(fid,'rel_delta_range = %f\n',parameters.rel_delta_range);
  end
  if ~isnan(parameters.force_new_search_p) 
    fprintf(fid,'force_new_search_p = %s\n',parameters.force_new_search_p);
  end  
end

if ext=='r-params'
end

fclose(fid);
