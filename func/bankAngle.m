function bank = bankAngle(data, t, a, window, tLevel)
%BANKANGLE Querneigung im Zeitfenster aus |a| und IMU-Roll.
%   data   - Tabelle (readRawCSV)
%   t, a   - Zeit [s] und Betrag der Beschleunigung [m/s^2] aus readLoadCellData
%   window - [tStart tEnd] stationärer Kurvenflug [s]
%   tLevel - optional [tStart tEnd] Geradeausflug als Roll-Referenz [s]

    g = 9.81;
    m = t >= window(1) & t <= window(2);

    % Methode 1: aus dem Lastvielfachen
    n = median(a(m)) / g;
    bank.fromAccel = acosd(min(1, 1/n));
    bank.loadFactor = n;

    % Methode 2: IMU-Orientation-Roll
    idx = strcmp(string(data.UID), "6kLMgW") & strcmp(string(data.VAR), "Orientation-Roll");
    tt  = data.TIME(idx);
    if ~isdatetime(tt)
        tt = datetime(string(tt), 'InputFormat', 'MM/dd/yyyy HH:mm:ss.SSS');
    end
    roll = double(data.RAW(idx)) / 16;                 % 1/16 Grad -> Grad
    tr   = seconds(tt - min(toDatetimeAll(data.TIME)));
    % hinweis: Zeitbasis wie in readLoadCellData ist t0 = spätester Start;
    % hier Referenz = erste Zeile der Datei, ggf. Offset anpassen
    mr = tr >= window(1) & tr <= window(2);
    bank.rollMedian = median(roll(mr));
    bank.rollMax    = max(abs(roll(mr)));

    if nargin >= 5 && ~isempty(tLevel)
        ml = tr >= tLevel(1) & tr <= tLevel(2);
        bank.rollOffset = median(roll(ml));
        bank.rollCorrected = bank.rollMedian - bank.rollOffset;
    end

    fprintf('\nLast-Vielfaches n = %.2f -> Querneigung %.1f° (aus |a|)\n', n, bank.fromAccel);
    fprintf('IMU-Roll: Median %.1f°, Max |roll| %.1f°\n', bank.rollMedian, bank.rollMax);
    if isfield(bank, 'rollCorrected')
        fprintf('IMU-Roll nach Offset-Korrektur: %.1f°\n', bank.rollCorrected);
    end
end

function tt = toDatetimeAll(x)
    if isdatetime(x), tt = x;
    else, tt = datetime(string(x), 'InputFormat', 'MM/dd/yyyy HH:mm:ss.SSS'); end
end