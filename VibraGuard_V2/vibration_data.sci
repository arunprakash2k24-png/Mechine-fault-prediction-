// ================================================================
// VIBRAGUARD V2
// Vibration Dataset Generator
// ================================================================

function [machines, labels, conditions, rpm, temperature, hours] = generate_dataset()

    // ------------------------------------------------------------
    // Basic configuration
    // ------------------------------------------------------------

    numMachines = 20;
    Fs = 1000;
    duration = 10;
    N = Fs * duration;

    machines = [];
    labels = [];
    conditions = [];
    rpm = zeros(numMachines, 1);
    temperature = zeros(numMachines, 1);
    hours = zeros(numMachines, 1);

    // ------------------------------------------------------------
    // Machine information
    // ------------------------------------------------------------

    for m = 1:numMachines

        machineName = "M-" + msprintf("%03d", m);

        machines(m) = machineName;

        // --------------------------------------------------------
        // Assign fault condition
        // --------------------------------------------------------

        if m <= 5 then

            conditions(m) = "NORMAL";

        elseif m <= 10 then

            conditions(m) = "IMBALANCE";

        elseif m <= 15 then

            conditions(m) = "MISALIGNMENT";

        else

            conditions(m) = "BEARING FAULT";

        end

        // --------------------------------------------------------
        // Machine operating parameters
        // --------------------------------------------------------

        rpm(m) = 1450 + round(rand() * 200);

        temperature(m) = 35 + rand() * 15;

        hours(m) = 500 + round(rand() * 5000);

        // --------------------------------------------------------
        // Generate vibration signal
        // --------------------------------------------------------

        signal = generate_vibration( ...
            conditions(m), rpm(m), Fs, N, m);

        // --------------------------------------------------------
        // Store signal
        // --------------------------------------------------------

        machines(m).signal = signal;

        labels(m) = conditions(m);

    end

endfunction


// ================================================================
// VIBRATION SIGNAL GENERATOR
// ================================================================

function signal = generate_vibration(condition, rpm, Fs, N, seed)

    t = (0:N-1) / Fs;

    // Mechanical rotation frequency
    f_rot = rpm / 60;

    // Deterministic seed-like variation
    amplitudeVariation = 1 + 0.03 * sin(seed);

    // Base vibration
    base = 0.20 * amplitudeVariation * ...
           sin(2 * %pi * f_rot * t);

    // Second harmonic
    harmonic2 = 0.05 * sin( ...
        2 * %pi * 2 * f_rot * t);

    // Random noise
    noise = 0.04 * rand(1, N, "normal");

    signal = base + harmonic2 + noise;

    // ------------------------------------------------------------
    // NORMAL
    // ------------------------------------------------------------

    if condition == "NORMAL" then

        signal = signal;

    // ------------------------------------------------------------
    // IMBALANCE
    // ------------------------------------------------------------

    elseif condition == "IMBALANCE" then

        signal = ...
            0.70 * sin(2 * %pi * f_rot * t) + ...
            0.10 * sin(2 * %pi * 2 * f_rot * t) + ...
            noise;

    // ------------------------------------------------------------
    // MISALIGNMENT
    // ------------------------------------------------------------

    elseif condition == "MISALIGNMENT" then

        signal = ...
            0.35 * sin(2 * %pi * f_rot * t) + ...
            0.30 * sin(2 * %pi * 2 * f_rot * t) + ...
            0.22 * sin(2 * %pi * 3 * f_rot * t) + ...
            0.15 * sin(2 * %pi * 4 * f_rot * t) + ...
            noise;

    // ------------------------------------------------------------
    // BEARING FAULT
    // ------------------------------------------------------------

    elseif condition == "BEARING FAULT" then

        signal = ...
            0.20 * sin(2 * %pi * f_rot * t) + ...
            0.06 * sin(2 * %pi * 2 * f_rot * t) + ...
            noise;

        // Repeated impact frequency
        faultFreq = 8 + seed * 0.15;

        numberImpacts = floor(duration * faultFreq);

        for k = 1:numberImpacts

            impactTime = round( ...
                (k / faultFreq) * Fs);

            if impactTime >= 1 & impactTime <= N then

                width = 30;

                for j = 0:width

                    index = impactTime + j;

                    if index <= N then

                        signal(index) = signal(index) + ...
                            1.2 * exp(-j / 5);

                    end

                end

            end

        end

    end

endfunction


// ================================================================
// CSV DATASET GENERATOR
// ================================================================

function create_csv(machines, rpm, temperature, hours)

    if ~isdir("data") then
        mkdir("data");
    end

    fileName = "data/vibration_dataset.csv";

    numMachines = length(machines);

    // Number of samples
    N = length(machines(1).signal);

    // ------------------------------------------------------------
    // Write header
    // ------------------------------------------------------------

    fd = mopen(fileName, "wt");

    mfprintf(fd, ...
        "Machine,Condition,RPM,Temperature,OperatingHours,Time,Vibration\n");

    // ------------------------------------------------------------
    // Write data
    // ------------------------------------------------------------

    for m = 1:numMachines

        signal = machines(m).signal;

        for n = 1:N

            timeValue = (n-1) / 1000;

            mfprintf(fd, ...
                "%s,%s,%.0f,%.2f,%.0f,%.4f,%.6f\n", ...
                machines(m), ...
                machines(m).condition, ...
                rpm(m), ...
                temperature(m), ...
                hours(m), ...
                timeValue, ...
                signal(n));

        end

    end

    mclose(fd);

    disp("CSV dataset created:");
    disp(fileName);

endfunction
