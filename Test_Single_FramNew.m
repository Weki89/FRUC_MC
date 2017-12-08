% %Test_Single_Frame.m
clear;clc;
addpath('D:\fruc\code\paper and code2\Codes\Codes\Videos');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Analysis');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Compensation');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Estimation');
yuvfilename = 'highway_cif.yuv';
% yuvfilename = 'foreman_cif_30fps.yuv';
format = 'cif';
init2last = [1,3];
[Y,U,V] = ReadMultiFrames(yuvfilename,format,init2last);

mid = (size(Y,3)+1)/2;
im_prev = Y(:,:,1);
im_next = Y(:,:,end);
im_original = Y(:,:,mid);
[im_rows,im_cols] = size(im_prev);

params.block_size = 8;
params.search_range = 16;
params.step_size = 1;
params.im_rows = im_rows;
params.im_cols = im_cols;

im_prev_pad = padarray(im_prev,params.search_range*[1,1],'replicate');
im_next_pad = padarray(im_next,params.search_range*[1,1],'replicate');

%--------------------Bi-directional Motion Estimation----------------------
mbSize = 8;
p=7;%  

% MVF = {}
tic
% MVF = motionEstESjgwallc4(im_prev,im_next,mbSize,p);

%  MVF = motionEstES(im_next,im_prev,mbSize,p)
% blk_sz = 8;
% mbSize = blk_sz;
enb_sz_me = 2;
% enb_sz_mc = 4;
% MVF_blk_pre = zeros(im_rows/blk_sz,im_cols/blk_sz,2)
% MVF = BMA_3DRS(im_prev,im_next,MVF_blk_pre,blk_sz,enb_sz_me);
 MVF = FME(im_prev_pad,im_next_pad,params)
 toc
MVF = BiMErefine(im_prev_pad,im_next_pad,MVF,2,params);
%--------------------------------------------------------------------------

%---------------------------Motion Analysis--------------------------------
%%% 1 %%%
%MVF = simple_smoothMVF(im_prev_pad,im_next_pad,MVF,params);
%%% 2 %%%
%MVF = median_smoothMVF(MVF);
%%% 3 %%%
%MVF = WM_smoothMVF(im_prev_pad,im_next_pad,MVF,params);
%--------------------------------------------------------------------------

%--------------------------Motion Compensation-----------------------------
%%% 1 %%%
% im_interp = MCI(im_prev_pad,im_next_pad,MVF,params);
%%% 2 %%%
%im_interp = OBMC(im_prev_pad,im_next_pad,MVF,params);
%%% 3 %%%
%im_interp = AOBMC(im_prev_pad,im_next_pad,MVF,params);
%%% 4 %%%
im_interp = MCI_8J(im_prev_pad,im_next_pad,MVF,0.25,params);
%%% 5 %%%
% im_interp = OBMC_8J(im_prev_pad,im_next_pad,MVF,0.25,params);
%--------------------------------------------------------------------------


MVF_left = MVF;
MVF_right = cell(2,1);
MVF_right{1} = -MVF{1};
MVF_right{2} = -MVF{2};

figure;
subplot(231);
imshow(mat2gray(im_prev));
xlabel(['The ',num2str(init2last(1)),'-th Frame']);
subplot(232);
imshow(mat2gray(im_original));
xlabel(['The ',num2str((init2last(2)+init2last(1))/2),'-th Frame']);
subplot(233);
imshow(mat2gray(im_next));
xlabel(['The ',num2str(init2last(2)),'-th Frame']);
subplot(234)
MVF_plot(MVF_left);
xlabel('The left MVF');
subplot(235);
imshow(mat2gray(im_interp));
PSNR = Psnr(im_original,im_interp);
xlabel(['The Interpolated Frame, PSNR = ',num2str(PSNR),' dB']);
subplot(236)
MVF_plot(MVF_right);
xlabel('The right MVF');




