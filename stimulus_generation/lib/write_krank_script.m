function write_krank_script(direc, basename, stimset, varargin)

%run_params = generate_krank_run_params();
run_params.ao_freq = stimset.samprate;
run_params.ai_freq = 32e3;
run_params.n_trials = 50;
run_params.stim_order = 2;
run_params.ramp_time = 0;
run_params.attenuation = 15;
run_params.attenuation2 = 0;
for karg = 1:2:length(varargin)
    switch lower(varargin{karg})
        case 'stim_order'
            run_params.stim_order = varargin{karg+1};
    end
end

% set total number of trials to ntrials*nstim
run_params.n_trials = run_params.n_trials * stimset.numstims;

% define param_script
param_script = {};
param_script{end+1} = 'stim list';
keys = fieldnames(run_params);
for kkey = 1:length(keys)
    param_script{end+1} = ['set ', keys{kkey}, ' ', num2str(run_params.(keys{kkey}))];
end
param_script{end+1} = '';
param_script{end+1} = '';

init_script = {};
init_script{1} = 'stim reset';
init_script{2} = '';
init_script{3} = '';

stimuli_script = {};
for kstim=1:length(stimset.stims)
    stimuli_script{end+1} = ['/tazo/jknowles/stimuli/', basename, '/' stimset.stims(kstim).fname];
end

% Write script from cell arrays
fid = fopen([direc, basename, '.rc'], 'w'); % write 
for row=1:length(init_script)
    fprintf(fid, '%s\n', init_script{row});
end
fprintf(fid, '%s\n', '');
fprintf(fid, '%s\n', '');
for row=1:length(stimuli_script)
    fprintf(fid, '%s\n', ['stim add ' ,stimuli_script{row}]);
end
fprintf(fid, '%s\n', '');
fprintf(fid, '%s\n', '');
for row=1:length(param_script)
    fprintf(fid, '%s\n', param_script{row});
end

fclose(fid);
