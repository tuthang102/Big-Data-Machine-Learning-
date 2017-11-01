    %% This script import patient 489 and 1048 only
    clear; close all
    i=1048; 
    load('patients.mat')
    folder='C:\Users\Orpheus\Desktop\LungCancerDetection\stage1';
    files=dir(fullfile([folder '\' patients(i).name],'*.dcm'));

 for i=1:length(files)
        filenames{i,1}=fullfile([files(i).folder '\' files(i).name]);
        inf{i,1}=dicominfo(filenames{i});
       
 end
 infos=struct([]);
    for i=1:length(files)
         [infos(i).Filename]=inf{i,1}.Filename;
         [infos(i).InstanceNumber]=inf{i,1}.InstanceNumber;
         [infos(i).RescaleSlope]=inf{i,1}.RescaleSlope;
         [infos(i).RescaleIntercept]=inf{i,1}.RescaleIntercept;
         [infos(i).ImagePositionPatient]=inf{i,1}.ImagePositionPatient;
         [infos(i).PixelSpacing]=inf{i,1}.PixelSpacing; 
         [infos(i).SliceLocation]=inf{i,1}.SliceLocation;
    end

[~,inds]= sort([infos.InstanceNumber]);
infos=infos(inds);
   
%%
    x = repmat(int16(0), [512 512 1 numel(infos)]);
  
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
%%
%   Since the pixel spacing is different for patients. Resize all patients to the same pixel spacing   
%   SliceThickness=abs(infos(5).SliceLocation - infos(6).SliceLocation);
    V=squeeze(x);
    new_spacing=[1 1 1]; % The new choosen pixel spacing
    spacing=[0.7031;0.7031;2]'; % Patients original Pixel Spacing
    resize_factor=spacing./ new_spacing; % calculate the resize factor
    new_real_shape=size(V).* resize_factor; % calculate the new real shape of the volume
    new_shape=round(new_real_shape); % round the new shape
    real_resize_factor=new_shape./ size(V); % calculate the real resize factor 
    new_spacing=spacing./real_resize_factor; % calculate the new_spacing (they're not exactly 1mmx1mmx1mm)
    V_resize=imresize3(V,new_shape,'Method','nearest'); % Finally,resize the volume using nearest method
    
    
%     [patients(i).RealPixelData]=V;

    save(sprintf('lung%d',1048),'V_resize');
