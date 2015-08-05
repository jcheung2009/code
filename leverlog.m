fleverlog = fopen('leverlog','w');

fid = fopen(log,'r')
tline = fgets(fid);
while ischar(tline)
    if ~isempty(strfind(tline,'synth'))
        ind = strfind(tline,'synth');
        fprintf(fleverlog,'%s',tline(ind:end));
    end
    tline = fgets(fid);
end
fclose(fleverlog);fclose(fid);
return

fid = fopen('leverlog','r')
tline = fgets(fid);
ABFG = [];
ABGF = [];
BAFG = [];
while ischar(tline)
    if ~isempty(strfind(tline,'ABFG'))
        ABFG = cat(2,ABFG,1);
    end
    if ~isempty(strfind(tline,'ABGF'))
        ABGF = cat(2,ABGF,1);
    end
    if ~isempty(strfind(tline,'BA1')) | ~isempty(strfind(tline,'BA2')) | ~isempty(strfind(tline,'BA3'))
        BAFG = cat(2,BAFG,1);
    end
    tline = fgets(fid);
end

fid = fopen(log,'r')
tline = fgets(fid);
songs_per_day = [];
while ischar(tline)
    if ~isempty(strfind(tline,'.wav'))
         x = regexp(tline,'(?<month>\d+)/(?<day>\d+)/(?<year>\d+)','names');
         dt = [str2num(x.year) str2num(x.month) str2num(x.day)];
        songs_per_day = cat(1,songs_per_day,[datenum(dt),1]);
    end
    tline = fgets(fid);
end

[m n] = unique(songs_per_day(:,1),'first');
songcount = m;
for i = 1:length(m)
    a = find(songs_per_day(:,1) == m(i));
    songcount(i,2) = length(a);
end

    
    
        
        