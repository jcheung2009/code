config;

condition = 'saline';
drug = 'naspm';

trials = params.trial(arrayfun(@(x) strcmp(x.condition,drug),params.trial));
for syll = 1:length(params.findnote)   
    figure;
    for i = 1:length(trials)
        load(['analysis/data_structures/',params.findnote(syll).fvstruct,trials(i).name]);
        load(['analysis/data_structures/',params.findnote(syll).fvstruct,trials(i).baseline]);
        basedata = eval([params.findnote(syll).fvstruct,trials(i).baseline]);
        testdata = eval([params.findnote(syll).fvstruct,trials(i).name]);
        
        pitchbase = [basedata(:).mxvals];
        volbase = [basedata(:).maxvol];
        sylldurbase = arrayfun(@(x) x.offs-x.ons,basedata);
        pitch = [testdata(:).mxvals];git sta
        vol = [testdata(:).maxvol];
        sylldur = arrayfun(@(x) x.offs-x.ons,testdata);
        
        subplot(3,length(trials),i);
        plot(pitchbase,log10(volbase),'k.');hold on;
        plot(pitch,log10(vol),'r.');
        title(strjoin({params.findnote(syll).syllable,trials(i).name}))
        xlabel('pitch');ylabel('amp');
        
        subplot(3,length(trials),i+length(trials));
        plot(pitchbase,sylldurbase,'k.');hold on;
        plot(pitch,sylldur,'r.');
        title(strjoin({params.findnote(syll).syllable,trials(i).name}))
        xlabel('pitch');ylabel('syll dur');
        
        subplot(3,length(trials),i+2*length(trials));
        plot(log10(volbase),sylldurbase,'k.');hold on;
        plot(log10(vol),sylldur,'r.');
        title(strjoin({params.findnote(syll).syllable,trials(i).name}))
        xlabel('amp');ylabel('syll dur');
        
    end
end
        