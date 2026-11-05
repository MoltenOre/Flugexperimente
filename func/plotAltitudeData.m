function plotAltitudeData(data, fc_gps)
    % data:   table with columns TIME, NAME, UID, VAR, RAW, UNIT
    % fc_gps: FFT cutoff for GPS altitude [Hz] (default 0.05 Hz = 20 s period)
    if nargin < 2, fc_gps = 0.05; end
%thisi s test
    % ---- common time origin ----
    allTime = data.TIME;
    if ~isdatetime(allTime)
        allTime = datetime(string(allTime), 'InputFormat', 'MM/dd/yyyy HH:mm:ss.SSS');
    end
    t0 = min(allTime);

    figure; hold on; grid on;
    leg = {};

    % ---- Barometric altitude ----
    idxP = strcmp(string(data.UID), "Joj") & strcmp(string(data.VAR), "Air Pressure");
    if any(idxP)
        [tP, p] = prepSignal(data(idxP,:), t0);
        p = p / 100;                                   % hPa
        altBaro = 44330 * (1 - (p / 1013.25).^(1/5.255));
        altBaro = smoothdata(altBaro, 'movmean', 1, 'SamplePoints', tP);  % 1 s window
        %altBaro = altBaro - altBaro(1);
        plot(tP, altBaro, 'LineWidth', 1.2);
        leg{end+1} = 'Barometric';
    else
        warning('No air pressure data found.');
    end

    % ---- GPS altitude (FFT filtered) ----
    idxG = strcmp(string(data.UID), "PvU") & strcmp(string(data.VAR), "Altitude-Altitude");
    if any(idxG)
        [tG, h] = prepSignal(data(idxG,:), t0);
        h = h / 100;                                   % cm -> m
        h = filloutliers(h, 'linear', 'movmedian', 5, 'SamplePoints', tG);  % spikes
        [tGu, hf] = fftLowpass(tG, h, fc_gps);
        %hf = hf - hf(1);
        plot(tGu, hf, 'LineWidth', 2);
        leg{end+1} = sprintf('GPS (FFT, %.3g Hz)', fc_gps);
    else
        warning('No GPS altitude data found.');
    end

    xlabel('Time [s]');
    ylabel('Relative altitude [m]');
    title('Altitude check: barometer vs. GPS');
    if ~isempty(leg), legend(leg, 'Location', 'best'); end
end

function [tu, yf] = fftLowpass(t, v, fc)
    % Resample to uniform grid, detrend, FFT low-pass, add trend back
    dt = median(diff(t));
    Fs = 1 / dt;
    tu = (t(1):dt:t(end))';
    vu = interp1(t, v, tu, 'linear');

    N = numel(vu);
    pf = polyfit(tu, vu, 1);                 % linear trend
    trend = polyval(pf, tu);
    x = vu - trend;

    X = fft(x);
    f = (0:N-1)' * Fs / N;
    fsym = min(f, Fs - f);                   % symmetric frequency axis
    X(fsym > fc) = 0;                        % remove everything above cutoff

    yf = real(ifft(X)) + trend;
end

function [t, v] = prepSignal(sd, t0)
    time = sd.TIME;
    if ~isdatetime(time)
        time = datetime(string(time), 'InputFormat', 'MM/dd/yyyy HH:mm:ss.SSS');
    end
    v = double(sd.RAW);

    ok = ~isnan(v);
    time = time(ok);  v = v(ok);

    [time, s] = sort(time);  v = v(s);
    [time, ~, g] = unique(time);
    v = accumarray(g, v, [], @mean);

    t = seconds(time - t0);
end