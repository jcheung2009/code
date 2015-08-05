function jc_generatemotif(motif)
%reconstruct motif from cbin file by isolating syllables and pasting them
%back together while preserving original gap durations 
%must label the motif in the cbin file with evsonganaly
%to be used for playback experiments
%saves the original sound clip of the motif and the reconstructed motif
%along with the reverse BOS in a folder in the current directory titled
%with the cbin file name. In addition, saves the cleaned BOS/revBOS to
%motif database in the birds directory 

% options
back_window = 25e-3; % set how far to step forward and backward around syllables in seconds
for_window = 25e-3;

filename = uigetfile;%select the cbin
load([filename,'.not.mat']);
[rawsong fs] = evsoundin('',filename,'obs0');
if isempty(motif)
    motifind = (labels ~= '-');
    kk = [find(diff([-1 motifind -1])~=0)];
    runlength = diff(kk);
    runlength = runlength(1+(motifind(1)==0):2:end);
    motifind = find(diff([0 motifind 0]) == 1);
else
    motifind = strfind(labels,motif);
end

if ~exist('../motif_database')
    mkdir('../motif_database')
end

mkdir([filename,'_motifs']);
figure;
for i = 1:length(motifind)
    mkdir(fullfile([filename,'_motifs'],['motif_',num2str(i)]));
    if ~isempty(motif)
        idxs = [onsets(motifind(i))*(1e-3)-back_window offsets(motifind(i)+length(motif)-1)*(1e-3)+for_window];
    else
        idxs = [onsets(motifind(i))*(1e-3)-back_window offsets(motifind(i)+runlength(i)-1)*(1e-3)+for_window];
    end
    idxs = floor(idxs*fs);
    if idxs(1) > 0 && idxs(2) < length(rawsong)
        motif_wf = rawsong(idxs(1):idxs(2));
        [sm spec t f] = evsmooth(motif_wf,fs);
        subplot(2,1,1);imagesc(t,f,log(abs(spec)));syn();xlim = get(gca,'xlim');
        title([filename,' motif',num2str(i)],'interpreter','none');
        subplot(2,1,2);plot(0:1/fs:(length(sm)-1)/fs,log(sm),'k');set(gca,'xlim',xlim);hold on;
        approve = 'n';
        while strcmp(approve,'n');
            threshold = input('threshold:');
            [ons offs] = SegmentNotes(log(sm),fs,5,30,threshold);%ons and offs in seconds
            for ii = 1:length(ons)
                plot([ons(ii) ons(ii)],[min(log(sm)) max(log(sm))],'r');hold on;
                plot([offs(ii) offs(ii)],[min(log(sm)) max(log(sm))],'r');hold on;
            end
            approve = input('segmentation ok?:','s');
        end
        clf; 
        gaps = ons(2:end)-offs(1:end-1);
        motif_wf = 0.5*motif_wf / max(abs(motif_wf));
        wavwrite(motif_wf,fs,fullfile([filename,'_motifs'],['motif_',num2str(i)], 'motif_original.wav'))
        
        syllables = struct;
        for m = 1:length(ons)
            syllables(m).wf = cut_segment(motif_wf,fs,ons(m),offs(m));
        end
        
        [newmotif_wf newonsets] = jc_generate_motif_with_specified_gaps(syllables,fs,gaps,25e-3);
        revnewmotif_wf = flipdim(newmotif_wf,1);
        
        [sm spec t f] = evsmooth(newmotif_wf,fs);
        subplot(2,1,1);imagesc(t,f,log(abs(spec)));syn();title('cleaned motif');
        [sm spec t f] = evsmooth(revnewmotif_wf,fs);
        subplot(2,1,2);imagesc(t,f,log(abs(spec)));syn();title('reverse motif');
        pause;
        clf;
        wavwrite(newmotif_wf,fs,fullfile([filename,'_motifs'],['motif_',num2str(i)],'motif_cleaned.wav'));
        wavwrite(revnewmotif_wf,fs,fullfile([filename,'_motifs'],['motif_',num2str(i)],'revmotif_cleaned.wav'));
        wavwrite(newmotif_wf,fs,fullfile('../motif_database',[filename,'_motif',num2str(i),'.wav']));
        wavwrite(revnewmotif_wf,fs,fullfile('../motif_database',[filename,'_motif',num2str(i),'_rev.wav']));
        
    end
end
