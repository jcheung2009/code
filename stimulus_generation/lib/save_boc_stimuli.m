 function stimset = save_boc_stimuli(stimset,dir, stimsetname, varargin)
% stimset = MakeStimsetFolder(stimsetname,d)
% transform a stimulus set into a folder of binary files
% save the stimulus set, minus the signals, to stimsetname/stimsetname.mat
%
% inputs - 
%   stimset - stimset as formulated below
%   dir - directory to save the stimset dir to.  This will produce:
%               stimsetname.mat
%               stimset_name/stimsetname.mat
%               stimset_name/stim_name{kstim}.wav
%   stimsetname - name of the stimset (overrides stimset.name)
%   varargin 
%
%   
%
% How to set amplitude:
%    - wf input: stimuli should be set so that 100dB has an RMS of 1. 
%    - wf output:  optional argument db will set the default amplitude for
%               all stimuli in the stimset.  This defaults to 75dB
%                   - the stimset default can be overwritten by
%                   stimset.stims(kstim).db for a particular stimulus
%
% stimset structure
%    stimset.
%           .samprate = wf sampling rate
%           .name = name of stimset
%           .numstims = length(stimset.stims)
%           .stims(kstim).
%                        .stims.
%                              .signal = wf
%                              .length
%                              .name
%                              .db (optional) - output stim db



db = 75;
if length(varargin) > 0
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case 'db'
                db = varargin{k+1};
            otherwise
                disp(['Warning no argument', varargin{k}])
        end
    end
end
mkdir(dir,stimsetname)
fs_out = 44100;
for i=1:stimset.numstims
    if isfield(stimset.stims(i),'db')
        stim_db = stimset.stims(i).db;
    else
        stim_db = db;
    end
    stimset.stims(i).signal = apply_boc_filters(stimset.stims(i).signal, stimset.samprate, 'db', stim_db, 'fs_out', fs_out);
    fname = fullfile(dir,stimsetname,[stimset.stims(i).name,'.wav']);
    wavwrite(stimset.stims(i).signal(:), fs_out, fname)   
    stimset.stims(i).length = length(stimset.stims(i).signal); 
    stimset.stims(i).offset = stimset.stims(i).length;
end
stimset.samprate = fs_out;
stimset.name = stimsetname;
% save version for outside dir
save(fullfile(dir,stimsetname),'stimset');
% remove signals and save version for inside dir
stimset.stims = rmfield(stimset.stims,'signal');
save(fullfile(dir,stimsetname,stimsetname),'stimset');




