function freqtest(file)

d=wavread(file);
figure;
psd(d,44000,22050);


