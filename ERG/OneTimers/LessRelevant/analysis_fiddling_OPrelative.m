%Don't know what it does anymore, neither whether it still works...
colors='bgrcmyk';
for mouse = [1 8 6 12 15 5 7 9 16] for exp = 1:2
%for mouse = [1 8 6 12 15] for exp = 1:2
%for mouse = 1 for exp = 1
    i = 0;
    clear saveDf;
    for s = 1:30:300
      i = i + 1;
      D = -1*data_erg(mouse,exp).raw(s:s+29,:);
      D = D-repmat(mean(D(:,1:2000),2),[1,size(D,2)]);
      D = erg_analysis_avgpulse(D(:,2000:3000),0);
      hsr = 10000/2;
      [B1, B2] = butter(2,[60/hsr,230/hsr]);
      Df = filter(B1, B2,D);
      saveDf(i,:) = Df';
    end

    clear w v j i ;
    j = 1;
    for smpl = 1:9
      for ronde = 1
        for i = 1:1000
          a = abs(([saveDf(smpl,:) zeros(1,i)] - j*[zeros(1,i) saveDf(smpl+1,:)]));
          w(i) = sum(a);
          %figure; hold on; plot([saveDf(4,:) zeros(1,i)]); plot([zeros(1,i) saveDf(5,:)]);
        end

        [y,x] = min(w);

        i=x;
        for j = 0:0.001:2
          a = abs(([saveDf(smpl,:) zeros(1,i)] - j*[zeros(1,i) saveDf(smpl+1,:)]));
          v(round(j*1000)+1) = sum(a);
          %figure; hold on; plot([saveDf(4,:) zeros(1,i)]); plot([zeros(1,i) saveDf(5,:)]);
        end
        %figure; hold on; plot(w); plot(v);

        [y,x] = min(v);
        j = (x-1)/1000;

      end
      difI(smpl) = i;
      difJ(smpl) = j;
    end

    figure(1); hold on; plot(difI,colors(data_erg(mouse,exp).expgroup))
    figure(2); hold on; plot(difJ,colors(data_erg(mouse,exp).expgroup))
  end
end

