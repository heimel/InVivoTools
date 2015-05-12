function [val val_sem]=get_bxdpublish( trait_id, strain)
% wrapper around get_genenetwork_probe to get data from published BXD phenotypes
%
% 2008, Alexander Heimel
%

[val val_sem]=get_genenetwork_probe(strain,'BXDPublish',trait_id);
