function [ent vol rat timebase] = interpspect(spectfile,fs)
    %
    % mnm, 16 april 2009
    %
    
    ent = spectfile(1:3:end);
    vol = spectfile(2:3:end);
    rat = spectfile(3:3:end);
    
    ent = resample(ent,256,1);
    vol = resample(vol,256,1);
    rat = resample(rat,256,1);
    
    timebase = [1/fs:1/fs:length(ent)*1/fs];
    
    
    