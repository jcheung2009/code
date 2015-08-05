close all; clear all; clc


pathdata = path_localsettings;


data = load(fullfile(pathdata.stim_path, 'syllable_database'));
data = data.data;

%% this is genreating a 3 motif repete song with A-B-C-X-E where X is one of several syllables
base_idxs = [1 8 9 0 0 0];
sub_idxs = [12 17 18;...
    19 20 21;...
    63 64 22;...
    70 80 370;...
    81 90 420;...
    105 110 510;...
    120 152 600];

fs_out = 44100;
fs=data.fs;
%generate all the songs
for ksub = 1:length(sub_idxs)
    syllable_idxs = base_idxs;
    syllable_idxs(4:6) = sub_idxs(ksub,:);
    syllables = data.syllables(syllable_idxs);
    for ksyl = 1:length(syllables)
        % normalize rms to 1
        syllables(ksyl).wf = normalize_rms_to_one(syllables(ksyl).wf);
    end
    wf = generate_motif_with_even_gaps(syllables, data.fs, 50e-3, 100e-3);
    fs = round(fs);
    div = gcd(fs, fs_out);
    p = fs/div;
    q = fs_out/div;
    wf = resample(wf, q, p);
    wf = wf(1:44100);
    songs{ksub} = wf(:);
end





count = 0;
for kfreq = [500 1000 2000 4000 6000 12000]
    count = count + 1;
    wf = vas(kfreq, 1, .1);
    wf = normalize_rms_to_one(wf);
    tones{count} = wf(:);
end


count = 0;
for kfreq = [500 1000 2000 4000 6000 12000]
    count = count + 1;

    noise{count} =  normalize_rms_to_one(randn(44100,1));

end




play_sound(tones{1},fs_out,80)
play_sound(songs{1},fs_out,80)
play_sound(noise{1},44100,80);

rms_noise = rms(noise{1});
if 1
    fig = figure;
    subplot(4,2,1)
    plot(noise{1})
    title('noise')
    ylim([-10 10])
    subplot(4,2,2)
    plot(20*log10(sliding_rms(noise{1},400)/rms_noise))
    hold on
    plot((extract_envelope(noise{1},fs,.05)/rms_noise),'g')
    ylim([0 10])
    
    subplot(4,2,3)
    plot(noise{1}+noise{2})
    title('noise+noise')
    ylim([-10 10])
    subplot(4,2,4)
    wf = noise{1}+noise{2};
    plot(20*log10(sliding_rms(wf,400)/rms_noise))
    hold on;
    plot((extract_envelope(wf,fs,.05)/rms_noise),'g')
    ylim([0 10])
    
    subplot(4,2,5)
    plot(noise{1}+tones{1})
    title('noise+tone')
    ylim([-10 10])
    subplot(4,2,6)
    wf = noise{1} + tones{1};
    plot(20*log10(sliding_rms(wf,400)/rms_noise))
    hold on;
    plot((extract_envelope(wf,fs,.05)/rms_noise),'g')
    ylim([0 10])
    
    subplot(4,2,7)
    plot(noise{1}+songs{1})
    ylim([-10 10])
    title('noise+song')
    subplot(4,2,8)
    wf = noise{1}+songs{1};
    plot(20*log10(sliding_rms(wf,400)/rms_noise))
    hold on
    plot((extract_envelope(wf,fs,.05)/rms_noise),'g')
    ylim([0 10])
    
end
play_sound(noise{1}+noise{2},44100,80);
play_sound(noise{1}+tones{1},44100,80);
play_sound(noise{1}+songs{1},44100,80);