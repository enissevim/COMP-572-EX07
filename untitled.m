close('all');    % start fresh

% Read images (example pair)
set2_far  = im2double(imread('fruit.jpg')); 
set2_near = im2double(imread('dog.jpg'));

% OPTIONAL: convert to grayscale
% set2_far  = rgb2gray(set2_far);
% set2_near = rgb2gray(set2_near);

%% === 1. GET ALIGNMENT POINTS INTERACTIVELY ===
disp('Click TWO points in the NEAR image (e.g., centers of eyes, etc.)');
fig1 = figure; imshow(set2_near); title('Select TWO points in NEAR image, press Enter after each');
[x1, y1] = ginput(2); close(fig1);

disp('Click TWO points in the FAR image (same locations as before)');
fig2 = figure; imshow(set2_far); title('Select TWO points in FAR image, press Enter after each');
[x2, y2] = ginput(2); close(fig2);

fprintf('\nAlignment points captured:\n');
disp(['x1 = [' num2str(x1(1)) ' ' num2str(x1(2)) ']; y1 = [' num2str(y1(1)) ' ' num2str(y1(2)) '];']);
disp(['x2 = [' num2str(x2(1)) ' ' num2str(x2(2)) ']; y2 = [' num2str(y2(1)) ' ' num2str(y2(2)) '];']);

[set2_near_aligned, set2_far_aligned] = align_images(set2_near, set2_far, x1, y1, x2, y2);

%% === 2. CHOOSE FILTER CUTOFFS ===
cutoff_low  = 10.0;   
cutoff_high = 8.0;

%% === 3. CREATE HYBRID IMAGE ===
set2_hybrid = hybridImage(set2_far_aligned, set2_near_aligned, cutoff_low, cutoff_high);
figure; imshow(set2_hybrid); title('Hybrid Image (before crop)');

%% === 4. INTERACTIVE CROPPING ===
disp('Click two opposite corners of crop region, then press Enter');
fig3 = figure; imshow(set2_hybrid);
[x, y] = ginput(2); close(fig3);
x = round(x); y = round(y);
fprintf('\nCrop coordinates captured:\n');
disp(['x = [' num2str(x(1)) ' ' num2str(x(2)) ']; y = [' num2str(y(1)) ' ' num2str(y(2)) '];']);

set2_hybrid = set2_hybrid(min(y):max(y), min(x):max(x), :);

[h, w, ~] = size(set2_hybrid);
viewed_from_afar = padarray(set2_hybrid, max(h, w));
figure; montage({set2_near, set2_far, set2_hybrid, viewed_from_afar}, 'Size', [2,2]);
title('Near | Far | Hybrid | Hybrid viewed from afar');

%% === 5. SUPPORT FUNCTIONS ===
function im12 = hybridImage(im1, im2, cutoff_low, cutoff_high)
    im1_fft = fftshift(fft2(im1));
    im2_fft = fftshift(fft2(im2));
    [h, w, ~] = size(im1);
    [X, Y] = meshgrid(-w/2:w/2-1, -h/2:h/2-1);
    D = sqrt(X.^2 + Y.^2);
    gauss_low = exp(-(D.^2)/(2*cutoff_low^2));
    gauss_high = 1 - exp(-(D.^2)/(2*cutoff_high^2));
    im1_filter = im1_fft .* gauss_low;
    im2_filter = im2_fft .* gauss_high;
    mix = im1_filter + im2_filter;
    im12 = real(ifft2(ifftshift(mix)));
end

function [im1, im2] = align_images(im1, im2, x1, y1, x2, y2)
    [h1,w1,~]=size(im1); [h2,w2,~]=size(im2);
    cx1=mean(x1); cy1=mean(y1); cx2=mean(x2); cy2=mean(y2);
    tx=round((w1/2-cx1)*2);
    if tx>0, im1=padarray(im1,[0 tx],'pre'); else, im1=padarray(im1,[0 -tx],'post'); end
    ty=round((h1/2-cy1)*2);
    if ty>0, im1=padarray(im1,[ty 0],'pre'); else, im1=padarray(im1,[-ty 0],'post'); end  
    tx=round((w2/2-cx2)*2);
    if tx>0, im2=padarray(im2,[0 tx],'pre'); else, im2=padarray(im2,[0 -tx],'post'); end
    ty=round((h2/2-cy2)*2);
    if ty>0, im2=padarray(im2,[ty 0],'pre'); else, im2=padarray(im2,[-ty 0],'post'); end
    len1=sqrt((y1(2)-y1(1)).^2+(x1(2)-x1(1)).^2);
    len2=sqrt((y2(2)-y2(1)).^2+(x2(2)-x2(1)).^2);
    dscale=len2./len1;
    if dscale<1, im1=imresize(im1,dscale,'bilinear'); else, im2=imresize(im2,1./dscale,'bilinear'); end
    theta1=atan2(-(y1(2)-y1(1)),x1(2)-x1(1)); theta2=atan2(-(y2(2)-y2(1)),x2(2)-x2(1));
    dtheta=theta2-theta1;
    im1=imrotate(im1,dtheta*180/pi,'bilinear');
    [h1,w1,~]=size(im1); [h2,w2,~]=size(im2);
    minw=min(w1,w2); brd=(max(w1,w2)-minw)/2;
    if minw==w1, im2=im2(:,(ceil(brd)+1):end-floor(brd),:); else, im1=im1(:,(ceil(brd)+1):end-floor(brd),:); end
    minh=min(h1,h2); brd=(max(h1,h2)-minh)/2;
    if minh==h1, im2=im2((ceil(brd)+1):end-floor(brd),:,:); else, im1=im1((ceil(brd)+1):end-floor(brd),:,:); end    
end
