function jc_rhdsongtowav(rhd_data)
%extract audio channel from rhd files and save as wav file 

for i = 1:length(rhd_data)
    song = rhd_data(i).song/(2*max(abs(rhd_data(i).song)));
    audiowrite([rhd_data(i).filename,'.wav'],song,rhd_data(i).Fs);
end


