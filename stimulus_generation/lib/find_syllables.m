function syllable_idxs = find_syllables(wf, fs)
wf = wf/std(wf);

windowsize = 2e-3;
% generate envelope
envelope = abs(hilbert(wf));
envelope = filtfilt(ones(1,windowsize*fs), 1, envelope);

level1 = 200;
level2 = 200;
trig_on = false;
syllable_idxs = [0 0];
count = 0;
for k = 1:length(envelope)
    if ~trig_on
        if envelope(k) > level1
            count = count + 1;
            trig_on = true;
            syllable_idxs(count,1) = k;
        end
    else
        if envelope(k) < level2
            trig_on = false; 
            syllable_idxs(count,2) = k;
        end            
    end
end

plot(envelope)
hold on
for k = 1:length(syllable_idxs)
    plot([syllable_idxs(k,1), syllable_idxs(k,2)], [0, 0], 'r', 'linewidth',2);
end

    