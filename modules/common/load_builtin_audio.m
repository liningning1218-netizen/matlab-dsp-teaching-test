function [x, fs, name, sourceFile] = load_builtin_audio(projectRoot)
%LOAD_BUILTIN_AUDIO Load the packaged classroom audio, with a generated fallback.
if nargin < 1 || isempty(projectRoot)
    projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end
sourceFile = '';
audioDir = fullfile(projectRoot,'audio');
mp3File = fullfile(audioDir,'builtin_demo.mp3');
wavFile = fullfile(audioDir,'builtin_demo.wav');
legacyFile = fullfile(audioDir,'demo_speech_like.wav');
if exist(mp3File,'file')
    [x,fs] = audioread(mp3File);
    name = '内置音频：最后一页片段';
    sourceFile = mp3File;
elseif exist(wavFile,'file')
    [x,fs] = audioread(wavFile);
    name = '内置音频';
    sourceFile = wavFile;
elseif exist(legacyFile,'file')
    [x,fs] = audioread(legacyFile);
    name = '内置教学示例（非真实语音）';
    sourceFile = legacyFile;
else
    [x,fs] = generate_demo_audio('');
    name = '内置教学示例（非真实语音）';
end
x = normalize_audio(x);
end
