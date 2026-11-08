function m = inWindows(t, windows)
%INWINDOWS Logische Maske: true, wenn t in mindestens einem Fenster liegt.
%   m = inWindows(t, [11 40])            % ein Fenster
%   m = inWindows(t, [1 34; 42 200])     % mehrere Fenster (N x 2)
    if size(windows, 2) ~= 2
        error('windows muss eine N x 2 Matrix sein, jede Zeile [tStart tEnd].');
    end
    m = false(size(t));
    for k = 1:size(windows, 1)
        m = m | (t >= windows(k,1) & t <= windows(k,2));
    end
end
