function [] = plotHeatMap(temp,startTime,endTime, numberOfTimeSteps)
% to use this function, the array temp needs to be an array of size[rows=numberOfcells, columns=numberOfTimesteps]

% make the startTime and endTime to the strings
startTimeString = matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(startTime);
endTimeString =  matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(endTime);

formatOut = 'HH:MM';
startTimeNum = datenum(datestr(startTimeString,formatOut));
endTimeNum = datenum(datestr(endTimeString,formatOut));

xData = linspace(startTimeNum,endTimeNum,numberOfTimeSteps/30 + 1)

% load the colormap from mycmap.mat 
load('mycmap','cm')
imagesc(temp);
colormap(cm);
colorbar;

% ax = handle(gca);
% ax.XTick = xData;
% datetick('x',formatOut,'keepticks')
% set('XTick',xData)

end