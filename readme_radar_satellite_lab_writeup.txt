
================================================================================
EXPERIMENT 1: RADAR RANGE EQUATION SIMULATION
================================================================================

1. FORMULAS & SAMPLE CALCULATION:
   - Radar Range Equation:
     Rmax = [ (Pt * G^2 * lambda^2 * sigma) / ((4 * pi)^3 * Pmin) ]^(1/4)
   - Given Values:
     Pt = 10 kW = 10,000 W
     G = 1000 (linear)
     f = 10 GHz  -->  lambda = c / f = (3e8) / (10e9) = 0.03 m
     sigma (RCS) = 1 m^2
     Pmin = 1e-13 W (-100 dBm)
   - Step-by-Step Calculation:
     Numerator   = 10000 * (1000)^2 * (0.03)^2 * 1 = 9,000,000 = 9e6
     Denominator = (4 * 3.1416)^3 * 1e-13 = 1984.4 * 1e-13 = 1.9844e-10
     Ratio       = 9e6 / 1.9844e-10 = 4.5353e16
     Rmax        = (4.5353e16)^(1/4) = 14,593 meters = 14.59 km

2. MATLAB SCRIPT (Writeup Format - Copy directly into .m file):
   clc; clear; close all;
   Pt = 10e3; G = 1000; lam = 0.03; s = 1; Pmin = 1e-13;
   Rm = @(Pt,G,l,s) (Pt.*G.^2.*l.^2.*s./((4*pi)^3*Pmin)).^(1/4);
   fprintf('Base Rmax = %.2f km\n', Rm(Pt,G,lam,s)/1e3);

   subplot(2,2,1); plot(1:100, Rm((1:100)*1e3,G,lam,s)/1e3); xlabel('Pt (kW)'); ylabel('Rmax (km)'); title('Pt vs Rmax'); grid on;
   subplot(2,2,2); plot(10:1000, Rm(Pt,10:1000,lam,s)/1e3); xlabel('Gain'); ylabel('Rmax (km)'); title('Gain vs Rmax'); grid on;
   subplot(2,2,3); plot(1:20, Rm(Pt,G,3e8./((1:20)*1e9),s)/1e3); xlabel('Freq (GHz)'); ylabel('Rmax (km)'); title('Freq vs Rmax'); grid on;
   subplot(2,2,4); plot(0.1:0.1:10, Rm(Pt,G,lam,0.1:0.1:10)/1e3); xlabel('RCS (m^2)'); ylabel('Rmax (km)'); title('RCS vs Rmax'); grid on;

3. LINE-BY-LINE HINGLISH EXPLANATION:
   - clc; clear; close all; -> Purani screen, variables aur graph windows ko saaf karta hai.
   - Pt = 10e3; G = 1000; lam = 0.03; s = 1; Pmin = 1e-13; -> Radar ke base values set kiye hain (10 kW power, 1000 gain, 0.03 m wavelength, 1 m^2 RCS, 1e-13 W sensitivity).
   - Rm = @(Pt,G,l,s) ... -> Ek shortcut formula machine banayi hai jo 4th root nikal kar Rmax deti hai. Dot operators (.*, .^, ./) array calculation ke liye lagaye hain.
   - fprintf(...) -> Command window mein base range 14.59 km print karta hai.
   - subplot(2,2,1) se (2,2,4) -> Ek hi window mein 4 graphs banata hai: Power, Gain, Frequency, aur RCS ke saath Rmax ka badlav.

4. OUTPUT GRAPH EXPLANATION:
   - Command Window prints: Base Rmax = 14.59 km.
   - Subplot 1 (Pt vs Rmax): Concave 4th-root curve; power 16x badhane par range sirf 2x badhti hai.
   - Subplot 2 (Gain vs Rmax): Square-root growth curve (Rmax proportional to sqrt(G)).
   - Subplot 3 (Freq vs Rmax): Neeche girti hui curve; frequency badhne se wavelength chhoti hoti hai aur range ghatti hai.
   - Subplot 4 (RCS vs Rmax): 4th-root growth curve; bada target zyada door se detect hota hai.


================================================================================
EXPERIMENT 2: RADAR TARGET DETECTION IN NOISE (ROC CURVE)
================================================================================

