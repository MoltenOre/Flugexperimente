function [x_filtered,y_filtered] = filterData(rawX,rawY, t, Fs, f_cutoff)
%FILTERDATA Summary of this function goes here
%   Detailed explanation goes here
%% ===================== MITTELWERT ENTFERNEN ===================

x_mean = mean(rawX);
y_mean = mean(rawY);

x_centered = rawX - x_mean;
y_centered = rawY - y_mean;


%% ===================== FFT ===================================

N = length(t);

X = fft(x_centered);
Y = fft(y_centered);


%% ===================== FREQUENZACHSE ==========================

f = (0:N-1)' * Fs/N;


%% ===================== FREQUENZFILTER =========================

% Positive und negative Frequenzen behalten,
% alles oberhalb von f_cutoff entfernen.

filterMask = ...
    (f <= f_cutoff) | ...
    (f >= Fs - f_cutoff);


X_filtered = X .* filterMask;
Y_filtered = Y .* filterMask;


%% ===================== RÜCKTRANSFORMATION =====================

x_filtered = real(ifft(X_filtered));
y_filtered = real(ifft(Y_filtered));


% Mittelwert wieder hinzufügen
x_filtered = x_filtered + x_mean;
y_filtered = y_filtered + y_mean;

%fprintf('\n----------------------------------------\n');
%fprintf('Abtastfrequenz:  %.3f Hz\n', Fs);
%fprintf('Nyquist:         %.3f Hz\n', Fs/2);
%fprintf('Cutoff:          %.3f Hz\n', f_cutoff);
%fprintf('----------------------------------------\n');


if f_cutoff >= Fs/2
    error(['f_cutoff muss kleiner als die Nyquist-Frequenz ' ...
           'sein!']);
end

end