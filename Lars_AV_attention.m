% Clear the workspace
clear;
close all;
Screen('Preference', 'SkipSyncTests', 1);
sca;

%----------------------------
% stimuli size setup
%----------------------------
screenYcm = 19.5; % screen width in y axis
screenDistance = 61; % distance between eye and screen

mvXDeg = 13.3/180*pi; % move sphere sinusoidally from center to 14 degree eccentricity
sphereRadiusDeg = 1.2/180*pi;
SphereRadiusRatio = tan(sphereRadiusDeg)*screenDistance*2 / screenYcm;

%---------------
% task timing setup
%---------------

% Length of the beep
stimSecs = 3.3*10; % 3.3*10 set TR = 3.3

% Length of the pause between beeps
restSecs = 3.3*8; % 3.3*8

trialNum = 28; %

targetDurSecs = 0.3; % target appearing duration
% targetInterSecs = [3 10]; % target appearing interval

% target will not appear at times that is close to the block ends [-targetNoRatio*StimSec, responseDuration]
targetNoRatio = 0.8;

targetInterSecs = [50 100]; % target appearing interval



%---------------
% task type setup
%---------------

taskTypes = [3]; % 1:audio motion; 2:visual motion; 3:congruent audiovisual motion; 4:incongruent audiovisual motion
responseDuration = 4; % sec

repeatNum = round(trialNum/length(taskTypes)); 
trialNum = repeatNum*length(taskTypes); % reset trialNum based on the task types

taskList = zeros(1,trialNum);
for idxBgn = 1:length(taskTypes):trialNum
    rng('shuffle'); % to avoid repeating the same random number arrays when MATLAB restart
    idx = randperm(length(taskTypes));
    taskList(idxBgn:idxBgn+length(taskTypes)-1) = taskTypes(idx);
    % if idxBgn == 1
    %     % make sure that it always start with the audiovisual or visual motion
    %     while taskList(1) ~= max(taskTypes)
    %         rng('shuffle');
    %         idx = randperm(length(taskTypes));
    %         taskList(idxBgn:idxBgn+length(taskTypes)-1) = taskTypes(idx);
    %     end
    % end   
end


% taskList = repmat(taskTypes,1,repeatNum);
% rng('shuffle'); % to avoid repeating the same random number arrays when MATLAB restart
% idx = randperm(trialNum);
% taskList = taskList(idx);

% % make sure that it always start with the audiovisual or visual motion
% while taskList(1) ~= max(taskTypes)
%     rng('shuffle'); % to avoid repeating the same random number arrays when MATLAB restart
%     idx = randperm(trialNum);
%     taskList = taskList(idx);
% end


%---------------
% Sound Setup
%---------------

% Initialize Sounddriver
InitializePsychSound(1);

[audiodataL, samplingRate] = psychwavread('Afro 20 sounds left.wav');
[audiodataR, samplingRate] = psychwavread('Afro 20 sounds right.wav');

audioLength = length(audiodataL);
audiodataL_last = audiodataL(1:round(audioLength*0.7),:);
audiodataR_last = audiodataR(1:round(audioLength*0.7),:);
framesLastAudio = round(round(audioLength*0.7)/samplingRate*60);

% Number of channels and Frequency of the sound
nrchannels = 2;
% samplingRate = 48000;

% Should we wait for the device to really start (1 = yes)
% INFO: See help PsychPortAudio
waitForDeviceStart = 1;

% Open Psych-Audio port, with the follow arguements
% (1) [] = default sound device
% (2) 1 = sound playback only
% (3) 1 = default level of latency
% (4) Requested frequency in samples per second
% (5) 2 = stereo putput
audioMotionR = PsychPortAudio('Open', [], 1, 1, samplingRate, nrchannels);
audioMotionL = PsychPortAudio('Open', [], 1, 1, samplingRate, nrchannels);
audioMotionR_last = PsychPortAudio('Open', [], 1, 1, samplingRate, nrchannels);
audioMotionL_last = PsychPortAudio('Open', [], 1, 1, samplingRate, nrchannels);

audioMotionList = [audioMotionR audioMotionL audioMotionR_last audioMotionL_last];

% Set the volume
volumeInc = 2.5;
PsychPortAudio('Volume', audioMotionL, volumeInc);
PsychPortAudio('Volume', audioMotionR, volumeInc);
PsychPortAudio('Volume', audioMotionL_last, volumeInc);
PsychPortAudio('Volume', audioMotionR_last, volumeInc);

% Length of the beep
beepLengthSecs = 3;
beepNumInACluster = round(stimSecs/beepLengthSecs); % num of beeps in one cluster

stimSecs = beepNumInACluster*beepLengthSecs; % reset stim duration


