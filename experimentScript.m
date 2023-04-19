%% EEG Validation Exp %%
% Emre, 12.02.2022
clear all; %have a fresh start

curPath= uigetdir(userpath, 'Please select the experiment folder'); % set the experiment folder path
%% Exp %%
% load('EEGValid.mat');
data={}; %create a cell for the first time, but I will comment here and use load() funct avoid overwriting.
ID=input('Enter participant ID\n');

%start by creating the stimuli
%Set the conditions and then the stimulus properties
TrialAmount = 100; % number of repetitions =10

%shapes on the screensm
stimColor= ['g', 'r', 'm','b','k']; %, 'b']; %I will use magneto and green.
stimShape = ['s', 'd', 'p','^', 'o']; %square,diamond, star, triangle, circle

%now randomize the trials
% SetSizes= repelem(Exp.Trial.Size ,TrialAmount *2) ; %sequence of sizes
ExpCondition= [zeros(1,TrialAmount) ones(1,TrialAmount) (ones(1,TrialAmount)+1) (ones(1,TrialAmount)+2) ]+1;% 15 right, 15 left.
%1=absent,2=present

ExpSequence=zeros(1,length(ExpCondition));%preallocation before loop
ExpSequence = Shuffle(ExpCondition);

sColor= [98 103 107 109 114]; %blue green black magenta red
sShape= [94 100 111 112 115]; % triangle diamond circle star sqaure
%Now lets work with PTB

FCPath= sprintf('%s/ExpStims/FixCross.png',curPath);

% Memory Item
FCCross=imread(FCPath);


global ptb_drawformattedtext_disableClipping;
ptb_drawformattedtext_disableClipping = 1;
if length(data)~=0
    recordingID=length(data)+1;
else
    recordingID=1;
end
data{recordingID}.ID=ID;

%Setting the instructions
Screen('Preference', 'VisualDebugLevel', 3); % for not seeing the exclamation mark before each session
Screen('Preference', 'SkipSyncTests', 2); % to avoid errors on my computer. (1=Windows, 2=Linux -I guess-)
Screen('Preference', 'SuppressAllWarnings', 1); % supressing all warnings...
KbName('UnifyKeyNames'); % The first one is so that Windows and Mac keyboards are treated identically
rng('shuffle');%Shuffling the random number generator.
ListenChar(2); % pressed keys during the experiment will not be seen on the command window, or accidentally type over your script.
pathOfExperiment=pwd; % print the experiment folder path, we will use it later

