function [cellSpeed] = setCellSpeedTaxi(startCell, endCell, v, totalNumberOfCells) 
    cellSpeed = NaN(1,totalNumberOfCells);
    for i = startCell:endCell
        cellSpeed(i) = v;
    end

end