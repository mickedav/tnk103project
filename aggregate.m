function [speedDataAggregated] = aggregate(speedData, endSec, totalNumberOfCells)
        speedDataAggregated = squeeze(nanmean(speedData,1));
end