% Fill the audio playback buffer with the audio data, doubled for stereo
% presentation
PsychPortAudio('FillBuffer', audioMotionL, audiodataL');
PsychPortAudio('FillBuffer', audioMotionR, audiodataR');
PsychPortAudio('FillBuffer', audioMotionL_last, audiodataL_last');
PsychPortAudio('FillBuffer', audioMotionR_last, audiodataR_last');

%---------------
% Screen Setup
%---------------

% visual field, screenpixels=1024x768
% 18 cm for screenY of 768 pxls, vertical direction
% display distance = 64 cm
% visual angle = atan(18/64)/pi*180 = 15.7 degree in vertical direction
% 

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Select the external screen if it is present, else revert to the native
% screen
screenNumber = min(screens);

% Define black, white and grey
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
grey = white / 2;

green = [0 1 0];

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper: A special setting of doAccum == 2 will
% enable OpenGL accumulation buffer support if code wants to use the
% glAccum() function.
InitializeMatlabOpenGL;

% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, 90/255);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

% Set the text size
Screen('TextSize', window, 70);

% Calculate how long the beep and pause are in frames
beepLengthFrames = round(beepLengthSecs / ifi);


% The avaliable keys to press
escapeKey = KbName('ESCAPE');
triggerKey = KbName('t');
responseKey = KbName({'r','g','b','y','a','s'});

%--------------------------------------------------------------------------
%                  checkerboard ball
%--------------------------------------------------------------------------

visualMotionList = [1 -1]; % moving left or right

% Setup the OpenGL rendering context of the onscreen window for use by
% OpenGL wrapper. After this command, all following OpenGL commands will
% draw into the onscreen window 'window':
Screen('BeginOpenGL', window);

% Get the aspect ratio of the screen:
ar = windowRect(4)/windowRect(3);

% Turn on OpenGL local lighting model: The lighting model supported by
% OpenGL is a local Phong model with Gouraud shading. The color values
% at the vertices (corners) of polygons are computed with the Phong lighting
% model and linearly interpolated accross the inner area of the polygon from
% the vertex colors. The Phong lighting model is a coarse approximation of
% real world lighting with ambient light reflection (undirected isotropic light),
% diffuse light reflection (position wrt. light source matters, but observer
% position doesn't) and specular reflection (ideal mirror reflection for highlights).
%
% The model does not take any object relationships into account: Any effects
% of (self-)occlusion, (self-)shadowing or interreflection of light between
% objects are ignored. If you need shadows, interreflections and global illumination
% you will either have to learn advanced OpenGL rendering and shading techniques
% to implement your own realtime shadowing and lighting models, or
% compute parts of the scene offline in some gfx-package like Maya, Blender,
% Radiance or 3D Studio Max...
%
% If you want to do any shape from shading studies, it is very important to
% understand the difference between a local lighting model and a global
% illumination model!!!
glEnable(GL.LIGHTING);

% Force there to be no ambient light (OpenGL default is for there to be
% some, however for this demo we want to fully demonstrate directional
% lighting)
glLightModelfv(GL.LIGHT_MODEL_AMBIENT, [0 0 0 1]);

% Enable the first local light source GL.LIGHT_0. Each OpenGL
% implementation is guaranteed to support at least 8 light sources,
% GL.LIGHT0, ..., GL.LIGHT7
glEnable(GL.LIGHT0);

% Defuse light only
glLightfv(GL.LIGHT0, GL.DIFFUSE, [1 1 1 1]);

% Point the light at the origin (this is where we will place our sphere)
glLightfv(GL.LIGHT0, GL.SPOT_DIRECTION, [0 0 0]);

% Enable proper occlusion handling via depth tests:
glEnable(GL.DEPTH_TEST);

% Allow normalisation
glEnable(GL.NORMALIZE);

% Set projection matrix: This defines a perspective projection,
% corresponding to the model of a pin-hole camera - which is a good
% approximation of the human eye and of standard real world cameras --
% well, the best aproximation one can do with 3 lines of code ;-)
glMatrixMode(GL.PROJECTION);
glLoadIdentity;


% Calculate the field of view in the y direction 
angle = 2 * atand(screenYcm/2 / screenDistance);

% Set up our perspective projection. This is defined by our field of view
% (here given by the variable "angle") and the aspect ratio of our frustum
% (our screen) and two clipping planes. These define the minimum and
% maximum distances allowable here 0.1cm and 200cm. If we draw outside of
% these regions then the stimuli won't be rendered
gluPerspective(angle, 1/ar, 0.1, 200);

% Setup modelview matrix: This defines the position, orientation and
% looking direction of the virtual camera:
glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

% Our point lightsource is at position (x,y,z) == (1,2,3)...
glLightfv(GL.LIGHT0,GL.POSITION,[ 1 2 5 0 ]);

% Cam is located at 3D position (3,3,5), points upright (0,1,0) and fixates
% at the origin (0,0,0) of the worlds coordinate system:
% The OpenGL coordinate system is a right-handed system as follows:
% Default origin is in the center of the display.
% Positive x-Axis points horizontally to the right.
% Positive y-Axis points vertically upwards.
% Positive z-Axis points to the observer, perpendicular to the display
% screens surface.
% gluLookAt(3,3,5,0,0,0,0,1,0);

% Location of the camera is at the origin
cam = [0 0 6.38];

% Set our camera to be looking directly down the Z axis (depth) of our
% coordinate system
fix = [0 0 -1];

% Define "up"
up = [0 1 0];

% Here we set up the attributes of our camera using the variables we have
% defined in the last three lines of code
gluLookAt(cam(1), cam(2), cam(3), fix(1), fix(2), fix(3), up(1), up(2), up(3));
% Reposition camera (see above):
% gluLookAt(0,0,5,0,0,0,0,1,0);

% Set background clear color to 'black' (R,G,B,A)=(0,0,0,0):
glClearColor(90/255,90/255,90/255,0);

% Clear out the backbuffer: This also cleans the depth-buffer for
% proper occlusion handling: You need to glClear the depth buffer whenever
% you redraw your scene, e.g., in an animation loop. Otherwise occlusion
% handling will screw up in funny ways...
glClear;

% Finish OpenGL rendering into PTB window. This will switch back to the
% standard 2D drawing functions of Screen and will check for OpenGL errors.
Screen('EndOpenGL', window);

% Show rendered image at next vertical retrace:
Screen('Flip', window);

% Prepare texture to by applied to the sphere: Load and create it from an image file:
myimg = imread('checker.jpg');

% Apply regular checkerboard pattern as texture:
bv = zeros(64);
wv = ones(64);
myimg = uint8((repmat([bv wv; wv bv],6,6) > 0.5) * 255);

% Make a special power-of-two texture from the image by setting the enforcepot - flag to 1
% when calling 'MakeTexture'. GL_TEXTURE_2D textures (==power of two textures) are
% especially easy to handle in OpenGL. If you use the enforcepot flag, it is important
% that the texture image 'myimg' has a width and a height that is exactly a power of two,
% otherwise this command will fail: Allowed values for image width and height are, e.g.,
% 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048 and on some high-end gfx cards
% 4096 pixels. Our example image has a size of 512 by 256 pixels...
% Psychtoolbox also supports rectangular textures of arbitrary size, so called
% GL_TEXTURE_RECTANGLE_2D textures. These are normally used for Screen's drawing
% commands, but they are more difficult to handle in standard OpenGL code...
mytex = Screen('MakeTexture', window, myimg, [], 1);

% Retrieve OpenGL handles to the PTB texture. These are needed to use the texture
% from "normal" OpenGL code:
[gltex, gltextarget] = Screen('GetOpenGLTexture', window, mytex);

% Begin OpenGL rendering into onscreen window again:
Screen('BeginOpenGL', window);

% Enable texture mapping for this type of textures...
glEnable(gltextarget);

% Bind our texture, so it gets applied to all following objects:
glBindTexture(gltextarget, gltex);

% Textures color texel values shall modulate the color computed by lighting model:
glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);

% Clamping behaviour shall be a cyclic repeat:
glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.REPEAT);
glTexParameteri(gltextarget, GL.TEXTURE_WRAP_T, GL.REPEAT);

% Checkerboard pattern: This has high frequency edges, so we'll
% need trilinear filtering for a good look:
glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);

