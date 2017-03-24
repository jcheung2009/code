function vals = evtaf_freq_script(bt,template,fbins,NT,NFFT,CS,makeX,USEX);
% vals = evtaf_freq_script(bt,template,fbins,NT,NFFT,CS,makeX,USEX);
% vals=[vals;fn2datenum(fn),tempvals,IND,filenum];
%
%  bt - batch file
%  template - spectral template
%  fbins - [Min Freq, Max Freq] to search for peaks (in Hz)
%  NT - target note
%  NFFT - length of template 
%  CS - chan spec
%  makeX - set to 1 if you want to use simulated triggers, otherwise set to
%  0 for triggers recorded by evTaf suring acquisition.
%  USEX - if == 1 look in X.rec for trigger times
% 
%   returns vals - 
%   vals=[datenum of file , FREQ vals , Note Index , file number];
% usage example:
%  vals=evtaf_freq('batch.train',[5000,6000],'a',128,'obs0',0);

if(makeX == 1)
    mk_tempf(bt,template,2,CS);
    
    %build cntrng struct array
    %cntrng(index) -> index is the template # if you have one template it's one
    %		 template it only equal to one
    %This is set up for case where there are three templates.
    
    % Try one set of cntrng values.
    
    %min threshold
    cntrng(1).MIN=2;
    cntrng(1).MAX=10;
    %true/false logic, true->note=0
    cntrng(1).NOT=0;
    %evtafmode=1; birdtafmode=0;
    cntrng(1).MODE=1;
    %threshold
    cntrng(1).TH=2;
    %and/or logic with other templates.
    cntrng(1).AND=0;
    cntrng(1).BTMIN=0
    
    get_trigt2(bt,cntrng,0.2,128,1,makeX);
    vals =  evtaf_freq(bt,fbins,NT,NFFT,CS,1);
else
    vals =  evtaf_freq(bt,fbins,NT,NFFT,CS,USEX);
end


