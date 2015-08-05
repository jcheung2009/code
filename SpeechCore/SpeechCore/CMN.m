function NormMatrix = CMN(Matrix)
%Author:        Olutope Foluso Omogbenigun
%Email:         olutopeomogbenigun at hotmail.com
%University:    London Metropolitan University
%Date:          27/07/07
%Syntax:        NormalisedMatrix = CMN(Matrix);
%This function accepts the feature vector matrix as input and
%returns a cesptral mean normalised version of the input matrix


[r,c]=size(Matrix);
NormMatrix=zeros(r,c);
for i=1:c
    MatMean=mean(Matrix(:,i));  %Derives mean for each column i in utterance
    NormMatrix(:,i)=Matrix(:,i)-MatMean; %Subtracts mean from each element in
                                         %column i
end
