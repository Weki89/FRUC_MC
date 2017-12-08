%Test_Single_Frame.m
clear;clc;
addpath('D:\fruc\code\paper and code2\Codes\Codes\Videos');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Analysis');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Compensation');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Estimation');

yuvfilename = 'foreman_cif_30fps.yuv';
format = 'cif';
init2last = [16,20];
[Y,U,V] = ReadMultiFrames(yuvfilename,format,init2last);
size(Y,3)
mid = (size(Y,3)+1)/2;
im_prev = Y(:,:,1)
im_next = Y(:,:,end)
im_original = Y(:,:,mid)
midL = mid-1;
midR = mid+1;
im_originalL = Y(:,:,midL);
im_originalR = Y(:,:,midR);
[im_rows,im_cols] = size(im_prev)

params.block_size = 8;
params.search_range = 16;
params.step_size = 1;
params.im_rows = im_rows;
params.im_cols = im_cols;

im_prev_pad = padarray(im_prev,params.search_range*[1,1],'replicate');
im_next_pad = padarray(im_next,params.search_range*[1,1],'replicate');

%--------------------Bi-directional Motion Estimation----------------------
MVF = FME(im_prev_pad,im_next_pad,params);

% MVF_blk_R2 = round(MVF_blk_Y/2);
% MVF_blk_Y = InterMVF(im_prev_pad,im_next_pad,MVF_blk_R1,MVF_blk_R2,blk_sz,enb_sz_me);
disp(MVF)
size(MVF)
% MVF = BiMErefine(im_prev_pad,im_next_pad,MVF,2,params);
%--------------------------------------------------------------------------

%---------------------------Motion Analysis--------------------------------
%%% 1 %%%
%MVF = simple_smoothMVF(im_prev_pad,im_next_pad,MVF,params);
%%% 2 %%%
% MVF = median_smoothMVF(MVF);
%%% 3 %%%
%MVF = WM_smoothMVF(im_prev_pad,im_next_pad,MVF,params);
%--------------------------------------------------------------------------

%--------------------------Motion Compensation-----------------------------
%%% 1 %%%
[im_interp,im_interpL,im_interpR] = MCIALL(im_prev_pad,im_next_pad,MVF,params);
%%% 2 %%%
% im_interp = OBMC(im_prev_pad,im_next_pad,MVF,params);
%%% 3 %%%
%im_interp = AOBMC(im_prev_pad,im_next_pad,MVF,params);
%%% 4 %%%
%im_interp = MCI_8J(im_prev_pad,im_next_pad,MVF,0.25,params);
%%% 5 %%%
% im_interp = OBMC_8J(im_prev_pad,im_next_pad,MVF,0.25,params);
%--------------------------------------------------------------------------

% 
% MVF_left = MVF;
% MVF_right = cell(2,1);
% MVF_right{1} = -MVF{1};
% MVF_right{2} = -MVF{2};

figure;
% subplot(231);
imshow(mat2gray(im_prev));
xlabel(['The ',num2str(init2last(1)),'-th Frame']);
% subplot(232);
figure;
imshow(mat2gray(im_original));
xlabel(['The ',num2str((init2last(2)+init2last(1))/2),'-th Frame']);
% subplot(233);
figure;
imshow(mat2gray(im_next));
xlabel(['The ',num2str(init2last(2)),'-th Frame']);
% subplot(234)
% MVF_plot(MVF_left);
% xlabel('The left MVF');
% subplot(235);
figure;
imshow(mat2gray(im_interp));
PSNR = Psnr(im_original,im_interp);
xlabel(['The Interpolated' ,num2str((init2last(2)+init2last(1))/2),' Frame, PSNR = ',num2str(PSNR),' dB']);
% subplot(236)
% MVF_plot(MVF_right);
% xlabel('The right MVF');
% % im_interp_pad = padarray(im_interp,params.search_range*[1,1],'replicate');
% size(im_prev_pad)
% size(im_interp)
% size(im_interp_pad)
% MVF = FME(im_prev_pad,im_interp_pad,params)
% MVF = median_smoothMVF(MVF)
% MVF = WM_smoothMVF(im_prev_pad,im_interp_pad,MVF,params);
% im_interpL = MCIL(im_prev_pad,im_interp_pad,MVF,params);
figure;
imshow(mat2gray(im_interpL));
PSNR = Psnr(im_originalL,im_interpL);
xlabel(['The Left Interpolated ' ,num2str(init2last(1)+1), ' Frame, PSNR = ',num2str(PSNR),' dB']);

% 
% MVF = FME(im_interp_pad,im_next_pad,params)
% % MVF = median_smoothMVF(MVF)
% % MVF = WM_smoothMVF(im_prev_pad,im_next_pad,MVF,params);
% im_interpR = MCIR(im_interp_pad,im_next_pad,MVF,params);
figure;
imshow(mat2gray(im_interpR));
PSNR = Psnr(im_originalR,im_interpR);
xlabel(['The Right Interpolated ',num2str(init2last(2)-1), ' Frame, PSNR = ',num2str(PSNR),' dB']);