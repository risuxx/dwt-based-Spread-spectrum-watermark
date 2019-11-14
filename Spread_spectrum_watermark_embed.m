clear;
% read the original cover
cover = imread('lena.jpg');
cover_red = cover(:,:,1);
% read the watermark image
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

% Generate a gold code
goldseq = comm.GoldSequence('SamplesPerFrame',200*200);
x = goldseq.step();
x = reshape(x, 200, 200);
watermark_img_spreading = watermark_img_spreading + x;

% Perform dwt transformation to get watermark_cA
[watermark_cA,watermark_cH,watermark_cV,watermark_cD] = dwt2(watermark_img_spreading,'sym4','mode','per');

% plot the watermark_cA
% imshow(watermark_cA)


% SVD decomposition of the watermark_cA matrix to get U, S, V of watermark
[watermark_U,watermark_S,watermark_V] = svd(watermark_cA);

% Perform dwt transformation to get cover_cD
[cover_cA,cover_cH,cover_cV,cover_cD] = dwt2(cover_red,'sym4','mode','per');

% SVD decomposition of the cover_cA matrix to get U, S, V of cover
[cover_U,cover_S, cover_V] = svd(cover_cD);


% Reconstructing steganographic images
embeded_img_matrix = watermark_U * cover_S * watermark_V';

% 2-D inverse discrete cosine transformation to get the reconstructed img
embeded_img_red = idwt2(cover_cA,cover_cH,cover_cV,embeded_img_matrix,'sym4','mode','per');
embeded_img = cover;
embeded_img(:,:,1) = embeded_img_red;
imwrite(embeded_img, 'lena_stego.bmp');








