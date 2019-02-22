function extract_profile
%EXTRACT_PROFILE
% 
%  Gets fluoresence intensity profiles for Vangeneugden et al.
%
% 2018, Alexander Heimel

slices = {'ignace3','louise','ovide4','raoul0','ulyssee5','walter0',...
    'NatComm_Mouse_01_plate2_slice09_small_flip','NatComm_Mouse_02_plate5_slice09_small_flip'};

for i = 1:length(slices)
   [intensity{i},x_mm{i}] = allenatlas(slices{i});
   x_mm{i} = -x_mm{i}; % swap to match figure direction
end

figure;
hold on
for i = 1:length(intensity)
    plot(x_mm{i},intensity{i})
end
xlabel('Distance V1 border (mm)');
ylabel('Normalized fluorescence');
ylim([0 1.1]);
xlim([-2 2]);
smaller_font(-10);
axis square
saveas(gcf,'fluorescence_profiles','epsc');

for i = 1:length(intensity)
    ind = find(x_mm{i}>-2 & x_mm{i}<2);
    mx_mm(i,:) = x_mm{i}(ind);
    mintensity(i,:) = intensity{i}(ind);
end

figure
hold on
area(mx_mm(1,:),mean(mintensity,1)+std(mintensity,1),'FaceColor',[0.7 0.7 0.7],'LineStyle','none');
area(mx_mm(1,:),mean(mintensity,1)-std(mintensity,1),'FaceColor','white','LineStyle','none');
plot(mx_mm(1,:),mean(mintensity,1),'k-','LineWidth',3);
plot([0 0],[0 1.1],':k');
ylim([0 1.1]);
xlim([-2 2]);
plot(xlim,[0 0],'k-')
xlabel('Distance V1 border (mm)');
ylabel('Normalized fluorescence');
smaller_font(-10);
axis square
saveas(gcf,'fluorescence_profiles_mean_std','epsc');


