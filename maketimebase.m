function [timebase] = maketimebase(songlen,sampRate)
    %
    % [timebase] = maketimebase(songlen,sampRate)
    %
    % songlen = number of data points in raw data
    % 
    % generates time axis given a cbin or wav file
    % mnm, 15 april 2009
    %
    
    dt = 1/sampRate;
    timebase = [dt:dt:songlen*dt];
    
    