% Need mipmapping for trilinear filtering --> Create mipmaps:
if ~isempty(findstr(glGetString(GL.EXTENSIONS), 'GL_EXT_framebuffer_object'))
    % Ask the hardware to generate all depth levels automatically:
    glGenerateMipmapEXT(GL.TEXTURE_2D);
else
    % No hardware support for auto-mipmap-generation. Do it "manually":

    % Use GLU to compute the image resolution mipmap pyramid and create
    % OpenGL textures ouf of it: This is slow, compared to glGenerateMipmapEXT:
    r = gluBuild2DMipmaps(gltextarget, GL.LUMINANCE, size(myimg,1), size(myimg,2), GL.LUMINANCE, GL.UNSIGNED_BYTE, uint8(myimg));
    if r>0
        error('gluBuild2DMipmaps failed for some reason.');
    end
end


glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

% Set basic "color" of object to white to get a nice interaction between the texture
% and the objects lighting:
glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 1 1 1 1 ]);
glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1 1 1 1 ]);

% % Reset our virtual camera and all geometric transformations:
% glMatrixMode(GL.MODELVIEW);
% glLoadIdentity;

% % Reposition camera (see above):
% gluLookAt(0,0,5,0,0,0,0,1,0);

% Create the sphere as a quadric object. This is needed because the simple glutSolidSphere
% command does not automatically assign texture coordinates for texture mapping onto a sphere:
% mysphere is a handle that you need to pass to all quadric functions:
mysphere = gluNewQuadric;

% Enable automatic generation of texture coordinates for our quadric object:
gluQuadricTexture(mysphere, GL.TRUE);

rot10= 80*sin(-.5*pi);
% rot20= 80*sin(-.5*pi);
% rot30= 80*sin(-.5*pi); 

% rotation = $rot, '-0.5*$rot2', '.75*$rot3';

% Apply some static rotation to the object to have a nice view onto it:
% This basically rotates our spinning earth into an orientation that
% roughly matches the real orientation in space...
% First -90 degrees around its x-axis...
glRotatef(rot10, 1,0,0);

