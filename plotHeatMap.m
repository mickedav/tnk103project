
function [] = plotHeatMap(temp,startTime,endTime, numberOfTimeSteps,titleString)
% to use this function, the array temp needs to be an array of size[rows=numberOfcells, columns=numberOfTimesteps]

% replace all NaN:s with zeros in order to get a nice plot with the same
% colors on the colorbar
temp(isnan(temp)) = 0;

% the preferred time step (in minutes) between the ticks on the x-axis
timeStep = 30;

% make the startTime and endTime to the strings
startTimeString = matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(startTime);
endTimeString =  matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(endTime);

formatOut = 'HH:MM';
startTimeNum = datenum(datestr(startTimeString,formatOut));
endTimeNum = datenum(datestr(endTimeString,formatOut));

% determine how many ticks that the x-axis is going to have
ticks = numberOfTimeSteps/timeStep + 1;

% defines the ticks between startTime and endTime
xDataNum = linspace(startTimeNum,endTimeNum,ticks);

% convert xDataNum to a string cell array xDataStr with element on the
% format 'HH:MM'
xDataStr = cell(ticks,1);
for i=1:(ticks)
    xDataStr{i} =[datestr(xDataNum(i),formatOut)];
end

% load the saved color map from mycmap.mat and plot temp
load('mycmap','cm')
imagesc(temp);
colormap(cm);
c=colorbar;

% set the tick labels on the x-axis
set(gca,'XLim',[0 numberOfTimeSteps])
set(gca,'XTick',[0:timeStep:numberOfTimeSteps])
set(gca,'XTickLabel',xDataStr)

formatOut = 'yyyy-mm-dd';

if strcmp(titleString,'date')
    startTimestr = datestr(startTimeString,formatOut);
else
    startTimestr = titleString;
end

title(startTimestr)
xlabel('time')
ylabel('cell ID')
ylabel(c,'km/h')
% set(c, 'ylim', [0 100])

end