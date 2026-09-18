// ================================================================
// VIBRAGUARD V2
// MACHINE HEALTH MONITORING DASHBOARD
// ================================================================

clc;
clear;
close;

exec("vibration_data.sci", -1);
exec("fault_detection.sci", -1);


// ================================================================
// GLOBAL SETTINGS
// ================================================================

Fs = 1000;
duration = 10;

numMachines = 20;


// ================================================================
// GENERATE DATASET
// ================================================================

disp("Generating machine dataset...");

[machines, labels, conditions, rpm, temperature, hours] = ...
    generate_dataset();


// ================================================================
// ADD CONDITION PROPERTY TO STRUCTURES
// ================================================================

for i = 1:numMachines

    machines(i).condition = conditions(i);

end


// ================================================================
// CREATE CSV
// ================================================================

create_csv(machines, rpm, temperature, hours);


// ================================================================
// MAIN GUI WINDOW
// ================================================================

fig = figure( ...
    "figure_name", "VIBRAGUARD - Machine Health Monitoring", ...
    "position", [50 50 1250 720], ...
    "background", [0.94 0.95 0.97]);


// ================================================================
// HEADER
// ================================================================

uicontrol(fig, ...
    "style", "text", ...
    "string", "VIBRAGUARD", ...
    "position", [30 675 300 35], ...
    "fontsize", 22, ...
    "fontweight", "bold", ...
    "background", [0.10 0.20 0.30], ...
    "foreground", [1 1 1]);

uicontrol(fig, ...
    "style", "text", ...
    "string", "Machine Health & Fault Detection System", ...
    "position", [330 680 500 25], ...
    "fontsize", 14, ...
    "background", [0.94 0.95 0.97]);


// ================================================================
// LEFT PANEL
// ================================================================

leftPanel = uicontrol(fig, ...
    "style", "frame", ...
    "position", [20 80 250 575], ...
    "background", [0.88 0.90 0.93]);


// ================================================================
// MACHINE SELECTOR
// ================================================================

uicontrol(fig, ...
    "style", "text", ...
    "string", "SELECT MACHINE", ...
    "position", [40 610 200 25], ...
    "fontsize", 12, ...
    "fontweight", "bold", ...
    "background", [0.88 0.90 0.93]);

machineNames = [];

for i = 1:numMachines

    machineNames(i) = machines(i);

end


machineList = uicontrol(fig, ...
    "style", "listbox", ...
    "string", machineNames, ...
    "position", [40 425 200 180], ...
    "fontsize", 11, ...
    "background", [1 1 1]);


// ================================================================
// ANALYZE BUTTON
// ================================================================

analyzeButton = uicontrol(fig, ...
    "style", "pushbutton", ...
    "string", "ANALYZE MACHINE", ...
    "position", [40 380 200 40], ...
    "fontsize", 12);


// ================================================================
// EXPORT BUTTON
// ================================================================

exportButton = uicontrol(fig, ...
    "style", "pushbutton", ...
    "string", "EXPORT DATASET", ...
    "position", [40 330 200 40], ...
    "fontsize", 11);


// ================================================================
// MACHINE INFO
// ================================================================

uicontrol(fig, ...
    "style", "text", ...
    "string", "MACHINE INFORMATION", ...
    "position", [40 290 200 25], ...
    "fontsize", 11, ...
    "fontweight", "bold", ...
    "background", [0.88 0.90 0.93]);

infoText = uicontrol(fig, ...
    "style", "text", ...
    "string", "Select a machine", ...
    "position", [40 150 200 130], ...
    "fontsize", 10, ...
    "background", [0.88 0.90 0.93]);


// ================================================================
// STATUS AREA
// ================================================================

statusText = uicontrol(fig, ...
    "style", "text", ...
    "string", "STATUS: READY", ...
    "position", [40 95 200 40], ...
    "fontsize", 12, ...
    "fontweight", "bold", ...
    "background", [0.88 0.90 0.93]);


