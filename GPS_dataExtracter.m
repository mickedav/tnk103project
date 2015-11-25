% This script is an example of how to get dynamic parameters from the MMS
% database.

%% Setup

% Adding a path to the top folder.
%addpath(genpath('H:\TNK103\KOD'),'-end');
clear all
import core.*               %Core classes


% Setting the enviroment (i.e loading all jar files)
% We do not wanna set the enviroment if it is allready set.
try
    Time(); % This is just to see if the import was successful.
catch
    setEnviroment
end

% Importing all java classes that will be used.
import java.lang.*          %String classes
import java.util.*          %Wrapper classes
import core.*               %Core classes
import matrix.*             %Matrix classes
import netconfig.*          %Network clases
import bAE.*               %Output data classes not needed in this example
import highwaycommon.*      %Parameter classes
%import highwayflowmodel.*  %Flow model classes not needed in this example
%import highway.*           %Highway classes not needed in this example

% Setting the network id and configuration id.
NETWORKID = 50;
CONFIGURATIONID = 15001;
linkIdArray = [11269 14136 6189 8568 15256 9150 38698 9160 71687 9198];

core.Monitor.set_db_env('tal_local')
core.Monitor.set_prog_name('mms_matlab')
core.Monitor.set_nid(NETWORKID);
core.Monitor.set_cid(CONFIGURATIONID);

network = Network();
import util.NetworkAnalysis
dbr = DatabaseReader();
analyst = NetworkAnalysis(network);

query = ['SELECT * FROM info24_feed.taxi_tt '...
    'WHERE(startlid = 11269 OR startlid = 14136 '...
    'OR startlid = 6189 OR startlid = 8568 '...
    'OR startlid = 15256 OR startlid = 9150 OR startlid = 38698 '...
    'OR startlid = 9160 OR startlid = 71687 OR startlid = 9198) '...
    'AND(endlid = 11269 OR endlid = 14136 OR endlid = 6189 OR endlid = 8568 '...
    'OR endlid = 15256 OR endlid = 9150 OR endlid = 38698 '...
    'OR endlid = 9160 OR endlid = 71687 OR endlid = 9198) '...
    'AND DATE(start_time) = ''2013-03-21'' AND isvalid '...
    'ORDER BY start_time LIMIT 100'];

%   query = 'SELECT * FROM info24_feed.taxi_tt WHERE(startlid = 11269 OR startlid = 14136 OR startlid = 6189 OR startlid = 8568 OR startlid = 15256 OR startlid = 9150 OR startlid = 38698 OR startlid = 9160 OR startlid = 71687 OR startlid = 9198) AND(endlid = 11269 OR endlid = 14136 OR endlid = 6189 OR endlid = 8568 OR endlid = 15256 OR endlid = 9150 OR endlid = 38698 OR endlid = 9160 OR endlid = 71687 OR endlid = 9198)AND DATE(start_time) = "2013-03-21" AND isvalid ORDER BY start_time';
query = String(query);
dbr.psCreate(String('test'),query);

try
    dbr.psQuery(String('test'));
catch
    'NOOOOOOOO!!!!!'
end

%dbr.psRSNext('test')
start_TimeStamp = Time.newTimeFromBerkeleyDateTime(2013,03,21,0,0,0,0);

wantedDataInt = [String('startlid'), String('endlid'), String('traveltime')];
wantedDataDouble = [String('start_offset'), String('end_offset')];
wantedDataTimeStamp = [String('start_time'), String('end_time')];

row = 1;
intData = zeros(110,10);
doubleData = zeros(110,10);
timeStampData = zeros(110,10);
bajskorv = 0; 
while bajskorv < 10
    dbr.psRSNext('test');
    for i = 1:size(wantedDataInt)
        intData(row,i) = dbr.psRSGetInteger('test',wantedDataInt(i));
    end
    
    for i = 1:size(wantedDataDouble)
        doubleData(row,i) = dbr.psRSGetDouble('test',wantedDataDouble(i));
    end
    
    for i = 1:size(wantedDataTimeStamp)
        time_stamp_temp = TimeInterval(start_TimeStamp, dbr.psRSGetTimestamp('test', wantedDataTimeStamp(i)));
        timeStampData(row,i) = time_stamp_temp.get_time_interval_duration;

    end
%         test_start = dbr.psRSGetTimestamp('test', wantedDataTimeStamp(1));   
%         test_end = dbr.psRSGetTimestamp('test', wantedDataTimeStamp(2));
%         timeStampData(row,i) = TimeInterval(start_TimeStamp, test_start) 
        %timeStampData(row,i) = dbr.psRSGetTimestamp('test',wantedDataTimeStamp(i));
     
    row = row + 1;
    bajskorv = bajskorv + 1;
end


a = Spot(network.getLinkWithID(intData(1,1)), doubleData(1,1), -1);
b = Spot(network.getLinkWithID(intData(1,2)), doubleData(1,2), -1);
travelTime = intData(1,3);
% 
route = analyst.extractRoute(a,b);
route.getRouteLength;
% 
v = (route.getRouteLength/travelTime)*3.6;


[numberOfCells, cellSize, lengthStretch, totalNumberOfCells] = getCellMap(network, linkIdArray);

startCell = getCellId(a, linkIdArray, numberOfCells, cellSize);
endCell = getCellId(b, linkIdArray, numberOfCells, cellSize);
k = setCellSpeedTaxi(startCell, endCell, v, totalNumberOfCells);



