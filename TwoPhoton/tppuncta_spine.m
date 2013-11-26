function tppuncta_spine( result )
%TPPUNCTA_SPINE shows the relationship between spines and puncta
%
% 2010, Alexander Heimel
%

ch_rfp = 2;
for s = 1:result.n_stacks
keyboard
    
    result.puncta_per_stack_intensities{s,ch_rfp}
end

keyboard

