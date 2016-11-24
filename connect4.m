function connect4
%% connect4
% Launches a game of Connect 4 made in Psychtoolbox!
% 
% CONTROLS: 
% 
%   Move Left    - Left Arrow
%   Move Right   - Right Arrow
%   Drop Counter - Down Arrow 
%   Reset        - R Key
%   End Game     - Esc

%% Main Function  
%~ Clear the workspace and the screen
sca;
close all;
clearvars;
myTimingSucksMode = true; 

%~ Psych Default Setup (Unify Keynames/FP Colour Range) 
PsychDefaultSetup(2)

%~ Skip Sync (if using laptop w/graphics issues) 
if myTimingSucksMode
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference','SuppressAllWarnings', 1);
    Screen('Preference','VisualDebugLevel', 0); 
end 

%~ Screen Variables 
scr.background = []; 
scr.foreground = []; 
scr.window = []; 
scr.windowRect = []; 
scr.height = []; 
scr.width = []; 
scr.cenX = []; 
scr.cenY = [];
scr.ifi = []; 
scr.vbl = []; 
scr.waitFrames = [];
scr.exit = false; 

%~ Controls 
ctrls.esc           = KbName('ESCAPE');
ctrls.left          = KbName('LeftArrow');
ctrls.right         = KbName('RightArrow'); 
ctrls.drop          = KbName('DownArrow'); 
ctrls.reset         = KbName('r'); 

%~ Cursor 
cursor.diam = 100; 
cursor.turn = 1; 
cursor.column = 1; 
cursor.timing = 0.25; 

%~ Frame Variables
frame.cenX = []; 
frame.cenY = []; 
frame.colour = [0, 0, 1]; 
frame.centered = [];
frame.minSize = 20; 
frame.maxSize = 200;
frame.table = zeros(7, 6);  

%~ PTB Setup 
screens = Screen('Screens');
scr.number = max(screens);
scr.foreground = WhiteIndex(scr.number);
scr.background = BlackIndex(scr.number);

[scr.window, scr.windowRect] = PsychImaging('OpenWindow', scr.number, scr.foreground/10);
[scr.width, scr.height] = Screen('WindowSize', scr.window);
[scr.cenX, scr.cenY] = RectCenter(scr.windowRect);
scr.ifi = Screen('GetFlipInterval', scr.window);

%~ Replot Frame
frame.centered = CenterRectOnPointd([0 0 1050 900], scr.cenX, scr.cenY);
xc = linspace(frame.centered(1)+75, frame.centered(3)-75, 7); 
yc = linspace(frame.centered(2)+75, frame.centered(4)-75, 6);

gameEnd = 0;

%% Animation Loop 
while scr.exit == false     
    
%~ Draw Frame
drawFrame(scr, frame, cursor, xc); 

    %~ Check Keys 
    [~,~,keyCode] = KbCheck;
    pressedKeys = find(keyCode); 
    [ctrls, cursor, scr, frame] = controlInput(pressedKeys, ctrls, cursor, scr, frame);

    
for x = 1:6
    for y = 1:7
        frame.cenSlots(y, :, x)= CenterRectOnPointd([0, 0, cursor.diam, cursor.diam], xc(y), yc(x));
        if frame.table(y, x) == 0
            color = [0.1, 0.1, 0.1]; 
        elseif frame.table(y, x) == 1
            color = [0.5, 0, 0]; 
        else 
            color = [0.5, 0.5, 0]; 
        end 
        Screen('FillOval',  scr.window, color,     frame.cenSlots(y, :, x));
        Screen('FrameOval', scr.window, [0, 0, 0], frame.cenSlots(y, :, x), 8)
    end 
end 

%~ Flip 
scr.vbl  = Screen('Flip', scr.window, scr.vbl + (scr.waitFrames - 0.5) * scr.ifi);
WaitSecs(0.01);

[frame, gameEnd] = winCheck(frame, gameEnd); 

end 
sca

end 