% % ...then 18 degrees around its new (rotated) y-axis...
% glRotatef(-0.5*rot20,0,1,0);

% glRotatef(0.75*rot30,0,0,1);



% pixels that sphere moves in X maximally
mvXPxls = screenDistance*tan(mvXDeg)*2 / screenYcm * screenYpixels; % from left maximal to right maximal
mvXNorm = mvXPxls/screenYpixels;

% glTranslatef(mvXNorm, 0, 0);

Screen('EndOpenGL', window);


%--------------------------------------------------------------------------
%                  fixation
%--------------------------------------------------------------------------

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 15;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

% position, 3.75 deg below center
fixYPos = floor(screenDistance*tan(3/180*pi) / screenYcm * screenYpixels);

crossColor = white;


nextTargetTimeList = zeros(100,1);

for nextInd = 1:length(nextTargetTimeList)
    if nextInd == 1
        nextTargetTime = randi(targetInterSecs,1,1);
        while rem(nextTargetTime,restSecs+stimSecs)>restSecs+stimSecs*targetNoRatio | rem(nextTargetTime,restSecs+stimSecs)<responseDuration
            nextTargetTime = randi(targetInterSecs,1,1);
        end
    else
        nextTargetTime = nextTargetTimeList(nextInd-1)+randi(targetInterSecs,1,1);
        while rem(nextTargetTime,restSecs+stimSecs)>restSecs+stimSecs*targetNoRatio | rem(nextTargetTime,restSecs+stimSecs)<responseDuration
            nextTargetTime = nextTargetTimeList(nextInd-1)+randi(targetInterSecs,1,1);
        end
    end
    nextTargetTimeList(nextInd) = nextTargetTime;
end

nextTargetTime = nextTargetTimeList(1);



%--------------------------------------------------------------------------
%                  present stimuli
%--------------------------------------------------------------------------

% initialize exp log
expLog.stimBgnTime = nan(trialNum,1);
expLog.motionType = cell(trialNum,1);
expLog.motionTypeIndex = taskList;

expLog.motionEndTime = nan(trialNum,1);
expLog.audioMotion = nan(trialNum,1);
expLog.visualMotion = nan(trialNum,1);
expLog.pressedButton = cell(trialNum,1);
expLog.pressedTime = nan(trialNum,1);

expLog.targetEndTime = nan(100,1);
expLog.targetBgnTime = nan(100,1);
% expLog.targetButton = cell(100,1);
expLog.targetButTime = nan(100,1);

targetInd = 0;
targetDisTime = -100;
expLog.targetBgnTime(targetInd+1) = nextTargetTime;

% display response result to subject
textString = 'We are going to start the fMRI runs';

% Text output of mouse position draw in the centre of the screen
DrawFormattedText(window, textString, 'center', 'center', white);
disp(textString);

% Flip to the screen
Screen('Flip', window);

WaitSecs(5);

%--- Get the KbQueue up and running.
KbQueueCreate();
KbQueueStart();

%--- KbReleaseWait() will also block if the trigger key is 'pressed', 
%    which is assumed to be short enough for being ignored here.
KbReleaseWait();

% record left and right button
DrawFormattedText(window, 'Please press left button \n\n Later use for final movement to left \n at the end of each block', 'center', 'center', [1 1 1]);
Screen('Flip', window);
while 1
    % Check the queue for key presses.
    [ pressed, firstPress]=KbQueueCheck();

    % If the user has pressed a key, then display its code number and name.
    if pressed
        expLog.leftButton = KbName(min(find(firstPress)));
        break;
    end
end


KbQueueFlush();
DrawFormattedText(window, 'Please press right button \n\n Later use for final movement to right \n at the end of each block', 'center', 'center', [1 1 1]);
Screen('Flip', window);
while 1
    % Check the queue for key presses.
    [ pressed, firstPress]=KbQueueCheck();

    % If the user has pressed a key, then display its code number and name.
    if pressed
        expLog.rightButton = KbName(min(find(firstPress)));
        break;
    end
end

KbQueueFlush();
DrawFormattedText(window, 'Please press any button \n\n when cross changes color to green in this run', 'center', screenYpixels * 0.4, [1 1 1]);
Screen('DrawLines', window, allCoords, lineWidthPix, white, [xCenter-fixYPos yCenter+fixYPos], 2);
Screen('DrawLines', window, allCoords, lineWidthPix, green, [xCenter+fixYPos yCenter+fixYPos], 2);
Screen('Flip', window);
while 1
    % Check the queue for key presses.
    [ pressed, firstPress]=KbQueueCheck();

    % If the user has pressed a key, then display its code number and name.
    if pressed
        break;
    end
end


KbQueueFlush();
% waiting for fMRI trigger
Screen('DrawLines', window, allCoords, lineWidthPix, crossColor, [xCenter yCenter+fixYPos], 2);
DrawFormattedText(window, 'Please stay still, keep eyes open and \n fix on the cross throughout this run', 'center', screenYpixels * 0.5, [1 1 1]);
Screen('Flip', window);

