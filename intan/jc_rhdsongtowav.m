function jc_rhdsongtowav(rhd_data)

for i = 1:length(rhd_data)
    song = rhd_data(i).song/(2*max(abs(rhd_data(i).song)));
    wavwrite(song,rhd_data(i).Fs,16,[rhd_data(i).filename,'.wav']);
end


