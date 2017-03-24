function  trigonset = jc_checkttimes(batch,stimsyll,filestart,fileend)

% trigonset is time into target syllable when WN was delivered



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

if isempty(filestart)
    filestart = 1;
end

if isempty(fileend)
    fileend = length(files);
end



trigonset = [];
min_int = 10;
min_dur = 20;
ampThresh = 1e4; %check!
CHANSPEC = 'obs0';
for i = filestart:fileend
    recdata = readrecf(files(i).fn,'');
    
    if ~exist(strcat(files(i).fn,'.not.mat'),'file')
%         [dat,fs]=evsoundin('',files(i).fn,CHANSPEC);
%         [sm]=SmoothData(dat,fs,1,'hanningfirff');
%         sm(1)=0.0;sm(end)=0.0;
%         [ons,offs]=SegmentNotes(sm,fs,min_int,min_dur,ampThresh);
%         onsets=ons*1e3;offsets=offs*1e3;
        
        continue
    else
        load(strcat(files(i).fn,'.not.mat'));
    end
    
    if ~isempty(stimsyll)

        a = strfind(labels,stimsyll);
        
        if isempty(a)
            continue
        else
            
            syllonsets = onsets(a);
        
                for ii = 1:length(recdata.ttimes)
                    m = find(recdata.ttimes(ii) > syllonsets);
                        if isempty(m)
                            disp(files(i).fn)
                        end
                 [trig ind] = min(abs(recdata.ttimes(ii) - syllonsets(m)));
                     if trig > 100
                         continue
                     else
                         trigonset = cat(1,trigonset,trig);
                     end
                end
        end

            
            %if label only the trigs with different syllable
%             for ii = 1:length(syllonsets)
%                 m = find(recdata.ttimes > syllonsets(ii));
%                 if isempty(m)
%                     disp(files(i).fn)
%                 end
%                 trig = recdata.ttimes(m(1)) - syllonsets(ii);
%                 if trig > 100
%                     continue
%                 else
%                     trigonset = cat(1,trigonset,trig);
%                 end
%             end
%         end
    
    else
        for ii = 1:length(recdata.ttimes)
               m = find(onsets < recdata.ttimes(ii));
               trig = recdata.ttimes(ii) - onsets(m(end));
               if trig > 100
                   disp(files(i).fn)
               else
               trigonset = cat(1,trigonset,trig);
               end
        end
    end
        
end

    
    
