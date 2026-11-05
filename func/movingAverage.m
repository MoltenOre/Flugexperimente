function [x_filtered, y_filtered] = movingAverage(rawX, rawY, t, windowSamples)
% movingAverage  Simple moving-average filter for two signals.
%   [x_filtered, y_filtered] = movingAverage(rawX, rawY, t)
%   uses a default window of 5 samples.
%
%   [x_filtered, y_filtered] = movingAverage(rawX, rawY, t, windowSamples)
%   uses windowSamples (positive integer) as the moving window length.
%
%   Inputs:
%     rawX, rawY - vectors of equal length (Nx1 or 1xN)
%     t          - time vector (kept only for size/validation; not required)
%     windowSamples - optional integer window length (default 5)
%
%   Outputs:
%     x_filtered, y_filtered - filtered vectors with same orientation as inputs

if nargin < 4 || isempty(windowSamples)
    windowSamples = 5;
end
validateattributes(windowSamples, {'numeric'}, {'scalar','integer','positive'});

% Ensure column vectors for processing
wasRow = isrow(rawX);
x = rawX(:);
y = rawY(:);

if numel(x) ~= numel(y) || numel(x) ~= numel(t)
    error('rawX, rawY and t must have the same number of elements.');
end

% Use movmean for efficiency; use 'Endpoints','shrink' to avoid padding
x_f = movmean(x, windowSamples, 'Endpoints', 'shrink');
y_f = movmean(y, windowSamples, 'Endpoints', 'shrink');

% Restore original orientation
if wasRow
    x_filtered = x_f.';
    y_filtered = y_f.';
else
    x_filtered = x_f;
    y_filtered = y_f;
end
end
