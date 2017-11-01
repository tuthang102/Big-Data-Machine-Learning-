clear all
load('labels.mat')
load('patients.mat')
for i=1:length(patients)
    for k=1:length(labels)
        if strcmp(patients(i).name,labels(k,1))== true
           [patients(i).label]=labels(k,2);
        end
    end
end

% imds = imageDatastore(fullfile(matlabroot,'toolbox','matlab'),...
% 'IncludeSubfolders',true,'FileExtensions','.tif','LabelSource','foldernames')   

