function make_stim_rc_rptnonrpt(rcfilename,filename,Fs)

if exist(rcfilename,'file')
  yesno = input(['Do you want overwrite existing file ', rcfilename, ' (y/N)? '], 's');
  if ~strncmpi(yesno,'y',1)  
    disp('Exiting without writing rc file!')
    return
  end
end

fid = fopen(rcfilename,'w');

nstim = length(filename)

fprintf(fid,'stim reset\n');
% Note the first file is the baseline stim!
for i=1:nstim
  %stimfile = fullfile(stimbasedir,filename{i})
  if i==1
    fprintf(fid,'# repeated\n');
  end
  if i==2
    fprintf(fid,'# non-repeated\n');
  end
  fprintf(fid,'stim add %s\n', filename{i});
end
fprintf(fid,'stim list\n');
fprintf(fid,'set ao_freq %d\n', Fs);
fprintf(fid,'set n_trials %d\n', 2*(nstim-1));
fprintf(fid,'set stim_order 1\n');
fprintf(fid,'set ramp_time 0.05\n');
fprintf(fid,'# Have to set the attenuation for this stim set!\n');

fclose(fid);

