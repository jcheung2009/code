%What I would like to do is add more points to existing cluster with two
%different colors.  One color for all previous points, another color for
%all new points.

%And that when I change the cluster dimension.  It does so for all the
%points.


%initialize variables
batchfile='//cobain/3667data/bluetet/batch1'
outfilefilter={'D:\tim\g36g67stim\3667.wav' 'D:\tim\g36g67stim\3667_rev.wav' 'D:\tim\g36g67stim\3667_m10.wav' 'D:\tim\g36g67stim\3667_p10.wav' 'D:\tim\g36g67stim\3667l.wav' 'D:\tim\g36g67stim\3667_m10tl.wav' 'D:\tim\g36g67stim\3667_p10tl.wav' 'D:\tim\g36g67stim\3667_m5.wav' 'D:\tim\g36g67stim\3667_p5.wav' 'D:\tim\g36g67stim\3667q.wav' }
%structnames={'bos' 'm10' 'm10tl' 'm5' 'p10' 'p10tl' 'p5' 'rev' }


display_skip=5;
secondflag=0;
clear clust_hand;
ampbuffer=[];
indbuffer=[];
spksinclust=[];
spksoutclust=[];
spkindclust=[];
spkamp=[];
spkind=[];

ppin=[];
cnt=0;
offset=0;
badfilecount=1;
anfilecount=1;
filtfilecount=1;
clustnum=1;
clear fnm;
tet_chans=[3:6];song_chan=1;
totalpolygons=0;

%get all the files in the batch file
fid=fopen(batchfile,'r');
while (1)
	fn=fgetl(fid);
	if (~ischar(fn))
		break;
	end
	if (~exist(fn,'file'))
		continue;
	end
	
	cnt=cnt+1;
	fnm{cnt}=fn;
end
fclose(fid);

% this goes through and gets the main spike cluster for each file in the
%batch file

%This loops through all the files in the batch file
for ifn=1:length(fnm)
    
    %Every display_skip number of trials, skip a trial(skiptrial=1)
    if(mod(filtfilecount,display_skip)==0||ifn==length(ifn))
        filtfilecount=filtfilecount+1;
        skiptrial=0;
    else
        skiptrial=1;
        filtfilecount=filtfilecount+1;
    end
    
    fn=fnm{ifn};
    %run tetanal on the file get spike times and spkamps
	
    rd=readrecf(fn);
    %read in data
    [data,fs,spkindnew,spkampnew]=tetanaldc(fn,-2000,song_chan,tet_chans);
    
    %This loop assigns data to appropriate data structure
   inputnum=0;
    
    for ii=1:length(outfilefilter) 
        if (strcmp(rd.outfile,outfilefilter{ii}))
            inputnum=ii;
            break;
        end
    end

    %Next-to-last column is trial number, last column is input type
    spkindnew(:,2)=ifn;
    spkampnew(:,5)=ifn;
    spkindnew(:,3)=inputnum;
    spkampnew(:,6)=inputnum;
    
    
    %pltdat;
    
    %R=input('Keep data? 1 for Yes')
    
    
    %Add to buffer of <display_skip> trials worth of data>
    
    %if (R==1)
        ampbuffer=[ampbuffer;spkampnew];    
        indbuffer=[indbuffer;spkindnew];
    %end
    if(skiptrial==0|ifn==length(fnm))
       pltscat4;
        if(ifn>1)
            pltdat;
            figure(DATPLT);
                    for ii = 1:Nusechans
                        indices=find(inspikes(:,5)==ifn)
                        indices2=find(indbuffer(ppin,2)==ifn)
                        subplot(Nusechans+1,1,ii+1);
                        hold on;grid on;
                        %plot(spkt(pp),dat(spki,usechans(ii-1)),[clr,'o']);
                        %plot(indbuffer(ppin(indices2),1)/fs,-inspikes(indices,ii),[clr,sym]);
                    end
       
       
            figure(CLUSTPLT);
        end
        clustnum=clustnum+1;
    
        while(1)
            R=input('Keep Cluster? 1 for Yes')
            %strname is the correct name for clustered spikes%
            if (R==1)
               spksinclust=[spksinclust;ppin+offset];
               spksoutclust=[spksoutclust;ppout+offset];
               totalpolygons=totalpolygons+1;
               clusterinfo{totalpolygons}.dims=[x,y];
               clusterinfo{totalpolygons}.chans=[chans];
               break;
            else
                figure(CLUSTPLT);
                [x,y]=ginput();
                 clust_hand=gca;
                pltscat4;
                pltdat;
                figure(DATPLT);
                    for ii = 1:Nusechans
                        indices=find(inspikes(:,5)==ifn)
                        indices2=find(indbuffer(ppin,2)==ifn)
                        subplot(Nusechans+1,1,ii+1);
                        hold on;grid on;
                        %plot(spkt(pp),dat(spki,usechans(ii-1)),[clr,'o']);
                        %plot(indbuffer(ppin(indices2),1)/fs,-inspikes(indices,ii),['r','.']);
                       end
                
                
            end
        end
    
        
        spkind=[spkind; indbuffer];
        spkamp=[spkamp;ampbuffer];
        offset=offset+length(ampbuffer(:,1));
        ampbuffer=[];
        indbuffer=[];
        clustnum=clustnum+1;
    end
end


        %pltdat;pltscat;
    
    
        if(secondflag)
            insd=inpolygon(spkamp(:,chans(1)),spkamp(:,chans(2)),x,y);
            pp=find(insd==1);
        end       
    
 %{ 
spkind=indvec;
    spkamp=ampvec;


    pltdat;pltscat;
    
    %get chans, x, and y from this .mat file
	%load CLUSTBND
    if(ifn>1)
        insd=inpolygon(spkamp(:,chans(1)),spkamp(:,chans(2)),x,y);
        pp=find(insd==1);

    %this finds the spike times inside the 
    %cluster
	spkind_clust = spkind(pp)/fs; %in seconds
	
    rd=readrecf(fn);
    
    %save this info 
	eval(['save ',fn,'.spkind spkind_clust rd']);
	disp(fn);

%}	
 