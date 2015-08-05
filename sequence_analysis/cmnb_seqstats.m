clear

fid = fopen('batchseqstats','r');

intg_leng = 5

%%%%%%%%%create matrices%%%%%%%%%%%%%%%%%
lklmtrxMst = [];lklmtrxMed = [];PlklmtrxMst = [];PlklmtrxMed = [];maxlklmtrxMst = [];
prbmtrxMst = [];prbmtrxMed = [];PprbmtrxMst = [];PprbmtrxMed = [];maxprbmtrxMst = [];
cnt = 0;
while 1
    crntfile = fscanf(fid,'%s',1);
    if isempty(crntfile)
        break
    end
    load (char(crntfile));cnt = cnt+1;
    lklmtrxMst = [lklmtrxMst; seq_stat.Mst.Lcnts]; prbmtrxMst = [prbmtrxMst; seq_stat.Mst.Pcnts];
    lklmtrxMed = [lklmtrxMed; seq_stat.Med.Lcnts]; prbmtrxMed = [prbmtrxMed; seq_stat.Med.Pcnts];
    PlklmtrxMst = [PlklmtrxMst; seq_stat.Mst.lkl]; PprbmtrxMst = [PprbmtrxMst; seq_stat.Mst.prb];
    PlklmtrxMed = [PlklmtrxMed; seq_stat.Med.lkl]; PprbmtrxMed = [PprbmtrxMed; seq_stat.Med.prb];
    maxlklmtrxMst = [maxlklmtrxMst; [cumsum(seq_stat.Mst.maxP.lkl) nan(1,10-length(seq_stat.Mst.maxP.lkl))]]; 
    maxprbmtrxMst = [maxprbmtrxMst; [cumsum(seq_stat.Mst.maxP.prb) nan(1,10-length(seq_stat.Mst.maxP.lkl))]];
    MaxL_b(cnt) = nlinfit([1:10],maxlklmtrxMst(cnt,:),@myzeroline,.1);
end


