%% IMPORT ALL DICOM FILES FROM STAGE1 FOLDER
clear; close all
folder='C:\Users\Orpheus\Desktop\LungCancerDetection\stage1';
load('patients.mat')
tic 
for i=1
    folder='C:\Users\Orpheus\Desktop\LungCancerDetection\stage1';
    load('patients.mat')
    files=dir(fullfile([folder '\' patients(i).name],'*.dcm'));
    filenames=cellfun(@(x)fullfile([folder '\'  patients(i).name],x), {files.name}, 'uni',0);
    infos=cellfun(@dicominfo, filenames);
    [~,inds]= sort([infos.InstanceNumber]);
    infos=infos(inds);
    % Create a zero matrix with int16 range from -32768 to 32767
    x = repmat(int16(0), [infos(1).Width infos(1).Height 1 numel(infos)]);
    fprintf('Now reading %d \n',i)
%     % Read the series of images.
    for p=1:numel(infos)
        slope= infos(p).RescaleSlope;  
        intercept=infos(p).RescaleIntercept;
        x(:,:,1,p) = dicomread(infos(p).Filename);
        
        if slope ~=1
            x(:,:,1,p)= slope*x(:,:,1,p);
        end
        x(:,:,1,p)= x(:,:,1,p) + intercept;
        [bw,x(:,:,1,p)]=segmentImage(x(:,:,1,p));
    end
%   Set outside-of-scan pixel to zero
%     x(x<-2000)=0;

%   Since the pixel spacing is different for patients. Resize all patients to the same pixel spacing   
%   SliceThickness=abs(infos(5).SliceLocation - infos(6).SliceLocation);
    SliceThickness=abs(infos(5).ImagePositionPatient(3) - infos(6).ImagePositionPatient(3));
    V=squeeze(x);
    new_spacing=[1 1 1]; % The new choosen pixel spacing
    spacing=[infos(1).PixelSpacing; SliceThickness]'; % Patients original Pixel Spacing
    resize_factor=spacing./ new_spacing; % calculate the resize factor
    new_real_shape=size(V).* resize_factor; % calculate the new real shape of the volume
    new_shape=round(new_real_shape); % round the new shape
    real_resize_factor=new_shape./ size(V); % calculate the real resize factor 
    new_spacing=spacing./real_resize_factor; % calculate the new_spacing (they're not exactly 1mmx1mmx1mm)
    V_resize=imresize3(V,new_shape,'Method','nearest'); % Finally,resize the volume using nearest method
    
%     [patients(i).PixelData]=V_resize;
%     [patients(i).RealPixelData]=V;

%     save(sprintf('patient%d',i),'V_resize');
%     [patients(i).PixelSpacing]=spacing;
%     [patients(i).NewSpacing]=new_spacing;
%     [patients(i).Size]=size(V);
%     [patients(i).NewSize]=size(V_resize);
%     [patients(i).Slope]=infos(1).RescaleSlope;
%     [patients(i).Intercept]=infos(1).RescaleIntercept;
% clear
end

toc
% patients = rmfield(patients, {'folder', 'isdir', 'datenum'});
%%
% load('patients')
% load('labels')
% for i=1:length(patients)
%    load(sprintf('lung%d',i));
%    x=imresize3(V_resize,[64 64 64],'Method','nearest');
% %    x=im2single(x);
%    [patients(i).Data]=x;
%    
% end
% %% FILTER OUT PATIENTS WITH LABELS
% load('labels.mat')
% load('patients.mat')
% load('stage1solution.mat')
% for i=1:length(patients)
%     for k=1:length(labels)
%         if strcmp(patients(i).name,labels(k,1))== true
%            [patients(i).label]=cell2mat(labels(k,2));
%            
%         end
%     end
% end
% 
% for i=1:length(patients)
%     for k=1:length(stage1solution)
%         if strcmp(patients(i).name,stage1solution{k,1})== true
%            [patients(i).label]=cell2mat(stage1solution(k,2));
%            
%         end
%     end
% end
% 
% 
%% LUNG SEGMENTATION
load('patient1.mat')
X=V_resize;

x=X(:,:,200);
imageSegmenter
%%
a=size(X);
Xseg = repmat(int16(0), [a(1) a(2) 1 a(3)]);
for j=1:a(3)
    [BW,Xseg(:,:,1,j)]=segmentImage(X(:,:,j));
end 
figure(1)
montage(Xseg,'DisplayRange',[])
figure(2)
montage(reshape(X,[a(1) a(2) 1 a(3)]),'DisplayRange',[])
%%
y2=Xseg(:,:,50);
imageSegmenter;
