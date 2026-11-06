clear; clc; close all;

%% ===================== SETTINGS =========================
addpath(genpath('func'));
dataFolder  = './Daten/WindUp/';
plotTitle = "WindUp Turn Left, Flaps 0";
fileIdx     = 1;            % which file(s): 1, 1:3, or 'all'

f_cutoff    = 2;          % FFT cutoff frequency [Hz]
sgWindow    = 201;          % Savitzky-Golay window [samples]

% Plot switches
plotRawData = false;        % show raw data in the plots
showLoad    = true;         % load cell plots
showFFT     = false;        % FFT plots
showGPS     = true;         % GPS velocity
showAlt     = true;         % altitude check
showAcc     = true;

saveFig     = true;
aspectRatio = 4/3;
plotFolder = "./Plots/"+erase(dataFolder, './Daten/');

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
end