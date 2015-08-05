function make_stim_rc(rcfilename,stimbasedir,filename,Fs)

if exist(rcfilename,'file')
  yesno = input(['Do you want overwrite existing file ', rcfilename, ' (y/N)? '], 's');
  if ~strncmpi(yesno,'y',1)  
    disp('Exiting without writing rc file!')
    return
  end
end

fid = fopen(rcfilename,'w')

nstim = length(filename)

fprintf(fid,'stim reset\n')
for i=1:nstim
  stimfile = fullfile(stimbasedir,filename{i})
  fprintf(fid,'stim add %s\n', stimfile)
end
fprintf(fid,'stim list\n')
fprintf(fid,'set ao_freq %f\n', Fs)
fprintf(fid,'set n_trials %d\n', nstim)
fprintf(fid,'set stim_order 2\n')
fprintf(fid,'set ramp_time 0\n')
fprintf(fid,'set attenuation 0\n')

fclose(fid);


