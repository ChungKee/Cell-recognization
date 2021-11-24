%% Crop Image
clear all;clc;
image_cell=imread("Ld4.jpg");
gray_image=rgb2gray(image_cell); 
gray_image_medfil=medfilt2(double(gray_image),[5,5]);   %median filter
figure(1);subplot(2,2,1);imshow(uint8(gray_image_medfil));
title('Grayscale Image'); 

b1=double(gray_image_medfil);
i=(b1>130 & b1<255 );
c=b1.*i;
figure(1);subplot(2,2,2);imshow(c);
title('Binary Image');

se=strel('disk',2);
c=imerode(c,se);
figure(1);subplot(2,2,3);imshow(~c);
title('After Erode Image');

[L Ne]=bwlabel(~c); 
s  = regionprops(L);
hold on;
g=find([s.Area]>300000 );
bBox = cat(1,s.BoundingBox);
cropxy=round(bBox(g(2),:));
ajustcrop=6;
cell_crop =imcrop(gray_image,[cropxy(1)+15 cropxy(2)+10 cropxy(3)-24 cropxy(4)-20]);
cell_crop2 =imcrop(gray_image,[cropxy(1)-ajustcrop cropxy(2)-ajustcrop cropxy(3)+ajustcrop*2 cropxy(4)+ajustcrop*2]);
for n=1:size(g,2)
   rectangle('Position',s(g(n)).BoundingBox,'EdgeColor','r','LineWidth',2); 
end
figure(1);subplot(2,2,4);imshow(uint8(cell_crop));
title('Crop image');

%% Line Crop
sizecrop2=size(cell_crop2);
cell_crop2([ajustcrop+10:sizecrop2(1)-ajustcrop*2],[ajustcrop+10:sizecrop2(2)-ajustcrop*2])=0;
% figure;imshow(uint8(cell_crop2));
% title('Crop frame image2');

%% Live Cell
doublecell_2=double(cell_crop);
i=(doublecell_2>140 & doublecell_2<255 );
size_i=size(i);
for XX=1:1:size_i(1)
    calsum=sum(i(XX,:));
    if calsum>150
        i(XX,:)=0;     
    end
end
for YY=1:1:size_i(2)
    calsum2=sum(i(:,YY));
    if calsum2>150
        i(:,YY)=0;     
    end
end
live_cell2=doublecell_2.*i;
live_cell3=imfill(live_cell2,'holes');
se3=strel('disk',2);
se33=strel('disk',6);
live_cell4=imclose(imopen(live_cell3,se3),se33);
[L2 Ne2]=bwlabel(live_cell4); 
s2  = regionprops(L2);
g2=find([s2.Area]>50 );

 %% Live Line  Cell
line_b=double(cell_crop2);
i=(line_b>240 & line_b<255 );
line_c=line_b.*i;
se_linelive=strel('disk',3);
linelive=imdilate(line_c,se_linelive);
[L_linelive number_linelive]=bwlabel(linelive); 
s3_linelive  = regionprops(L_linelive);
g3_linelive=find([s3_linelive.Area]>68 );

%% Die Cell
cell_crop = imsharpen(cell_crop,'Radius',2,'Amount',4);
doublecell_2=double(cell_crop);
t=graythresh(cell_crop)*255-74;
i2=(doublecell_2>0 & doublecell_2<t);
size_i2=size(i2);
for XX2=1:1:size_i2(1)
    calsum3=sum(i2(XX2,:));
    if calsum3>150
        i2(XX2,:)=0;     
    end
end
for YY2=1:1:size_i2(2)
    calsum4=sum(i2(:,YY2));
    if calsum4>150
        i2(:,YY2)=0;     
    end
end
die_cell2=doublecell_2.*i2;
se3=strel('disk',2);
die_cell2=imclose(die_cell2,se3);
se33=strel('disk',2);
die_cell2=imopen(die_cell2,se33);
[L3 Ne3]=bwlabel(die_cell2); 
s3  = regionprops(L3);
g3=find([s3.Area]>22 );

%% Result
figure;imshow(gray_image)
for n3=1:size(g3,2)
   rectangle('Position',s3(g3(n3)).BoundingBox+[cropxy(1)+15 cropxy(2)+10 0 0],'EdgeColor','y','LineWidth',1,'Curvature',[1 1]);
   findx2=round(s3(g3(n3)).Centroid(1))+cropxy(1)+15;
   findy2=round(s3(g3(n3)).Centroid(2))+cropxy(2)+10;
   text(findx2,findy2,num2str(n3),'Color','y','FontSize',12);
end
for n2=1:size(g2,2)
   rectangle('Position',s2(g2(n2)).BoundingBox+[cropxy(1)+15 cropxy(2)+10 0 0],'EdgeColor','r','LineWidth',1,'Curvature',[1 1]); 
   findx=round(s2(g2(n2)).Centroid(1))+cropxy(1)+15;
   findy=round(s2(g2(n2)).Centroid(2))+cropxy(2)+10;
   text(findx,findy,num2str(n2),'Color','r','FontSize',12);
end
for n3_linelive=1:size(g3_linelive,2)
   rectangle('Position',s3_linelive(g3_linelive(n3_linelive)).BoundingBox+[cropxy(1)-ajustcrop cropxy(2)-ajustcrop 0 0],'EdgeColor','r','LineWidth',1,'Curvature',[1 1]);
   findx2=round(s3_linelive(g3_linelive(n3_linelive)).Centroid(1))+cropxy(1)-ajustcrop;
   findy2=round(s3_linelive(g3_linelive(n3_linelive)).Centroid(2))+cropxy(2)-ajustcrop;
   text(findx2,findy2,num2str(n3_linelive+n2),'Color','r','FontSize',12);
end
text(1100,488,['Live Cell= ',num2str(n2+n3_linelive)],'Color','r','FontSize',16);
text(1100,588,['Die Cell= ',num2str(n3)],'Color','y','FontSize',16);
text(1100,688,['Total Cell= ',num2str(n2+n3_linelive+n3)],'Color','c','FontSize',16);