// ================================================================
// DASHBOARD METRICS
// ================================================================

uicontrol(fig, ...
    "style", "text", ...
    "string", "MACHINE HEALTH", ...
    "position", [300 610 180 25], ...
    "fontsize", 12, ...
    "fontweight", "bold");

healthValue = uicontrol(fig, ...
    "style", "text", ...
    "string", "--", ...
    "position", [300 565 180 45], ...
    "fontsize", 20, ...
    "fontweight", "bold", ...
    "background", [0.85 0.90 0.95]);


// RMS
uicontrol(fig, ...
    "style", "text", ...
    "string", "RMS", ...
    "position", [500 610 120 25], ...
    "fontsize", 11, ...
    "fontweight", "bold");

rmsValue = uicontrol(fig, ...
    "style", "text", ...
    "string", "--", ...
    "position", [500 565 120 40], ...
    "fontsize", 16);


// Peak
uicontrol(fig, ...
    "style", "text", ...
    "string", "PEAK", ...
    "position", [650 610 120 25], ...
    "fontsize", 11, ...
    "fontweight", "bold");

peakValue = uicontrol(fig, ...
    "style", "text", ...
    "string", "--", ...
    "position", [650 565 120 40], ...
    "fontsize", 16);


// Kurtosis
uicontrol(fig, ...
    "style", "text", ...
    "string", "KURTOSIS", ...
    "position", [800 610 120 25], ...
    "fontsize", 11, ...
    "fontweight", "bold");

kurtValue = uicontrol(fig, ...
    "style", "text", ...
    "string", "--", ...
    "position", [800 565 120 40], ...
    "fontsize", 16);


// Frequency
uicontrol(fig, ...
    "style", "text", ...
    "string", "DOMINANT Hz", ...
    "position", [950 610 150 25], ...
    "fontsize", 11, ...
    "fontweight", "bold");

freqValue = uicontrol(fig, ...
    "style", "text", ...
    "string", "--", ...
    "position", [950 565 150 40], ...
    "fontsize", 16);


// ================================================================
// ANOMALY SCORE
// ================================================================

uicontrol(fig, ...
    "style", "text", ...
    "string", "ANOMALY SCORE", ...
    "position", [300 525 180 25], ...
    "fontsize", 11, ...
    "fontweight", "bold");

anomalyValue = uicontrol(fig, ...
    "style", "text", ...
    "string", "-- %", ...
    "position", [300 480 180 40], ...
    "fontsize", 18, ...
    "fontweight", "bold");


// ================================================================
// GRAPH WINDOWS
// ================================================================

// Create embedded axes-like plot areas using separate figures.
// This is more compatible across Scilab versions.


// ================================================================
// CALLBACK - ANALYZE
// ================================================================

analyzeButton.callback = ...
"analyze_selected_machine();";


// ================================================================
// CALLBACK - EXPORT
// ================================================================

exportButton.callback = ...
"export_message();";


// ================================================================
// FUNCTIONS USED BY GUI
// ================================================================

