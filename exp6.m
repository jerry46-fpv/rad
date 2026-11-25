az=[40 120 220 300];
r=[25 50 75 60];

figure;
subplot(1,3,1)
polarplot(deg2rad(az),r,’ro’,’MarkerFaceColor’,’r’);
rlim([0 100]); title(‘PPI’);

subplot(1,3,2)
plot(r,’b-o’); grid on
xlabel(‘Target’); ylabel(‘Range (km)’);
title(‘A-Scan’);

subplot(1,3,3)
imagesc(az,r,ones(4,1)*[1 2 3 4]);
xlabel(‘Azimuth’); ylabel(‘Range (km)’);
title(‘B-Scan’); colorbar;
