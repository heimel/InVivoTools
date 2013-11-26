function index = cellfind( needle, haystack  )
  index = -1;
  for i = 1:length(haystack)
    if strcmp(needle,haystack{i}) 
      index = i;
      return;
    end
  end
  