function ncoherence_vec = coherence_exp(coherence_one_vec,n_repetitions,plot_fig);
%%
%Coherence from 0 (incoherent) to 1 (coherent)
if n_repetitions == 1
    tmp = coherence_one_vec;
    ncoherence_vec = [tmp,tmp((end-1):-1:1)];
else
    ncoherence_vec = [];
    for i = 1:n_repetitions
        if i < n_repetitions
            tmp = coherence_one_vec;
            ncoherence_vec = [ncoherence_vec,tmp,tmp((end-1):-1:2)];
            clear tmp;
        else
            tmp = coherence_one_vec;
            ncoherence_vec = [ncoherence_vec,tmp,tmp((end-1):-1:1)];
            clear tmp;
        end
    end
end
if plot_fig == 1
    plot(ncoherence_vec);
end
return;