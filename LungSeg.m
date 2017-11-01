%%
clear; close all;
load('patient2')
x=V_resize(:,:,260);
% x(x==0)=-1000;
imtool(x,[])
imageSegmenter;
% a=size(V_resize); 
% figure(1)
% montage(reshape(V_resize,[a(1),a(2),1,a(3)]),'DisplayRange',[]);
%%
load('patient1')
x=V_resize(:,:,180);
[bw,y]=segmentImage(x);
imtool(y,[]);
imtool(x,[]);
%% 
clear; close all;
load('patients')
patients = rmfield(patients, {'folder'});
for i=1:5
    load(sprintf('patient%d',i))
    a=size(V_resize);
    V_resize(V_resize==0)=-2000;
    x = repmat(int16(0), [a(1) a(2) 1 a(3)]);
    for j=1:a(3)
        [BW,x(:,:,1,j)]=segmentImage(V_resize(:,:,j));
    end 
    [patients(i).LungSeg]=x;
    clear x a V_resize 
    
end
%%
figure(1)
montage(patients(2).LungSeg,'DisplayRange',[]);
V=squeeze(patients(2).LungSeg);
V(V==0)=-2000;
% volumeViewer(V)
