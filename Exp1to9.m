Exp 9 

clc; clear; close all;
T = 150; G = 35; Pc = -100; k = 1.38e-23; B = 1e6;
N = @(T) 10*log10(k*T*B);
fprintf('Noise Power = %.2f dBW | C/N = %.2f dB | G/T = %.2f dB/K\n', N(T), Pc-N(T), G-10*log10(T));

Tr = 50:10:500;
subplot(2,2,1); plot(Tr, N(Tr)); xlabel('Temp T (K)'); ylabel('Noise N (dBW)'); title('Noise Power vs Temp'); grid on;
subplot(2,2,2); plot(Tr, Pc - N(Tr)); xlabel('Temp T (K)'); ylabel('C/N (dB)'); title('C/N vs Temp'); grid on;
subplot(2,2,3); plot(20:50, (20:50) - 10*log10(T)); xlabel('Gain G (dBi)'); ylabel('G/T (dB/K)'); title('G/T vs Antenna Gain'); grid on;
subplot(2,2,4); plot(Tr, G - 10*log10(Tr)); xlabel('Temp T (K)'); ylabel('G/T (dB/K)'); title('G/T vs Temp'); grid on;


exp 8 

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


exp 7 

clc; clear; close all;
f = 12e9; R = 38000e3; lam = 3e8/f;
Gt = 10*log10(0.65*(pi*2.4/lam)^2);
Gr = 10*log10(0.60*(pi*1.8/lam)^2);

EIRP = 10*log10(100) + Gt - 2;
FSPL = 20*log10(4*pi*R/lam);
Pr = EIRP - FSPL + Gr - 3.5;
N = 10*log10(1.38e-23*500*36e6);
CN = Pr - N;
M = CN - 10;

fprintf('EIRP = %.2f dBW\nFSPL = %.2f dB\nPr = %.2f dBW\nN = %.2f dBW\nC/N = %.2f dB\nMargin = %.2f dB\n', EIRP, FSPL, Pr, N, CN, M);

d = linspace(1e3, 5e4, 20)*1e3;
plot(d/1e3, EIRP - 20*log10(4*pi*d/lam) + Gr - 3.5, 'o-', 'LineWidth', 1.5);
xlabel('Distance (km)'); ylabel('Received Power Pr (dBW)'); title('Received Power vs Distance'); grid on;


exp 6 

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


exp 5 

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


exp 4 

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


exp 3 


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


exp 2 

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


exp 1 

clc; clear; close all;
Pt = 10e3; G = 1000; lam = 0.03; s = 1; Pmin = 1e-13;
Rm = @(Pt,G,l,s) (Pt.*G.^2.*l.^2.*s./((4*pi)^3*Pmin)).^(1/4);
fprintf('Base Rmax = %.2f km\n', Rm(Pt,G,lam,s)/1e3);

subplot(2,2,1); plot(1:100, Rm((1:100)*1e3,G,lam,s)/1e3); xlabel('Pt (kW)'); ylabel('Rmax (km)'); title('Pt vs Rmax'); grid on;
subplot(2,2,2); plot(10:1000, Rm(Pt,10:1000,lam,s)/1e3); xlabel('Gain (linear)'); ylabel('Rmax (km)'); title('Gain vs Rmax'); grid on;
subplot(2,2,3); plot(1:20, Rm(Pt,G,3e8./((1:20)*1e9),s)/1e3); xlabel('Frequency (GHz)'); ylabel('Rmax (km)'); title('Frequency vs Rmax'); grid on;
subplot(2,2,4); plot(0.1:0.1:10, Rm(Pt,G,lam,0.1:0.1:10)/1e3); xlabel('RCS (m^2)'); ylabel('Rmax (km)'); title('RCS vs Rmax'); grid on;