function IntanKillSmall(time);

files=dir('*.rhd')

for i=1:length(files)
    
    header=IntanRHDReadHeader('./', files(i).name);

    if header.record_time < time
        delete(files(i).name);
    end;
    
end;