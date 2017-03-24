%tafsimtw
%for making templates.

% 'a' is the target note not context notes ('' '')
[avny,t,f]=get_avn(bt,'y',0.05,0.1,'','','obs0'); 

%plot with time, frequency
figure
imagesc(t,f,log(avny));syn;ylim([0,1e4]);

%for template making I plot image without t and freq axis
figure
imagesc(log(avny));syn;

% I choose slice to pull template from.
templa1=mean(avnc(1:2:256,27),2);
size(templa1) %should be 128 point vector  (128 by 1)

%normalize first six values of template to 0.
templa1(1:6)=0;
templa1=templa1./max(templa1);
%check out template with gui
uievtafsim('batch.keep',[templa1]);

%get an idea of the counter values and thresholds you want to use


%generate X.tmp files
%   templ is the template vector, 2 is the pre time of the files
%   get the 2 from the rec file use the same # as the T Before value
mk_tempf('cbinBatch',templa1,2,'obs0');

%build cntrng struct array
%cntrng(index) -> index is the template # if you have one template it's one
%		 template it only equal to one
%This is set up for case where there are three templates.

% Try one set of cntrng values.

%min threshold
cntrng(1).MIN=1;
cntrng(1).MAX=20;
%true/false logic, true->note=0
cntrng(1).NOT=0;
%evtafmode=1; birdtafmode=0;
cntrng(1).MODE=1;
%threshold
cntrng(1).TH=2;
%and/or logic with other templates.
cntrng(1).AND=0;
cntrng(1).BTMIN=0



cntrng(2).MIN=2;
cntrng(2).MAX=3;
cntrng(2).NOT=0;
cntrng(2).MODE=1;
cntrng(2).TH=2.5;
cntrng(2).AND=1;
cntrng(2).BTMIN=0



cntrng(3).MIN=3;
cntrng(3).MAX=4;
cntrng(3).NOT=0;
cntrng(3).MODE=1;
cntrng(3).TH=3;
cntrng(3).AND=0;
cntrng(3).BTMIN=0


cntrng(4).MIN=3;
cntrng(4).MAX=4;
cntrng(4).NOT=0;
cntrng(4).MODE=1;
cntrng(4).TH=3;
cntrng(4).AND=0;
cntrng(4).BTMIN=0

cntrng(5).MIN=3;
cntrng(5).MAX=4;
cntrng(5).NOT=0;
cntrng(5).MODE=1;
cntrng(5).TH=3;
cntrng(5).AND=1;
cntrng(5).BTMIN=0

cntrng(6).MIN=6;
cntrng(6).MAX=18;
cntrng(6).NOT=0;
cntrng(6).MODE=0;
cntrng(6).TH=2;
cntrng(6).AND=1;
cntrng(6).BTMIN=0




%SIMULATION OF TRIGGERING, with those cntrng values.
%example if you has a second template
%do a simulation of the counter ranges to see where it would have triggered
get_trigt2('cbinBatch.keep',cntrng,0.2,128,1,1);


%how well did this template match
[vals,trigs]=triglabel('cbinBatch.keep','w',1,1,0,1);

sum(vals)

   232        234        232
% N match    N note    n trig

%More systematic approach.
% another way to determine the threshold
% loop over a bunch of threshold vales pull out hit rates
tvals=[];
for TH=1.6:-.2:.8
	cntrng(1).TH=TH;
	get_trigt2('batch13comb',cntrng,0.18,128,1,1);
	[vals]=triglabel('batch13comb','b',1,1,0,1);
	tvals=[tvals;TH,sum(vals)];
end

plot(tvals(:,1),tvals(:,2)./tvals(:,3),'bs-')

%pick a TH out of tvals and run triglabel with it
cntrng(1).TH=2;
get_trigt('batch07.keep',cntrng,0.2,128,1,1);  
[vals,trigs]=triglabel('batch07.keep','a',1,1,0,1);

%pull the offsets out of trigs
toff=[];
for ii=1:length(trigs)
	toff=[toff;trigs(ii).toffset];
end

%toff is the trigger offset

figure
imagesc(t,f,log(avna));syn;ylim([0,1e4]);
hold on
plot(mean(toff*1e-3),2000,'k^');
plot((mean(toff)+[-1,1]*std(toff))*1e-3,2000*[1,1],'k-');


%THIS CODE WRITES THE TEMPLATE TO A DATA FILE

wrt_templ('o93o75_c.dat',templa1);

