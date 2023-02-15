all_audio_files = {'aud1.wav', 'aud2.wav', 'aud3.wav', 'aud4.wav', 'aud5.wav', 'aud6.wav', 'aud7.wav', 'aud8.wav', 'aud9.wav', 'aud10.wav', 'aud11.wav', 'aud12.wav'};
played_audio_files = {};

while ~isempty(all_audio_files)
    % randomly select an audio file from all_audio_files
    index = randi(numel(all_audio_files));
    audio_file = all_audio_files{index};
    
    % play the audio file
    [y,Fs] = audioread(audio_file);
    sound(y,Fs);
    
    % add the audio file to the list of played audio files
    played_audio_files = [played_audio_files, audio_file];
    
    % remove the audio file from the list of all audio files
    all_audio_files = setdiff(all_audio_files, audio_file);
end