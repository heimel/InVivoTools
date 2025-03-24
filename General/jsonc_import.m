function config = jsonc_import(jsonc_file)

        fid = fopen(jsonc_file, 'r');
        txt = fread(fid, '*char')';
        fclose(fid);
        %get rid of comments in the template jsonc file
        txt = regexprep(txt, '//[^\n]*' , '');
        config = jsondecode(txt); % convert to data structure