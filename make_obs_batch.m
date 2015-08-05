function make_obs_batch(batchfile,f_type)
%
% function make_obs(batchfile,f_type)
% <batchfile>:a batchfile containing names of soundfiles to convert
% <f_type>:type of sound file referenced

%open batch_file
meta_fid=fopen([batchfile]);
if meta_fid == -1 | batchfile == 0
    disp('cannot open file' )
    disp (batchfile)
    return
end

while 1
    %get songfile name
    songfile = fscanf(meta_fid,'%s',1);
    %end when there are no more songfiles
    if isempty(songfile);
        break
    end

    %if songfile exists, get it
    if exist([songfile]);
        song = soundin('',char(songfile),char(f_type));
    else
        disp(['cannot find ', songfile])
    end

    %create file name by parsing original file name
    breaks = strfind(songfile,'.');
    if isempty(breaks)
        songname = [songfile,'.cbin'];
    elseif f_type =='w'
        songname = [songfile,'.cbin'];
    else
        songname = [songfile(1:breaks(end)),'cbin'];
    end
    nmbrpnts = length(song);

    %create obs file
    obswrite(song,char(songname));

    %create rec file
    if isempty(breaks)
        recname  = [songfile,'.rec'];
    elseif f_type =='w'
        recname  = [songfile,'.rec'];
    else
        recname  = [songfile(1:breaks(end)),'rec'];
    end


    fid = fopen(char(recname),'a');
    dateinfo = ['File created ',date];
    beginfo = ['begin rec =      0 ms'];triginfo = ['trig time =      0 ms'];
    endinfo = ['rec end = ', num2str(round(length(song)/32)),' ms'];
    freqinfo = ['ADFREQ =  32000']; sampinfo = ['Samples =  ', num2str(nmbrpnts)];
    chaninfo = ['Chans =  1'];
    fprintf(fid,'%s\n',dateinfo,beginfo,triginfo,endinfo,freqinfo,sampinfo,chaninfo);
    fclose(fid);
end
fclose(meta_fid);