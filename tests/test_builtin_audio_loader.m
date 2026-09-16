function test_builtin_audio_loader()
%TEST_BUILTIN_AUDIO_LOADER The app should use a packaged built-in audio file when present.
root=tempname; mkdir(root); mkdir(fullfile(root,'audio'));
cleanup=onCleanup(@()cleanup_root(root)); %#ok<NASGU>
fs0=8000; t=(0:fs0-1)'/fs0; x0=0.3*sin(2*pi*440*t);
audiowrite(fullfile(root,'audio','builtin_demo.wav'),x0,fs0);
[x,fs,name,sourceFile]=load_builtin_audio(root);
assert(fs==fs0,'Built-in audio loader did not preserve sample rate.');
assert(numel(x)==numel(x0),'Built-in audio loader did not load the packaged waveform.');
assert(contains(name,'内置音频'),'Built-in audio should be identified as built-in audio.');
assert(endsWith(sourceFile,'builtin_demo.wav'),'Packaged built-in audio file was not selected.');
end

function cleanup_root(root)
if exist(root,'dir'), rmdir(root,'s'); end
end
