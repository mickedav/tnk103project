function [stdArray] = getStandardDev(compTT, TT)

for i = 1:size(TT,1)
    stdArray(i) = std(compTT - TT(i,:));

end

end