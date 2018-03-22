% Joe Kusters
% downlink_sim.m
% matlab script for simulating a laser downlink

% set parameter values for sim
M  =   4;
num_codewords = 1;
code_length = 100; 
frame_header = [2 4 6 8];
frame_size = code_length;
framed_length =  code_length+size(frame_header, 2);

% create random data
data = randi([0 2^M-1],  num_codewords, code_length);

% encode data
encoded_data = data;

% add frame headers
framed_data = zeros(num_codewords, framed_length);
for i = 1:num_codewords
    framed_data(i, 1:size(frame_header, 2)) = frame_header;
    framed_data(i, size(frame_header, 2)+1:end) = encoded_data(i, :);
end  

% map to ppm symbols + add guard slots
modulated_data = zeros(num_codewords, framed_length*(1.25*2^M));
for i = 1:num_codewords
    for j = 1:framed_length
        slot = framed_data(i, j);
        modulated_data(i, (1.25*2^M)*j+slot) = 1; 
    end
end

% convert to transmit power, add channel noise, compute received power
noise = makedist('Normal', 'mu', 0.1, 'sigma', 0.03);
signal = makedist('Gamma', 'a', 3, 'b',  3);
received_data =  random(noise, num_codewords, framed_length*(1.25*2^M));
for i =  1:num_codewords
    for j =  1:framed_length
        slot = framed_data(i, j);
        received_data(i, (1.25*2^M)*j+slot) = received_data(i, (1.25*2^M)*j+slot) + random(signal);
    end
end

% slot sync via ML ISGT

% frame sync via convolution with frame header

% llr generation

% decode

% compute bit errors after decoding