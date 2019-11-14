clear;
% read the stego
stego = imread('lena_stego.bmp');
stego_red = stego(:,:,1);

% read the watermark
watermark_img = imread('logo.jpg');
watermark_img = watermark_img(:,:,1);

watermark_img_vector = watermark_img(:);

% Spreading the watermark
watermark_img_spreading_vector = zeros(200*200, 1);

for i = 1:100*100
    watermark_img_spreading_vector(4*i-3) = watermark_img_vector(i);
    watermark_img_spreading_vector(4*i-2) = watermark_img_vector(i);
    watermark_img_spreading_vector(4*i-1) = watermark_img_vector(i);
    watermark_img_spreading_vector(4*i) = watermark_img_vector(i);
end

watermark_img_spreading = reshape(watermark_img_spreading_vector, 200, 200);

% Perform dwt transformation to get stego_cA
[stego_cA,stego_cH,stego_cV,stego_cD] = dwt2(stego_red,'sym4','mode','per');

% SVD decomposition of the stego_cD matrix to get U, S, V of cover
[stego_U,stego_S, stego_V] = svd(stego_cD);

% Perform dwt transformation to get watermark_cA
[ori_watermark_cA,ori_watermark_cH,ori_watermark_cV,ori_watermark_cD] = dwt2(watermark_img_spreading,'sym4','mode','per');

% SVD decomposition of the watermark_cA matrix to get U, S, V of original watermark
[ori_watermark_U,ori_watermark_S,ori_watermark_V] = svd(ori_watermark_cA);

% recover the cA of the watermark
watermark_cA = stego_U * ori_watermark_S * stego_V';

% reconstruct the watermark
watermark_recover = idwt2(ori_watermark_cA,ori_watermark_cH,ori_watermark_cV,ori_watermark_cD,'sym4','mode','per');

% Generate a gold code
goldseq = comm.GoldSequence('SamplesPerFrame',200*200);
x = goldseq.step();
x = reshape(x, 200, 200);
watermark_recover = watermark_recover - x;

watermark_recover_vector = watermark_recover(:);

% shrink the watermark
% Detect and delete outliers in the data
watermark_shrink_vector = zeros(100*100,1);
for i = 1:100*100
    temp = sort(watermark_recover_vector(4*i-3:4*i));
    watermark_shrink_vector(i) = mean(temp(2:3));
    % if your matlab is the newest version, you can use the following
    % temp = rmoutliers(watermark_recover_vector(4*i-3:4*i));
    % watermark_shrink_vector(i) = mean(temp);
end
watermark_shrink = reshape(watermark_shrink_vector, 100, 100);

correct_count = 0;
for i = 1:100*100
    if watermark_shrink_vector(i) > watermark_img_vector(i)-2 && watermark_shrink_vector(i) < watermark_img_vector(i)+2
        correct_count = correct_count + 1;
    end
end

correct_rate = correct_count/10000
        
imshow(watermark_shrink);
imwrite(watermark_shrink, 'recovered_logo.jpg');




