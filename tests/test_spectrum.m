function test_spectrum()
fs = 8000;
N = 8000;
t = (0:N-1)' / fs;
x = 0.8 * sin(2*pi*1000*t);
[f, mag] = one_sided_spectrum(x, fs);
[~, idx] = max(mag);
assert(abs(f(idx) - 1000) <= fs/N, 'FFT peak should be at 1 kHz.');
assert(abs(mag(idx) - 0.8) < 0.02, 'Single-sided amplitude should preserve sinusoid amplitude.');
end
