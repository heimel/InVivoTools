while ~done
    stimuli = randperm(8);
    %     1lefta1s1
    %     2lefta1s0
    %     3lefta0s1
    %     4lefta0s0
    %     5righta1s1
    %     6righta1s0
    %     7righta0s1
    %     8righta0s0
    done = 1;
    for i = 1:length(stimuli) - 1
        if stimuli(i) == 1
            if stimuli(i + 1) == 7 || stimuli(i + 1) == 8
                done = 0;
            end
            
            
        elseif stimuli(i) == 2
            if stimuli(i + 1) == 3 || stimuli(i + 1) == 4 || stimuli(i + 1) == 7 || stimuli(i + 1) == 8
                done = 0;
            end
            
        elseif stimuli(i) == 3
            if stimuli(i + 1) == 3 || stimuli(i + 1) == 4
                done = 0;
            end
            
        elseif stimuli(i) == 4
            if stimuli(i + 1) == 3 || stimuli(i + 1) == 4 || stimuli(i + 1) == 7 || stimuli(i + 1) == 8
                done = 0;
            end
            
        elseif stimuli(i) == 5
            if stimuli(i + 1) == 3 || stimuli(i + 1) == 4
                done = 0;
            end
        elseif stimuli(i) == 6
            if stimuli(i + 1) == 3 || stimuli(i + 1) == 4 || stimuli(i + 1) == 7 || stimuli(i + 1) == 8
                done = 0;
            end
        elseif stimuli(i) == 7
            if stimuli(i + 1) == 7 || stimuli(i + 1) == 8
                done = 0;
            end
        elseif stimuli(i) == 8
            if stimuli(i + 1) == 3 || stimuli(i + 1) == 4 || stimuli(i + 1) == 7 || stimuli(i + 1) == 8
                done = 0;
            end
        end
    end
end
display(stimuli);
