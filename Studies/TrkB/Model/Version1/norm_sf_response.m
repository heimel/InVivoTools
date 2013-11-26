function [acuity,max_response,response_midsf ]=norm_sf_response(sigma,n,k)

if nargin<3
  k=0.1;
end
if nargin<2
  sigma=0.5;
end
if nargin<1
  n=2;
end

contrast=(0.2:0.2:1);

[r,sf]=sf_response(0.3);

a=0.5
r=k^a*r; % depending on a the max_response will grow or decrease depending on k


rg=k*sf_groupresponse(0.3);

for c=1:length(contrast)
  nr(c,:)=contrast(c)*r;
  % gain modulation dependent on SF
  nr(c,:)=( nr(c,:)./ sqrt( sigma^2 + contrast(c) ^2*rg.^2) ).^n;
  
  
  % gain modulation independent of SF
  %nr(c,:)=( nr(c,:)./ sqrt( sigma^2 + contrast(c) ^2) ).^n;

  [maxnr,ind_max]=max(nr(c,:));
  [rc(c),offset(c)]=fit_thresholdlinear(sf(ind_max:end),nr(c,ind_max:end));
  cutoff(c)=-offset(c)/rc(c);
end


figure
hold on
h=plot(sf,nr,'k');
set(h,'LineWidth',2);
if 0 % plot sf_cutoff
  for i=1:length(rc)
    h=plot(sf,sf*rc(i)+offset(i),'k');
  end
end

acuity=cutoff(end);
max_response=max(nr(end,:)); % at high contrast
ind=find(sf>0.2,1);
response_midsf=nr(end,ind);

disp(['High contrast acuity: ' num2str(acuity,2) ])
disp(['High contrast max response: ' num2str(max_response,2) ]);
disp(['High contrast sf=0.2 cpd response: ' num2str(response_midsf,2) ]);

