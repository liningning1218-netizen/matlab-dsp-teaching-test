function audio = make_audio_struct(x, fs, name)
%MAKE_AUDIO_STRUCT Build the shared audio state used by the teaching app.
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'}, mfilename, 'fs');
if nargin < 3 || isempty(name)
    name = '未命名音频';
end
x = normalize_audio(x);
audio = struct();
audio.x = x;
audio.fs = double(fs);
audio.t = (0:numel(x)-1)' / audio.fs;
audio.name = char(string(name));
audio.processed = [];
audio.processedFs = audio.fs;
audio.processedName = '';
end
