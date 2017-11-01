clear 
% len=5999;
% load('candidates.mat')
load('annotations.mat')
for i=1
%     load('annotations.mat')
    info=mha_read_header([char(annotations{i,1}) '.mhd']);
    fid = fopen(char([char(annotations{i,1}) '.raw']), 'r');
    di=info.Dimensions;
    a=di(1)*di(2)*di(3);
    if fid == -1
    x=i;
    else
    data =fread(fid,a,'int16');
%     data=int16(data);
    fclose(fid);
    data = reshape(data, [di(1) di(2) di(3)]);
    world=[annotations{i,2} annotations{i,3} annotations{i,4}];
    strVoxel=abs(world - info.Offset);
    voxel= strVoxel./info.PixelDimensions;
    x=data(:,:,round(voxel(3)));
    maxHU=400;
    minHU=-1000;
    x=(x- minHU)/(maxHU -minHU);
    x(x>1)=1;
    x(x<0)=0;
    new_spacing=[1 1]; % The new choosen pixel spacing
    spacing=[info.PixelDimensions(1) info.PixelDimensions(2)]; % Patients original Pixel Spacing
    resize_factor=spacing./ new_spacing; % calculate the resize factor
    new_real_shape=size(x).* resize_factor; % calculate the new real shape of the volume
    new_shape=round(new_real_shape); % round the new shape
    real_resize_factor=new_shape./ size(x); % calculate the real resize factor 
    new_spacing=spacing./real_resize_factor; % calculate the new_spacing (they're not exactly 1mmx1mmx1mm)
    x=imresize(x,new_shape,'Method','nearest'); % Finally,resize the volume using nearest method

% save(sprintf('mag%d',i),'x')
% imwrite(x,sprintf('mag%d.tiff',i))
% fprintf('Now reading %d \n',i)
    end
%     clear
end



