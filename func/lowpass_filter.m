function y = lowpass_filter(x, fs, fc, order)
% LOWPASS_FILTER  Lowpass filter for 1D data using zero-phase Butterworth
%   y = LOWPASS_FILTER(x, fs, fc)         uses order = 4
%   y = LOWPASS_FILTER(x, fs, fc, order) specify filter order
%
%   x   : vector (row or column) oder NxM (filtert jede Spalte)
%   fs  : sampling frequency (Hz)
%   fc  : cutoff frequency (Hz) (<= fs/2)
%   order: optional, filter order (default 4)

if nargin < 4 || isempty(order), order = 4; end
if fc <= 0 || fc >= fs/2
    error('Cutoff frequency fc must satisfy 0 < fc < fs/2.');
end

Wn = fc/(fs/2);                 % normalized cutoff (0..1)
[b,a] = butter(order, Wn, 'low');
% apply zero-phase filtering columnwise
if isvector(x)
    y = filtfilt(b,a,double(x(:)))'; % preserve row-vector shape if needed
    if iscolumn(x), y = y.'; end
else
    y = zeros(size(x));
    for c = 1:size(x,2)
        y(:,c) = filtfilt(b,a,double(x(:,c)));
    end
end
end