function analyze_selected_machine()

    global machines rpm temperature hours;
    global machineList infoText statusText;
    global healthValue rmsValue peakValue;
    global kurtValue freqValue anomalyValue;

    // ------------------------------------------------------------
    // Selected machine
    // ------------------------------------------------------------

    selected = machineList.value;

    if selected < 1 then

        messagebox( ...
            "Please select a machine.", ...
            "VIBRAGUARD");

        return;

    end


    // ------------------------------------------------------------
    // Get signal
    // ------------------------------------------------------------

    signal = machines(selected).signal;


    // ------------------------------------------------------------
    // Analyze
    // ------------------------------------------------------------

    [RMS, Peak, Crest, Kurt, dominantFreq, ...
     anomaly, detectedStatus] = ...
        analyze_signal(signal, 1000, rpm(selected));


    // ------------------------------------------------------------
    // Update information
    // ------------------------------------------------------------

    infoString = ...
        "Machine: " + machines(selected) + ...
        ascii(10) + ...
        "Condition: " + machines(selected).condition + ...
        ascii(10) + ...
        "RPM: " + string(rpm(selected)) + ...
        ascii(10) + ...
        "Temperature: " + ...
        msprintf("%.2f", temperature(selected)) + " C" + ...
        ascii(10) + ...
        "Operating Hours: " + ...
        string(hours(selected));

    infoText.string = infoString;


    // ------------------------------------------------------------
    // Update metrics
    // ------------------------------------------------------------

    rmsValue.string = msprintf("%.4f", RMS);

    peakValue.string = msprintf("%.4f", Peak);

    kurtValue.string = msprintf("%.3f", Kurt);

    freqValue.string = msprintf("%.2f", dominantFreq);

    anomalyValue.string = ...
        msprintf("%.1f %%", anomaly);


    // ------------------------------------------------------------
    // Status
    // ------------------------------------------------------------

    healthValue.string = detectedStatus;

    statusText.string = ...
        "STATUS: " + detectedStatus;


    // ------------------------------------------------------------
    // Display signal
    // ------------------------------------------------------------

    scf(10);
    clf();

    t = (0:length(signal)-1) / 1000;

    plot(t(1:1000), signal(1:1000));

    xlabel("Time (seconds)");
    ylabel("Vibration");

    title( ...
        "Vibration Signal - " + ...
        machines(selected) + " - " + ...
        detectedStatus);

    xgrid();


    // ------------------------------------------------------------
    // Display FFT
    // ------------------------------------------------------------

    [f, amplitude] = ...
        get_fft(signal, 1000);

    scf(11);
    clf();

    plot(f, amplitude);

    xlabel("Frequency (Hz)");
    ylabel("Amplitude");

    title( ...
        "FFT Spectrum - " + ...
        machines(selected));

    xgrid();


    // ------------------------------------------------------------
    // Feature chart
    // ------------------------------------------------------------

    scf(12);
    clf();

    featureData = [RMS; Peak; Crest; Kurt];

    bar(featureData);

    xlabel("Feature");
    ylabel("Value");

    title( ...
        "Vibration Features - " + ...
        machines(selected));

    xgrid();


    // ------------------------------------------------------------
    // Print result in console
    // ------------------------------------------------------------

    disp(" ");
    disp("==============================================");
    disp("         VIBRAGUARD ANALYSIS RESULT");
    disp("==============================================");

    disp("Machine       : " + machines(selected));
    disp("Actual Fault  : " + machines(selected).condition);
    disp("Detected      : " + detectedStatus);

    mprintf("RMS           : %.4f\n", RMS);
    mprintf("Peak          : %.4f\n", Peak);
    mprintf("Crest Factor  : %.4f\n", Crest);
    mprintf("Kurtosis      : %.4f\n", Kurt);
    mprintf("Dominant Freq : %.2f Hz\n", dominantFreq);
    mprintf("Anomaly Score : %.2f %%\n", anomaly);

    disp("==============================================");

endfunction


// ================================================================
// EXPORT CALLBACK
// ================================================================

function export_message()

    messagebox( ...
        "Dataset already exported to:" + ...
        ascii(10) + ...
        "data/vibration_dataset.csv", ...
        "VIBRAGUARD DATA EXPORT");

endfunction


// ================================================================
// INITIAL MACHINE SELECTION
// ================================================================

machineList.value = 1;


// ================================================================
// STARTUP MESSAGE
// ================================================================

disp(" ");
disp("==============================================");
disp("          VIBRAGUARD V2 STARTED");
disp("==============================================");

disp("20 machines generated.");
disp("10,000 vibration samples per machine.");
disp("Total vibration samples: 200,000");

disp(" ");

disp("Fault classes:");
disp("1. NORMAL");
disp("2. IMBALANCE");
disp("3. MISALIGNMENT");
disp("4. BEARING FAULT");

disp(" ");

disp("CSV:");
disp("data/vibration_dataset.csv");

disp("==============================================");
