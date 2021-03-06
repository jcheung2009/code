function [pitch_data tm f avsp]=jc_pitchcontourFV2(dat,N,OVERLAP,sigma,F_low,F_high,harms,filetype)
%F_low and F_high are the boundary frequencies in which to look for a peak
%in the autocorrelation function (i.e. in which to calculate the pitch at
%each point in time).
%dat = amplitude envelope for each syllable, samples x renditions

% F_low and F_high set the FF range to look for peaks within
% harms are the harmonics to take the weighted average of pitch within
    % (weighted by power at that harmonic)
% sigma of ~1 is optimal for Bengalese song, ~2 is optimal for Zebra song ---
    % the reason for this is the optimal sigma (as determined by the
    % Consensus function in the Gardner/Magnasco papers) is inversely
    % related to the sparseness of the signal (i.e. the width in Hz between
    % harmonics)  --- If your curves for Bengalese song look choppy at
    % sigma=1, the song is probably noisy due to probes/etc. and you should
    % increase the sigma.  There is a rigorous but slow way to do this - 
    % let me know if you want to do it. A decent alternative is just to
    % increas it until the curves look smooth.
    
%jc_pitchcontourFV(fvals,1024,1020,1,2800,4200,[1],'obs0');


m=size(dat);
NumberOfNotes=m(2);

%Parameters that one may want to change.
if strcmp(filetype,'obs0')
    SAMPLING=32000; 
else SAMPLING=44100;
end

%sonodvA program
t=-N/2+1:N/2;
sigma=(sigma/1000)*SAMPLING;
%Gaussian and first derivative as windows.
w=exp(-(t/sigma).^2);
timebins=floor((size(dat,1)-(N))/(N-OVERLAP))+1;
freqbins=(N/2)+1;

Nyquist=SAMPLING/2;
step=Nyquist/freqbins; %hz per bin
mini=round(F_high/step);
maxi=round(F_low/step);
highest_harmonic=1; 

sonogram=zeros(freqbins,timebins);
pitch_data=zeros(timebins,NumberOfNotes);
for found_note=1:NumberOfNotes
    
    [sonogram f tm] =spectrogram(dat(:,found_note),w,OVERLAP,N,SAMPLING); %gaussian windowed spectrogram
    if found_note == 1
        avsp = abs(sonogram);
    else
        avsp = avsp + abs(sonogram);
    end
    sonogram=abs(flipdim(sonogram,1));
    

    %This loop determines the pitch (fundamental frequency) at each time bin by
    %taking the peak of the autocorrelation function within a range specified
    %by the user
    for currenttime_bin=1:size(sonogram,2)
        slice=sonogram(:,currenttime_bin); %power at each frequency for the current time bin
        Powerful(1)=0;
        Freqbinest(1)=0;
        for i=1:length(harms)
            minimum=freqbins-mini*harms(i);  %finds range of bins to look for max power 
            maximum=freqbins-maxi*harms(i);     %flipdim on sonogram 
            freq_window=slice(minimum:maximum);
            [Pow,Ind]=max(freq_window);  

            if Ind==1 || Ind==length(freq_window)
                Indest=Ind;
            else
                Indest=pinterp([Ind-1;Ind;Ind+1], [freq_window(Ind-1);freq_window(Ind);freq_window(Ind+1)]);
            end
            Real_Index=minimum+Indest-1; % -1 to account for window;
            Freqbinest(i)=(freqbins-Real_Index)/harms(i);
            Powerful(i)=Pow;
        end
        normalizer=sum(Powerful);
        normpower=Powerful/normalizer;
        freqbin_estimate(currenttime_bin)=dot(normpower,Freqbinest);
    end
    pitch_data(:,found_note)=freqbin_estimate*(Nyquist/(freqbins-1));
end

avsp = avsp./NumberOfNotes;