1. FORMULAS & SAMPLE CALCULATION:
   - Energy Detector Test Statistic: E = sum( |y[n]|^2 ) for n = 1 to N
   - Decision Rule: If E > Threshold (gamma) --> Target Present (H1), else Noise Only (H0)
   - SNR Conversion: SNR_linear = 10^(SNR_dB / 10)
     At SNR = -8 dB: SNR_linear = 10^(-0.8) = 0.1585
   - Probability of Detection (Pd) = (Number of H1 trials exceeding threshold) / Total Trials
   - Probability of False Alarm (Pfa) = (Number of H0 noise trials exceeding threshold) / Total Trials

2. MATLAB SCRIPT (Writeup Format - Copy directly into .m file):
   clc; clear; close all;
   N = 1000; p = zeros(1,N); p(401:500) = 1;
   snr = -10:2:10; M = 2000; Pfa = 1e-2;

   for k = 1:numel(snr)
       sg = sqrt(mean(p.^2) / 10^(snr(k)/10));
       e0 = sort(sum((sg*randn(M,N)).^2, 2));
       e1 = sum((p + sg*randn(M,N)).^2, 2);
       Pd(k) = mean(e1 > e0(ceil((1-Pfa)*M)));
   end
   figure; plot(snr, Pd, 'o-'); xlabel('SNR (dB)'); ylabel('Pd'); title('Pd vs SNR (Pfa = 0.01)'); grid on;

   sg = sqrt(0.1 / 10^(-0.8));
   e0 = sort(sum((sg*randn(M,N)).^2, 2));
   e1 = sum((p + sg*randn(M,N)).^2, 2);
   Pf = logspace(-3, 0, 30);
   for i = 1:30
       Pd2(i) = mean(e1 > e0(max(1, floor((1-Pf(i))*M))));
   end
   figure; semilogx(Pf, Pd2, 'o-'); xlabel('Pfa'); ylabel('Pd'); title('ROC Curve (at -8 dB SNR)'); grid on;

3. LINE-BY-LINE HINGLISH EXPLANATION:
   - N = 1000; p = zeros(1,N); p(401:500) = 1; -> 1000 samples mein sample 401 se 500 tak 1 rakh kar radar pulse banaya hai.
   - snr = -10:2:10; M = 2000; Pfa = 1e-2; -> -10 dB se +10 dB tak SNR, 2000 random trials, aur 1% false alarm rate set kiya hai.
   - sg = sqrt(mean(p.^2) / 10^(snr(k)/10)); -> Har SNR ke hisaab se noise ki strength calculate ki hai.
   - e0 = sort(sum((sg*randn(M,N)).^2, 2)); -> Sirf noise (H0) ki energy nikal kar ascending order mein sort ki hai.
   - e1 = sum((p + sg*randn(M,N)).^2, 2); -> Signal + noise (H1) ki energy nikali hai.
   - Pd(k) = mean(e1 > e0(ceil((1-Pfa)*M))); -> H0 ke 99th percentile ko threshold maan kar dekha ki kitni baar target detect hua (Pd).
   - semilogx(Pf, Pd2, 'o-'); -> -8 dB SNR par alag-alag Pfa thresholds ke liye ROC curve plot kiya hai.

4. OUTPUT GRAPH EXPLANATION:
   - Figure 1 (Pd vs SNR): S-shaped curve. -10 dB par Pd lagbhag 0 hota hai, -4 dB se tezi se upar uthta hai, aur 0 dB ke baad Pd = 1.0 (100% detection) ho jaata hai.
   - Figure 2 (ROC Curve): Logarithmic X-axis par Pd vs Pfa curve jo upar-left ki taraf uthta hai, dikhata hai ki Pfa badhane par Pd bhi badhta hai.


================================================================================
EXPERIMENT 3: DOPPLER FREQUENCY SHIFT SIMULATION
================================================================================

1. FORMULAS & SAMPLE CALCULATION:
   - Doppler Frequency Shift Formula:
     fd = (2 * v * fc) / c
   - Sample Calculation (for v = 30 m/s, fc = 10 GHz, c = 3e8 m/s):
     fd = (2 * 30 * 10e9) / (3e8) = 6e11 / 3e8 = 2000 Hz = 2 kHz
   - For v = 10, 20, 30, 40, 50 m/s at fc = 10 GHz:
     fd = 666.7 Hz, 1333.3 Hz, 2000 Hz, 2666.7 Hz, 3333.3 Hz

