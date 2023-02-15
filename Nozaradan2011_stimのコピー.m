%********************************************************************
% Nozaradan2011_stim.m
% author: Shinya Fujii@Keio University SFC
% created: November-9-2022
% editor: Keigo Yoshida@Keio Uinversity SFC
% edited: December-1-2022 
% explanation:
% This is a Matlab M file to create the 
% sound stimulus in the Nozaradan 2011 paper
% See: Nozaradan, S., Peretz, I., Missal, M., & Mouraux, A. (2011). 
% Tagging the neuronal entrainment to beat and meter. 
% The Journal of Neuroscience 31(28), 10234–10240.
%******************************************************************

% Description of Auditory stimulation from Nozaradan et al. (2011)
% Each auditory stimulus lasted 33 s.
% The stimulus consisted of a 333.3 Hz pure tone in which 
% a 2.4 Hz auditory beat was introduced by modulating 
% the amplitude of the tone with a 2.4 Hz periodicity 
% (i.e., 144 beats/min), 
% using an asymmetrical Hanning envelope 
% (22 ms rise time and 394 ms fall time, 
% amplitude modulation between 0 and 1). 
% The sound was then amplitude modulated using an 11 Hz sinusoidal function
% oscillating between 0.3 and 1. 

%---------
% Step 1: 
% Create a 333.3 Hz career pure-tone which have 33-s duration.
%---------
fs = 48000 ; % sampling frequency (Hz)
f = 333.3 ; % stimulus frequency (Hz)
amp_career = 1 ; % amplitude of career 
d = 33 ; % duration (sec)

n = round(fs*d) ; % get number of data
t = [(1:n)/fs]' ; % creat t axis
y = sin(2*pi*f*t); % make pure note

%---------
% Step 2: 
% Create an asymmetrical Hanning envelope 
% (22 ms rise time and 394 ms fall time, 
% amplitude modulation between 0 and 1). 
%---------
% rise part
d_rise = 0.022 ; % duration of rise part (sec)
n_rise = round(fs*d_rise*2) ; % mutiply by two because symmetrical Hann window
hann_rise = hann(n_rise) ;
hann_rise_half = hann_rise(1:n_rise/2) ;

% fall part
d_fall = 0.394 ; % duration of rise part (sec)
n_fall = round(fs*d_fall*2) ; % mutiply by two because symmetrical Hann window
hann_fall = hann(n_fall) ;
hann_fall_half = hann_fall(n_fall/2+1:end) ;

% combine the rise and fall parts
hann_async = [hann_rise_half; hann_fall_half];
n_hann_async = length(hann_async) ; % number of data points
d_hann_async = n_hann_async/fs ; % duration of window -> confirmed as 416 sec

%---------
% Step 3: 
% modulating the amplitude of the tone 
% with the asymmetric hanning window (2.4 Hz periodicity) 
%---------
% calculate the number of repeat
nRep = floor(n/n_hann_async) ;
% repeat the async hann window
hann_async_rep = repmat(hann_async,nRep,1) ;
% the number of repeated async hann window
n_hann_async_rep = length(hann_async_rep) ;
% the number of last async hann window
n_last = n - n_hann_async_rep ;
% the last async hanning window
hann_async_last = hann_async(1:n_last) ;
% combine the repeated windows and the last window
hann_all = [hann_async_rep; hann_async_last] ;
% check if the number of data match with the n
n_hann_all = length(hann_all) ;

%---------
% Step 4: 
% amplitude modulation using an 11 Hz sinusoidal function
% oscillating between 0.3 and 1. 
%---------
fmod = 11 ; % stimulus frequency (Hz)
ymod1 = sin(2*pi*fmod*t); % make pure note
ymod2 = ymod1 + 1.857 ; % <- Don't know why this
ymod3 = ymod2./max(ymod2);
% check the oscillating between 0.3 and 1. 
min(ymod3)
max(ymod3)

% ---------
% Step 5: 
% Create the signal and Envelope
% ---------
env = hann_all.*ymod3 ; % Envelope
sig = y.*env ; % Signal

sigx = reshape(sig,[],1);
sigxx = reshape(sig,[],1);

xx = length(sigx);
sigx(1000000:1200000,:) = 0;
sigxx(900000:900192,:) = 0;
%1s = 48000 1ms=48 4ms = 192
% disp(sigx)
% disp(xx)


% plot to confirm
figure
subplot(7,1,1)
plot(t,y)
subplot(7,1,2)
plot(t,hann_all)
subplot(7,1,3)
plot(t,y.*hann_all)
subplot(7,1,4)
plot(t,ymod3)
subplot(7,1,5)
plot(t,env)
subplot(7,1,6)
plot(t,sigx)
subplot(7,1,7)
plot(t,sigxx)

% % fft for signal
% n_sig = length(sig) ;
% y_sig = fft(sig);
% p2_sig = abs(y_sig/n_sig);
% p1_sig = p2_sig(1:n_sig/2+1);
% p1_sig(2:end-1) = 2*p1_sig(2:end-1);
% f_sig = fs*(0:(n_sig/2))/n_sig;
% 
% % fft for envelope
% n_env = length(env) ;
% y_env = fft(env);
% p2_env = abs(y_env/n_env);
% p1_env = p2_env(1:n_env/2+1);
% p1_env(2:end-1) = 2*p1_env(2:end-1);
% f_env = fs*(0:(n_env/2))/n_env;
% 
% % plot fft to confirm 
% figure
% subplot(2,1,1)
% plot(f_sig,p1_sig) 
% title('Single-Sided Amplitude Spectrum of Signal')
% xlabel('f (Hz)')
% ylabel('|power|')
% xlim([0 500])
% 
% subplot(2,1,2)
% plot(f_env,p1_env) 
% title('Single-Sided Amplitude Spectrum of Signal')
% xlabel('f (Hz)')
% ylabel('|power|')
% xlim([0.5 12.5])
% 
% % play sound
 sound(sigxx,fs);
% audiowrite('B.wav',sigxx,fs) ;