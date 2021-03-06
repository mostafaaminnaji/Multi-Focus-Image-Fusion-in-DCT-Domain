% C)Mostafa Amin-Naji, Babol Noshirvani University of Technology,
% My Official Website: www.Amin-Naji.com
% My Email: Mostafa.Amin.Naji@Gmail.com

% PLEASE CITE THE BELOW PAPER IF YOU USE THIS CODE

%M. Amin-Naji and A. Aghagolzadeh, �Multi-Focus Image Fusion in DCT Domain using
%Variance and Energy of Laplacian and Correlation Coefficient for Visual Sensor
%Networks,� Journal of AI and Data Miningm vol. 6, no. 2, 2018, pp. 233-250.
% DOI:  http://dx.doi.org/10.22044/jadm.2017.5169.1624

clc
clear
close all

%Select First Image
disp('Please Select First Image:')
[filename, pathname]= uigetfile({'*.jpg;*.png;*.tif'},'Select First Image');
path=fullfile(pathname, filename);
im1=imread(path);
disp('Great! First Image is selected')

%Select Second Image
disp('Please Select Second Image:')
[filename, pathname]= uigetfile({'*.jpg;*.png;*.tif'},'Select Second Image');
path=fullfile(pathname, filename);
im2=imread(path);
disp('Great! Second Image is selected')


if size(im1,3) == 3     % Check if the images are grayscale
    im1 = rgb2gray(im1);
end
if size(im2,3) == 3
    im2 = rgb2gray(im2);
end

if size(im1) ~= size(im2)	% Check if the input images are of the same size
    error('Size of the source images must be the same!')
end

disp('congratulations! Fusion Process in Running')

% Get input image size
[m,n] = size(im1);
FusedDCT = zeros(m,n);
FusedDCT_CV = zeros(m,n);
Map = zeros(floor(m/8),floor(n/8));	

% Level shifting
im1 = double(im1)-128;
im2 = double(im2)-128;

x=-1;
y=-4;
z=20;
C=dctmtx(8);
t=[

     y     x     0     0     0     0     0     0
     x     y     x     0     0     0     0     0
     0     x     y     x     0     0     0     0
     0     0     x     y     x     0     0     0
     0     0     0     x     y     x     0     0
     0     0     0     0     x     y     x     0
     0     0     0     0     0     x     y     x
     0     0     0     0     0     0     x     y];
 s=[

     z     y     0     0     0     0     0     0
     y     z     y     0     0     0     0     0
     0     y     z     y     0     0     0     0
     0     0     y     z     y     0     0     0
     0     0     0     y     z     y     0     0
     0     0     0     0     y     z     y     0
     0     0     0     0     0     y     z     y
     0     0     0     0     0     0     y     z];
 u=[

     x+2*y     0     0     0     0     0     0     0
     0         0     0     0     0     0     0     0
     0         0     0     0     0     0     0     0
     0         0     0     0     0     0     0     0
     0         0     0     0     0     0     0     0
     0         0     0     0     0     0     0     0
     0         0     0     0     0     0     0     0
     0         0     0     0     0     0     0     x+2*y ];
 
v=[

     0     x     0     0     0     0     0     0
     x     y     x     0     0     0     0     0
     0     x     y     x     0     0     0     0
     0     0     x     y     x     0     0     0
     0     0     0     x     y     x     0     0
     0     0     0     0     x     y     x     0
     0     0     0     0     0     x     y     x
     0     0     0     0     0     0     x     0];
 
  lu =[

     0     1     0     0     0     0     0     0
     1     0     1     0     0     0     0     0
     0     1     0     1     0     0     0     0
     0     0     1     0     1     0     0     0
     0     0     0     1     0     1     0     0
     0     0     0     0     1     0     1     0
     0     0     0     0     0     1     0     1
     0     0     0     0     0     0     1     0];
   q =[

     1     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     0
     0     0     0     0     0     0     0     1];
 
 LU=C*lu*C';
 T=C*t*C';
 S=C*s*C';
 U=C*u*C';
 V=C*v*C';
 Q=C*q*C';
 

