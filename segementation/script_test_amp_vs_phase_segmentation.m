%this script tests the robustness of phase segmentation vs amp segmentation
%for changes in volume

config
batch = uigetfile;
ff = load_batchf(batch);
for i = 1:length(ff)
    if isempty(ff(i).name)
        continue
    end
    for ii = 1:length(params.findmotif)
        load('analysis/data_structures/motifsegment_',params.findmotif(ii).motif','_',ff(i).name]);
        
        