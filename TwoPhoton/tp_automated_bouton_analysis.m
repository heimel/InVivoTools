function record = tp_automated_bouton_analysis( record)


% see tp_analyse_neurites
measures = record.measures;
ind_axons = [measures.axon];  % maar nu de axonen



for i = ind_axons % over axons
    axon = measures(i);

    ind_linked2axon = ([measures.linked2neurite]==axon.index) & [measures.bouton] ;
    
end