f = 12e9;           % Carrier frequency = 12 GHz
d = 38000e3;        % Satellite slant range = 38,000 km
Pt = 100;           % Transmitter power = 100 W
Dt = 2.4;           % Transmit antenna diameter = 2.4 m
et = 0.65;          % Transmit antenna efficiency = 65%
Dr = 1.8;           % Receive antenna diameter = 1.8 m
er = 0.60;          % Receive antenna efficiency = 60%
Lt = 2;             % Transmitter losses = 2 dB
Lo = 1.5;           % Other propagation/system losses = 1.5 dB
Lr = 2;             % Rain attenuation = 2 dB
T = 500;            % Receiver system temperature = 500 K
B = 36e6;           % Receiver bandwidth = 36 MHz
CN_req = 12;        % Required C/N = 12 dB

lam = 3e8 / f;
Gt = 10*log10(et * (pi*Dt/lam)^2);
Gr = 10*log10(er * (pi*Dr/lam)^2);
EIRP = 10*log10(Pt) + Gt - Lt;

FSL = 20*log10(4*pi*d/lam);
Pr = EIRP + Gr - FSL - Lo - Lr;
N = -228.6 + 10*log10(T*B);
CN = Pr - N;
Margin = CN - CN_req;

fprintf('EIRP = %.2f dBW\n', EIRP);
fprintf('Received Power (Pr) = %.2f dBW\n', Pr);
fprintf('C/N Ratio = %.2f dB\n', CN);
fprintf('Link Margin = %.2f dB\n', Margin);
