function outliers(batch, maxpitch,minpitch);

foutliers = fopen([batch,'.outliers'],'w')

bt = batch;

tbinshft= 0.025;
NFFT=512;%number of data points to FFTstrcmd=strcat('!cd ' dir{i})
fbins=[3000 4000];
%save BINS_B NFFT fbins tbinshft
% frequency analysis just for 'b'
%load BINS_B
NT='w';PRENT='';PSTNT='';
    
       % edges=[6000:75:8000];
    
        fv=findwnote4(bt,NT,PRENT,PSTNT,tbinshft,fbins,NFFT,1,'obs0');
        
for i = 1:length(fv)
    if fv(i).mxvals(2) > maxpitch || fv(i).mxvals(2) < minpitch 
        fprintf(foutliers, '%s\n', fv(i).fn)
    end
end

fclose(foutliers);


    
    
        

