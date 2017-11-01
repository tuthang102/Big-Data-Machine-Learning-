%% EXAMPLE
       load mri
       D = squeeze(V);
%        D(:,1:60,:) = [];
       p = patch(isosurface(D, 5), 'FaceColor', 'red', 'EdgeColor', 'none');
       p2 = patch(isocaps(D, 5), 'FaceColor', 'interp', 'EdgeColor', 'none');
       view(3); axis tight;  daspect([1 1 .4])
       colormap(gray(100))
       camlight; lighting gouraud
       isonormals(D, p);
%% MAIN
clear
load('V.mat')
load('V_resize.mat')
[a,b,c]=size(V);

[row,col]=find(V>400); % thresh hold=400 
maxcol=512*(c+1);
k=1:512:maxcol;
for i=1:length(col)
    for  n=1:length(k)-1
        if col(i)>k(n) && col(i)<= k(n+1)
            z(i)=n;
        end
    end
end
idx=[row col z'];
Vnew = repmat(int16(0), []);

% V(V<400)=0;
% V(V>1000)=0;
% volumeViewer(V);


% V_resize(V_resize<-600)=0;
% V_resize(V_resize>-400)=0;
volumeViewer(V_resize);
%% USE IMAGE GRADIDENT TO VIEW THE VESSEl IN THE LUNG
% Resize data
% load('V_resize.mat')
V_resize=seg2fill;
V_resize(V_resize>400)=0;
sz=size(V_resize);
[Gmag, Gaz, Gelev] = imgradient3(V_resize);
figure(1)
gradV=reshape(Gmag,sz(1),sz(2),1,sz(3));
montage(gradV,'DisplayRange',[]);
title('Gradient magnitude of resize data')
volumeViewer(squeeze(gradV))


% Original data
% load('V.mat')
% V(V>0)=0 ;% ignore the bones
% sz=size(V);
% [Gmag, Gaz, Gelev] = imgradient3(V);
% figure(2)
% montage(reshape(Gmag,sz(1),sz(2),1,sz(3)),'DisplayRange',[])
% title('Gradient magnitude of original data')







