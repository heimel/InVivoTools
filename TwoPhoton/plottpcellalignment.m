function plottpcellalignment(cellnames1, cellnames2,changes1,changes2,pvimg1,pvimg2,dirname1,dirname2,drift1,drift2,rowsperpage);

if strcmp(computer,'PCWIN') | strcmp(computer,'PCWIN64')
  maxcolors = 256;
else
  maxcolors = 1000;
end;

pvimg1 = rescale(pvimg1,[min(min(pvimg1)) max(max(pvimg1))],[0 maxcolors]);
pvimg2 = rescale(pvimg2,[min(min(pvimg2)) max(max(pvimg2))],[0 maxcolors]);

for i=1:length(changes1),
	if mod(i,rowsperpage)==1, figure; ctr = 1; end;
	subplot(rowsperpage,2,ctr);
	image(pvimg1); hold on; plot(changes1{i}.xi-drift1(1),changes1{i}.yi-drift1(2),'b-');
	ctrloc = [mean(changes1{i}.xi)-drift1(1) mean(changes1{i}.yi)-drift1(2)];
	axis([ctrloc(1)-100 ctrloc(1)+100 ctrloc(2)-100 ctrloc(2)+100]);
	title([cellnames1{i} ' ' dirname1],'interp','none');
	subplot(rowsperpage,2,ctr+1);
	image(pvimg2); hold on; plot(changes2{i}.xi-drift2(1),changes2{i}.yi-drift2(2),'b-');
	ctrloc = [mean(changes2{i}.xi)-drift2(1) mean(changes2{i}.yi)-drift2(2)];
	axis([ctrloc(1)-100 ctrloc(1)+100 ctrloc(2)-100 ctrloc(2)+100]);
	title([cellnames2{i} ' ' dirname2],'interp','none');
	ctr = ctr+2;
	colormap(gray(maxcolors));
end;
