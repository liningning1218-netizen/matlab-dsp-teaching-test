function test_aliasing()
fa = alias_frequency(900, 1000);
assert(abs(fa - 100) < 1e-12, 'Expected alias at 100 Hz.');
fa = alias_frequency(200, 1000);
assert(abs(fa - 200) < 1e-12, 'Sub-Nyquist tone should not alias.');
fs = 8000;
t = (0:fs-1)' / fs;
x = sin(2*pi*3000*t);
[y, fsNew] = naive_decimate_audio(x, fs, 4);
assert(fsNew == 2000, 'New sample rate should be fs/factor.');
assert(numel(y) == 2000, 'Direct decimation should keep every fourth sample.');
end
