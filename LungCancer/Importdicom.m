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
%     x = repmat(int16(0), [infos(1).Width infos(1).Height 1 numel(infos)]);
%     fprintf('Now reading %d \n',i)
%     % Read the series of images.
    for p=1:numel(infos)
        slope= infos(p).RescaleSlope;  
        intercept=infos(p).RescaleIntercept;
        x = dicomread(infos(p).Filename);
        
        new_spacing=[1 1]; % The new choosen pixel spacing
        spacing=[infos(p).PixelSpacing]'; % Patients original Pixel Spacing
        resize_factor=spacing./ new_spacing; % calculate the resize factor
        new_real_shape=size(x).* resize_factor; % calculate the new real shape of the volume
        new_shape=round(new_real_shape); % round the new shape
        real_resize_factor=new_shape./ size(x); % calculate the real resize factor 
        new_spacing=spacing./real_resize_factor; % calculate the new_spacing (they're not exactly 1mmx1mmx1mm)
        x=imresize(x,new_shape,'Method','nearest'); % Finally,resize the volume using nearest method
        
        if slope ~=1
           x= slope*x;
        end
        x=double(x) + intercept;
%         x=double(x);
        maxHU=400;
        minHU=-1000;
        x=(x- minHU)/(maxHU -minHU);
        x(x>1)=1;
        x(x<0)=0;
%         x=x -0.25;
        save(sprintf('slice%d',p),'x')
        imwrite(x,sprintf('slice%d.tiff',p))
        fprintf('Now reading %d \n',p)
    end
end

toc