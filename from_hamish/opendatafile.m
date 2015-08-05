function fid = opendatafile(datarec)
% OPENDATAFILE: open a multi-channel data file
%
% opendatafile just opens up an multi-channel data file
% (datarec.filename) and returns
% a file handle (fid). Also checks its length against that
% indicated in the datarec structure (datarec.n_ai_chan).
%
% Usage: fid = opendatafile(datarec)

if length(strmatch('LE uint16', [datarec.chan.format])) == datarec.n_ai_chan
    samp_type = 'uint16';
    endianness = 'LE';
    samp_size = 2;
else
    error('Can not handle this data format yet (for no good reason).')
end

% Open the file
if strcmp(endianness,'LE')
    fid = fopen(datarec.filename,'r','l');
else
    fid = fopen(datarec.filename,'r','b');
end
if fid == -1
    error(['Could not open file: ', datarec.filename])
end

fstatus = fseek(fid,0,'eof');
if fstatus == -1
    msg = ferror(fid);
    error(msg)
end
filesize = ftell(fid);
if filesize == -1;
    msg = ferror(fid);
    error(msg);
end

data_length = filesize/(samp_size*datarec.n_ai_chan);
if data_length ~= datarec.n_samples
    error('Inconsistent file length compared to rec file.')
end

if 0
    disp(['File size is ', num2str(filesize), ' bytes.']);
    disp(['Length of data file: ', num2str(data_length*1000/datarec.ai_freq), ...
        ' msec, ', num2str(data_length/(datarec.ai_freq*60)), ' minutes.']);
    disp(['Length of data file in samples: ', ...
        num2str(datarec.n_samples)])
end

