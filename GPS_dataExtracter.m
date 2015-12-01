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
import netconfig.*          %Network clases
import util.NetworkAnalysis
import bAE.*                %Output data classes not needed in this example
%import highwayflowmodel.*  %Flow model classes not needed in this example
%import highway.*           %Highway classes not needed in this example

% Setting the network id and configuration id.
NETWORKID = 50;
CONFIGURATIONID = 15001;
linkIdArray = [11269 14136 6189 8568 15256 9150 38698 9160 71687 9198];

%%Create Network
core.Monitor.set_db_env('tal_local')
core.Monitor.set_prog_name('mms_matlab')
core.Monitor.set_nid(NETWORKID);
core.Monitor.set_cid(CONFIGURATIONID);
network = Network();
dbr = DatabaseReader();
analyst = NetworkAnalysis(network);


nbrDays = 4 ;
start_TimeStamp = Time.newTimeFromBerkeleyDateTime(2013,03,4,6,30,59,59)
end_TimeStamp = Time.newTimeFromBerkeleyDateTime(2013,03,4,9,30,0,0)
hoppas = GPSdataExtractor(nbrDays, network, analyst, dbr, linkIdArray, start_TimeStamp, end_TimeStamp);
hatt = squeeze(hoppas(1,:,:));

for i = 1:nbrDays
    hatt = squeeze(hoppas(i,:,:));
    figure(i)
    plotHeatMap(hatt, start_TimeStamp, end_TimeStamp, length(hatt));
end





