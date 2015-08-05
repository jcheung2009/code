
% Load in filename list
savefile = input(['Enter mat file containing file information' ...
      ' for each stimulus type: '], 's')

load(savefile,'nstims','file_info','nfiles','filenameprefix','Fs','stim_lengths')

batch_dur = input(['Enter approximate duration of a stimulus' ...
      ' batch (sec): '])

stim_lengths_dur = stim_lengths/Fs;

if batch_dur < stim_lengths_dur(1)
  error(['Batch duration must be longer than the duration of the' ...
	' first stimulus.'])
end

stimpath = input(['Enter path for stimulus specification (can be' ...
      ' relative) [stimuli/noise]: '], 's')
if isempty(stimpath)
  stimpath = 'stimuli/noise'
end

rcfilenamesuffix = input(['Enter rc filename suffix [', ...
      filenameprefix, ']: '], 's')
if isempty(rcfilenamesuffix)
  rcfilenamesuffix = filenameprefix;
end

% The first file is the baseline repeated stimulus
all_batches_dur = (nfiles - 1)*stim_lengths_dur(1) + sum(stim_lengths_dur(2:nfiles))

ibf = 0;
ibatch = 0;
ifile_start = 2;
this_batch_dur = 0;
% To complete a batch, ibf must end up being even
ifile = 1;

while ifile <= nfiles
  ibf = ibf+1;  
  if rem(ibf,2)
    this_batch_dur_prev = this_batch_dur;
    this_batch_dur = this_batch_dur + stim_lengths_dur(1);    
  else
    ifile = ifile + 1
    if (ifile > nfiles) 
      break;
    end
    this_batch_dur = this_batch_dur + stim_lengths_dur(ifile);
  end
  if this_batch_dur > batch_dur
    % We've finished a new batch file
    ibatch = ibatch+1
    batch_dur(ibatch) = this_batch_dur_prev 
    if rem(ibf,2)
      % subtract off extra baseline file
      n_files_batch(ibatch) = ibf-1
     else
      % subtract off extra baseline file and nonrepeated file
      n_files_batch(ibatch) = ibf-2
      ifile = ifile - 1;
    end      
    ifile_end = ifile;
    file_idx_batches{ibatch} = ifile_start:ifile_end;
    ifile_start = ifile+1;
    ibf = 0;
    this_batch_dur = 0;
  end
end
% Finish extra files
if ifile_end ~= nfiles
  ibatch = ibatch+1
  batch_dur(ibatch) = this_batch_dur 
  if rem(ibf,2)
    error('This should not happen!')
  else
    n_files_batch(ibatch) = ibf
  end
  file_idx_batches{ibatch} = ifile_start:nfiles;
end
n_batches = ibatch
 
% Save data rc files.
yesno = input('Do you want to create a krank rc file for this stimulus set (y/N)?', 's');
if strncmpi(yesno,'y',1)  
  rcbasedir = input('Enter base directory for rc files: ', 's')
  for ibatch = 1:n_batches
    fb_idx = [1 file_idx_batches{ibatch}];
    for istim=1:nstims
      clear batch_files
      ifile = 0;
      for idx = fb_idx
	ifile = ifile+1;
	[fpath,fname,fext,fver] = fileparts(file_info{istim}.files{idx});
	batch_files{ifile} = fullfile(stimpath,[fname,fext,fver]); 
      end
      rcfilename = fullfile(rcbasedir,[file_info{istim}.key, '_', rcfilenamesuffix, '_', num2str(ibatch), '.rc'])   
      make_stim_rc_rptnonrpt(rcfilename,batch_files,Fs)  
    end
  end
end
