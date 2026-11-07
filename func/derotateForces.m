function [xr, yr, phi] = derotateForces(t, x, y, window)
%DEROTATEFORCES Dreht (x,y) so, dass die Hauptkraftrichtung auf der X-Achse liegt.
%   Annahme: im Fenster überwiegt die Pitch-Kraft.
    m = t >= window(1) & t <= window(2);
    C = cov([x(m) y(m)]);
    [V, D] = eig(C);
    [~, i] = max(diag(D));
    v = V(:, i);
    phi = atan2(v(2), v(1));                  % Winkel der Hauptrichtung [rad]
    xr =  x*cos(phi) + y*sin(phi);
    yr = -x*sin(phi) + y*cos(phi);
    % Vorzeichen: Ziehen (größere Spitzen) soll positiv sein
    if prctile(xr(m), 95) < -prctile(xr(m), 5)
        xr = -xr;  yr = -yr;  phi = phi + pi;
    end
    fprintf('Geschätzte Drehung: %.1f°\n', rad2deg(phi));
end