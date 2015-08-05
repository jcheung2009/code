function vlsor = mPitch(bt,NT,PRENT,PSTNT,tbinshft,fbins,NFFT,filetype)

%
% Returns pitch for all notes NT in batch bt measured at time tbinshift
% from start of segmented note.
%
% bt = batch file
% NT = the note of interest
% PRENT + PSTNT = optional pre and post notes to NT
% tbinshift = offset from start of note to measure pitch at, in ms
% fbins = frequency range to compute pitch
% NFFT = window (in points) over which pitch is computed, should be a factor of 2
% filetype = 'obs0', 'wav' etc

 fv=findwnote4(bt,NT,PRENT,PSTNT,tbinshft,fbins,NFFT,1,filetype);
 vlsor=getvals(fv,1,'TRIG');
 [vlsor killpnts] = mSDfilt_vect(vlsor,3);