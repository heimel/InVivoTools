function show_ancestry( mouse, n_gen )
%SHOW_ANCESTRY shows ancestors of mouse from Mice.mdb
%

if nargin<2
  n_gen=2;
end

ancestry=ancestryfrommdb(mouse,n_gen);

mpos=get(0,'MonitorPositions');

figure;


height=100*n_gen;
width=2^n_gen*100;

set(gcf,'Position',[ceil((mpos(3)-width)/2) ceil((mpos(4)-height)/2) width height]);


plot_nuclearfamily(0.5,0.5/2,0.1,1/(n_gen+1),ancestry);
axis off

return



function plot_nuclearfamily(x,dx,y,h,mice)
txt1=[];
txt2='';
txt3='';
txt4='';
if ~iscell(mice)
  if isstruct(mice)
    mice={mice};
  else
    txt1=mice;
  end
else
  if iscell(mice)
    plot_nuclearfamily(x-dx,dx/2,y+h,h,mice{2})
    plot_nuclearfamily(x+dx,dx/2,y+h,h,mice{3})
  end
end
if isempty(txt1)
  txt1=num2str(mice{1}.Muisnummer);
  txt2=[mice{1}.Transgene ': ' mice{1}.Typing_Transgene ];
  txt3=[mice{1}.KOdKI ': ' mice{1}.Typing_KOdKI ];
  txt4=[mice{1}.Cre ': ' mice{1}.Typing_Cre ];
end
text(x,y,txt1,'HorizontalAlignment','Center');
text(x,y-h/5,txt2,'HorizontalAlignment','Center');
text(x,y-2*h/5,txt3,'HorizontalAlignment','Center');
text(x,y-3*h/5,txt4,'HorizontalAlignment','Center');
