clear;clc;close all

%--------------------------------------------------------------------------
% Load in the data
% load('Data.mat')
load Data
whos

%--------------------------------------------------------------------------
% Choose the variables we want to use for the fit.
WantedName={...
    'Lag_15_MaxDISPH','Lag_26_MinGRN','MinZ0H','Lag_9_MeanEFLUX',...
    'Lag_9_MaxEVPTRNS','Lag_12_MeanEVPTRNS','Lag_9_MeanEVPTRNS',...
    'Lag_14_MeanEVPTRNS','Lag_11_MeanEVPTRNS','Lag_12_MaxEVPTRNS',...
    'Lag_8_MaxEVPTRNS','Lag_11_MaxEVPTRNS','Lag_14_MaxEVPTRNS',...
    'Lag_30_MinTELAND','MeanTSH','Lag_29_MinTELAND','Lag_1_MeanTSH',...
    'MaxHLML','Lag_8_MaxEFLUX','Lag_29_MaxTELAND','MeanTUNST',...
    'Lag_1_MeanTUNST','Lag_8_MaxEVAP','MeanTWLT'...
    };
AllNamesWeights=WantedName;


%--------------------------------------------------------------------------
% Set up the Input & Output arrays
command=['OutAll=double(Data.Pollen);InAll=double(['];
for i=1:length(WantedName)
    if length(WantedName{i})>0
        command=[command 'Data.' WantedName{i}];
        if i<length(WantedName)
            command=[command ' '];
        end
    end
end
command=[command ']);'];
disp(command);
eval(command);


%--------------------------------------------------------------------------
% 1. Repeat HW1 but using Neural Network Regression (hint nftool will help
% you create the code)

% nftool

trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

x=InAll'; % Input Data
t=OutAll'; % Output Data

% Create a Fitting Network
hiddenLayerSize = 10;
net = fitnet(hiddenLayerSize,trainFcn);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100; % 70% for training
net.divideParam.valRatio = 15/100; % 15% for validation
net.divideParam.testRatio = 15/100; % 15% for testing

% Train the Network
[net,tr] = train(net,x,t); % output net is the network model and tr is the training record

% Use trained NN on training dataset
trainX= x(:,tr.trainInd);
trainT=t(:,tr.trainInd);
trainY=net(trainX);

% Use trained NN on validation dataset
valX=x(:,tr.valInd);
valT=t(:,tr.valInd);
valY=net(valX);

% Use trained NN on testing dataset
testX=x(:,tr.testInd);
testT=t(:,tr.testInd);
testY=net(testX);

% Used trained NN for entire dataset
output=net(x);

% Caculate fit error
trainEr= trainT - trainY; % train error
valEr= valT -valY; % val error
testEr= testT- testY; % test error
allEr= t - output; % error for the entire dataset

ptrainEr=100*trainEr./trainT;
pvalEr=100*valEr./valT;
ptestEr=100*testEr./testT;

% Histogram plot of errors
f1=figure;
f1.Position=[0 500 500 500];
edges=-4:0.05:4;
h1=histogram(trainEr,edges,'FaceAlpha',1,'FaceColor','b');
hold on
h2=histogram(valEr,edges,'FaceAlpha',1,'FaceColor','g');
h3=histogram(testEr,edges,'FaceAlpha',1,'FaceColor','r');
title('Error Histogram') 
legend('Training','Validation','Testing')
xlabel('Errors')
ylabel('Counts')
set(gca,'FontSize',18)

f2=figure;
f2.Position=[510 500 500 500];
edges=-40:0.5:40;
histogram(ptrainEr,edges,'FaceAlpha',1,'FaceColor','b')
hold on
histogram(pvalEr,edges,'FaceAlpha',1,'FaceColor','g')
histogram(ptestEr,edges,'FaceAlpha',1,'FaceColor','r')
legend('Training','Validation','Testing')
title('% Error Histogram')
xlabel(' % Errors')
ylabel('Counts')
set(gca,'FontSize',18)

% Calculate correlation coefficients
Rtrain=corr(trainT',trainY')
Rval=corr(valT',valY')
Rtest=corr(testT',testY')
Rall=corr(t',output')

% Calculate and plot the mean squared root error
f3=figure;
f3.Position=[1 50 600 500];
plotperform(tr)
set(gca,'FontSize',16)

% Use a second NN to learn about the error

x1=[x' output'];
a=x1';
hiddenLayerSize1 = 10;
net1 = fitnet(hiddenLayerSize1,trainFcn);

% Setup Division of Data for Training, Validation, Testing
net1.divideParam.trainRatio = 70/100; % 70% for training
net1.divideParam.valRatio = 15/100; % 15% for validation
net1.divideParam.testRatio = 15/100; % 15% for testing

[net1,er] = train(net1,a,allEr);

% Use trained NN on training dataset
trainX1= a(:,er.trainInd);
trainEr1=net1(trainX1);
% Use trained NN on validation dataset
valX1=a(:,er.valInd);
valEr1=net1(valX1);
% Use trained NN on testing dataset
testX1=a(:,er.testInd);
testEr1=net1(testX1);
% Used trained NN for entire dataset
allEr1=net1(a);

trainY1=trainY + trainEr1;
valY1=valY + valEr1;
testY1=testY + testEr1;
output1=output +allEr1;

% Scatter plot of truth vs estimate
f4=figure;
f4.Position=[620 50 600 500];
plotregression(trainT,trainY1,'Training',valT,valY1,'Validation',...
    testT,testY1,'Test',t,output1,'All')



