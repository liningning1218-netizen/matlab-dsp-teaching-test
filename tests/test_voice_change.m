function test_voice_change()
x = linspace(-1, 1, 1000)';
yUp = change_pitch_speed(x, 1.25);
yDown = change_pitch_speed(x, 0.8);
assert(numel(yUp) == 800, 'Factor 1.25 should shorten duration by 1/1.25.');
assert(numel(yDown) == 1250, 'Factor 0.8 should lengthen duration by 1/0.8.');
assert(all(isfinite(yUp)) && all(isfinite(yDown)), 'Voice-change output must be finite.');
end
