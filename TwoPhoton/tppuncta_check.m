function tppuncta_check( result )


figure;
t = 1;
s = 1;
ch = 1;


present =result.puncta_per_stack{s}(:,t)>0;
for ch = 1:2
    intensities(:,ch) = result.puncta_per_stack_intensities{s,ch}(:,t);
end
h = plot(intensities(present,1),intensities(present,2),'g.')
set(h,'ButtonDownFcn',@buttondownfcn)
hold on
not_present = find(result.puncta_per_stack{s}(:,t)==0);
h = plot(intensities(not_present,1),intensities(not_present,2),'r.')
set(h,'ButtonDownFcn',@buttondownfcn)
xlabel('Channel 1')
ylabel('Channel 2')
ud.intensities = intensities;
set(gcf,'userdata',ud);

set(gca,'ButtonDownFcn',@buttondownfcn)

function buttondownfcn(obj,event_obj)
obj
event_obj
%p = get(gca,'position')
p=get(gca,'currentpoint')
r = [p(1,1) p(1,2)];
ud = get(gcf,'userdata');
d = sum((ud.intensities-repmat(r,size(ud.intensities,1),1)).^2,2)
[~,ind] = min(d);

disp(['ROI ' num2str(ind) ': intensities = ' mat2str(ud.intensities(ind,:),2)]);



