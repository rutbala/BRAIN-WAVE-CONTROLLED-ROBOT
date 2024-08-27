% Initialize Bluetooth connection with Mindwave Mobile
bt = Bluetooth('HC-05', 1); % Replace 'HC-05' with your Bluetooth module name
fopen(bt);

% Initialize Arduino
arduinoBoard = arduino('COM3', 'Uno'); % Replace 'COM3' with your Arduino port
motorShield = addon(arduinoBoard, 'Adafruit/MotorShieldV2');

% Initialize motors
motor1 = dcmotor(motorShield, 1); % Motor 1 on port 1
motor2 = dcmotor(motorShield, 2); % Motor 2 on port 2

% Function to read EEG data and blink detection
function [attention, blink, meditation] = readEEGData(bt)
    data = fread(bt, 256, 'uint8'); % Read data from Bluetooth
    attention = data(4); % Example index for attention (adjust as needed)
    blink = data(12); % Example index for blink detection (adjust as needed)
    meditation = data(20); % Example index for meditation (adjust as needed)
end

% Function to control robot movement based on direction
function controlMovement(direction, motor1, motor2)
    switch direction
        case 'forward'
            writeSpeed(motor1, 0.5); % Forward at half speed
            writeSpeed(motor2, 0.5); % Forward at half speed
        case 'backward'
            writeSpeed(motor1, -0.5); % Backward at half speed
            writeSpeed(motor2, -0.5); % Backward at half speed
        case 'left'
            writeSpeed(motor1, -0.5); % Rotate left
            writeSpeed(motor2, 0.5); % Rotate left
        case 'right'
            writeSpeed(motor1, 0.5); % Rotate right
            writeSpeed(motor2, -0.5); % Rotate right
        case 'stop'
            stop(motor1);
            stop(motor2);
        otherwise
            stop(motor1);
            stop(motor2);
    end
end

% Main control loop
currentMode = 'chair'; % Default mode
while true
    [attention, blink, meditation] = readEEGData(bt);
    
    % Mode switching based on blink detection
    if blink > 50  % Threshold for detecting a blink
        disp('Blink detected, switching mode...');
        if strcmp(currentMode, 'chair')
            currentMode = 'light';
        else
            currentMode = 'chair';
        end
        pause(0.5); % Debounce to prevent multiple detections
    end
    
    % Chair mode: control movement based on attention level
    if strcmp(currentMode, 'chair')
        if attention > 60  % Example threshold for attention level
            disp('Moving forward...');
            controlMovement('forward', motor1, motor2);
        elseif attention < 30  % Example threshold for low attention
            disp('Stopping...');
            controlMovement('stop', motor1, motor2);
        end
    elseif strcmp(currentMode, 'light')
        % Light mode: Example logic for controlling lights
        if blink > 50
            disp('Toggling light...');
            % Add your code here to toggle lights or perform other actions
            pause(1); % Prevent multiple toggles
        end
    end
    
    pause(0.1); % Pause to allow for a stable control loop
end

% Close Bluetooth connection
fclose(bt);  % Close the Bluetooth connection
delete(bt);  % Delete the Bluetooth object
clear bt;    % Clear the variable from the workspace
