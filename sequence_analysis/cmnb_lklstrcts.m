function [] =cmnb_seqstats(batchseqstats)

fid = fopen(batchlkl,'r');

lklmtrxMst = [];lklmtrxMed = [];
prbmtrxMst = [];prbmtrxMed = [];

while 1
    crntfile = fscanf(fid,'%s',1);
    if isempty(crntfile)
        break
    end
    load (char(crntfile));
    lklmtrxMst = [lklmtrxMst; seq_stats.Mst.lkl]; prbmtrxMst = [prbmtrxMst; seq_stats.Mst.prb];
    lklmtrxMed = [lklmtrxMed; seq_stats.Med.lkl]; prbmtrxMed = [prbmtrxMed; seq_stats.Med.prb];
end


for i = 1:size(lklmtrxMst,1)
    for k =1:9
        lklmtrxMed2(i,k) = lklmtrxMed(i,k+1)/lklmtrxMst(i,k);
        lklmtrxMst2(i,k) = lklmtrxMst(i,k+1)/lklmtrxMst(i,k);
        
        
    end
end

for i = 1:size(lklmtrxMst,1)
    for k =1:9
        lklmtrxMst3(i,k) = lklmtrxMst(i,k+1)/lklmtrxMst(i,k);
        lklmtrxMed3(i,k) = lklmtrxMed(i,k+1)/lklmtrxMed(i,k);
        
        
    end
end

for i = 1:size(lklmtrxMst,1)
    for k =1:9
        lklmtrxMst4(i,k) = lklmtrxMst(i,k+1)/lklmtrxMst(i,1);
        lklmtrxMed4(i,k) = lklmtrxMed(i,k+1)/lklmtrxMed(i,1);
        
        
    end
end



mumst2 = cumsum(mean(lklmtrxMst2));
mumed2 = cumsum(mean(lklmtrxMed2));
mumst3 = cumsum(mean(lklmtrxMst3));
mumed3 = cumsum(mean(lklmtrxMed3));
mumst4 = cumsum(mean(lklmtrxMst4));
mumed4 = cumsum(mean(lklmtrxMed4));


ratio = mean(mumed2)./mean(mumst2)
intgevid = mumst2(5)

% for i = 1:size(lklmtrxMst2)
%     idx = find(cumsum(lklmtrxMst2(i,:))>intgevid);
%     if ~isempty(idx)
%         lklmtrxMst2(i,idx) = zeros(1,length(idx));
%     end
%     idx = find(cumsum(lklmtrxMed2(i,:))>intgevid);
%     if ~isempty(idx)
%         lklmtrxMed2(i,idx) = zeros(1,length(idx));
%     end
% end

%lklmtrxMed3 = lklmtrxMed3.*ratio;

for i = 1:size(lklmtrxMst3)
    cumvect = cumsum(lklmtrxMst3(i,:));
    idx = find(cumvect>intgevid);
    if ~isempty(idx)
        lklmtrxMst3(i,idx(1)) = intgevid-cumvect(idx(1)-1);
        if length(idx)>1
            lklmtrxMst3(i,[idx(2):idx(end)]) = zeros(1,length(idx)-1);
        end
    end
    cumvect = cumsum(lklmtrxMed3(i,:));
    idx = find(cumvect>intgevid);
    if ~isempty(idx)
        lklmtrxMed3(i,idx(1)) = intgevid-cumvect(idx(1)-1);
        if length(idx)>1
            lklmtrxMed3(i,[idx(2):idx(end)]) = zeros(1,length(idx)-1);
        end
    end
end

for i = 1:size(lklmtrxMst2)
    cumvect = cumsum(lklmtrxMst2(i,:));
    idx = find(cumvect>intgevid);
    if ~isempty(idx)
        lklmtrxMst2(i,idx(1)) = intgevid-cumvect(idx(1)-1);
        if length(idx)>1
            lklmtrxMst2(i,[idx(2):idx(end)]) = zeros(1,length(idx)-1);
        end
    end
    cumvect = cumsum(lklmtrxMed2(i,:));
    idx = find(cumvect>intgevid);
    if ~isempty(idx)
        lklmtrxMed2(i,idx(1)) = intgevid-cumvect(idx(1)-1);
        if length(idx)>1
            lklmtrxMed2(i,[idx(2):idx(end)]) = zeros(1,length(idx)-1);
        end
    end
end


figure; plot(mumst2,'r'); hold on; plot(mumed2);

mumstintg = cumsum(mean(lklmtrxMst2));mumedintg = cumsum(mean(lklmtrxMed2));
nrmmst = cumsum(lklmtrxMst2')'./max(mumstintg); nrmmed = (cumsum(lklmtrxMed2')'./max(mumedintg)).*ratio;
stdemst = [0 stde(lklmtrxMst2)]; stdemed = [0 stde(lklmtrxMed2)];

figure; hd1 = errorbar([0 mean(nrmmst)],stdemst,'rs'); hold on; hd2 = errorbar([0 mean(nrmmed)],stdemed,'bd'); axis('tight'); set([hd1 hd2],'LineW',2)

figure; plot(mumst3,'r'); hold on; plot(mumed3);

mumstintg = cumsum(mean(lklmtrxMst3));mumedintg = cumsum(mean(lklmtrxMed3));
mxmst = max(mumstintg)
mxmed = max(mumedintg)
nrmmst = cumsum(lklmtrxMst3')'./max(mumstintg); nrmmed = (cumsum(lklmtrxMed3')'./mxmed).*1;
stdemst = [0 stde(lklmtrxMst3)]; stdemed = [0 stde(lklmtrxMed3)];

figure; hold on; hd2 = errorbar([0 mean(nrmmed)],stdemed,'bo'); axis([.8 10.2 -.02 1.1]); hd1 = errorbar([0 mean(nrmmst)],stdemst,'ko'); set([hd1 hd2],'LineW',2)
