function plotGPSVelocity(data, cutoffFreq, maxDeviation, options)
    % data:         table with columns TIME, NAME, UID, VAR, RAW, UNIT
    % cutoffFreq:   FFT low-pass cutoff [Hz]          (default 0.15)
    % maxDeviation: max. position deviation of an outlier [m] (default 30)
    % Name-Value options:
    %   SaveFig, OutputFolder, AspectRatio, WidthCm, Name (Dateiname-Prefix)
    arguments
        data table
        cutoffFreq   (1,1) double  = 0.05
        maxDeviation (1,1) double  = 30
        options.SaveFig      (1,1) logical = false
        options.OutputFolder (1,1) string  = "./Plots/"
        options.AspectRatio  (1,1) double  = 15/11
        options.WidthCm      (1,1) double  = 15
        options.Name         (1,1) string  = "Flight"
    end

    %% Select GPS data (UID PvU)
    idxLat = strcmp(string(data.UID), "PvU") & strcmp(string(data.VAR), "Coordinates-Latitude");
    idxLon = strcmp(string(data.UID), "PvU") & strcmp(string(data.VAR), "Coordinates-Longitude");

    if ~any(idxLat) || ~any(idxLon)
        warning('plotGPSVelocity:noData', 'No GPS data found.');
        return
    end

    %% Common time origin (first sample of the whole file)
    t0 = min(toDatetime(data.TIME));

    %% Prepare latitude / longitude (sorted, duplicates averaged)
    [tLat, latRaw] = prepSignal(data(idxLat,:), t0);
    [tLon, lonRaw] = prepSignal(data(idxLon,:), t0);
    latRaw = latRaw / 1e6;
    lonRaw = lonRaw / 1e6;

    %% Uniform time base
    tStart = max(tLat(1),   tLon(1));
    tEnd   = min(tLat(end), tLon(end));

    dt = max(median(diff(tLat)), median(diff(tLon)));
    Fs = 1 / dt;
    tPos = (tStart:dt:tEnd)';

    lat = interp1(tLat, latRaw, tPos, 'linear');
    lon = interp1(tLon, lonRaw, tPos, 'linear');

    %% Outlier detection via position deviation
    n = numel(lat);
    bad = false(n,1);
    for k = 2:n-1
        alpha = (tPos(k)-tPos(k-1)) / (tPos(k+1)-tPos(k-1));
        latPred = lat(k-1) + alpha * (lat(k+1)-lat(k-1));
        lonPred = lon(k-1) + alpha * (lon(k+1)-lon(k-1));
        if haversine(lat(k), lon(k), latPred, lonPred) > maxDeviation
            bad(k) = true;
        end
    end
    valid = ~bad;
    lat(bad) = interp1(tPos(valid), lat(valid), tPos(bad), 'linear');
    lon(bad) = interp1(tPos(valid), lon(valid), tPos(bad), 'linear');

    %% FFT low-pass
    if cutoffFreq >= Fs/2
        error('cutoffFreq must be smaller than Fs/2 (= %.3g Hz).', Fs/2);
    end
    lat = fftLowpass(lat, Fs, cutoffFreq);
    lon = fftLowpass(lon, Fs, cutoffFreq);

    %% Velocity
    distance = haversine(lat(1:end-1), lon(1:end-1), lat(2:end), lon(2:end));
    v_kmh = distance / dt * 3.6;
    tVel  = (tPos(1:end-1) + tPos(2:end)) / 2;

    %% Plot
    heightCm = options.WidthCm / options.AspectRatio;
    fig = figure('Color', 'w', 'Units', 'centimeters', ...
                 'Position', [2 2 options.WidthCm heightCm]);
    plot(tVel, v_kmh, 'LineWidth', 1.2);
    grid on;
    xlabel('Time [s]');
    ylabel('Velocity [km/h]');
    title(sprintf('Filtered GPS Velocity (FFT cutoff %.3g Hz)', cutoffFreq));

    %% Save as SVG
    if options.SaveFig
        saveFigure(fig, options.OutputFolder, erase(options.Name, ".csv") + "_GPS", ...
                   options.WidthCm, heightCm);
    end
end


%% ---------- Helpers ----------
function time = toDatetime(x)
    if isdatetime(x)
        time = x;
    else
        time = datetime(string(x), 'InputFormat', 'MM/dd/yyyy HH:mm:ss.SSS');
    end
end

function [t, v] = prepSignal(sd, t0)
    time = toDatetime(sd.TIME);
    v = double(sd.RAW);

    ok = ~isnan(v);
    time = time(ok);  v = v(ok);

    [time, s] = sort(time);  v = v(s);
    [time, ~, g] = unique(time);
    v = accumarray(g, v, [], @mean);

    t = seconds(time - t0);
end

function d = haversine(lat1, lon1, lat2, lon2)
    R = 6371000;
    lat1 = deg2rad(lat1);
    lat2 = deg2rad(lat2);
    dLat = lat2 - lat1;
    dLon = deg2rad(lon2 - lon1);
    a = sin(dLat/2).^2 + cos(lat1).*cos(lat2).*sin(dLon/2).^2;
    d = 2*R*atan2(sqrt(a), sqrt(1-a));
end

function y = fftLowpass(x, Fs, cutoffFreq)
    x = x(:);
    N = numel(x);
    mu = mean(x);
    x = x - mu;

    xExt = [x; flipud(x)];            % symmetric extension (edge effects)
    NExt = numel(xExt);

    X = fft(xExt);
    f = (0:NExt-1)' * Fs / NExt;
    X(~((f <= cutoffFreq) | (f >= Fs - cutoffFreq))) = 0;

    yExt = real(ifft(X));
    y = yExt(1:N) + mu;
end