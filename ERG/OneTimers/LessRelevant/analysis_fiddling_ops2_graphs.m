%Don't know what it does anymore, neither whether it still works...
A = all_fmax(:,:,1)'; hold on; plot(mean(A(:,1:10),2),'r'); 
A = all_fmax(:,:,3)'; hold on; plot(mean(A(:,11:18),2),'g'); 

%%
  
  stims = data_erg(1,1).stims;
  data_erg(15,2).expgroup = 1;
  for group = [1 2 3 4 5]
%    A = mean(permute(mean((data_erg2_f110([data_erg(:,2).expgroup]==group,:,:)),2),[1,3,2]),1)
%    B = mean(permute(mean((data_erg2_f75([data_erg(:,2).expgroup]==group,:,:)),2),[1,3,2]),1)
%    C = mean(permute(mean((data_erg2_fpow([data_erg(:,2).expgroup]==group,:,:)),2),[1,3,2]),1)
%    plot(A./C,colors(group)); plot(B./C,[colors(group) ':']);
    A = permute(mean((data_erg2_f110([data_erg(:,2).expgroup]==group,:,:)),2),[1,3,2])./permute(mean((data_erg2_fpow([data_erg(:,2).expgroup]==group,:,:)),2),[1,3,2]);
    B = permute(mean((data_erg2_f75([data_erg(:,2).expgroup]==group,:,:)),2),[1,3,2])./permute(mean((data_erg2_fpow([data_erg(:,2).expgroup]==group,:,:)),2),[1,3,2]);
    C = permute(mean((data_erg2_fmax([data_erg(:,2).expgroup]==group,:,:)),2),[1,3,2]);
    D = permute(mean((data_erg2_fpow([data_erg(:,2).expgroup]==group,:,:)),2),[1,3,2]);
    figure; hold on;
%    errorbar(log(stims),mean(D,1),std(D,1),std(D,1),colors(group));
    
    errorbar(log(stims),mean(A,1),std(A,1),std(A,1),colors(group));
    errorbar(log(stims),mean(B,1),std(B,1),std(B,1),[colors(group) ':']);

    %errorbar(log(stims),mean(C,1),std(C,1),std(C,1),[colors(group) ':']);
    title(group);
    %plot(mean(A,D,colors(group)); plot(B,[colors(group) ':']);
  end  

%%
%Plot all from 1 group from 1 measure
stimulus = 10;
clf; A = {data_erg([data_erg(:,2).expgroup]==1,1).avgs}; for i = 1:length(A); B = A{i}; plot(B(stimulus,2000:4000)); hold on; end;

%%
%
figure;
stimulus = 6;
totsamples = size(D);
hsr = 10000/2;
[B1, B2] = butter(5,[65/hsr,300/hsr]);
clf; A = {data_erg([data_erg(:,2).expgroup]==5,1).avgs}; for i = 1:length(A); B = A{i}; plot(filter(B1,B2,B(stimulus,2000:4000))); hold on; end;
 A = {data_erg([data_erg(:,2).expgroup]==1,1).avgs}; for i = 1:length(A); B = A{i}; plot(B(stimulus,2000:4000),'r:'); hold on; end;
