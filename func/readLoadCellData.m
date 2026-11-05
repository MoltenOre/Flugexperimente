function [t, x, y, xy, ax, ay, az, a, Fs] = readLoadCellData(data)
%READLOADCELLDATA Load cell (X/Y) and IMU acceleration from a data table.
%
% Input:
%   data - table with columns TIME, NAME, UID, VAR, RAW, UNIT
%          (e.g. from readRawCSV)
%
% Outputs:
%   t        - common time vector [s]
%   x, y     - X / Y load-cell signal
%   xy       - magnitude of x and y
%   ax,ay,az - IMU acceleration [m/s^2]
%   a        - acceleration magnitude [m/s^2]
%   Fs       - sampling frequency [Hz]

    m       = 0.001;        % load-cell scaling factor
    UID_X   = "y";
    UID_Y   = "29oL";
    UID_IMU = "6kLMgW";

    % Reference time (first sample of the whole file)
    tRef = min(toDatetime(data.TIME));

    % ---------------------------------------------------------
    % Read signals (time in s, sorted, duplicates averaged)
    % ---------------------------------------------------------
    [tX,  rawX ] = getSignal(data, UID_X,   "Weight",         tRef, 'X load cell');
    [tY,  rawY ] = getSignal(data, UID_Y,   "Weight",         tRef, 'Y load cell');
    [tAX, rawAX] = getSignal(data, UID_IMU, "Acceleration-X", tRef, 'X acceleration');
    [tAY, rawAY] = getSignal(data, UID_IMU, "Acceleration-Y", tRef, 'Y acceleration');
    [tAZ, rawAZ] = getSignal(data, UID_IMU, "Acceleration-Z", tRef, 'Z acceleration');

    % ---------------------------------------------------------
    % Time origin: latest first sample of all signals
    % ---------------------------------------------------------
    t0 = max([tX(1), tY(1), tAX(1), tAY(1), tAZ(1)]);
    tX = tX - t0;  tY = tY - t0;
    tAX = tAX - t0;  tAY = tAY - t0;  tAZ = tAZ - t0;

    % ---------------------------------------------------------
    % Sampling interval (median of all signals)
    % ---------------------------------------------------------
    dt = median([median(diff(tX)),  median(diff(tY)), ...
                 median(diff(tAX)), median(diff(tAY)), median(diff(tAZ))]);

    % ---------------------------------------------------------
    % Common time range
    % ---------------------------------------------------------
    tStart = max([tX(1),   tY(1),   tAX(1),   tAY(1),   tAZ(1)]);
    tEnd   = min([tX(end), tY(end), tAX(end), tAY(end), tAZ(end)]);
    t = (tStart:dt:tEnd)';

    % ---------------------------------------------------------
    % Interpolate load cells and apply scaling
    % ---------------------------------------------------------
    x = interp1(tX, rawX, t, 'linear') * m;
    y = interp1(tY, rawY, t, 'linear') * m;

    % ---------------------------------------------------------
    % Interpolate acceleration (1/100 m/s^2 -> m/s^2)
    % ---------------------------------------------------------
    ax = interp1(tAX, rawAX, t, 'linear') / 100;
    ay = interp1(tAY, rawAY, t, 'linear') / 100;
    az = interp1(tAZ, rawAZ, t, 'linear') / 100;

    a = sqrt(ax.^2 + ay.^2 + az.^2);

    % Weight the load cells with the acceleration magnitude
    x = x .* a;
    y = y .* a;
    xy = sqrt(x.^2 + y.^2);

    Fs = 1 / dt;
end


%% ---------- Helpers ----------
function [t, v] = getSignal(data, uid, var, tRef, label)
    idx = strcmp(string(data.UID), uid) & strcmp(string(data.VAR), var);
    if ~any(idx)
        error('No %s data found (UID %s, %s).', label, uid, var);
    end

    time = toDatetime(data.TIME(idx));
    v = data.RAW(idx);
    if ~isnumeric(v)
        v = str2double(string(v));
    end
    v = double(v);

    ok = ~isnan(v);                          % drop NaN values
    time = time(ok);  v = v(ok);

    [time, s] = sort(time);  v = v(s);       % sort by time
    [time, ~, g] = unique(time);             % average duplicate timestamps
    v = accumarray(g, v, [], @mean);

    t = seconds(time - tRef);
end

function time = toDatetime(x)
    if isdatetime(x)
        time = x;
    else
        time = datetime(string(x), 'InputFormat', 'MM/dd/yyyy HH:mm:ss.SSS');
    end
end