% Add the directory containing the utility functions to the MATLAB path.
utilpath = fullfile(matlabroot, 'toolbox', 'imaq', 'imaqdemos', ...
    'html',  'laserTracking');
addpath(utilpath);

% Access and configure a device.
vid = videoinput('winvideo', 1, 'RGB24_320x240');
vid.FramesPerTrigger = 1;
vid.TriggerRepeat = Inf;
triggerconfig(vid,'manual')

% Create the laser figure window.
laserFig = figure;
hBox = plot([0 0 1 1 0], [0 1 1 0 0], 'b-');
hold on

% Set up calibration screen. Modify the cursor so it does not 
% interfere with the calibration.
hTarget = plot(0, 0, 'yo');
ax = gca;
ax.Color = [0, 0, 0];
laserFig.Color = [0, 0, 0];
laserFig.Menubar = 'none';
laserFig.DoubleBuffer = 'on';
laserFig.Pointer = custom;
laserFig.PointerShapeCData = repmat(NaN, 16, 16);