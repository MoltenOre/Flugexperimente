function [tOut, dataOut] = removeDuplicateTimes(tIn, dataIn, keepOrder)
% removeDuplicateTimes  Entfernt doppelte Zeitstempel, bildet Mittelwerte.
%   [tOut, dataOut] = removeDuplicateTimes(tIn, dataIn)
%   tIn      - Nx1 Zeitvektor (numeric, datetime oder duration)
%   dataIn   - NxM Vektor/Matrix (M Messkanäle)
%   keepOrder - optional logical: true = 'stable' (erste Reihenfolge), 
%               false (default) = sortiere nach Zeit
%
%   Rückgabe:
%   tOut     - Kx1 eindeutige Zeitstempel
%   dataOut  - KxM gemittelte Werte pro Zeitstempel

if nargin<3, keepOrder = false; end
% Sicherstellen Spalten
t = tIn(:);
D = dataIn;
if size(D,1)~=numel(t)
    error('Anzahl Zeilen von dataIn muss Anzahl Zeiten entsprechen.');
end

% Optional sortieren
if ~keepOrder
    [tSorted, sidx] = sort(t);
    D = D(sidx,:);
else
    tSorted = t;
end

% unique und Gruppenindex
[tu, ~, ic] = unique(tSorted);

% Mittelwerte je Gruppe und Spalte
m = size(D,2);
dataOut = zeros(numel(tu), m);
for col = 1:m
    dataOut(:,col) = accumarray(ic, D(:,col), [], @mean);
end

tOut = tu;
end
