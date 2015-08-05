function spike_vect = read_in_tt(ttfile)

spike_vect = [];

fid = fopen(char(ttfile),'r','l');
n = 1;

while ~feof(fid)
    TS_crnt = fread(fid,1,'uint32');
    SW_crnt = fread(fid,160,'int16');
    spike_vect = [spike_vect TS_crnt SW_crnt];
end

