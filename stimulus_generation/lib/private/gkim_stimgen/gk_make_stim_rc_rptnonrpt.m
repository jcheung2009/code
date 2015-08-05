function gk_make_stim_rc_rptnonrpt(rcfilename,Fs)

if exist(rcfilename,'file')
  yesno = input(['Do you want overwrite existing file ', rcfilename, ' (y/N)? '], 's');
  if ~strncmpi(yesno,'y',1)  
    disp('Exiting without writing rc file!')
    return
  end
end

% Get batch file information and load in files.
batch_info = [];
batch_info = gk_batch_select(batch_info);
batch_info = gk_batch_read(batch_info)

fid = fopen(rcfilename,'w');

fprintf(fid,'stim reset\n');
% Note the first file is the baseline stim!
for ifile=1:batch_info.nfiles
%  stimfile = fullfile(batch_info.basedir,batch_info.filenames{ifile});
  stimfile = fullfile('stimuli/ripple_gk/expfilt_50Hz_38bands',batch_info.filenames{ifile});
  if ifile==1
    fprintf(fid,'\n# repeated\n');
  end
  if ifile==2
    fprintf(fid,'\n# non-repeated\n');
  end
  fprintf(fid,'stim add %s\n', stimfile);
end
fprintf(fid,'\nstim list\n');
fprintf(fid,'set ao_freq %d\n', Fs);
fprintf(fid,'set n_trials %d\n', 2*(batch_info.nfiles-1));
fprintf(fid,'set stim_order 1\n');
fprintf(fid,'set ramp_time 0\n');
%fprintf(fid,'# Have to set the attenuation for this stim set!\n');
fprintf(fid,'set attenuation 15\n');

fclose(fid);