while 1
    % Check the queue for key presses.
    [ pressed, firstPress]=KbQueueCheck();

    % If the user has pressed a key, then display its code number and name.
    if pressed && firstPress(triggerKey)
        t0 = firstPress(triggerKey);
        break;
    end
end



tic;
KbQueueStop();
KbQueueRelease();
keysOfInterest=zeros(1,256);
keysOfInterest([escapeKey responseKey])=1;
KbQueueCreate(-1, keysOfInterest);
KbQueueStart;

elapsedTime = GetSecs - t0;

% baseline scanning
while elapsedTime < restSecs

    elapsedTime = GetSecs - t0;
    if elapsedTime >= nextTargetTime & elapsedTime < nextTargetTime+targetDurSecs
        crossColor = green;
        if abs(elapsedTime-nextTargetTime-targetDurSecs) <= 2*ifi
            targetInd = targetInd+1;
            expLog.targetEndTime(targetInd) = elapsedTime;
            targetDisTime = elapsedTime;

            nextTargetTime = nextTargetTimeList(targetInd+1);

            expLog.targetBgnTime(targetInd+1) = nextTargetTime;
        end

    else
        crossColor = white;
    end


    % Draw the fixation cross
    Screen('DrawLines', window, allCoords, lineWidthPix, crossColor, [xCenter yCenter+fixYPos], 2);

    % Flip to the screen
    Screen('Flip', window);

    % Check the queue for key presses.
    [ pressed, firstPress]=KbQueueCheck();
    % timeSecs = firstPress(min(find(firstPress)));

    % If the user has pressed a key, then display its code number and name.
    if pressed 
        if firstPress(escapeKey)
            KbQueueStop();
            KbQueueRelease();
            PsychPortAudio('Close');
            sca;
            return;
        elseif elapsedTime-targetDisTime < 2
            % expLog.targetButton{targetInd} = KbName(min(find(firstPress)));
            expLog.targetButTime(targetInd) = elapsedTime;  
        end
    end

end
KbQueueFlush();


% % check sound, ball position and diameter across time
% checkLength = beepNumInACluster*180;
% checkTS = [1:checkLength]*ifi;
% checkBallPos = zeros(checkLength,1);
% checkBallRad = zeros(checkLength,1);
% checkIdx = 0;
% checkSound = [audiodataR;audiodataR;audiodataL];
% checkSound = checkSound/max(max(checkSound));
% checkSoundTS = [1/samplingRate:1/samplingRate:9]';
ballPos = 0;


