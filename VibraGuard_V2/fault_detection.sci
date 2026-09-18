// ================================================================
// VIBRAGUARD V2
// Fault Detection and Signal Analysis
// ================================================================


// ================================================================
// ANALYZE VIBRATION SIGNAL
// ================================================================

function [RMS, Peak, Crest, Kurt, dominantFreq, anomaly, status] = ...
    analyze_signal(signal, Fs, rpm)

    N = length(signal);

    // ------------------------------------------------------------
    // Remove DC component
    // ------------------------------------------------------------

    signal = signal - mean(signal);

    // ------------------------------------------------------------
    // RMS
    // ------------------------------------------------------------

    RMS = sqrt(mean(signal.^2));

    // ------------------------------------------------------------
    // Peak
    // ------------------------------------------------------------

    Peak = max(abs(signal));

    // ------------------------------------------------------------
    // Crest factor
    // ------------------------------------------------------------

    if RMS > 0 then
        Crest = Peak / RMS;
    else
        Crest = 0;
    end

    // ------------------------------------------------------------
    // Kurtosis
    // ------------------------------------------------------------

    varianceValue = mean(signal.^2);

    if varianceValue > 0 then

        Kurt = mean(signal.^4) / ...
               (varianceValue^2);

    else

        Kurt = 0;

    end

    // ------------------------------------------------------------
    // FFT
    // ------------------------------------------------------------

    Y = fft(signal);

    P2 = abs(Y / N);

    P1 = P2(1:floor(N/2)+1);

    if length(P1) > 2 then
        P1(2:$-1) = 2 * P1(2:$-1);
    end

    f = Fs * (0:floor(N/2)) / N;

    // Ignore DC component
    if length(P1) > 1 then

        P1(1) = 0;

    end

    [maxValue, index] = max(P1);

    dominantFreq = f(index);

    // ------------------------------------------------------------
    // Anomaly scoring
    // ------------------------------------------------------------

    // Reference limits for simulated normal operation
    normalRMS = 0.25;
    normalPeak = 0.60;
    normalKurtosis = 4.0;

    rmsScore = min(100, ...
        (RMS / normalRMS) * 100);

    peakScore = min(100, ...
        (Peak / normalPeak) * 100);

    kurtScore = min(100, ...
        (Kurt / normalKurtosis) * 100);

    anomaly = ...
        0.45 * rmsScore + ...
        0.30 * peakScore + ...
        0.25 * kurtScore;

    anomaly = min(100, anomaly);

    // ------------------------------------------------------------
    // Classification
    // ------------------------------------------------------------

    if anomaly < 40 then

        status = "NORMAL";

    elseif Kurt > 8 & Crest > 5 then

        status = "BEARING FAULT";

    elseif dominantFreq > 2 * rpm / 60 then

        status = "MISALIGNMENT";

    elseif RMS > 0.45 then

        status = "IMBALANCE";

    elseif anomaly >= 70 then

        status = "FAULT";

    else

        status = "WARNING";

    end

endfunction


// ================================================================
// FFT DATA
// ================================================================

function [f, amplitude] = get_fft(signal, Fs)

    N = length(signal);

    signal = signal - mean(signal);

    Y = fft(signal);

    P2 = abs(Y / N);

    P1 = P2(1:floor(N/2)+1);

    if length(P1) > 2 then
        P1(2:$-1) = 2 * P1(2:$-1);
    end

    f = Fs * (0:floor(N/2)) / N;

    amplitude = P1;

endfunction
