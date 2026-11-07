function plotFFT(rawX, rawY, x_filtered,y_filtered, ...
                Fs,f_cutoff, t,Name,plotRawData, ...
                saveFig, outputFolder, aspectRatio, widthCm)
%PLOTFFT Plot X and Y FFT in two vertically stacked graphs.
%
% Inputs:
%   fftData      - structure containing FFT data
%   frequencies  - automatically detected vibration frequencies
%   Fs           - sampling frequency [Hz]
%   saveFig      - true: save figure as SVG        (default false)
%   outputFolder - target folder                   (default './Plots/')
%   aspectRatio  - width/height                    (default 15/11)
%   widthCm      - figure width in cm              (default 15)

    if nargin < 10 || isempty(saveFig),      saveFig = false;           end
    if nargin < 11 || isempty(outputFolder), outputFolder = './Plots/'; end
    if nargin < 12 || isempty(aspectRatio),  aspectRatio = 15/11;       end
    if nargin < 13 || isempty(widthCm),      widthCm = 15;              end
    Name = erase(Name, ".csv");
    heightCm = widthCm / aspectRatio;

   %% ============================================================
% FFT - RAW VS FILTERED
% ============================================================

% Raw FFT
X_raw_fft = fft(rawX - mean(rawX));
Y_raw_fft = fft(rawY - mean(rawY));

% Filtered FFT
X_filtered_fft = fft(x_filtered - mean(x_filtered));
Y_filtered_fft = fft(y_filtered - mean(y_filtered));

N = length(t);
% Positive frequencies
nHalf = floor(N/2);

f = (0:N-1)' * Fs/N;
f_positive = f(1:nHalf);


% Amplitudes
X_raw_amp = 2 * abs(X_raw_fft(1:nHalf)) / N;
Y_raw_amp = 2 * abs(Y_raw_fft(1:nHalf)) / N;

X_filtered_amp = 2 * abs(X_filtered_fft(1:nHalf)) / N;
Y_filtered_amp = 2 * abs(Y_filtered_fft(1:nHalf)) / N;


%% FFT X

fig = figure('Name',"FFT"+Name,'NumberTitle','off','Color','w', ...
             'Units','centimeters','Position',[2 2 widthCm heightCm]);
subplot(2,1,1);


if plotRawData
    plot(f_positive, X_raw_amp, '--', ...
        'LineWidth', 0.9);
    hold on;
end

plot(f_positive, X_filtered_amp, ...
    'LineWidth', 1.3);
hold on;
xline(f_cutoff, '--', ...
    'Cutoff Frequency');

grid on;

xlabel('Frequency [Hz]');
ylabel('Amplitude');

title('FFT - X');

if plotRawData
    legend('Raw X','Filtered X','Cutoff');
else
    legend('Filtered X','Cutoff');
end

xlim([0 Fs/2]);


%% FFT Y


subplot(2,1,2);

if plotRawData
    plot(f_positive, Y_raw_amp, '--', ...
        'LineWidth', 0.9);
    hold on;
end

plot(f_positive, Y_filtered_amp, ...
    'LineWidth', 1.3);

xline(f_cutoff, '--', ...
    'Cutoff Frequency');

grid on;

xlabel('Frequency [Hz]');
ylabel('Amplitude');

title('FFT - Y');

if plotRawData
    legend('Raw Y','Filtered Y','Cutoff');
else
    legend('Filtered Y','Cutoff');
end

xlim([0 Fs/2]);

%% Save as SVG
if saveFig
    saveFigure(fig, outputFolder, Name + "_FFT", widthCm, heightCm);
end

end