%%%%%%%%the pairwise transitions and convergences
MstcumPrb =[zeros(40,1) cumsum(PprbmtrxMst')'];MedcumPrb =[zeros(40,1) cumsum(PprbmtrxMed')'];
MstcumLkl =[zeros(40,1) cumsum(PlklmtrxMst')'];MedcumLkl =[zeros(40,1) cumsum(PlklmtrxMed')'];
MstmuL = mean(MstcumLkl); MststdeL = std(MstcumLkl);MedmuL = mean(MedcumLkl); MedstdeL = std(MedcumLkl);
MstmuP = mean(MstcumPrb); MststdeP = std(MstcumPrb);MedmuP = mean(MedcumPrb); MedstdeP = std(MedcumPrb);


for i = 1:size(lklmtrxMst,1)
    %%%%%%calculate slopes
    MstL_b(i) = nlinfit([1:10],MstcumLkl(i,:),@myzeroline,.1);
    MedL_b(i) = nlinfit([1:10],MedcumLkl(i,:),@myzeroline,.1);
    MstP_b(i) = nlinfit([1:10],MstcumPrb(i,:),@myzeroline,.1);
    MedP_b(i) = nlinfit([1:10],MedcumPrb(i,:),@myzeroline,.1);
end

%histogram calc
[cnt1,val1] = hist(MstL_b);[cnt2,val2] = hist(MedL_b);cnt2 = cnt2./sum(cnt2);cnt1 = cnt1./sum(cnt1);
figure; h1=stairs(val1,cnt1,'k'); hold on;h2=stairs(val2,cnt2,'b');set([h1 h2],'LineW',3);
[cnt3,val3] = hist(MstP_b);[cnt4,val4] = hist(MedP_b);cnt4 = cnt4./sum(cnt4);cnt3 = cnt3./sum(cnt3);
figure; h3=stairs(val3,cnt3,'k'); hold on;h4=stairs(val4,cnt4,'b');set([h3 h4],'LineW',3);

%plotting
MstmuL = mean(MstcumLkl); MststdeL = std(MstcumLkl);MedmuL = mean(MedcumLkl); MedstdeL = std(MedcumLkl);
MstmuP = mean(MstcumPrb); MststdeP = std(MstcumPrb);MedmuP = mean(MedcumPrb); MedstdeP = std(MedcumPrb);
figure; h1 = errorbar(MstmuL,MststdeL,'ko'); hold on; h2 = errorbar(MedmuL,MedstdeL,'bo'); set([h1 h2],'LineW',2);axis tight;
figure; h1 = errorbar(MstmuP,MststdeP,'ko'); hold on; h2 = errorbar(MedmuP,MedstdeP,'bo'); set([h1 h2],'LineW',2);axis tight;




%%%%%%%%%%%%%calculate longer range probabilities and
%%%%%%%%%%%%%likelihoods
for i = 1:size(lklmtrxMst,1)
    for k =1:9
        lklmtrxMed2(i,k) = lklmtrxMed(i,k+1)/(lklmtrxMst(i,k+1)+lklmtrxMed(i,k+1)); 
        lklmtrxMst2(i,k) = lklmtrxMst(i,k+1)/(lklmtrxMst(i,k+1)+lklmtrxMed(i,k+1));
        prbmtrxMed2(i,k) = prbmtrxMed(i,k+1)/(prbmtrxMst(i,k+1)+prbmtrxMed(i,k+1)); 
        prbmtrxMst2(i,k) = prbmtrxMst(i,k+1)/(prbmtrxMst(i,k+1)+prbmtrxMed(i,k+1));
        
%         if  lklmtrxMed2(i,k) > 1
%             lklmtrxMed2(i,k) = 1; end
%         if  prbmtrxMed2(i,k) > 1
%             prbmtrxMed2(i,k) = 1; end
%         if  lklmtrxMst2(i,k) > 1
%             lklmtrxMst2(i,k) = 1; end
%         if  prbmtrxMst2(i,k) > 1
%             prbmtrxMst2(i,k) = 1; end
        
    end
end






for i = 1:size(lklmtrxMst,1)
    for k =1:9
        lklmtrxMst3(i,k) = lklmtrxMst(i,k+1)/lklmtrxMst(i,k); lklmtrxMed3(i,k) = lklmtrxMed(i,k+1)/lklmtrxMst(i,k);
        prbmtrxMed3(i,k) = prbmtrxMed(i,k+1)/prbmtrxMst(i,k); prbmtrxMst3(i,k) = prbmtrxMst(i,k+1)/prbmtrxMst(i,k); 
    end
end

for i = 1:size(lklmtrxMst,1)
    for k =1:9
        lklmtrxMst4(i,k) = lklmtrxMst(i,k+1)/lklmtrxMst(i,1);lklmtrxMed4(i,k) = lklmtrxMed(i,k)/lklmtrxMed(i,1);
        prbmtrxMst4(i,k) = prbmtrxMst(i,k+1)/prbmtrxMst(i,1);prbmtrxMed4(i,k) = prbmtrxMed(i,k+1)/prbmtrxMst(i,1);
    end
end


MstcumPrb =[zeros(40,1) cumsum(PprbmtrxMst')'];MedcumPrb =[zeros(40,1) cumsum(PprbmtrxMed')'];
MstcumLkl =[zeros(40,1) cumsum(PlklmtrxMst')'];MedcumLkl =[zeros(40,1) cumsum(PlklmtrxMed')'];
MstmuL = mean(MstcumLkl); MststdeL = std(MstcumLkl);MedmuL = mean(MedcumLkl); MedstdeL = std(MedcumLkl);
MstmuP = mean(MstcumPrb); MststdeP = std(MstcumPrb);MedmuP = mean(MedcumPrb); MedstdeP = std(MedcumPrb);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MstcumLkl2 = [zeros(40,1) cumsum(lklmtrxMst2')'];
MedcumLkl2 = [zeros(40,1) cumsum(lklmtrxMed2')'];
MstcumPrb2 = [zeros(40,1) cumsum(prbmtrxMst2')'];
MedcumPrb2 = [zeros(40,1) cumsum(prbmtrxMed2')'];
    
MstmuL2 = mean(MstcumLkl2); MststdeL2 = std(MstcumLkl2);MedmuL2 = mean(MedcumLkl2); MedstdeL2 = std(MedcumLkl2);
MstmuP2 = mean(MstcumPrb2); MststdeP2 = std(MstcumPrb2);MedmuP2 = mean(MedcumPrb2); MedstdeP2 = std(MedcumPrb2);

MstcumLkl3 = [zeros(40,1) cumsum(lklmtrxMst3')'];
MedcumLkl3 = [zeros(40,1) cumsum(lklmtrxMed3')'];
MstcumPrb3 = [zeros(40,1) cumsum(prbmtrxMst3')'];
MedcumPrb3 = [zeros(40,1) cumsum(prbmtrxMed3')'];
    
MstmuL3 = mean(MstcumLkl3); MststdeL3 = std(MstcumLkl3); MedmuL3 = mean(MedcumLkl3); MedstdeL3 = std(MedcumLkl3);
MstmuP3 = mean(MstcumPrb3); MststdeP3 = std(MstcumPrb3); MedmuP3 = mean(MedcumPrb3); MedstdeP3 = std(MedcumPrb3);

MstcumLkl4 = [zeros(40,1) cumsum(lklmtrxMst4')'];
MedcumLkl4 = [zeros(40,1) cumsum(lklmtrxMed4')'];
MstcumPrb4 = [zeros(40,1) cumsum(prbmtrxMst4')'];
MedcumPrb4 = [zeros(40,1) cumsum(prbmtrxMed4')'];

MstmuL4 = mean(MstcumLkl4); MststdeL4 = std(MstcumLkl4);MedmuL4 = mean(MedcumLkl4); MedstdeL4 = std(MedcumLkl4);
MstmuP4 = mean(MstcumPrb4); MststdeP4 = std(MstcumPrb4);MedmuP4 = mean(MedcumPrb4); MedstdeP4 = std(MedcumPrb4);


%%%%%%%%likelihoods%%%%%%%%%
Lintgevid2 = mean(MstmuL2([intg_leng:intg_leng+1]))
Lintgevid3 = mean(MstmuL3([intg_leng:intg_leng+1]))
Lintgevid4 = mean(MstmuL4([intg_leng:intg_leng+1]))

%%%%%%%%%%probabilities%%%%%%%%%%%
Pintgevid2 = mean(MstmuP2([intg_leng:intg_leng+1]))
Pintgevid3 = mean(MstmuP3([intg_leng:intg_leng+1]))
Pintgevid4 = mean(MstmuP4([intg_leng:intg_leng+1]))



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% impose integration limit and calculate slopes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%


maxlklmtrxMstIL = maxlklmtrxMst;

for h = 1:cnt
    idxL = find(maxlklmtrxMst(h,:)>Lintgevid2);
    if ~isempty(idxL)
        maxlklmtrxMstIL(h,idxL(1)) = Lintgevid2;%-maxlklmtrxMst(h,idxL(1)-1);
        if length(idxL)>1
            maxlklmtrxMstIL(h,[idxL(2):idxL(end)]) = Lintgevid2;
        end
    end
end



for i = 1:size(lklmtrxMst3)
    %%%%%%%%%%%%%%%%%%%%%%%%%
    MstL2_b(i) = nlinfit([1:10],MstcumLkl2(i,:),@myzeroline,.1);
    MedL2_b(i) = nlinfit([1:10],MedcumLkl2(i,:),@myzeroline,.1);
    MstP2_b(i) = nlinfit([1:10],MstcumPrb2(i,:),@myzeroline,.1);
    MedP2_b(i) = nlinfit([1:10],MedcumPrb2(i,:),@myzeroline,.1);
    
    MstL3_b(i) = nlinfit([1:10],MstcumLkl3(i,:),@myzeroline,.1);
    MedL3_b(i) = nlinfit([1:10],MedcumLkl3(i,:),@myzeroline,.1);
    MstP3_b(i) = nlinfit([1:10],MstcumPrb3(i,:),@myzeroline,.1);
    MedP3_b(i) = nlinfit([1:10],MedcumPrb3(i,:),@myzeroline,.1);
    
    MstL4_b(i) = nlinfit([1:10],MstcumLkl4(i,:),@myzeroline,.1);
    MedL4_b(i) = nlinfit([1:10],MedcumLkl4(i,:),@myzeroline,.1);
    MstP4_b(i) = nlinfit([1:10],MstcumPrb4(i,:),@myzeroline,.1);
    MedP4_b(i) = nlinfit([1:10],MedcumPrb4(i,:),@myzeroline,.1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %mst
    Lcumvect = cumsum(lklmtrxMst3(i,:));
    Pcumvect = cumsum(prbmtrxMst3(i,:));
    idxL = find(Lcumvect>Lintgevid3);
    idxP = find(Pcumvect>Pintgevid3);
    if ~isempty(idxL)
        lklmtrxMst3(i,idxL(1)) = Lintgevid3-Lcumvect(idxL(1)-1);
        if length(idxL)>1
            lklmtrxMst3(i,[idxL(2):idxL(end)]) = zeros(1,length(idxL)-1);
        end
    end
    if ~isempty(idxP)
        prbmtrxMst3(i,idxP(1)) = Pintgevid3-Pcumvect(idxP(1)-1);
        if length(idxP)>1
            prbmtrxMst3(i,[idxP(2):idxP(end)]) = zeros(1,length(idxP)-1);
        end
    end
    
    %med
    Lcumvect = cumsum(lklmtrxMed3(i,:));
    Lidx = find(Lcumvect>Lintgevid3);
    if ~isempty(Lidx)
        lklmtrxMed3(i,Lidx(1)) = Lintgevid3-Lcumvect(Lidx(1)-1);
        if length(Lidx)>1
            lklmtrxMed3(i,[Lidx(2):Lidx(end)]) = zeros(1,length(Lidx)-1);
        end
    end
    
    Pcumvect = cumsum(prbmtrxMed3(i,:));
    Pidx = find(Pcumvect>Pintgevid3);
    if ~isempty(Pidx)
        prbmtrxMed3(i,Pidx(1)) = Pintgevid3-Pcumvect(Pidx(1)-1);
        if length(Pidx)>1
            prbmtrxMed3(i,[Pidx(2):Pidx(end)]) = zeros(1,length(Pidx)-1);
        end
    end


%%%%%%

    %%%mst
    Lcumvect = cumsum(lklmtrxMst4(i,:));
    Pcumvect = cumsum(prbmtrxMst4(i,:));
    idxL = find(Lcumvect>Lintgevid4);
    idxP = find(Pcumvect>Pintgevid4);
    if ~isempty(idxL)
        lklmtrxMst4(i,idxL(1)) = Lintgevid4-Lcumvect(idxL(1)-1);
        if length(idxL)>1
            lklmtrxMst4(i,[idxL(2):idxL(end)]) = zeros(1,length(idxL)-1);
        end
    end
    if ~isempty(idxP)
        prbmtrxMst4(i,idxP(1)) = Pintgevid4-Pcumvect(idxP(1)-1);
        if length(idxP)>1
            prbmtrxMst4(i,[idxP(2):idxP(end)]) = zeros(1,length(idxP)-1);
        end
    end
    
    %%%med
    Lcumvect = cumsum(lklmtrxMed4(i,:));
    Lidx = find(Lcumvect>Lintgevid4);
    if ~isempty(Lidx)
        lklmtrxMed4(i,Lidx(1)) = Lintgevid4-Lcumvect(Lidx(1)-1);
        if length(Lidx)>1
            lklmtrxMed4(i,[Lidx(2):Lidx(end)]) = zeros(1,length(Lidx)-1);
        end
    end
    
    Pcumvect = cumsum(prbmtrxMed4(i,:));
    Pidx = find(Pcumvect>Pintgevid4);
    if ~isempty(Pidx)
        prbmtrxMed4(i,Pidx(1)) = Pintgevid4-Pcumvect(Pidx(1)-1);
        if length(Pidx)>1
            prbmtrxMed4(i,[Pidx(2):Pidx(end)]) = zeros(1,length(Pidx)-1);
        end
    end


%%%%%

    %mst
    Lcumvect = cumsum(lklmtrxMst2(i,:));
    Pcumvect = cumsum(prbmtrxMst2(i,:));
    idxL = find(Lcumvect>Lintgevid2);
    idxP = find(Pcumvect>Pintgevid2);
    if ~isempty(idxL)
        lklmtrxMst2(i,idxL(1)) = Lintgevid2-Lcumvect(idxL(1)-1);
        if length(idxL)>1
            lklmtrxMst2(i,[idxL(2):idxL(end)]) = zeros(1,length(idxL)-1);
        end
    end
    if ~isempty(idxP)
        prbmtrxMst2(i,idxP(1)) = Pintgevid2-Pcumvect(idxP(1)-1);
        if length(idxP)>1
            prbmtrxMst2(i,[idxP(2):idxP(end)]) = zeros(1,length(idxP)-1);
        end
    end
    
    %med
    Lcumvect = cumsum(lklmtrxMed2(i,:));
    Lidx = find(Lcumvect>Lintgevid2);
    if ~isempty(Lidx)
        lklmtrxMed2(i,Lidx(1)) = Lintgevid2-Lcumvect(Lidx(1)-1);
        if length(Lidx)>1
            lklmtrxMed2(i,[Lidx(2):Lidx(end)]) = zeros(1,length(Lidx)-1);
        end
    end
    
    Pcumvect = cumsum(prbmtrxMed2(i,:));
    Pidx = find(Pcumvect>Pintgevid2);
    if ~isempty(Pidx)
        prbmtrxMed2(i,Pidx(1)) = Pintgevid2-Pcumvect(Pidx(1)-1);
        if length(Pidx)>1
            prbmtrxMed2(i,[Pidx(2):Pidx(end)]) = zeros(1,length(Pidx)-1);
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%plotting%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%likelihoods%%%%%

figure; 
%h3 = plot([0 nanmean(maxlklmtrxMst)],'r--'); hold on; 
h1 = plot(MstmuL2,'k--'); 
hold on; h2 = plot(MedmuL2,'--'); axis tight; %set([h1 h2],'LineW',2);
mumstintg = cumsum(mean(lklmtrxMst2));mumedintg = cumsum(mean(lklmtrxMed2));
nrmmst = cumsum(lklmtrxMst2')';%./max(mumstintg);
nrmmed = cumsum(lklmtrxMed2')';%./max(mumedintg));%.*ratio2;
stdemst = [0 std(lklmtrxMst2)]; stdemed = [0 std(lklmtrxMed2)];
hd1 = errorbar([0 mean(nrmmst)],stdemst,'ko'); hold on; hd2 = errorbar([0 mean(nrmmed)],stdemed,'bo'); 
%hd3 = errorbar([0 nanmean(maxlklmtrxMstIL)],[0 nanstd(maxlklmtrxMstIL)],'ro');
set([hd1 hd2],'LineW',2);%set([hd1 hd2 hd3],'LineW',2);
%hd3 = plot([0 nanmean(maxlklmtrxMstIL)],'r');
hd2 = plot([0 mean(nrmmed)],'b');hd1 = plot([0 mean(nrmmst)],'k'); 
set([hd1 hd2],'LineW',2); %set([hd1 hd2 hd3],'LineW',2);
axis([1 10 0 3]); 


%%%%%
figure; h1 = plot(MstmuL3,'k--'); hold on; h2 = plot(MedmuL3,'--'); axis tight; %set([h1 h2],'LineW',2);

mumstintg = cumsum(mean(lklmtrxMst3));mumedintg = cumsum(mean(lklmtrxMed3));
nrmmst = cumsum(lklmtrxMst3')';%./max(mumstintg); 
nrmmed = cumsum(lklmtrxMed3')';%./max(mumedintg));%.*ratio3;
stdemst = [0 std(lklmtrxMst3)]; stdemed = [0 std(lklmtrxMed3)];
hd2 = errorbar([0 mean(nrmmed)],stdemed,'bo');hd1 = errorbar([0 mean(nrmmst)],stdemst,'ko'); set([hd1 hd2],'LineW',2);axis tight; 
hd2 = plot([0 mean(nrmmed)],'b');hd1 = plot([0 mean(nrmmst)],'k'); set([hd1 hd2],'LineW',2);axis tight; axis([1 10 0 4]); 

% %%%%%
% figure; h1 = plot(MstmuL4,'k--'); hold on; h2 = plot(MedmuL4,'--'); axis tight; %set([h1 h2],'LineW',2);
% 
% mumstintg = cumsum(mean(lklmtrxMst4));mumedintg = cumsum(mean(lklmtrxMed4));
% nrmmst = cumsum(lklmtrxMst4')';%./max(mumstintg); 
% nrmmed = cumsum(lklmtrxMed4')';%./max(mumedintg));%.*ratio4;
% stdemst = [0 std(lklmtrxMst4)]; stdemed = [0 std(lklmtrxMed4)];
% hd2 = errorbar([0 mean(nrmmed)],stdemed,'bo');hd1 = errorbar([0 mean(nrmmst)],stdemst,'ko'); set([hd1 hd2],'LineW',2);axis tight; 
% hd2 = plot([0 mean(nrmmed)],'b');hd1 = plot([0 mean(nrmmst)],'k'); set([hd1 hd2],'LineW',2);axis tight; 

%%%%%%%%%%%%%%%%probabilities
%%%%%
figure; hold on; h1 = plot(MstmuP2,'k--'); hold on; h2 = plot(MedmuP2,'--'); axis tight; %set([h1 h2],'LineW',2);

mumstintg = cumsum(mean(prbmtrxMst2));mumedintg = cumsum(mean(prbmtrxMed2));
nrmmst = cumsum(prbmtrxMst2')';%./max(mumstintg);
nrmmed = cumsum(prbmtrxMed2')';%./max(mumedintg));%.*ratio2;
stdemst = [0 std(prbmtrxMst2)]; stdemed = [0 std(prbmtrxMed2)];
hd1 = errorbar([0 mean(nrmmst)],stdemst,'ko'); hold on; hd2 = errorbar([0 mean(nrmmed)],stdemed,'bo'); axis('tight'); set([hd1 hd2],'LineW',2)
hd2 = plot([0 mean(nrmmed)],'b');hd1 = plot([0 mean(nrmmst)],'k'); set([hd1 hd2],'LineW',2);axis tight; axis([1 10 0 4]); 

%%%%%
figure; h1 = plot(MstmuP3,'k--'); hold on; h2 = plot(MedmuP3,'--'); axis tight; %set([h1 h2],'LineW',2);

mumstintg = cumsum(mean(prbmtrxMst3));mumedintg = cumsum(mean(prbmtrxMed3));
nrmmst = cumsum(prbmtrxMst3')';%./max(mumstintg); 
nrmmed = cumsum(prbmtrxMed3')';%./max(mumedintg));%.*ratio3;
stdemst = [0 std(prbmtrxMst3)]; stdmed = [0 stde(prbmtrxMed3)];
hd2 = errorbar([0 mean(nrmmed)],stdemed,'bo');hd1 = errorbar([0 mean(nrmmst)],stdemst,'ko'); set([hd1 hd2],'LineW',2);axis tight; 
hd2 = plot([0 mean(nrmmed)],'b');hd1 = plot([0 mean(nrmmst)],'k'); set([hd1 hd2],'LineW',2);axis tight; axis([1 10 0 4]); 

% % %%%%%
% figure; h1 = plot(MstmuP4,'k--'); hold on; h2 = plot(MedmuP4,'--'); axis tight; %set([h1 h2],'LineW',2);
% 
% mumstintg = cumsum(mean(prbmtrxMst4));mumedintg = cumsum(mean(prbmtrxMed4));
% nrmmst = cumsum(prbmtrxMst4')';%./max(mumstintg); 
% nrmmed = cumsum(prbmtrxMed4')';%./max(mumedintg));%.*ratio4;
% stdemst = [0 std(prbmtrxMst4)]; stdemed = [0 std(prbmtrxMed4)];
% hd2 = errorbar([0 mean(nrmmed)],stdemed,'bo');hd1 = errorbar([0 mean(nrmmst)],stdemst,'ko'); set([hd1 hd2],'LineW',2);axis tight; 
% hd2 = plot([0 mean(nrmmed)],'b');hd1 = plot([0 mean(nrmmst)],'k'); set([hd1 hd2],'LineW',2);axis tight; 





%%%%%%%%%%%histogram calculations
%histogram calc
Mmu = nanmean(MaxL_b); Mstd = nanstd(MaxL_b);
% 
% [cnt1,val1] = hist(MstL2_b,10);[cnt2,val2] = hist(MedL2_b,10);[cnt3,val3] = hist(MaxL_b,4)
% cnt2 = cnt2./sum(cnt2);cnt1 = cnt1./sum(cnt1);cnt3 = cnt3./sum(cnt3);
% 
mu1 = mean(MstL2_b); mu2 = mean(MedL2_b);std1 = std(MstL2_b);std2 = std(MedL2_b);
nrm1 = normpdf([0:.02:1],mu1,std1); nrm1 = nrm1./sum(nrm1);
nrm2 = normpdf([0:.02:1],mu2,std2);nrm2 = nrm2./sum(nrm2);
%nrm3 = normpdf([0:.01:1],Mmu,Mstd);nrm3 = nrm3./sum(nrm3);
figure; hold on; h2=plot([0:.02:1],nrm2,'b');% h(3)=plot([0:.01:1],nrm3,'r'); 
h1=plot([0:.02:1],nrm1,'k');
h4 = plot(median(MstL2_b),max(nrm1),'ko');h5 = plot(median(MedL2_b),max(nrm2),'bo'); 
%h(6) = plot(median(Mmu),max(nrm3),'ro');
set([h1 h2 h4 h5],'LineW',3);

[cnt3,val3] = hist(MstP2_b,10);[cnt4,val4] = hist(MedP2_b,10);cnt4 = cnt4./sum(cnt4);cnt3 = cnt3./sum(cnt3);
figure; h3=stairs(val3,cnt3,'k'); hold on;h4=stairs(val4,cnt4,'b');set([h3 h4],'LineW',3);

[cnt1,val1] = hist(MstL3_b);[cnt2,val2] = hist(MedL3_b);cnt2 = cnt2./sum(cnt2);cnt1 = cnt1./sum(cnt1);
figure; h1=stairs(val1,cnt1,'k'); hold on;h2=stairs(val2,cnt2,'b');set([h1 h2],'LineW',3);
[cnt3,val3] = hist(MstP3_b);[cnt4,val4] = hist(MedP3_b);cnt4 = cnt4./sum(cnt4);cnt3 = cnt3./sum(cnt3);
figure; h3=stairs(val3,cnt3,'k'); hold on;h4=stairs(val4,cnt4,'b');set([h3 h4],'LineW',3);

% [cnt1,val1] = hist(MstL4_b);[cnt2,val2] = hist(MedL4_b);cnt2 = cnt2./sum(cnt2);cnt1 = cnt1./sum(cnt1);
% figure; h1=stairs(val1,cnt1,'k'); hold on;h2=stairs(val2,cnt2,'b');set([h1 h2],'LineW',3);
% [cnt3,val3] = hist(MstP4_b);[cnt4,val4] = hist(MedP4_b);cnt4 = cnt4./sum(cnt4);cnt3 = cnt3./sum(cnt3);
% figure; h3=stairs(val3,cnt3,'k'); hold on;h4=stairs(val4,cnt4,'b');set([h3 h4],'LineW',3);



