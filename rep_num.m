function repeats = rep_num(batch,repeat,CHANSPEC)
%% total number of repeats in all motifs


fid=fopen(batch,'r');
files=[];cnt=0;
while (1)
       fn=fgetl(fid);
       if (~ischar(fn))
               break;
       end
       cnt=cnt+1;
       files(cnt).fn=fn;
end
fclose(fid);


repeats = [];
for i = 1:length(files);
    load(strcat(files(i).fn,'.not.mat'));
    rd = readrecf(files(i).fn);
    a = ismember(labels,repeat);
    ii = [find(diff([-1 a -1])~=0)];
    runlength = diff(ii);
    runlength1 = runlength(1 + (a(1)==0):2:end);
    onind = 1 + find(diff(a)==1);
    
    recf = readrecf(files(i).fn);
    ton = onsets(onind);
    if (strcmp(CHANSPEC,'obs0'))
                key = 'created:';
                ind = strfind(recf.header{1},key);
                tmstamp = recf.header{1}(ind+length(key):end);
                tmstamp = datenum(tmstamp,'ddd, mmm dd, yyyy, HH:MM:SS');%time file was closed
                
                ind2 = strfind(recf.header{5},'=');
                filelength = sscanf(recf.header{5}(ind2 + 1:end),'%g');%duration of file
                tm_st = addtodate(tmstamp,-(filelength),'millisecond');%time at start of file
                for kk = 1:length(ton)
                    datenm = addtodate(tm_st, round(ton(kk)), 'millisecond');%add time to onset of syllable
                    [yr mon dy hr min sec] = datevec(datenm);
                    repeats = cat(1,repeats,[datenm, runlength1(kk)]);
                end
     elseif strcmp(CHANSPEC,'w')
         datenm = fn2datenum(files(i).fn);
         repeats = cat(1,repeats,[datenm*ones(length(runlength1),1),runlength1']);
     end
    
end