% start scanning of task trials
for trial = 1:trialNum

    % beep + dot stim
    elapsedTime = GetSecs - t0;
    expLog.stimBgnTime(trial) = elapsedTime;

    if taskList(trial) == 1
        expLog.motionType{trial} = ['audio only motion'];
    elseif taskList(trial) == 2
        expLog.motionType{trial} = ['visual only motion'];
    elseif taskList(trial) == 3
        expLog.motionType{trial} = ['congruent audiovisual motion'];
    elseif taskList(trial) == 4
        expLog.motionType{trial} = ['incongruent audiovisual motion'];
    end


    visMotDirList = [ones(1,ceil(beepNumInACluster/2)) 2*ones(1,ceil(beepNumInACluster/2))];
    idx = randperm(beepNumInACluster);
    visMotDirList = visMotDirList(idx);

    if taskList(trial) == 4
        audMotDirList = 3-visMotDirList;
    else
        audMotDirList = visMotDirList;
    end

    audMotDirList(end) = audMotDirList(end)+2;

    for beepIndex = 1:beepNumInACluster

        audioMotion = audioMotionList(audMotDirList(beepIndex));
        visualMotion = visualMotionList(visMotDirList(beepIndex));

        if beepIndex == beepNumInACluster
            audioFrames = framesLastAudio;
        else
            audioFrames = 180;
        end

        if taskList(trial) ~= 2 % not visual only motion
            % play audio
            PsychPortAudio('Start', audioMotion, 1, 0, waitForDeviceStart);
            % startTime = PsychPortAudio('Start', pahandle [, repetitions=1]      [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
            % when: Wait until this time to start playing (default is play now)
            % waitForDeviceStart: 0: Ask playback to start and move on; 1: wait for playback to actually begin. 
            % A 1 here is necessary if you want to get timing info back
            % stopTime: set a time to stop playing
            % resume: Set to 0 to repeat indefinitely
        end

        if taskList(trial) ~= 1 % not audio only motion

            counter2 = 1;
            for frameInBeep = 1:audioFrames

                % if beepIndex == 1 && frameInBeep == 0
                %     mvx0 = 0;
                %     mvx1 = 0;

                %     rotx0 = 0;
                %     % roty0 = 0;
                %     % rotz0 = 0;

                %     rotx1 = 80*sin(-.5*pi);
                %     % roty1 = -0.5*80*sin(-.5*pi);
                %     % rotz1 = 0.75*80*sin(-.5*pi);
                % end

                % if beepIndex ~= 1 && frameInBeep == 0
                %     mvx0 = mvXNorm*sin((2*pi*(179/180)));
                %     mvx1 = mvXNorm*sin((2*pi*(0/180)));

                %     rotx0 = 80*sin((-.5*pi)+(2*pi*(179/150)));
                %     % roty0 = -0.5*80*sin((-.5*pi)+(2*pi*(179/75)));
                %     % rotz0 = 0.75*80*sin((-.5*pi)+(2*pi*(179/100)));

                %     rotx1 = 80*sin(-.5*pi);
                %     % roty1 = -0.5*80*sin(-.5*pi);
                %     % rotz1 = 0.75*80*sin(-.5*pi);
                % end

                % if frameInBeep ~= 0
                    mvx0 = mvXNorm*sin((2*pi*((frameInBeep-1)/180)));
                    mvx1 = mvXNorm*sin((2*pi*(frameInBeep/180)));

                    rotx0 = 80*sin((-.5*pi)+(2*pi*((frameInBeep-1)/150)));
                    % roty0 = -0.5*80*sin((-.5*pi)+(2*pi*((frameInBeep-1)/75)));
                    % rotz0 = 0.75*80*sin((-.5*pi)+(2*pi*((frameInBeep-1)/100)));

                    rotx1 = 80*sin((-.5*pi)+(2*pi*(frameInBeep/150)));
                    % roty1 = -0.5*80*sin((-.5*pi)+(2*pi*(frameInBeep/75)));
                    % rotz1 = 0.75*80*sin((-.5*pi)+(2*pi*(frameInBeep/100)));
                % end
                
                dmvx = visualMotion*(mvx1-mvx0);

                drotx = rotx1-rotx0;
                % droty = roty1-roty0;
                % drotz = rotz1-rotz0;
         
                if counter2>9
                    counter2=1;
                end 

                if counter2==1
                    radius=40;
                end

                if counter2==2
                    radius=46;
                end

                if counter2==3
                    radius=52;
                end

                if counter2==4
                    radius=52;
                end

                if counter2==5
                    radius=46;
                end

                if counter2==6
                    radius=40;
                end


                counter2=counter2+1;


                % Start OpenGL rendering again after flip for drawing of next frame...
                Screen('BeginOpenGL', window);

                if beepIndex == 1 && frameInBeep == 1
                    glTranslatef(-ballPos, 0, 0); % reset ball position to the center
                    ballPos = 0;
                end

                % Clear out backbuffer and depth buffer:
                glClear;

                % Increment rotation angle around new z-Axis (0,0,1)  by 0.1 degrees:
                glRotatef(drotx, 1, 0, 0);
                % glRotatef(droty, 0, 1, 0);
                % glRotatef(drotz, 0, 0, 1);


                % Draw the textured sphere-quadric of radius 0.7. As OpenGL has to approximate
                % all curved surfaces (i.e. spheres) with flat triangles, we tell it to resolve
                % the sphere into 100 slices in elevation and 100 sectors in azimuth: Higher values
                % provide a better approximation, but they take longer to draw. Live is full of
                % trade-offs...
                gluSphere(mysphere, radius/40*SphereRadiusRatio, 100, 100);

                % Translate the cube in xyz
                glTranslatef(dmvx, 0, 0);
                ballPos = ballPos+dmvx;

                % Finish OpenGL rendering into PTB window. This will switch back to the
                % standard 2D drawing functions of Screen and will check for OpenGL errors.
                Screen('EndOpenGL', window);

                elapsedTime = GetSecs - t0;
                if elapsedTime >= nextTargetTime & elapsedTime < nextTargetTime+targetDurSecs
                    crossColor = green;
                    if abs(elapsedTime-nextTargetTime-targetDurSecs) <= 2*ifi
                        targetInd = targetInd+1;
                        expLog.targetEndTime(targetInd) = elapsedTime;
                        targetDisTime = elapsedTime;

                        nextTargetTime = nextTargetTimeList(targetInd+1);

                        expLog.targetBgnTime(targetInd+1) = nextTargetTime;
                    end

                else
                    crossColor = white;
                end

                % Draw the fixation cross
                Screen('DrawLines', window, allCoords, lineWidthPix, crossColor, [xCenter yCenter+fixYPos], 2);

                % Show new image at next retrace:
                Screen('Flip', window);

                % % check sound, ball position and diameter across time
                % checkIdx = checkIdx+1;
                % checkBallRad(checkIdx) = radius/40*SphereRadiusRatio;
                % if checkIdx == 1
                %     checkBallPos(checkIdx) = dmvx;
                % else
                %     checkBallPos(checkIdx) = checkBallPos(checkIdx-1) + dmvx;
                % end


                [ pressed, firstPress ] = KbQueueCheck();

                if pressed 
                    if firstPress(escapeKey)
                        KbQueueStop();
                        KbQueueRelease();
                        PsychPortAudio('Close');
                        sca;
                        return;
                    elseif elapsedTime-targetDisTime < 2
                        expLog.targetButTime(targetInd) = elapsedTime;
                    end
                end
            end

        else
            for frameInBeep = 1:audioFrames

                elapsedTime = GetSecs - t0;
                if elapsedTime >= nextTargetTime & elapsedTime < nextTargetTime+targetDurSecs
                    crossColor = green;
                    if abs(elapsedTime-nextTargetTime-targetDurSecs) <= 2*ifi
                        targetInd = targetInd+1;
                        expLog.targetEndTime(targetInd) = elapsedTime;
                        targetDisTime = elapsedTime;

                        nextTargetTime = nextTargetTimeList(targetInd+1);

                        expLog.targetBgnTime(targetInd+1) = nextTargetTime;
                    end

                else
                    crossColor = white;
                end

                % Draw the fixation cross
                Screen('DrawLines', window, allCoords, lineWidthPix, crossColor, [xCenter yCenter+fixYPos], 2);

                % Show new image at next retrace:
                Screen('Flip', window);

                % Check the queue for key presses.
                [ pressed, firstPress]=KbQueueCheck();
                % If the user has pressed a key, then display its code number and name.
                if pressed 
                    if firstPress(escapeKey)
                        KbQueueStop();
                        KbQueueRelease();
                        PsychPortAudio('Close');
                        sca;
                        return;
                    elseif elapsedTime-targetDisTime < 2
                        expLog.targetButTime(targetInd) = elapsedTime;
                    end
                end
            end

        end

    end

    KbQueueFlush();

    expLog.motionEndTime(trial) = GetSecs - t0;

    %--------------------------------------------------------------------------
    %                  time window for button pressing
    %-------------------------------------------------------------------------- 
    for frame4Button = 1:responseDuration*60

        % Draw the fixation cross
        Screen('DrawLines', window, allCoords, lineWidthPix, crossColor, [xCenter yCenter+fixYPos], 2);

        % Flip to the screen
        Screen('Flip', window);

    end


    [ pressed, firstPress ] = KbQueueCheck();
    timeSecs = firstPress(min(find(firstPress)));

    % final movement direction is opposite to the initial one   
    expLog.visualMotion(trial) = -visualMotion;
    if audioMotion == audioMotionL_last
        expLog.audioMotion(trial) = 1;
    elseif audioMotion == audioMotionR_last
        expLog.audioMotion(trial) = -1;
    end
        
    if pressed

        expLog.pressedButton{trial} = KbName(min(find(firstPress)));
        expLog.pressedTime(trial) = timeSecs - t0;  

    else
        
        expLog.pressedButton{trial} = 'No response';
        expLog.pressedTime(trial) = 0;

    end



    %--------------------------------------------------------------------------
    %                  rest time
    %-------------------------------------------------------------------------- 
    elapsedTime = GetSecs - t0;
    while elapsedTime < restSecs+(stimSecs+restSecs)*trial

        elapsedTime = GetSecs - t0;
        if elapsedTime >= nextTargetTime & elapsedTime < nextTargetTime+targetDurSecs
            crossColor = green;
            if abs(elapsedTime-nextTargetTime-targetDurSecs) <= 2*ifi
                targetInd = targetInd+1;
                expLog.targetEndTime(targetInd) = elapsedTime;
                targetDisTime = elapsedTime;

                nextTargetTime = nextTargetTimeList(targetInd+1);

                expLog.targetBgnTime(targetInd+1) = nextTargetTime;
            end

        else
            crossColor = white;
        end

        % Draw the fixation cross
        Screen('DrawLines', window, allCoords, lineWidthPix, crossColor, [xCenter yCenter+fixYPos], 2);

        % Flip to the screen
        Screen('Flip', window);

        % Check the queue for key presses.
        [ pressed, firstPress]=KbQueueCheck();

        % If the user has pressed a key, then display its code number and name.
        if pressed 
            if firstPress(escapeKey)
                KbQueueStop();
                KbQueueRelease();
                PsychPortAudio('Close');
                sca;
                return;
            elseif elapsedTime-targetDisTime < 2
                expLog.targetButTime(targetInd) = elapsedTime;
            end
        end

        elapsedTime = GetSecs - t0;

    end
    KbQueueFlush();


end

% display the timing of the end of each run
toc;

%% stop monitoring key press
KbQueueStop();
KbQueueRelease();

% Close the audio device
PsychPortAudio('Close');

% Done with the drawing loop:

% Delete our sphere object:
gluDeleteQuadric(mysphere);

% Unselect our texture...
glBindTexture(gltextarget, 0);

% ... and disable texture mapping:
glDisable(gltextarget);

%--------------------------------------------------------------------------
%                  save experiment log
%-------------------------------------------------------------------------- 
expLog.responseTime = (expLog.pressedTime-expLog.motionEndTime).*(expLog.pressedTime~=0);
expLog.responseTime(expLog.responseTime==0) = NaN; 

% seperate stim time, response time, correct rate for different task type
audInd = find(expLog.motionTypeIndex==1);
visInd = find(expLog.motionTypeIndex==2);
avcInd = find(expLog.motionTypeIndex==3);
avicInd = find(expLog.motionTypeIndex==4);

expLog.audBgnTime = expLog.stimBgnTime(audInd);
expLog.visBgnTime = expLog.stimBgnTime(visInd);
expLog.avcBgnTime = expLog.stimBgnTime(avcInd);
expLog.avicBgnTime = expLog.stimBgnTime(avicInd);

if elapsedTime-expLog.targetEndTime(targetInd) < 2
    targetInd = targetInd-1;
end
expLog.targetBgnTime = expLog.targetBgnTime(1:targetInd);
expLog.targetEndTime = expLog.targetEndTime(1:targetInd);
expLog.targetButTime = expLog.targetButTime(1:targetInd);

expLog.audResponseTime = expLog.responseTime(audInd);
expLog.visResponseTime = expLog.responseTime(visInd);
expLog.avcResponseTime = expLog.responseTime(avcInd);
expLog.avicResponseTime = expLog.responseTime(avicInd);

responseMotion = zeros(size(expLog.pressedButton));
responseMotion(ismember(expLog.pressedButton,expLog.leftButton)) = -1;
responseMotion(ismember(expLog.pressedButton,expLog.rightButton)) = 1;

correctList = responseMotion.*expLog.audioMotion;
expLog.correctRate = sum(correctList==1)/trialNum;

expLog.audCorrectRate = sum(correctList(audInd)==1)/length(audInd);
expLog.visCorrectRate = sum(correctList(visInd)==1)/length(visInd);
expLog.avcCorrectRate = sum(correctList(avcInd)==1)/length(avcInd);
expLog.avicCorrectRate = sum(correctList(avicInd)==1)/length(avicInd);

targetRespT = expLog.targetButTime - expLog.targetEndTime;
expLog.targetRate = sum((targetRespT>0).*(targetRespT<3))/length(targetRespT);


outputName = ['Logs/Lars_AV_' datestr(now,'yyyy-mm-dd_HH-MM') '.mat'];
save(outputName,'expLog','expLog');

% display response result to subject
textString = ['Thank you! \n You detected ' num2str(round(expLog.correctRate*100)) '% movements and \n' num2str(round(expLog.targetRate*100)) '% color changes correctly.'];

% Text output of mouse position draw in the centre of the screen
DrawFormattedText(window, textString, 'center', 'center', white);
disp(textString);

% Flip to the screen
Screen('Flip', window);

WaitSecs(5);


% Clear up and leave the building
sca
close all


% correctRate = [expLog.audCorrectRate expLog.visCorrectRate expLog.avcCorrectRate expLog.avicCorrectRate];
% xlist={'A' 'V' 'AVc' 'AVic'};
% figure;
% bar(correctRate,0.6,'FaceColor',[.5 .5 .5],'EdgeColor',[0.5 0.5 0.5],'LineWidth',2);
% ylabel('Correct rate','Fontsize',25,'FontWeight','normal');
% set(gca,'xticklabel',xlist);,
% xtickangle(0);
% xlim([0.3 4.7]);
% % ylim([0 1])
% box off
% whitebg('white');
% set(gcf,'color',[1 1 1])
% set(gca,'linewidth',3,'fontsize',25,'FontWeight','normal','Xcolor',[0 0 0],'Ycolor',[0 0 0])
% fig_name=replace(outputName,'.mat','_correctRate.png');
% export_fig(fig_name,'-r300');

% responseTimeMean = [mean(expLog.audResponseTime,'omitnan') mean(expLog.visResponseTime,'omitnan') mean(expLog.avcResponseTime,'omitnan') mean(expLog.avicResponseTime,'omitnan')];
% responseTimeSD = [std(expLog.audResponseTime,'omitnan') std(expLog.visResponseTime,'omitnan') std(expLog.avcResponseTime,'omitnan') std(expLog.avicResponseTime)]/sqrt(length(expLog.audResponseTime));;
% xlist={'A' 'V' 'AVc' 'AVic'};
% figure;
% bar(responseTimeMean,0.6,'FaceColor',[.5 .5 .5],'EdgeColor',[0.5 0.5 0.5],'LineWidth',2);
% hold on; errorbar(responseTimeMean,responseTimeSD,'x','MarkerEdgeColor','none','LineWidth',3,'Color','k');
% ylabel('Response time (s)','Fontsize',25,'FontWeight','normal');
% % title(['p = ' num2str(p,'%0.3f')],'FontWeight','normal');
% set(gca,'xticklabel',xlist);
% xtickangle(0);
% xlim([0.3 4.7]);
% % ylim([0 1])
% box off
% whitebg('white');
% set(gcf,'color',[1 1 1]);
% set(gca,'linewidth',3,'fontsize',25,'FontWeight','normal','Xcolor',[0 0 0],'Ycolor',[0 0 0]);
% fig_name=replace(outputName,'.mat','_responseTime.png');
% export_fig(fig_name,'-r300');


% % % check sound, ball position and diameter across time
% % checkBallRad = (checkBallRad-min(checkBallRad))/max(checkBallRad);
% % checkBallRad = checkBallRad/max(checkBallRad);
% % checkBallPos = checkBallPos/max(checkBallPos);


% % figure;
% % plot(checkTS,checkBallRad,checkSoundTS,checkSound);






