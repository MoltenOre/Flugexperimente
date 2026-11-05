%% Cut a section from a CSV file based on time

% Input / Output
src = "./Daten/F3/MessDaten_F3_WindUp_Stal   l.csv";
dst = "./Daten/cut_out/Stall_Flaps.csv";

% Start and end time in seconds relative to the first timestamp
startSec = 690;
endSec   = 823;

% Timestamp format in the first field
fmt = "MM/dd/yyyy HH:mm:ss.SSS";

%% Read the CSV

% Read the table while keeping the original column names
T = readtable(src, "VariableNamingRule", "preserve");

% Get the first column (timestamps)
timestamps = T{:,1};

% Convert timestamps to datetime if necessary
if ~isdatetime(timestamps)
    timestamps = datetime(timestamps, "InputFormat", fmt);
end

%% Calculate time relative to the first timestamp

t0 = timestamps(1);

timeSec = seconds(timestamps - t0);

%% Select the desired section

keep = timeSec >= startSec & timeSec <= endSec;

T_cut = T(keep, :);

%% Create output directory if it does not exist

[outDir, ~, ~] = fileparts(dst);

if ~exist(outDir, "dir")
    mkdir(outDir);
end

%% Write the cut data

writetable(T_cut, dst);

%% Display information

fprintf("Original rows: %d\n", height(T));
fprintf("Cut rows:      %d\n", height(T_cut));
fprintf("Start time:    %.3f s\n", startSec);
fprintf("End time:      %.3f s\n", endSec);
fprintf("Output file:   %s\n", dst);