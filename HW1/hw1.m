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
disp(command)
eval(command);

% whos Data InAll OutAll

%--------------------------------------------------------------------------
% 1. Split up the data to provide a training dataset and independent validation 
%    dataset of size specified by the validation fraction, validation_fraction
% 2. Train a random forest (treebagger)
% 3. Use trained random forest on validation dataset
% 4. Use trained random forest on training dataset
% 5. Calculate fit error
% 6. Calculate the correlation coefficients between truth and estimates for
%    the validation and training datasets
% 7. Calculate and plot the Out of bag error over the number of grown trees
% 8. Calculate and plot the relative importance of the inputs
% 9. Use a second random forest to learn the error in the first estimate
%    then use this to correct the first estimate.
% 10. Plot a scatter diagram of the truth against the estimate.
varnames={...
    'Lag15MaxDISPH','Lag26MinGRN','MinZ0H','Lag9MeanEFLUX',...
    'Lag9MaxEVPTRNS','Lag12MeanEVPTRNS','Lag9MeanEVPTRNS',...
    'Lag14MeanEVPTRNS','Lag11MeanEVPTRNS','Lag12MaxEVPTRNS',...
    'Lag8MaxEVPTRNS','Lag11MaxEVPTRNS','Lag14MaxEVPTRNS',...
    'Lag30MinTELAND','MeanTSH','Lag29MinTELAND','Lag1MeanTSH',...
    'MaxHLML','Lag8MaxEFLUX','Lag29MaxTELAND','MeanTUNST',...
    'Lag1MeanTUNST','Lag8MaxEVAP','MeanTWLT'...
    };
%% 1. Split up the data to provide a training dataset and independent validation 
%    dataset of size specified by the validation fraction, validation_fraction
validation_fraction = 0.5;
cvp = cvpartition(OutAll,'HoldOut',validation_fraction);
intrain= InAll(cvp.training,:); % create training dataset
outtrain =OutAll(cvp.training,:); % create truth for training dataset
intest=InAll(cvp.test,:); % create test dataset
outtest=OutAll(cvp.test,:);% create truth for test dataset

%% 2. Train a random forest (treebagger)
% rng('default')
ntrees=80;
b = TreeBagger(ntrees,intrain,outtrain,'OOBPrediction','On','Method',...
    'regression','OOBvarimp','on');
% view(b.Trees{1},'Mode','graph') % view the decision tree

%% 3. Use trained random forest on validation dataset
train_fit=predict(b, intrain);

%% 4. Use trained random forest on training dataset
test_fit=predict(b, intest);

%% 5. Calculate fit error
train_er=train_fit - outtrain; % Train error
test_er=test_fit -outtest; % Test error

%% 6. Calculate the correlation coefficients between truth and estimates for
%    the validation and training datasets
R_train=corr(outtrain,train_fit) % correlation coefficient R
R_test=corr(outtest,test_fit) % correlation coefficients R

%% 7. Calculate and plot the Out of bag error over the number of grown trees

f1=figure; 
f1.Position=[1 50 600 500];
plot(oobError(b),'LineWidth',2)
title('Out of Bag Error')
xlabel('Number of Trees')
ylabel('Out of Bag Error')
box on
set(gca,'FontSize',18)

%% 8. Calculate and plot the relative importance of the inputs
imp =abs(b.OOBPermutedPredictorDeltaError);

[A,I]=sort(imp,'descend');

for i=1:length(I)
    varnames(i)=varnames(I(i));
end

f2=figure;
f2.Position=[620 50 600 500];
hold on
barh(1:1:5,A(1:5),'r') % create horizontal bar plot
barh(6:1:10,A(6:10),'y')
barh(11:1:24,A(11:24),'g')
for i=1:24
    text(A(i)+0.005,i,varnames(i),'FontSize',14)
end

title('Relative Importance of Inputs')
% set(axes1,'YTick',0:1:25,'YTickLabel',names)
ylim([0.5 24.5])
% xlim([0 1.5])
box on
grid on
ylabel('Variable Rank')
xlabel('Variable Importance')
set(gca,'YDir','Reverse')
set(gca,'FontSize',18)

%% 9. Use a second random forest to learn the error in the first estimate
%    then use this to correct the first estimate.
intest1=[intest test_fit];
intrain1=[intrain train_fit];

test_er1=outtest-test_fit; %error= truth - estimate
train_er1=outtrain-train_fit;

b2=TreeBagger(ntrees,intrain1,train_er1,'Method','regression');

new_test_er=predict(b2,intest1);
new_train_er=predict(b2,intrain1);

test_fit= test_fit + test_er1;
train_fit=train_fit+ train_er1;

%% 10. Plot a scatter diagram of the truth against the estimate.
x=[0 2000];
y=x;
f3=figure;
plot(x,y,'b','linewidth',8)
hold on
% scatter(outtest,test_fit,100,'g')
errorbar(outtest,test_fit,new_test_er,'og')
hold on
% scatter(outtrain,train_fit,100,'r')
errorbar(outtrain,train_fit,new_train_er,'or')
hold off
set(gca,'fontsize',18)
xlabel('Observed')
ylabel('Estimated')
xlim([0 2000])
ylim([0 2000])
grid on
format shortg;
title(['Random Forest (R_T=' num2str(round(R_train,2)),', R_V=' num2str(round(R_test,2)) ' )'])
legend('1:1','Validation','Training')
% restrain=fit_t - outtrain
% pretrain=100*restrain./outtrain


