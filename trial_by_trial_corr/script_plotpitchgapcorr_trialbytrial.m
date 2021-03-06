ff = load_batchf('batchnaspm');
pitchgapcorr = struct();
load('analysis/data_structures/naspmvolumelatency');
syllables = {'b','d'};
motif = 'bcd';
trialcnt = 0;

for i = 1:4:length(ff)
    trialcnt = trialcnt+1;
    for ii = 1:length(syllables)
        durind = strfind(motif,syllables{ii});
        durind = durind(1);
        numgapsfor = length(motif)-durind;
        numgapsback = durind-1;

        load(['analysis/data_structures/motif_',motif,'_',ff(i).name]);
        load(['analysis/data_structures/motif_',motif,'_',ff(i+2).name]);
        fv1 = ['motif_',motif,'_',ff(i).name];
        fv2 = ['motif_',motif,'_',ff(i+2).name];
        
        if ~isempty(strfind(ff(i+2).name,'sal'))
            startpt = '';
        else
            drugtime = naspmvolumelatency.(['tr_',ff(i+2).name]).treattime;
            startpt = (drugtime+1.13)*3600;%change latency time
        end
        
        pitchgapcorr(trialcnt).(['syll',syllables{ii}]) = ...
            jc_pitchgapcorr(eval(fv1),eval(fv2),ii,durind,numgapsfor,...
            numgapsback,1,startpt,'');
        
    end
end

        