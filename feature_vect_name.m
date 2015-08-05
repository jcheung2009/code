function featname = feature_vect_name(idx)


if idx == 1
    featname = 'Mean Freq';
elseif idx ==2
    featname = 'Spct. Entrp';
elseif idx ==3
    featname = 'Peak Amp';
elseif idx ==4
    featname = 'Duration';
elseif idx ==5
    featname = 'Amp. Entrp';
elseif idx ==6
    featname = 'Harm. Crctd. Mean Freq.';
elseif idx ==7
    featname = 'Harm. Crctd. Max Freq.';
elseif idx ==8
    featname = 'Freq. Slope';
elseif idx ==9
    featname = 'Time to .5 Pk Amp';
elseif idx ==10
    featname = 'Cep. Peak Loc';
elseif idx ==11
    featname = 'Amp. Slope';
elseif idx ==12
    featname = 'Loc. of Peak Amp';
elseif idx ==13
    featname = 'Mag. of Hrm. Freq';
elseif idx ==14
    featname = 'Spct Peak';
elseif idx ==15
    featname = 'Entrp of Full Spect';
elseif idx == 16
    featname = 'Mean Amp.';
elseif idx == 17
    featname = 'Spectral Wiener Ent.';
end
