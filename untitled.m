%% Get Alignment and Crop Points for Hybrid Image
% Run this in MATLAB Desktop or MATLAB Online (NOT MATLAB Grader)

close all; clc;

%% --- STEP 1: Load your images ---
% Replace these filenames with your actual images
near_img = im2double(imread('clock.jpg'));
far_img  = im2double(imread('eye.jpg'));

fprintf('Make sure both images are loaded correctly.\n');
fprintf('Close any old figures if needed.\n\n');

%% --- STEP 2: Get alignment points ---
% Select two points (e.g., left and right eyes) from each image.
fprintf('Step 2: Select two points on the NEAR image (e.g., the eyes)...\n');
figure; imshow(near_img);
title('Click TWO points on the NEAR image (e.g., eyes)');
[x1, y1] = ginput(2);
close;

fprintf('Now select two matching points on the FAR image...\n');
figure; imshow(far_img);
title('Click TWO matching points on the FAR image (e.g., eyes)');
[x2, y2] = ginput(2);
close;

fprintf('\n--- Alignment Points ---\n');
fprintf('x1 = [%.4f %.4f]; y1 = [%.4f %.4f];\n', x1(1), x1(2), y1(1), y1(2));
fprintf('x2 = [%.4f %.4f]; y2 = [%.4f %.4f];\n', x2(1), x2(2), y2(1), y2(2));

%% --- STEP 3: (Optional) Align and preview ---
% If you want to preview the alignment, uncomment these lines:
% [near_aligned, far_aligned] = align_images(near_img, far_img, x1, y1, x2, y2);
% figure; imshowpair(near_aligned, far_aligned, 'montage');
% title('Aligned images preview');

%% --- STEP 4: Compute a quick hybrid (optional preview) ---
% Only if your hybridImage function is already implemented.
% cutoff_low = 15; cutoff_high = 10;
% hybrid = hybridImage(far_aligned, near_aligned, cutoff_low, cutoff_high);
% figure; imshow(hybrid); title('Rough Hybrid Preview');

%% --- STEP 5: Crop selection ---
% Once your hybrid is generated, use this section to get crop coordinates.
fprintf('\nWhen your hybrid image is shown, select two opposite corners.\n');
fprintf('(Click top-left and bottom-right corners of the desired crop region.)\n\n');

% Example variable name for your hybrid:
% Replace 'set1_hybrid' with your actual hybrid variable
try
    figure; imshow(set1_hybrid);
    title('Click two opposite corners to crop the final hybrid image');
    [x, y] = ginput(2);
    x = round(x); y = round(y);
    fprintf('\n--- Crop Coordinates ---\n');
    fprintf('x = [%.0f %.0f]; y = [%.0f %.0f];\n', min(x), max(x), min(y), max(y));
    close;
catch
    fprintf('No hybrid image found. Skip cropping for now.\n');
end

fprintf('\n✅ Copy these coordinates into your main hybrid image script.\n');
