function b = design_fir_filter(type, fs, order, f1, f2)
%DESIGN_FIR_FILTER Toolbox-independent windowed-sinc FIR filter design.
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(order, {'numeric'}, {'scalar','integer','>=',2});
validateattributes(f1, {'numeric'}, {'scalar','real','finite','positive','<',fs/2});
if rem(order,2) ~= 0
    order = order + 1;
end
if nargin < 5, f2 = []; end
type = lower(char(string(type)));
if any(strcmp(type, {'bandpass','bandstop'}))
    validateattributes(f2, {'numeric'}, {'scalar','real','finite','>',f1,'<',fs/2});
end
n = (0:order)';
m = n - order/2;
w = 0.54 - 0.46*cos(2*pi*n/order);
delta = zeros(size(n)); delta(order/2+1) = 1;
lp1 = ideal_lowpass(f1, fs, m) .* w;
lp1 = lp1 / sum(lp1);
switch type
    case 'lowpass'
        b = lp1;
    case 'highpass'
        b = delta - lp1;
        b = b / response_gain(b, fs/2, fs);
    case {'bandpass','bandstop'}
        lp2 = ideal_lowpass(f2, fs, m) .* w;
        lp2 = lp2 / sum(lp2);
        bp = lp2 - lp1;
        bp = bp / response_gain(bp, (f1+f2)/2, fs);
        if strcmp(type, 'bandpass')
            b = bp;
        else
            b = delta - bp;
            b = b / sum(b);
        end
    otherwise
        error('design_fir_filter:UnknownType', '未知 FIR 类型: %s', type);
end
b = real(b(:));
end

function h = ideal_lowpass(fc, fs, m)
a = 2*fc/fs;
z = a*m;
s = ones(size(z));
nz = abs(z) > eps;
s(nz) = sin(pi*z(nz))./(pi*z(nz));
h = a*s;
end

function g = response_gain(b, f, fs)
n = (0:numel(b)-1)';
H = sum(b(:).*exp(-1i*2*pi*f/fs*n));
g = abs(H);
if g < 1e-12
    error('design_fir_filter:DegenerateResponse', '滤波器归一化失败，请检查截止频率。');
end
end