tic

threshold1=0;
% Divide source images into 8*8 blocks and perform the fusion process
for i = 1:floor(m/8)
    for j = 1:floor(n/8)
        
        im1_Block  = im1(8*i-7:8*i,8*j-7:8*j);
        im2_Block  = im2(8*i-7:8*i,8*j-7:8*j);
        
        % Compute the 2-D DCT of 8*8 blocks
        im1_Block_DCT = C*im1_Block*C';
        im2_Block_DCT = C*im2_Block*C';
        
        Laplacian1=(LU*im1_Block_DCT*T)+(im1_Block_DCT*S)+((Q*im1_Block_DCT*U)+(V*im1_Block_DCT*Q)+(Q*im1_Block_DCT*V));
        Laplacian2=(LU*im2_Block_DCT*T)+(im2_Block_DCT*S)+((Q*im2_Block_DCT*U)+(V*im2_Block_DCT*Q)+(Q*im2_Block_DCT*V));
       
        im1ave = Laplacian1(1,1);
        im2ave = Laplacian2(1,1);
        VOLDCT1 = sum(sum(Laplacian1.^2)) - im1ave.^2;
        VOLDCT2 = sum(sum(Laplacian2.^2)) - im2ave.^2;
        
        z=VOLDCT1;
        zz=VOLDCT2;


        if z>=zz
           dctBlock = im1_Block_DCT;
            Map(i,j) = -1;	% Consistency verification index

        end
        if z<zz
            dctBlock = im2_Block_DCT;
            Map(i,j) = +1;    % Consistency verification index



        end
        if z<zz+threshold1 && z>zz-threshold1
            dctBlock = (im2_Block_DCT+im2_Block_DCT)./2;
            Map(i,j) =0 ;
        end
        
        % Compute the 2-D inverse DCT of 8*8 blocks and construct fused image
        FusedDCT(8*i-7:8*i,8*j-7:8*j) = C'*dctBlock*C;	% DCT+VOL method
       
    end
end
toc
% Concistency verification (CV) with Majority Filter (3x3 Averaging Filter)
fi=fspecial('average',3);
Map_Filtered = imfilter(Map, fi,'symmetric');	% Filtered index map

threshold2=0.00;
for i = 1:m/8
    for j = 1:n/8
        % DCT+Variance+CV method
        if Map_Filtered(i,j) <= -threshold2
            FusedDCT_CV(8*i-7:8*i,8*j-7:8*j) = im1(8*i-7:8*i,8*j-7:8*j);
   
        end
        if Map_Filtered(i,j) > threshold2
            FusedDCT_CV(8*i-7:8*i,8*j-7:8*j) = im2(8*i-7:8*i,8*j-7:8*j);
      
        end
        if Map_Filtered(i,j) > -threshold2 &&  Map_Filtered(i,j) < threshold2
             FusedDCT_CV(8*i-7:8*i,8*j-7:8*j) = (im1(8*i-7:8*i,8*j-7:8*j)+im2(8*i-7:8*i,8*j-7:8*j))./2;
        end
        end
end

% Inverse level shifting 
im1 = uint8(double(im1)+128);
im2 = uint8(double(im2)+128);
FusedDCT = uint8(double(FusedDCT)+128);
FusedDCT_CV = uint8(double(FusedDCT_CV)+128);

% Show Images Table
subplot(2,2,1), imshow(im1), title('Source image 1');
subplot(2,2,2), imshow(im2), title('Source image 2');
subplot(2,2,3), imshow(FusedDCT), title('"DCT+VOL" fusion result');
subplot(2,2,4), imshow(FusedDCT_CV), title('"DCT+VOL+CV" fusion result');

% Good Luck
% Mostafa Amin-Naji ;)
