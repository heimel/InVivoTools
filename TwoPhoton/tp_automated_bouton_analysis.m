function record = tp_automated_bouton_analysis( record)

% see tp_analyse_neurites
measures = record.measures;
ROIlist = record.ROIs.celllist;
indices = [measures.index]; %indices of all rois

axons = find([measures.axon]);
ind_axons = indices(axons);  % just the axons

%ObjPos = [];
for i = 1:length(axons) % over axons
    axon = axons(i);
    axoni = ind_axons(i);   %axon index number 
    boutons = find(([measures.linked2neurite]==axoni) & [measures.bouton]);
    axon_ints = find(([measures.linked2neurite]==axoni) & [measures.axon_int]);
    
   % ObjPos(i).axonidx = axoni;
   %find closest spot on axon for each bouton +and take this position as position order
   axi = ROIlist(axon).xi;
   axj = ROIlist(axon).yi;
    for j = 1:length(boutons)
        bouton = boutons(j);
        %position of this bouton
        bi = mean(ROIlist(bouton).xi);
        bj = mean(ROIlist(bouton).yi);  

        [~, posindx] = min((axi - bi).*(axi - bi) + (axj - bj).*(axj - bj));
        ROIlist(bouton).extra = posindx;
       % ObjPos(i).BoutonPos(j).pos = posindx; %position along the axon
       % plot(ROIlist(axon).xi(posindx), ROIlist(axon).yi(posindx), '*')
        
    end
    %find closest spot on axon for each axon_int +and take this position as position order
    for j = 1:length(axon_ints)
        ax_int = axon_ints(j);
        %position of this bouton
        ai = mean(ROIlist(ax_int).xi);
        aj = mean(ROIlist(ax_int).yi);  

        [~, posindx] = min((axi - ai).*(axi - ai) + (axj - aj).*(axj - aj));
        %ObjPos(i).AxintPos(j).pos = posindx; %position along the axon   
        ROIlist(ax_int).extra = posindx;
    end
    
end

record.ROIs.celllist = ROIlist;


%now we have ordered boutons and axonints in space, take two axon ints
%besides each bouton and calculate fractional response of bouton.






    

