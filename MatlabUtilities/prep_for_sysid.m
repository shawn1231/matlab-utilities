% first load in a table of data using the GUI import tool
% you should also read in the prescribed_input.csv using the same technique

% change the name to df so the rest of the functions will run unmodified
df = ServoAYMB2Mar1321320;

% use curly braces to unpack the table into a simple vector
input = prescribedinput{:,:};

% create a vector for the response (output) using the make_continuous
% function
response = make_continuous(df.adc3, 5000-thresh, 0+thresh, 5000);

% make sure the vectors are the same length
response(length(input)+1:end) = [];

% have to transpose as well
response = response';