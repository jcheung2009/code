close all; clear all; clc

% set parameters
fs = 40e3;
period = 4;
f = 2e3;
phi = 0;

% generate signal
t = 0:(1/fs):period;
x = sin(t*(2*pi*f) + phi);

wf = apply_krank_filters(x(:), fs, 'db', 100);
write_krank_file(wf, '/data/doupe_lab/stimuli/cf_2khz.raw')