clear;
clc;
close all;

%% ===================== EINSTELLUNGEN =========================

dataFolder = './Daten/F4/';
files = dir(fullfile(dataFolder, '*.csv'));
%i = 4;
% FFT-Grenzfrequenz [Hz]
f_cutoff = 3.5;

plotRawData = false;
for i = 1%1:length(files)
    
%%% ===================== Daten Lesen =========================  
    filename = fullfile(files(i).folder,files(i).name);
    Name = files(i).name;  
    
    data = readRawCSV(filename);

    [t, rawX, rawY, rawXY, rawAX, rawAY, rawAz, a, Fs] = readLoadCellData(data);
    x_filtered = rawX;
    y_filtered = rawY;



%%% ===================== FFT Filtern =========================  

    [x_filtered,y_filtered] = filterData(x_filtered, y_filtered, t, Fs, f_cutoff);

%%%===================== Savitzky-Golay-Filter ========================= 
    
    x_filtered = smoothdata(x_filtered, 'sgolay', 201);
    y_filtered = smoothdata(y_filtered, 'sgolay', 201);

%%%===================== Daten Plotten ========================= 
    xy_filtered = sqrt(x_filtered.^2+y_filtered.^2);
    
    
    plotLoadCells(t, rawX, rawY, x_filtered,y_filtered, ...
                           rawXY, xy_filtered, plotRawData,Name)
    
    %plotFFT(rawX,rawY,x_filtered,y_filtered,Fs,f_cutoff,t,Name,plotRawData);
    

 %%%===================== GPS =========================   
 plotGPSVelocity(data);  

 %%%===================== Alti =========================  
 PlotAltitudeData(data);


end