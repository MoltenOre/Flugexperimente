clear; clc; close all;

%% ===================== SETTINGS =========================
addpath(genpath('func'));
dataFolder  = './Daten/SteepTurn/';
fileIdx     = 3;            % which file(s): 1, 1:3, or 'all'

f_cutoff    = 3;          % FFT cutoff frequency [Hz]
sgWindow    = 201;          % Savitzky-Golay window [samples]

% Plot switches
plotRawData = true;        % show raw data in the plots
showLoad    = true;         % load cell plots
showFFT     = true;        % FFT plots
showGPS     = true;         % GPS velocity
showAlt     = true;         % altitude check
showAcc     = true;
showBank    = true;
showFligtStats = true;

rotateInput = true;

showForce   = false;
%tWindow     = [2,51];      
%tWindow     = [11,40]; %Steep Turn Left    
%tWindow     = [2,51]; %Steep Right        

saveFig     = true;
aspectRatio = 4/3;



%% WindUp
%tWindow  = [9 12.5; 21 25; 29 34.5; 37.5 42; 43.8 47.8]; %R
%tWindow  = [15.5 21; 27.5 30.5; 34 37.5; 44 47.5; 50.5 55]; %L
%tWindow  = [35.5 38.5; 44.5 48.5; 50.5 53.5; 57 61.5; 64 67]; %2
%names = ["10°" "20°" "30°" "45°" "60°"];

%% Speed Variation
tWindow     = [1,200];%34;42
names       = ["Acceleration", "Deacceleration"];

%% Stall
%tWindow     = [3 55]; %l1
%tWindow     = [23,55];%r2
%tWindow     = [5,57]; %Flaps
%names       = ["Stall"];

winStall    = tWindow;
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
    plotFolder  = "./Plots/"+erase(dataFolder, './Daten/')+plotTitle;

    [t, rawX, rawY, rawXY, Fs, ax, ay, az, a] = readLoadCellData(data);

    % ---- Filter: FFT low-pass, then Savitzky-Golay ----
    [xF, yF] = filterData(rawX, rawY, t, Fs, f_cutoff);
    xF = smoothdata(xF, 'sgolay', sgWindow);
    yF = smoothdata(yF, 'sgolay', sgWindow);
    xyF = hypot(xF, yF);

    % ---- Plots ----
    if rotateInput
        xF0 = xF;  yF0 = yF;                                   % Originale merken
    
        % Drehung bestimmen und anwenden
        [xF, yF, phi] = derotateForces(t, xF0, yF0, winStall);
        fprintf('Drehkorrektur %s: %.1f°\n', Name, rad2deg(phi));
    
        % Dieselbe Drehung auf die Rohdaten (nur nötig, wenn plotRawData = true)
        if plotRawData
            rawXr =  rawX*cos(phi) + rawY*sin(phi);
            rawYr = -rawX*sin(phi) + rawY*cos(phi);
            rawX = rawXr;  rawY = rawYr;
        end
        % Vorher / Nachher nebeneinander
        m = t >= winStall(1) & t <= winStall(2);
        figRot1 = figure('Color','w','Units','centimeters','Position',[2 2 18 8]);
        tl = tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
        title(tl, ['Kraftrichtung, ' erase(Name,'.csv')], 'Interpreter','none');
    
        nexttile;
        scatter(xF0(m), yF0(m), 6, t(m), 'filled'); colorbar;
        axis equal; grid on;
        xlabel('X [N]'); ylabel('Y [N]'); title('Vor der Drehung');
    
        nexttile;
        scatter(xF(m), yF(m), 6, t(m), 'filled'); cb = colorbar; cb.Label.String = 'Time [s]';
        axis equal; grid on;
        xlabel('X [N]'); ylabel('Y [N]'); title(sprintf('Nach der Drehung (%.1f°)', rad2deg(phi)));
    
        % Zeitverlauf der Pitch-Kraft vorher / nachher
        if saveFig
            saveFigure(figRot1, plotFolder, plotTitle + "_Rotation_Scatter", 18, 8);
        end

        figRot2 = figure('Color','w','Units','centimeters','Position',[2 2 15 15/aspectRatio]);
        hold on; grid on;
        plot(t, xF0, 'DisplayName', 'vorher');
        plot(t, xF,  'DisplayName', 'nachher');
        xline(winStall, '--k', 'HandleVisibility', 'off');
        xlabel('Time [s]'); ylabel('Pitch-Kraft [N]'); legend;
        if saveFig
            saveFigure(figRot2, plotFolder, plotTitle + "_Rotation_Verlauf", 15, 15/aspectRatio);
        end
    end

    if showLoad
        plotLoadCells(t, rawX, rawY, xF, yF, rawXY, xyF, plotRawData, Name, saveFig, plotFolder, aspectRatio,15, plotTitle);
    end
    if showFFT
        plotFFT(rawX, rawY, xF, yF, Fs, f_cutoff, t, Name, plotRawData, ...
                saveFig, plotFolder, aspectRatio, 15);
    end
    if showGPS
        plotGPSVelocity(data, 0.05, 30, 'SaveFig', saveFig, 'OutputFolder', plotFolder, ...
                        'AspectRatio', aspectRatio, 'Name', Name);
    end
    if showAlt
        plotAltitudeData(data, 0.05, 'SaveFig', saveFig, 'OutputFolder', plotFolder, ...
                         'AspectRatio', aspectRatio, 'Name', Name);
    end
    if showAcc
        plotAcceleration(t, ax, ay, az, a, Name, ...
        'SaveFig', saveFig, 'OutputFolder', plotFolder, ...
        'AspectRatio', 4/3, 'InG', true, 'Smooth', 5, ...
        'Title', Name);
    end
    if showFligtStats
        T = flightStats(data, t, xF, yF, a, tWindow, names);
        flightStatsLatex(T, 'Caption', plotTitle, ...
                    'Label', "tab:"+replace(replace(plotTitle,", "," ")," ", "_"), 'Clipboard', true, 'Bank',false);
    end 
    if showForce
        forceStats(t, xF, yF, tWindow, Name);
    end
    if showBank
        bank = bankAngle(data, t, a, tWindow);
    end
    
end