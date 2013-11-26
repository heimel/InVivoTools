function plotcells(cells)
%PLOTCELLS Plot shapes and spikes for a cell for each channel

% first plot shapes together with spikes

n_spikes_to_show=10;

figure;


n_tetrodes=size(cells,1);
n_cells_per_tetrode=size(cells,2);
spikewindow=size(cells(1,1).shape,1);

for tet=1:n_tetrodes
  height=0;
  for cl=1:n_cells_per_tetrode
    nheight=max(max(cells(tet,cl).shape));
    if(nheight>height)
      height=nheight;
    end
  end

  for cl=1:n_cells_per_tetrode
     if ~isempty(cells(tet,cl).shape)
       subplot(n_tetrodes,n_cells_per_tetrode*2,...
           n_cells_per_tetrode*2*(tet-1)+cl*2);
       hold on
       cells(tet,cl).name(find(cells(tet,cl).name=='_'))='-';
       title(cells(tet,cl).name,'fontsize',8)

       for ch=1:size(cells(tet,1).shape,2)
         n_spikes=size(cells(tet,cl).spikes,3);
         plot(squeeze(cells(tet,cl).spikes(:,ch,ceil(linspace(1,n_spikes,n_spikes_to_show))))+4*height*ch,'g')
       end
       for ch=1:size(cells(tet,1).shape,2)
         plot(cells(tet,cl).shape(:,ch)+4*height*ch,'r')
       end
	 xlabel([num2str(n_spikes) ' spikes'],'fontsize',8)
       ax=axis;
       ax=[1 spikewindow  0 5*size(cells(tet,1).shape,2)*height];
       axis(ax);
       
     end
  end
end


%now plot shapes only
%figure;

for tet=1:n_tetrodes
     height=0;bottom=0;
  for cl=1:n_cells_per_tetrode
    nheight=max(max(cells(tet,cl).shape));
    nbottom=min(min(cells(tet,cl).shape));
    if(nheight>height)
      height=nheight;
    end
    if(nbottom<bottom)
      bottom=nbottom;
    end

  end

  for cl=1:n_cells_per_tetrode
     if ~isempty(cells(tet,cl).shape)
       subplot(n_tetrodes,n_cells_per_tetrode*2,...
        n_cells_per_tetrode*2*(tet-1)+cl*2-1);
       hold on
       cells(tet,cl).name(find(cells(tet,cl).name=='_'))='-';
       title(cells(tet,cl).name,'fontsize',8)
       plot(cells(tet,cl).shape(:,:))
       ax=axis;
       ax=[1 spikewindow  1.2*bottom 1.2*height];
       axis(ax);
       
     end
  end
end


%print trial number
h1 = uicontrol('Parent',gcf, ...
	'Units','points', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',8, ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[1 1 60 20], ...
	'String',['Trial ' num2str(cells(1,1).trial)], ...
	'Style','text');


