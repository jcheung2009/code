function jc_separateBOS(playbacklog,batchrhdBOS)
%uses the playbacklog from jc_playBOS to identify which rhd files corresponds
%to the type of auditory playback. Also takes in batchrhdBOS which is a
%batch listing all files that contain any type of auditory playback 
%generates batch lists 

playback = load_batchf(playbacklog);
batchsongs = load_batchf(batchrhdBOS);

fbos = fopen('batchrhdBOS','w');
frev = fopen('batchrhdREVBOS','w');
fcon = fopen('batchrhdCON','w');

for i = 1:length(batchsongs)
    [~,ind] = min(arrayfun(@(x) abs(datenum(datevec(batchsongs(i).name(end-16:end-4),...
        'yymmdd_HHMMSS'))-datenum(datevec(x.name(1:20)))),playback));
    if strfind(playback(ind).name,'reverse')
        fprintf(frev,'%s\n',batchsongs(i).name);
    elseif strfind(playback(ind).name,'con')
        fprintf(fcon,'%s\n',batchsongs(i).name);
    else
        fprintf(fbos,'%s\n',batchsongs(i).name);
    end
end

