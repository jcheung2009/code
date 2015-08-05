function mSplice(target,insert,onset,pad)
%
%  splices insert into target vector at point onset, with pad points on
%  either side. Assumes insert contains pad points.
%
%
%

startpnt = onset-pad;
stoppnt = startpnt + length(insert);

target(startpnt:stoppnt) = insert;