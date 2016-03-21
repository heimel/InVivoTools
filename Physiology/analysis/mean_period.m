function [base,stim,post]=mean_period(analysed,analysed_br)

for i = 1:numel(analysed)
    base.avg(i)    = analysed(i).baselinemean;
    base.avg_br(i) = analysed_br(i).baselinemean_br;
    
    stim.avg(i)    = analysed(i).mean_tot;
    stim.avg_br(i) = analysed_br(i).mean_tot_br;
    
    post.avg(i)    = analysed(i).mean_tot_post;
    post.avg_br(i) = analysed_br(i).mean_tot_post_br;
    
end

end