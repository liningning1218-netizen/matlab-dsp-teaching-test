function test_filtering()
fs = 8000;
t = (0:fs-1)' / fs;
x = sin(2*pi*300*t) + 0.8*sin(2*pi*1000*t);
b = design_fir_filter('bandstop', fs, 200, 900, 1100);
y = apply_fir_filter(x, b);
[f0, m0] = one_sided_spectrum(x, fs);
[f1, m1] = one_sided_spectrum(y, fs);
idx300_0 = nearest_bin(f0, 300);
idx1000_0 = nearest_bin(f0, 1000);
idx300_1 = nearest_bin(f1, 300);
idx1000_1 = nearest_bin(f1, 1000);
atten1000 = m1(idx1000_1) / m0(idx1000_0);
preserve300 = m1(idx300_1) / m0(idx300_0);
assert(atten1000 < 0.20, 'Band-stop FIR should strongly attenuate 1 kHz.');
assert(preserve300 > 0.70, 'Band-stop FIR should largely preserve 300 Hz.');
end

function idx = nearest_bin(f, target)
[~, idx] = min(abs(f-target));
end