2. MATLAB SCRIPT (Writeup Format - Copy directly into .m file):
   clc; clear; close all;
   c = 3e8; Fs = 1e5; t = 0:1/Fs:0.1-1/Fs;
   v = 10:10:50; fc = 10e9; fd = 2*v*fc/c;
   disp([v; fd]');

   N = numel(t); f = (-N/2:N/2-1)*Fs/N;
   figure;
   for k = 1:5
       subplot(5,1,k);
       plot(f, abs(fftshift(fft(cos(2*pi*fd(k)*t)))/N));
       xlim([-5e3 5e3]); xlabel('Freq (Hz)'); ylabel('Mag'); title(['fd = ' num2str(round(fd(k),1)) ' Hz']); grid on;
   end

   fc2 = [2 5 10 15 20]*1e9; fd2 = 2*30*fc2/c;
   figure; plot(fc2/1e9, fd2, '-o'); xlabel('Carrier Frequency (GHz)'); ylabel('Doppler Shift (Hz)'); title('fd vs fc (at v = 30 m/s)'); grid on;

3. LINE-BY-LINE HINGLISH EXPLANATION:
   - c = 3e8; Fs = 1e5; t = 0:1/Fs:0.1-1/Fs; -> Speed of light, 100 kHz sampling frequency, aur 0.1 sec ka time vector banaya hai.
   - v = 10:10:50; fc = 10e9; fd = 2*v*fc/c; -> 5 speeds ke liye Doppler shift fd calculate kiya hai.
   - disp([v; fd]'); -> Command window mein velocity aur fd ki table print karta hai.
   - f = (-N/2:N/2-1)*Fs/N; -> FFT graph ke liye negative se positive frequency axis banayi hai.
   - plot(f, abs(fftshift(fft(cos(2*pi*fd(k)*t)))/N)); -> Har speed ke signal par FFT lagaya hai; real cosine hone se +fd aur -fd par 2 peaks dikhte hain.
   - fc2 = [2 5 10 15 20]*1e9; fd2 = 2*30*fc2/c; -> Speed 30 m/s fix rakh kar carrier frequency badhayi aur straight line plot ki.

4. OUTPUT GRAPH EXPLANATION:
   - Figure 1 (5 Subplots): Har subplot mein +/- fd par do symmetric spikes dikhte hain jo speed badhne par bahar ki taraf khisakte hain.
   - Figure 2 (fd vs fc): Seedhi linear line (origin se guzarti hui), dikhati hai ki carrier frequency double karne par Doppler shift bhi double ho jaata hai.


================================================================================
EXPERIMENT 4: MTI RADAR USING DELAY LINE CANCELLER
================================================================================

1. FORMULAS & SAMPLE CALCULATION:
   - Single Delay Line Canceller Difference Equation:
     y[n] = x[n] - x[n-1]
   - Stationary Clutter (v = 0, fd = 0):
     x[n] = 1.0, x[n-1] = 1.0  -->  y[n] = 1.0 - 1.0 = 0 (Clutter Cancelled!)
   - Moving Target (v != 0, fd != 0):
     x[n] != x[n-1]  -->  y[n] != 0 (Target Detected!)
   - Frequency Response Magnitude:
     |H(f)| = 2 * |sin(pi * f * T)|

2. MATLAB SCRIPT (Writeup Format - Copy directly into .m file):
   clc; clear; close all;
   N = 1000; t = 0:N-1;
   cl = 1 + 0.1*randn(1,N);
   tg = sin(2*pi*0.08*t);
   rx = cl + tg + 0.1*randn(1,N);
   mti = diff(rx);

   subplot(4,1,1); plot(cl); ylabel('Amp'); title('1. Stationary Clutter (DC)'); grid on;
   subplot(4,1,2); plot(tg); ylabel('Amp'); title('2. Moving Target Signal'); grid on;
   subplot(4,1,3); plot(rx); ylabel('Amp'); title('3. Received Signal (Clutter + Target + Noise)'); grid on;
   subplot(4,1,4); plot(mti); xlabel('Pulse Number'); ylabel('Amp'); title('4. MTI Output (Clutter Cancelled)'); grid on;

3. LINE-BY-LINE HINGLISH EXPLANATION:
   - N = 1000; t = 0:N-1; -> 1000 radar pulses ka index banaya hai.
   - cl = 1 + 0.1*randn(1,N); -> Stationary clutter (pahad/building) banaya hai jiska DC level 1 hai aur halka noise hai.
   - tg = sin(2*pi*0.08*t); -> Moving airplane ka oscillating Doppler signal banaya hai.
   - rx = cl + tg + 0.1*randn(1,N); -> Total received signal mein clutter, target aur noise teeno jode hain.
   - mti = diff(rx); -> Single delay line canceller (rx(n) - rx(n-1)) lagaya hai jisse constant clutter 1 zero ho jaata hai aur sirf target bachta hai.

4. OUTPUT GRAPH EXPLANATION:
   - Subplot 1: +1.0 ke aas-paas flat DC clutter line.
   - Subplot 2: 0 ke aas-paas oscillate karti hui sine wave (moving target).
   - Subplot 3: +1.0 ke upar shift hui wave (clutter ne target ko upar utha diya hai).
   - Subplot 4: +1.0 DC clutter poori tarah gayab ho gaya aur signal wapas 0 ke around aa gaya.


================================================================================
EXPERIMENT 5: PULSE DOPPLER RADAR TARGET DETECTION
================================================================================

1. FORMULAS & SAMPLE CALCULATION:
   - Maximum Unambiguous Range:
     Rmax = c / (2 * PRF) = 3e8 / (2 * 5000) = 30,000 m = 30 km
   - Maximum Unambiguous Velocity:
     lambda = c / fc = 3e8 / 10e9 = 0.03 m
     Vmax = (lambda * PRF) / 4 = (0.03 * 5000) / 4 = +/- 37.5 m/s
   - Range Resolution:
     Delta_R = c / (2 * BW) = 3e8 / (2 * 5e6) = 30 m
   - Simulated Targets:
     Target 1: R = 5 km, V = +20 m/s
     Target 2: R = 12 km, V = -15 m/s
     Target 3: R = 20 km, V = +8 m/s

2. MATLAB SCRIPT (Writeup Format - Copy directly into .m file):
   clc; clear; close all;
   c = 3e8; fc = 10e9; lam = c/fc; PRF = 5e3; Fs = 20e6; pw = 10e-6; BW = 5e6; Np = 64;
   R = [5000 12000 20000]; V = [20 -15 8];
   Ns = Fs/PRF; Npw = Fs*pw;

   t = (0:Npw-1)'/Fs;
   tx = exp(1j*pi*BW/pw*(t-pw/2).^2);
   rx = zeros(Ns, Np);
   for n = 1:3
       d = round(2*R(n)/c*Fs);
       rx(d+1:d+Npw,:) = rx(d+1:d+Npw,:) + tx*exp(1j*2*pi*2*V(n)/lam*(0:Np-1)/PRF);
   end
   rx = awgn(rx, 10, 'measured');

   y = filter(conj(flipud(tx)), 1, rx);
   D = fftshift(fft(y.*hamming(Np)', 128, 2), 2);
   r = (0:Ns-1)*c/(2*Fs);
   v = (-64:63)*PRF/128*lam/2;

   imagesc(v, r/1e3, 20*log10(abs(D)/max(abs(D(:))))); axis xy; colorbar; clim([-50 0]);
   xlabel('Velocity (m/s)'); ylabel('Range (km)'); title('2D Range-Doppler Map (dB)');

3. LINE-BY-LINE HINGLISH EXPLANATION:
   - c = 3e8; fc = 10e9; ... Np = 64; -> Radar parameters aur 64 pulses set kiye hain.
   - R = [5000 12000 20000]; V = [20 -15 8]; -> 3 targets ki distance aur speed set ki hai.
   - tx = exp(1j*pi*BW/pw*(t-pw/2).^2); -> LFM Chirp pulse banaya hai.
   - for n = 1:3 ... rx(...) = ... end -> Har target ke echo ko delay d par daala hai aur har pulse mein Doppler phase shift joda hai.
   - y = filter(conj(flipud(tx)), 1, rx); -> Matched filter lagaya hai jo pulse compression karke exact range nikalta hai.
   - D = fftshift(fft(y.*hamming(Np)', 128, 2), 2); -> 64 pulses ke across Doppler FFT lagaya hai jo targets ki speed nikalta hai.
   - imagesc(v, r/1e3, ...); -> 2D color heatmap banata hai jisme X-axis par Velocity aur Y-axis par Range hai.

4. OUTPUT GRAPH EXPLANATION:
   - 2D Range-Doppler Map: Neela/dark background (-50 dB noise floor) par 3 bright yellow spots dikhte hain:
     Spot 1 at (+20 m/s, ~6.5 km), Spot 2 at (-15 m/s, ~13.5 km), aur Spot 3 at (+8 m/s, ~21.5 km) (1.5 km shift matched filter pulse delay c*pw/2 ki wajah se aata hai).


================================================================================
EXPERIMENT 6: RADAR DISPLAY SIMULATION (A-SCAN, B-SCAN, PPI)
================================================================================

1. FORMULAS & SAMPLE CALCULATION:
   - Polar to Cartesian Conversion (Navigation/Radar Convention, 0 deg = North):
     X = R * sin(Azimuth)
     Y = R * cos(Azimuth)
   - Sample Target 1 (R = 25 km, Az = 40 deg):
     X = 25 * sin(40 deg) = 16.07 km
     Y = 25 * cos(40 deg) = 19.15 km
   - Phosphor Persistence Decay:
     B_new = 0.99 * B_old

2. MATLAB SCRIPT (Writeup Format - Copy directly into .m file):
   clc; clear; close all;
   r = 0:100; th = linspace(0,2*pi,200);
   R = [25 50 75 60]; Az = [40 120 220 300];
   B = zeros(101, 360);

   for ang = 1:360
       hit = abs(mod(Az - ang + 180, 360) - 180) <= 4;
       a = 0.02*rand(size(r)); B = 0.99*B;
       for k = find(hit)
           a = a + exp(-((r - R(k))/2).^2);
           B(round(R(k))+1, Az(k)+1) = 1;
       end
       subplot(1,3,1); plot(r, a); ylim([0 1.2]); xlabel('Range (km)'); ylabel('Amp'); title('A-Scan');
       subplot(1,3,2); imagesc(0:359, r, B); axis xy; xlabel('Azimuth (deg)'); ylabel('Range (km)'); title('B-Scan');
       subplot(1,3,3); plot(R.*sind(Az), R.*cosd(Az), 'ro', [0 100*sind(ang)], [0 100*cosd(ang)], 'k', sin(th)'*(25:25:100), cos(th)'*(25:25:100), ':');
       axis equal; axis([-100 100 -100 100]); xlabel('East-West (km)'); ylabel('North-South (km)'); title('PPI Display');
       drawnow;
   end

3. LINE-BY-LINE HINGLISH EXPLANATION:
   - R = [25 50 75 60]; Az = [40 120 220 300]; -> 4 targets ki range (km) aur angle (degrees) set kiye hain.
   - for ang = 1:360 -> Antenna ko 1 se 360 degree tak poora ek chakkar ghumane ka loop.
   - hit = abs(mod(Az - ang + 180, 360) - 180) <= 4; -> Check karta hai ki kya ghumti hui beam (+/- 4 deg) kisi target ke upar aayi hai.
   - a = a + exp(...); B(...) = 1; -> Hit hone par A-Scan mein spike aur B-Scan mein bright dot banata hai (0.99*B purane dots ko dheere fade karta hai).
   - subplot(1,3,3); plot(...) -> Gol PPI radar screen par red targets, ghumti hui kaali sweep line, aur dotted range rings animate karta hai.

4. OUTPUT GRAPH EXPLANATION:
   - Subplot 1 (A-Scan): 1D graph jo beam hit hone par target ki doori par vertical peak dikhata hai.
   - Subplot 2 (B-Scan): Rectangular grid jisme X-axis par Angle (0-360 deg) aur Y-axis par Range (0-100 km) dikhti hai.
   - Subplot 3 (PPI Display): Circular radar map jisme 4 red targets apni asli polar positions par aur 4 concentric range rings (25, 50, 75, 100 km) dikhte hain.


================================================================================
EXPERIMENT 7: SATELLITE LINK BUDGET ANALYSIS (EXAM SHEET PROBLEM)
================================================================================

1. GIVEN DATA (FROM EXAM PAPER):
   - Carrier Frequency (f) = 12 GHz = 12e9 Hz
   - Satellite Slant Range (R) = 38,000 km = 38e6 m
   - Transmitter Power (Pt) = 100 W
   - Transmit Antenna Diameter (Dt) = 2.4 m, Efficiency (eta_t) = 65% = 0.65
   - Receive Antenna Diameter (Dr) = 1.8 m, Efficiency (eta_r) = 60% = 0.60
   - Transmitter Feeder Loss (Lt) = 2 dB
   - Other Propagation / System Losses (L_other) = 1.5 dB
   - Rain Attenuation (L_rain) = 2 dB
   - Receiver System Temperature (T) = 500 K
   - Receiver Bandwidth (B) = 36 MHz = 36e6 Hz
   - Required C/N = 10 dB

2. FORMULAS & STEP-BY-STEP CALCULATIONS:
   - Step 1: Wavelength (lambda)
     lambda = c / f = (3e8) / (12e9) = 0.025 m

   - Step 2: Transmit & Receive Antenna Gains (Gt, Gr)
     Gt = 10 * log10( eta_t * (pi * Dt / lambda)^2 )
        = 10 * log10( 0.65 * (3.1416 * 2.4 / 0.025)^2 )
        = 10 * log10(59129.6) = 47.72 dBi

     Gr = 10 * log10( eta_r * (pi * Dr / lambda)^2 )
        = 10 * log10( 0.60 * (3.1416 * 1.8 / 0.025)^2 )
        = 10 * log10(30701.9) = 44.87 dBi

   - Step 3: Equivalent Isotropically Radiated Power (EIRP)
     Pt (dBW) = 10 * log10(100) = 20 dBW
     EIRP = Pt (dBW) + Gt - Lt = 20 + 47.72 - 2 = 65.72 dBW

   - Step 4: Free Space Path Loss (FSPL)
     FSPL = 20 * log10(4 * pi * R / lambda)
          = 20 * log10(4 * 3.1416 * 38e6 / 0.025) = 205.62 dB
     (Alternative formula: FSPL = 92.45 + 20*log10(f_GHz) + 20*log10(d_km)
                               = 92.45 + 20*log10(12) + 20*log10(38000) = 205.63 dB)

   - Step 5: Received Power (Pr)
     Pr = EIRP - FSPL + Gr - L_other - L_rain
        = 65.72 - 205.62 + 44.87 - 1.5 - 2 = -98.53 dBW

   - Step 6: Thermal Noise Power (N)
     N = 10 * log10(k * T * B)
       = 10 * log10(1.38e-23 * 500 * 36e6)
       = 10 * log10(2.484e-13) = -126.05 dBW

   - Step 7: Carrier-to-Noise Ratio (C/N) & Link Margin
     C/N = Pr - N = -98.53 - (-126.05) = 27.52 dB
     Link Margin = (C/N)_achieved - (C/N)_required = 27.52 - 10 = +17.52 dB (FEASIBLE)

3. MATLAB SCRIPT (Writeup Format - Copy directly into .m file):
   clc; clear; close all;
   f = 12e9; R = 38000e3; lam = 3e8/f;
   Gt = 10*log10(0.65*(pi*2.4/lam)^2);
   Gr = 10*log10(0.60*(pi*1.8/lam)^2);

   EIRP = 10*log10(100) + Gt - 2;
   FSPL = 20*log10(4*pi*R/lam);
   Pr = EIRP - FSPL + Gr - 1.5 - 2;
   N = 10*log10(1.38e-23*500*36e6);
   CN = Pr - N;
   M = CN - 10;

   fprintf('EIRP = %.2f dBW\nFSPL = %.2f dB\nPr = %.2f dBW\nN = %.2f dBW\nC/N = %.2f dB\nMargin = %.2f dB\n', EIRP, FSPL, Pr, N, CN, M);

   d = linspace(1e3, 5e4, 20)*1e3;
   plot(d/1e3, EIRP - 20*log10(4*pi*d/lam) + Gr - 3.5, 'o-', 'LineWidth', 1.5);
   xlabel('Distance (km)'); ylabel('Received Power Pr (dBW)'); title('Received Power vs Distance'); grid on;

4. LINE-BY-LINE HINGLISH EXPLANATION:
   - f = 12e9; R = 38000e3; lam = 3e8/f; -> Frequency 12 GHz, distance 38,000 km aur wavelength 0.025 m set ki hai.
   - Gt = ...; Gr = ...; -> Dish antenna gain formula se transmit (47.72 dBi) aur receive (44.87 dBi) gains nikale hain.
   - EIRP = 10*log10(100) + Gt - 2; -> 100 W (20 dBW) power + Gt - 2 dB loss = 65.72 dBW.
   - FSPL = 20*log10(4*pi*R/lam); -> Free space path loss 205.62 dB nikala hai.
   - Pr = EIRP - FSPL + Gr - 1.5 - 2; -> Other loss (1.5 dB) aur rain loss (2 dB) minus karke received power -98.53 dBW nikali hai.
   - N = ...; CN = Pr - N; M = CN - 10; -> Noise (-126.05 dBW), C/N (27.52 dB), aur Link Margin (+17.52 dB) print kiya hai.

5. OUTPUT GRAPH EXPLANATION:
   - Command Window prints: EIRP = 65.72 dBW, FSPL = 205.62 dB, Pr = -98.53 dBW, N = -126.05 dBW, C/N = 27.52 dB, Margin = 17.52 dB.
   - Plot (Received Power vs Distance): Logarithmic curve jo dikhati hai ki 1,000 km se 50,000 km jaane par received power -67 dBW se gir kar -101 dBW tak pahunch jaati hai.


================================================================================
EXPERIMENT 8: SATELLITE ORBIT & GROUND TRACK SIMULATION
================================================================================

1. FORMULAS & SAMPLE CALCULATIONS:
   - Orbital Radius: r = Re + altitude (where Re = 6371 km)
   - Kepler's Third Law (Orbital Period):
     T = 2 * pi * sqrt(r^3 / mu)   (where mu = 398,600.44 km^3/s^2)
   - Calculated Orbital Periods:
     1) LEO (h = 500 km)   --> r = 6871 km  --> T = 5667 sec = 1.57 hours
     2) MEO (h = 20,200 km)--> r = 26571 km --> T = 43083 sec = 11.97 hours
     3) GEO (h = 35,786 km)--> r = 42157 km --> T = 86164 sec = 23.93 hours

2. MATLAB SCRIPT (Writeup Format - Copy directly into .m file):
   clc; clear; close all;
   alt = [500 20200 35786];
   c = input('Enter 1 for LEO, 2 for MEO, 3 for GEO: ');
   r = 6371 + alt(c);
   T = 2*pi*sqrt(r^3/398600.4418);
   fprintf('Orbital Period = %.2f hours\n', T/3600);

   th = linspace(0, 2*pi, 500);
   [a,b,d] = sphere(30);
   figure;
   surf(6371*a, 6371*b, 6371*d, 'EdgeColor', 'none'); hold on; axis equal; grid on;
   plot3(r*cos(th), r*sin(th), 0*th, 'r--', 'LineWidth', 1.5);
   xlabel('X (km)'); ylabel('Y (km)'); zlabel('Z (km)'); title('3D Satellite Orbit Around Earth');

   figure;
   plot(mod(th*180/pi + 180, 360) - 180, 0*th, 'b', 'LineWidth', 2); grid on;
   xlim([-180 180]); ylim([-90 90]);
   xlabel('Longitude (deg)'); ylabel('Latitude (deg)'); title('Equatorial Ground Track');

3. LINE-BY-LINE HINGLISH EXPLANATION:
   - alt = [500 20200 35786]; c = input(...); -> LEO, MEO, aur GEO ki height set ki hai aur user se 1, 2, ya 3 input leta hai.
   - r = 6371 + alt(c); T = 2*pi*sqrt(r^3/398600.4418); -> Earth ke center se radius r aur Kepler formula se period T (hours mein) nikalta hai.
   - surf(6371*a, 6371*b, 6371*d, ...); plot3(...) -> Beech mein 3D Earth sphere aur uske chaaron taraf red dashed orbit circle banata hai.
   - plot(mod(th*180/pi + 180, 360) - 180, 0*th) -> Doosri window mein Longitude (-180 to +180) vs Latitude (0 deg) ground track line banata hai.

4. OUTPUT GRAPH EXPLANATION:
   - Figure 1 (3D Orbit): 3D Earth sphere ke equator ke chaaron taraf circular orbit dikhata hai (LEO sabse paas, GEO sabse door).
   - Figure 2 (Ground Track): Equatorial orbit hone ki wajah se Latitude = 0 deg par ek horizontal seedhi line banti hai.


================================================================================
EXPERIMENT 9: SYSTEM NOISE, C/N, AND G/T ANALYSIS
================================================================================

1. FORMULAS & SAMPLE CALCULATIONS:
   - Given Nominal Values:
     T = 150 K, G = 35 dBi, Pc = -100 dBW, B = 1 MHz = 1e6 Hz, k = 1.38e-23 J/K
   - Step 1: Thermal Noise Power (N)
     N = 10 * log10(k * T * B) = 10 * log10(1.38e-23 * 150 * 1e6) = -146.84 dBW
   - Step 2: Carrier-to-Noise Ratio (C/N)
     C/N = Pc - N = -100 - (-146.84) = 46.84 dB
   - Step 3: Receiver Figure of Merit (G/T)
     G/T = G - 10 * log10(T) = 35 - 10 * log10(150) = 35 - 21.76 = 13.24 dB/K

2. MATLAB SCRIPT (Writeup Format - Copy directly into .m file):
   clc; clear; close all;
   T = 150; G = 35; Pc = -100; k = 1.38e-23; B = 1e6;
   N = @(T) 10*log10(k*T*B);
   fprintf('Noise Power = %.2f dBW | C/N = %.2f dB | G/T = %.2f dB/K\n', N(T), Pc-N(T), G-10*log10(T));

   Tr = 50:10:500;
   subplot(2,2,1); plot(Tr, N(Tr)); xlabel('Temp T (K)'); ylabel('Noise N (dBW)'); title('Noise Power vs Temp'); grid on;
   subplot(2,2,2); plot(Tr, Pc - N(Tr)); xlabel('Temp T (K)'); ylabel('C/N (dB)'); title('C/N vs Temp'); grid on;
   subplot(2,2,3); plot(20:50, (20:50) - 10*log10(T)); xlabel('Gain G (dBi)'); ylabel('G/T (dB/K)'); title('G/T vs Antenna Gain'); grid on;
   subplot(2,2,4); plot(Tr, G - 10*log10(Tr)); xlabel('Temp T (K)'); ylabel('G/T (dB/K)'); title('G/T vs Temp'); grid on;

3. LINE-BY-LINE HINGLISH EXPLANATION:
   - T = 150; G = 35; Pc = -100; k = 1.38e-23; B = 1e6; -> Nominal noise temperature, antenna gain, carrier power aur bandwidth set kiye hain.
   - N = @(T) 10*log10(k*T*B); -> Noise power (dBW) calculate karne ka formula function banaya hai.
   - fprintf(...) -> Screen par Noise (-146.84 dBW), C/N (46.84 dB), aur G/T (13.24 dB/K) print karta hai.
   - subplot(2,2,1) se (2,2,4) -> 4 graphs banata hai jo temperature aur antenna gain badalne par N, C/N, aur G/T ka asar dikhate hain.

4. OUTPUT GRAPH EXPLANATION:
   - Command Window prints: Noise Power = -146.84 dBW | C/N = 46.84 dB | G/T = 13.24 dB/K.
   - Subplot 1 (Noise vs Temp): Temperature 50 K se 500 K badhne par Noise -151.6 dBW se badh kar -141.6 dBW hota hai.
   - Subplot 2 (C/N vs Temp): Noise badhne ki wajah se C/N 51.6 dB se gir kar 41.6 dB ho jaata hai.
   - Subplot 3 (G/T vs Gain): Seedhi linear line (slope = 1); gain badhane se G/T badhta hai.
   - Subplot 4 (G/T vs Temp): Neeche girti hui curve; temperature badhne se receiver sensitivity (G/T) kam hoti hai.
================================================================================