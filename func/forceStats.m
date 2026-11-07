function stats = forceStats(t, x, y, window, name)
%FORCESTATS Kennwerte der Steuerknüppelkräfte in einem Zeitfenster.
%   stats = forceStats(t, x, y, [tStart tEnd])
%   stats = forceStats(t, x, y, [tStart tEnd], 'Linkskurve')
%
%   t      - Zeitvektor [s]
%   x, y   - Pitch- (X) und Roll-Kraft (Y) [N], gefiltert
%   window - [tStart tEnd] in s
%   name   - optionale Bezeichnung für die Ausgabe
%
%   Ausgabe: Struktur mit den Feldern pitchMean, pitchP95, pitchMax,
%            rollMean, rollMeanAbs, rollMaxAbs, n

    if nargin < 5, name = ''; end
    if numel(window) ~= 2 || window(1) >= window(2)
        error('window muss [tStart tEnd] mit tStart < tEnd sein.');
    end

    m = t >= window(1) & t <= window(2);
    if ~any(m)
        error('Keine Datenpunkte im Fenster [%.1f %.1f] s.', window(1), window(2));
    end
    xw = x(m);
    yw = y(m);

    stats.pitchMean   = mean(xw);
    stats.pitchP95    = prctile(xw, 95);
    stats.pitchMax    = max(xw);
    stats.rollMean    = mean(yw);
    stats.rollMeanAbs = mean(abs(yw));
    stats.rollMaxAbs  = max(abs(yw));
    stats.n           = nnz(m);

    if nargout == 0 || ~isempty(name)
        if ~isempty(name), fprintf('--- %s ', name); end
        fprintf('(Fenster %.1f-%.1f s) ---\n', window(1), window(2));
        fprintf('Pitch: Mittel %.1f, P95 %.1f, Max %.1f N\n', ...
                stats.pitchMean, stats.pitchP95, stats.pitchMax);
        fprintf('Roll:  Mittel %.1f, Mittel|F| %.1f, Max|F| %.1f N\n', ...
                stats.rollMean, stats.rollMeanAbs, stats.rollMaxAbs);
    end
end