% Set Some Keyboard Button Names
escapeKey = KbName('ESCAPE');
spaceKey = KbName('SPACE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
RestrictKeysForKbCheck([escapeKey spaceKey leftKey rightKey]); %PTB will only look for these keypresses.
%if participants press another key rather then they supposed to do, ptb will not proceed to the next trial.

[screenHandle, screenRect]=Screen('OpenWindow', max(Screen('Screens')), [128 128 128]); % [225 225 225] means white. We can change this RGB value if we want a different background.
xCenter=screenRect(3)/2; % these are our central coordinates for horizontal axis
yCenter=screenRect(4)/2; % same for the vertical axis

Screen('TextSize',screenHandle,35); % Text size, can be adjusted for different screens

%now lets code the experiment. I will use the try catch command in here.

datamatrix=zeros(length(ExpCondition),(4));%preallocating for the future use


% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 20;
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 6;


try %Begin try block.

    curPath=pwd; %we will use it later
    HideCursor %just hide the curse during experiment...

    %now I am setting the instructions.
    sentence1= 'Welcome to the delayed matching EEG experiment! \n\n Please press the SPACE key to see the instructions.';
    sentence2= 'You will be presented with several stimuli during the experiment.\n You need to press different keys regarding the presented stimulus.\n \n You will be using the RIGHT ARROW and LEFT ARROW keys to state your answers. \n\n  Please press the SPACE key to proceed.';
    sentence3= 'You need to press the LEFT ARROW key to state that there is a conflicting stimulus on the screen,  \n \n otherwise please press the RIGHT ARROW key. \n\n  Please press the SPACE key to proceed. ';
    sentence4= 'You can end the experiment before completing it by pressing the ESC key after the instructions are done. \n\n  Please press the SPACE key to proceed.';
    sentence5= 'The experiment will start after this page. \n\n Please press the SPACE key to start the experiment.';

    instructions={sentence1, sentence2, sentence3, sentence4, sentence5};
    for i=1:5 %each sentence will be displayed in order. Participants need to press the SPACE to proceedin ech one.
        cont=0;
        DrawFormattedText(screenHandle,double(instructions{i}),'center','center',[0 0 0],100,[],[],2);
        Screen('Flip',screenHandle);
        while cont==0

            [keyIsDown,t,keyCode]=KbCheck;
            if keyCode(spaceKey) %so when they press the space key, it proceeds! magic!
                cont=1;
            end
        end
        KbReleaseWait; %waits until all keys are released
    end

    Screen('Flip',screenHandle); %over here I want to have a short break between the exp and instructions.
    WaitSecs(0.5);
    DrawFormattedText(screenHandle,double('Your experiment has started. \n\n Have fun!'),'center','center',[0 0 0],90);
    Screen('Flip',screenHandle);
    WaitSecs(1.5);
    Screen('Flip',screenHandle);
    WaitSecs(0.5);

    quitExperiment=0;


    for ii= 1: length(ExpSequence)

        sColor= [98 103 107 109 114]; %blue green black magenta red
        sShape= [94 100 111 112 115]; % triangle diamond circle star sqaure

        if ExpSequence(ii)==1
            % get a random color and shape
            memColor= randsample(sColor,1);
            memShape=randsample(sShape,1);

            % since it's the same, we will use them again for the probe part
            probColor= memColor;
            probShape= memShape;


            %%% get file names %%%
            memPath=sprintf('%s//ExpStims//ExpStim_%d_%d.png', curPath,memColor, memShape);
            probePath=sprintf('%s//ExpStims//ExpStim_%d_%d.png',curPath, probColor, probShape);


        elseif ExpSequence(ii)==2

            % get a random color and shape
            memColor= randsample(sColor,1);
            memShape=randsample(sShape,1);

            probCol= sColor(find(sColor ~= memColor));
            % only change the color
            probColor= randsample(probCol,1);
            probShape= memShape;

            memPath=sprintf('%s//ExpStims//ExpStim_%d_%d.png', curPath,memColor, memShape);
            probePath=sprintf('%s//ExpStims//ExpStim_%d_%d.png',curPath, probColor, probShape);


        elseif ExpSequence(ii)==3

            % get a random color and shape
            memColor= randsample(sColor,1);
            memShape=randsample(sShape,1);

            probShape= sShape(find(sShape ~= memShape));
            % only change the shape
            probColor= memColor;
            probShape= randsample(probShape,1);

            memPath=sprintf('%s//ExpStims//ExpStim_%d_%d.png', curPath,memColor, memShape);
            probePath=sprintf('%s//ExpStims//ExpStim_%d_%d.png',curPath, probColor, probShape);


        elseif ExpSequence(ii)==4
            % get a random color and shape
            memColor= randsample(sColor,1);
            memShape=randsample(sShape,1);

            probCol= sColor(find(sColor ~= memColor));
            probShape= sShape(find(sShape ~= memShape));

            % total change
            probColor= randsample(probCol,1);
            probShape= randsample(probShape,1);

            memPath=sprintf('%s//ExpStims//ExpStim_%d_%d.png', curPath,memColor, memShape);
            probePath=sprintf('%s//ExpStims//ExpStim_%d_%d.png',curPath, probColor, probShape);
        end


        % Memory Item
        memItem=imread(memPath);
        memoryPic=Screen('MakeTexture',screenHandle,memItem);
        % Probe item
        probItem=imread(probePath);
        probPic=Screen('MakeTexture',screenHandle,probItem);

        %%%
        [ySize,xSize,depth]=size(memItem);
        StimLocation=CenterRectOnPoint([0 0 xSize/2  ySize/2],xCenter-0,yCenter-0);

        RestrictKeysForKbCheck([escapeKey leftKey rightKey spaceKey]); % This means PTB will only look for these keypresses. RestrictKeysForKbCheck([]) if you want to allow everything.
        %
        % %%%%%% fixation cross%%%

        FixationCross=Screen('MakeTexture',screenHandle,FCCross);
        Screen('DrawTexture',screenHandle,FixationCross,[],StimLocation);
        Screen('Flip',screenHandle);
        WaitSecs(0.3);

        Screen('Flip',screenHandle);
        WaitSecs(0.3);


        memTime=GetSecs;
        while  GetSecs-memTime<=0.3
            Screen('DrawTexture',screenHandle,memoryPic,[],StimLocation);
        end
        Screen('Flip',screenHandle);


        Screen('Flip',screenHandle);
        WaitSecs(1.1);

        click=0;
        presentime=GetSecs;
        while ~click
            %%%%%%%%%%%%%%%%%%%%%%%% Drawing the question - until a key press has been executed %%%%%%%%%%%%%%%%%%%%%%%%

            Screen('DrawTexture',screenHandle,probPic,[],StimLocation)
            Screen('Flip',screenHandle);

            % make pressedKey an array/list
            [~,~,keyCode]=KbCheck;
            if keyCode(leftKey) | keyCode(rightKey) | keyCode(escapeKey)
                click=1;
                presstime=GetSecs;
                if keyCode(leftKey)

                    data{recordingID}.pressedKey(ii)=1;

                    if ExpSequence(ii)== 3 || 4
                        data{recordingID}.response(ii)=1;
                    else
                        data{recordingID}.response(ii)=2;
                    end

                    data{recordingID}.ExpCondition(ii)= ExpSequence(ii);
                    data{recordingID}.pressedTime(ii)= presstime;
                    data{recordingID}.reactiontime(ii)=presstime-presentime;

                elseif keyCode(rightKey)

                    data{recordingID}.pressedKey(ii)=2;

                    if ExpSequence(ii)== 1|| 2
                        data{recordingID}.response(ii)=1;
                    else
                        data{recordingID}.response(ii)=2;
                    end

                    data{recordingID}.ExpCondition(ii)= ExpSequence(ii);
                    data{recordingID}.pressedTime(ii)= presstime;
                    data{recordingID}.reactiontime(ii)=presstime-presentime;

                elseif keyCode(escapeKey)
                    quitExperiment=1;
                    break;
                end
            end
        end


        if quitExperiment==1
            break
        end

        Screen('Flip',screenHandle);
        WaitSecs(0.5)

    end


    cont=0;

    while cont==0
        DrawFormattedText(screenHandle,double('End of the experiment. \n Thanks for your participation. \n \n  '),'center','center',[0 0 0],100,[],[],2)
        Screen('Flip',screenHandle);
        WaitSecs(0.5);
        [keyIsDown,t,keyCode]=KbCheck;
        if keyCode(escapeKey)
            cont=1;

        end
    end


catch ME %IF WE HAVE AN ERROR, this part is gonna run.
    sca; % this just wraps everything up. It stands for Screen('CloseAll')
    ShowCursor %enable the cursor...
    RestrictKeysForKbCheck([]); %allow all keys, no more restrictions (space, esc, right and left...)
    ListenChar(0);%we can use the keyboard again
    fprintf('WE HAVE AN ERROR :( \n\n . Here''s what happened:\n');
    rethrow(ME)

end
%datamatrix=sortrows(datamatrix,5); %sort all matrix according to the trials.
%datamatrix(:,5)=[]; %delete the last column since we dont want it in the datamatrix
save('delayedMatchResults.mat','data')
RestrictKeysForKbCheck([]);
ShowCursor

Screen('Flip',screenHandle);
WaitSecs(0.5);
KbStrokeWait;

ListenChar(0);
sca;
clc;
clearvars -except data datamatrix screenHandle screenRect

%% End of the Exp
