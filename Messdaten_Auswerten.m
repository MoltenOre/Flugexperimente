clear; clc; close all;

%% ===================== SETTINGS =========================
addpath(genpath('func'));
dataFolder  = './Daten/WindUp/';
fileIdx     = 3;            % which file(s): 1, 1:3, or 'all'

f_cutoff    = 4;          % FFT cutoff frequency [Hz]
sgWindow    = 201;          % Savitzky-Golay window [samples]

% Plot switches
plotRawData = false;        % show raw data in the plots
showLoad    = true;         % load cell plots
showFFT     = false;        % FFT plots
showGPS     = false;         % GPS velocity
showAlt     = false;         % altitude check
showAcc     = true;
showBank    = false;
showFligtStats = true;

showForce   = false;
%tWindow     = [2,51];      
%tWindow     = [11,40]; %Steep Turn Left    
%tWindow     = [2,51]; %Steep Right        

saveFig     = true;
aspectRatio = 4/3;
plotFolder  = "./Plots/"+erase(dataFolder, './Daten/');


%% WindUp
tWindow  = [9 12.5; 21 25; 29 34.5; 37.5 42; 43.8 47.8]; %R
%tWindow  = [15.5 21; 27.5 30.5; 34 37.5; 44 47.5; 50.5 55]; %L
%tWindow  = [35.5 38.5; 44.5 48.5; 50.5 53.5; 57 61.5; 64 67]; %2
names = ["10°" "20°" "30°" "45°" "60°"];


%% ===================== FILES =========================
files = dir(fullfile(dataFolder, '*.csv'));
if ischar(fileIdx) || isstring(fileIdx)      % 'all'
    fileIdx = 1:numel(files);
end

%% ===================== EVALUATION =========================
for i = fileIdx

    % ---- Read ----
    filename = fullfile(files(i).folder, files(i).name);
    Name     = files(i).name;
    data     = readRawCSV(filename);
    plotTitle= erase(Name,".csv");

    [t, rawX, rawY, rawXY, Fs, ax, ay, az, a] = readLoadCellData(data);

    % ---- Filter: FFT low-pass, then Savitzky-Golay ----
    [xF, yF] = filterData(rawX, rawY, t, Fs, f_cutoff);
    xF = smoothdata(xF, 'sgolay', sgWindow);
    yF = smoothdata(yF, 'sgolay', sgWindow);
    xyF = hypot(xF, yF);

    % ---- Plots ----
    if showLoad
        plotLoadCells(t, rawX, rawY, xF, yF, rawXY, xyF, plotRawData, Name, saveFig, plotFolder, aspectRatio,15, plotTitle);
    end
    if showFFT
        plotFFT(rawX, rawY, xF, yF, Fs, f_cutoff, t, Name, plotRawData);
    end
    if showGPS
        plotGPSVelocity(data);
    end
    if showAlt
        plotAltitudeData(data);
    end
    if showAcc
        plotAcceleration(t, ax, ay, az, a, Name, ...
        'SaveFig', saveFig, 'OutputFolder', plotFolder, ...
        'AspectRatio', 4/3, 'InG', true, 'Smooth', 5, ...
        'Title', {'WindUp Left', 'Klappen: Stufe 0'});
    end
    if showFligtStats
        T = flightStats(data, t, xF, yF, a, tWindow, names);
        flightStatsLatex(T, 'Caption', plotTitle, ...
                    'Label', "tab:"+replace(replace(plotTitle,", "," ")," ", "_"), 'Clipboard', true);
    end 
    if showForce
        forceStats(t, xF, yF, tWindow, Name);
    end
    if showBank
        bank = bankAngle(data, t, a, tWindow);
    end
end