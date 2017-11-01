clear; close all

% for i=1:length(patientsL)
%     sub1{i,1}=dir([folder '\' patientsL(i).name]);
%     sub1{i,1} (1:2)=[];
% end

for k=1
    folder='C:\Users\Orpheus\Desktop\LungCancerDetection\DOI';
    load('annotations')
    a=dir(folder);
    a(1:2)=[];
    files=struct([]);
    b=dir([folder '\' a(k).name]);
    b(1:2)=[];
    for j=1:length(b)
      c=dir([b(j).folder '\' b(j).name]);
      c(1:2)=[];
      
      for l=1:length(c)
          
          files=dir(fullfile([c(1).folder '\' c(1).name],'*.dcm'));
          
         if length(files) > 15
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
                 [infos(i).SeriesInstanceUID]=inf{i,1}.SeriesInstanceUID;
                 [infos(i).ImageOrientationPatient]=inf{i,1}.ImageOrientationPatient;
%                [infos(1).Width]=inf{i,1}.Width;
%                [infos(1).Height]=inf{i,1}.Height;
         
               end
    [~,inds]= sort([infos.InstanceNumber]);
    infos=infos(inds);

   for i=1:length(annotations)
      if strcmp(annotations{i,1},infos(1).SeriesInstanceUID)== true
          position=annotations{i,4};          
          t=i;
       
           for l=1:length(infos)
               diff(l)=abs(position - infos(l).SliceLocation) ;
           end
            [distance,index]=min(diff);
            p=index;
          
         x=dicomread(infos(p).Filename);
         slope= infos(p).RescaleSlope;  
         intercept=infos(p).RescaleIntercept;

         if slope ~=1
            x=slope*x;
         end
         x=infos(p).RescaleSlope*int16(x) +intercept;
         save(sprintf('mag%d',k),'x')  
       else
%            save(sprintf('be%d',k),'k')  
%       end
%     % Read the series of images.
%                y = repmat(int16(0), [512 512 1 numel(infos)]);
%           for p=1:numel(infos)
%               slope= infos(p).RescaleSlope;  
%               intercept=infos(p).RescaleIntercept;
%               y(:,:,1,p) = dicomread(infos(p).Filename);
%         
%               if slope ~=1
%                  y(:,:,1,p)= slope*y(:,:,1,p);
%               end
%               y(:,:,1,p)= y(:,:,1,p) + intercept;
         end
      end
    end
   end
  end
  fprintf('Now reading %d \n',k)
%  clear
end