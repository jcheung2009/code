function [out]=ReturnScaledInputs(in)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    global Gain;
    global AmpMode;

    if AmpMode==0
            out=in*Gain.VCInputs;     
    end;
    if AmpMode==1
            out=in*Gain.ICInputs;
    end;
end

