function ret=shuffle_similar(todo,leftover,shuffled,maxdif)
%if length(todo)<30
%  disp([num2str(length(todo)) ' togo']);
%end
global start_clock
global max_shuffletime

ret=[];

if isempty(todo)
  %disp(['Done: ' mat2str(shuffled) ]);
  %disp([' in ' num2str(etime(clock, start_clock)) 's.']);
  ret=shuffled;
  return
end

if  etime(clock, start_clock)>max_shuffletime % time's up
  %disp('fail');
  ret=nan;
  return
end

doing=todo(1);
ind_similar=find( (leftover>=doing-maxdif) & (leftover<=doing+maxdif) & leftover~=doing,2); % try maximally 2 branches
for i=ind_similar
  ret=shuffle_similar(todo(2:end),[leftover(1:i-1) leftover(i+1:end)]  ,[shuffled leftover(i)],maxdif);
  if ~isempty(ret)
    break;
  end
end

return
    

%if ~isempty(ind_similar)
%  if length(todo)<100
%    i=ind_similar(ceil(rand(1)*length(ind_similar)));
%    shuffle_similar(todo(2:end),[leftover(1:i-1) leftover(i+1:end)]  ,[shuffled leftover(i)],maxdif);
%  else
%    for i=ind_similar(1:min(2:end))
%      shuffle_similar(todo(2:end),[leftover(1:i-1) leftover(i+1:end)]  ,[shuffled leftover(i)],maxdif);
%    end
%  end
%end

%if ~isempty(ind_similar)
%  if length(ind_similar)==1
%    i=ind_similar;
%    shuffle_similar(todo(2:end),[leftover(1:i-1) leftover(i+1:end)]  ,[shuffled leftover(i)],maxdif);
%  else
%    i=ind_similar(ceil(rand(1)*length(ind_similar));
%  end
%end


