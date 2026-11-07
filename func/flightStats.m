function T = flightStats(data, t, x, y, a, windows, names, levelWindow)
%FLIGHTSTATS Steuerkräfte und Querneigung für mehrere Zeitfenster.
%   T = flightStats(data, t, xF, yF, a, [11 40; 2 51], ["Links" "Rechts"])
%   T = flightStats(..., levelWindow)   % [tStart tEnd] Geradeausflug als Roll-Referenz
%
%   data    - Tabelle aus readRawCSV
%   t       - Zeitvektor aus readLoadCellData [s]
%   x, y    - Pitch-/Roll-Kraft [N], gefiltert (xF, yF)
%   a       - Betrag der Beschleunigung [m/s^2] aus readLoadCellData
%   windows - N x 2 Matrix, jede Zeile [tStart tEnd] in s (Zeitbasis von t)
%   names   - optional, N Bezeichnungen
%   levelWindow - optional [tStart tEnd] für den IMU-Roll-Offset

    g = 9.81;

    % ---- Eingaben prüfen ----
    if size(windows, 2) ~= 2
        error('windows muss eine N x 2 Matrix sein, jede Zeile [tStart tEnd].');
    end
    N = size(windows, 1);
    if nargin < 7 || isempty(names), names = "Fenster " + (1:N); end
    names = string(names(:));
    if numel(names) ~= N
        error('names braucht %d Einträge (einen je Fenster).', N);
    end
    if nargin < 8, levelWindow = []; end
    t = t(:);  x = x(:);  y = y(:);  a = a(:);

    % ---- IMU-Roll auf die Zeitbasis von t bringen ----
    % readLoadCellData setzt t = 0 beim spätesten ersten Messwert der 5 Signale.
    sig = {"y","Weight"; "29oL","Weight"; "6kLMgW","Acceleration-X"; ...
           "6kLMgW","Acceleration-Y"; "6kLMgW","Acceleration-Z"};
    first = NaT(size(sig,1),1);
    for k = 1:size(sig,1)
        idx = strcmp(string(data.UID), sig{k,1}) & strcmp(string(data.VAR), sig{k,2});
        first(k) = min(toDatetime(data.TIME(idx)));
    end
    tAbs0 = max(first);

    idxR = strcmp(string(data.UID), "6kLMgW") & strcmp(string(data.VAR), "Orientation-Roll");
    haveRoll = any(idxR);
    if haveRoll
        tr   = seconds(toDatetime(data.TIME(idxR)) - tAbs0);
        roll = double(data.RAW(idxR)) / 16;              % 1/16 Grad -> Grad
        rollOffset = 0;
        if ~isempty(levelWindow)
            ml = tr >= levelWindow(1) & tr <= levelWindow(2);
            if any(ml), rollOffset = median(roll(ml)); end
        end
    else
        warning('flightStats:noRoll', 'Keine Orientation-Roll-Daten gefunden.');
    end

    % ---- Auswertung je Fenster ----
    v = @(n) nan(N,1);
    pMean = v(); pP95 = v(); pMax = v();
    rMean = v(); rMeanAbs = v(); rMaxAbs = v();
    nLoad = v(); bankAcc = v(); bankIMU = v(); nPts = zeros(N,1);

    for k = 1:N
        w = windows(k,:);
        if w(1) >= w(2)
            warning('flightStats:window', 'Fenster %d: tStart muss < tEnd sein.', k);
            continue
        end
        m = t >= w(1) & t <= w(2);
        nPts(k) = nnz(m);
        if ~any(m)
            warning('flightStats:window', 'Fenster %d (%.1f-%.1f s): keine Datenpunkte.', k, w(1), w(2));
            continue
        end

        % Kräfte
        pMean(k) = mean(x(m));  pP95(k) = prctile(x(m), 95);  pMax(k) = max(x(m));
        rMean(k) = mean(y(m));  rMeanAbs(k) = mean(abs(y(m)));  rMaxAbs(k) = max(abs(y(m)));

        % Querneigung aus dem Lastvielfachen: n = |a|/g, phi = acos(1/n)
        nLoad(k)   = median(a(m)) / g;
        bankAcc(k) = acosd(min(1, 1/nLoad(k)));

        % Querneigung aus IMU-Roll (Betrag, nach Offset-Korrektur)
        if haveRoll
            mr = tr >= w(1) & tr <= w(2);
            if any(mr), bankIMU(k) = abs(median(roll(mr)) - rollOffset); end
        end
    end

    T = table(names, windows(:,1), windows(:,2), nPts, ...
              pMean, pP95, pMax, rMean, rMeanAbs, rMaxAbs, ...
              nLoad, bankAcc, bankIMU, ...
        'VariableNames', {'Name','tStart','tEnd','nPts', ...
              'PitchMittel','PitchP95','PitchMax', ...
              'RollMittel','RollMittelAbs','RollMaxAbs', ...
              'Lastvielfaches','BankAccel','BankIMU'});

    Td = T;
    for c = 5:width(Td), Td{:,c} = round(Td{:,c}, 2); end
    disp(Td);
end


function time = toDatetime(x)
    if isdatetime(x), time = x;
    else, time = datetime(string(x), 'InputFormat', 'MM/dd/yyyy HH:mm:ss.SSS'); end
end