function [Cross ] =  hdfwavecross(S, Ffilter, messg)

NOFSW = size(S, 3);
Nchan = size(S, 2);

Wtemp = zeros(size(Ffilter,1),size(Ffilter,2),Nchan);

Cross = cell(Nchan, Nchan);
for k = 1:Nchan
    for m = k : Nchan
        Cross{k,m} = zeros(size(Ffilter));
    end
end

h = waitbar(0,messg);
%sum over trials
for k = 1:NOFSW
            waitbar(k/NOFSW,h);
            for j = 1:Nchan
                Wtemp(:,:,j) = gaborspaceF(S(:,j,k),Ffilter); %fourier transform and wavelets convolution
           end
           
           for j = 1:Nchan
                for m = j : Nchan
                    Cross{j,m} = Cross{j,m} + Wtemp(:,:,j).* conj(Wtemp(:,:,m));
                end
           end
end
close(h)