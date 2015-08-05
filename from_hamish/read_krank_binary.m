function data = read_krank_binary(rec_file, channel, range)
% function to read data from krank .raw file fname
% range. 
% inputs
%       re_file - the filename of the .rec file for a krank trial. 
%       channel - the channel to read
%       range - the range to read in sampels
%
% outputs
%       data = waveform of data
rec = gk_parse_rec(rec_file); % load meta data
fid  = opendatafile(rec);

skip = 2*(rec.n_ai_chan-1); % skip xx bytes
raw_start = range(1);
raw_stop = range(2);
raw_offset = (raw_start)* 2 * rec.n_ai_chan + (channel-1)*2;
fseek(fid, raw_offset, 'bof');
read_length = raw_stop - raw_start;
[data,num_read] = fread(fid,read_length,'uint16',skip);

% normalize by scale and add offset
data = data*rec.chan(channel).scale + rec.chan(channel).offset;
fclose(fid);

end