function [ctrls, cursor, scr, frame] = controlInput(pressedKeys, ctrls, cursor, scr, frame) 
    
    %~ Check Keys 
    if length(pressedKeys) == 1
        if pressedKeys == ctrls.esc
            scr.exit = true;
        elseif pressedKeys == ctrls.reset
            frame.table = zeros(7, 6); 
            cursor.turn = 1; 
            WaitSecs(cursor.timing); 
        elseif pressedKeys == ctrls.left
            cursor.column = cursor.column - 1;
            WaitSecs(cursor.timing); 
        elseif pressedKeys == ctrls.right
            cursor.column = cursor.column + 1;
            WaitSecs(cursor.timing); 
        elseif pressedKeys == ctrls.drop
            space = find(~frame.table(cursor.column, :), 1, 'last'); 
            if space
                frame.table(cursor.column, space) = cursor.turn;
                cursor.turn = -cursor.turn; 
                WaitSecs(cursor.timing); 
            end 
        end  
    end 
    
    %~ Eccentricity Checks
    if cursor.column < 1
        cursor.column = 1;
    elseif cursor.column > 7
        cursor.column = 7;
    end
    
end 

function drawFrame(scr, frame, cursor, xc)
    Screen('FillRect',  scr.window, [0, 0, 0.6],     frame.centered);
    Screen('FrameRect', scr.window, scr.background,  frame.centered, 8)
    Screen('FillRect',  scr.window, [0, 0, 0.5],    [frame.centered(1) - 40, frame.centered(2)-20, frame.centered(1),    frame.centered(4)+60]); 
    Screen('FrameRect', scr.window, scr.background, [frame.centered(1) - 40, frame.centered(2)-20, frame.centered(1),    frame.centered(4)+60], 8);
    Screen('FillRect',  scr.window, [0, 0, 0.5],    [frame.centered(3),      frame.centered(2)-20, frame.centered(3)+40, frame.centered(4)+60]); 
    Screen('FrameRect', scr.window, scr.background, [frame.centered(3),      frame.centered(2)-20, frame.centered(3)+40, frame.centered(4)+60], 8); 
    cursor.position = CenterRectOnPointd([0, 0, cursor.diam, cursor.diam], xc(cursor.column), frame.centered(2)-75);

    if cursor.turn == 1
        Screen('FillOval',  scr.window, [0.5, 0, 0],   cursor.position);
    else 
        Screen('FillOval',  scr.window, [0.5, 0.5, 0], cursor.position); 
    end 
    Screen('FrameOval', scr.window, scr.background, cursor.position, 7);
end 

function [frame, gameEnd] = winCheck(frame, gameEnd)

checkFrame = frame.table';

%~ Do vertical check 
for VX = 1:7
    for VY = 1:3
        if sum(checkFrame(VY:VY+3, VX)) >= 4 || sum(checkFrame(VY:VY+3, VX)) <= -4; 
            if sign(sum(checkFrame(VY:VY+3, VX))) == 1
                frame.table = ones(7, 6); 
            else 
                frame.table = -ones(7, 6); 
            end 
            gameEnd = 1; 
        end 
    end 
end 

%~ Do horizontal check
for HX = 1:4
    for HY = 1:6
        if sum(checkFrame(HY, HX:HX+3)) >= 4 || sum(checkFrame(HY, HX:HX+3)) <= -4; 
            if sign(sum(checkFrame(HY, HX:HX+3))) == 1
                frame.table = ones(7, 6); 
            else 
                frame.table = -ones(7, 6); 
            end 
        end 
    end 
end 

%~ Do diagonal check 
for DX = 1:4
    for DY = 1:6
        
        if DY <= 3
            toCheck = [checkFrame(DY, DX), checkFrame(DY+1, DX+1), checkFrame(DY+2, DX+2), checkFrame(DY+3, DX+3)]; 
        else 
            toCheck = [checkFrame(DY, DX), checkFrame(DY-1, DX+1), checkFrame(DY-2, DX+2), checkFrame(DY-3, DX+3)]; 
        end
        
        if sum(toCheck) >= 4 || sum(toCheck) <= -4;
            
            if sign(sum(toCheck)) == 1
                frame.table = ones(7, 6); 
            else 
                frame.table = -ones(7, 6); 
            end 
            
        end 
    end 
end 

end 


