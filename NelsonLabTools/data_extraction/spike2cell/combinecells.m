function newcells=combinecells(cells,tetrode,cellnr1,cellnr2)
%COMBINECELLS Combines two cells from loadcells
%
%    NEWCELLS=TRANSFERCELLS(CELLS,TETRODE,CELLNR1,CELLNR2)
%
% June 2002, Alexander Heimel, heimel@brandeis.edu
  if(cellnr1==cellnr2)
    newcells=cells;
    return;
  end

  %make cellnr1 lowest number of the two
  if(cellnr1>cellnr2)
    help=cellnr2;
    cellnr2=cellnr1;
    cellnr1=help;
  end;

  n_spikes_1=size(cells(tetrode,cellnr1).spikes,3);
  n_spikes_2=size(cells(tetrode,cellnr2).spikes,3);

  cells(tetrode,cellnr1).spikes(:,:,n_spikes_1+1:n_spikes_1+n_spikes_2)=  ...
                 cells(tetrode,cellnr2).spikes;

  cells(tetrode,cellnr1).shape=  ...
     (n_spikes_1*cells(tetrode,cellnr1).shape+...
      n_spikes_2*cells(tetrode,cellnr2).shape)/(n_spikes_1+n_spikes_2);

   cells(tetrode,cellnr1).data(n_spikes_1+1:n_spikes_1+n_spikes_2)=  ...
                 cells(tetrode,cellnr2).data;

   cells(tetrode,cellnr1).data=sort(cells(tetrode,cellnr1).data);


  %now move all following cells over 1 place

  for cellnr=cellnr2:size(cells,2)-1;
    keepname=cells(tetrode,cellnr).name;
    cells(tetrode,cellnr)=cells(tetrode,cellnr+1);
    cells(tetrode,cellnr).name=keepname;
  end
  cellnumber=size(cells,2);
      cells(tetrode,cellnumber).spikes=[];
      cells(tetrode,cellnumber).shape=[];
      cells(tetrode,cellnumber).name='';
      cells(tetrode,cellnumber).intervals=[];
      cells(tetrode,cellnumber).desc_long=[];
      cells(tetrode,cellnumber).desc_brief=[];
      cells(tetrode,cellnumber).data=[];
      cells(tetrode,cellnumber).detector_params=[];

  newcells=cells;


