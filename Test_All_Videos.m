%test_video.m
clear;clc;close all;
addpath('D:\fruc\code\paper and code2\Codes\Codes\Videos');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Analysis');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Compensation');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Estimation');

yuvfilename = 'news_cif.yuv';
format = 'cif';

init2last = [1,9];
Y = ReadMultiFrames(yuvfilename,format,init2last);


%Params setting
[im_rows,im_cols] = size(Y(:,:,1));
params.block_size = 8;
params.search_range = 16;
params.step_size = 1;
params.im_rows = im_rows;
params.im_cols = im_cols;

%Interpolation Frame
PSNR = [];
tic
for ii = 3:4:size(Y,3)
    disp(['The ',num2str(ii),'-th Frame.']);
    im_prev = Y(:,:,ii-2);
    im_org = Y(:,:,ii);
    im_next = Y(:,:,ii+2);
    im_prev_pad = padarray(im_prev,params.search_range*[1,1],'replicate');
    im_next_pad = padarray(im_next,params.search_range*[1,1],'replicate');
    mbSize = 8
    p = 7
    %--------------------Bi-directional Motion Estimation------------------
%     MVF = FME(im_prev_pad,im_next_pad,params);
      MVF = motionEstESjgwallc4(im_prev,im_next,mbSize,p);
    MVF = BiMErefine(im_prev_pad,im_next_pad,MVF,2,params);
    
    %---------------------------Motion Analysis----------------------------
    %%% 1 %%%
    %MVF = simple_smoothMVF(im_prev_pad,im_next_pad,MVF,params);
    %%% 2 %%%
    %MVF = median_smoothMVF(MVF);
    %%% 3 %%%
    MVF = WM_smoothMVF(im_prev_pad,im_next_pad,MVF,params);
    %----------------------------------------------------------------------
    
    %-------------------------Motion Compensation--------------------------
    %%% 1 %%%
%     im_interp = MCI(im_prev_pad,im_next_pad,MVF,params);
    %%% 2 %%%
%     im_interp = OBMC(im_prev_pad,im_next_pad,MVF,params);
    %%% 3 %%%
    %im_interp = AOBMC(im_prev_pad,im_next_pad,MVF,params);
    %%% 4 %%%
    %im_interp = MCI_8J(im_prev_pad,im_next_pad,MVF,0.25,params);
    %%% 5 %%%
    im_interp = OBMC_8J(im_prev_pad,im_next_pad,MVF,0.25,params);
    
    temp = Psnr(Y(:,:,ii),im_interp);
    PSNR = [PSNR,temp];
% %     Y(:,:,ii) = im_interp;
% PSNR = Psnr(im_org,im_interp);
% figure;imshow(mat2gray(im_interp));xlabel(['The ',num2str(ii),'-th Interpolated Frame, PSNR = ',num2str(temp),' dB']);
% % % % time = toc;
% % % % im_originalL = Y(:,:,ii-1);
% % % % im_originalR = Y(:,:,ii+1);
% % % % im_interp_pad = padarray(im_interp,params.search_range*[1,1],'replicate');
% % % % % size(im_prev_pad)
% % % % % size(im_interp)
% % % % % size(im_interp_pad)
% % % % % MVF = FME(im_prev_pad,im_interp_pad,params);
% % % % % MVF = median_smoothMVF(MVF);
% % % % MVF = motionEstESjgwallc4(im_prev,im_next,mbSize,p);
% % % %   MVF = BiMErefine(im_prev_pad,im_next_pad,MVF,2,params);
% % % % MVF = WM_smoothMVF(im_prev_pad,im_interp_pad,MVF,params);
% % % % im_interpL = MCIL(im_prev_pad,im_interp_pad,MVF,params);
% % % % % figure;imshow(mat2gray(im_interpL));
% % % % % PSNR = Psnr(im_originalL,im_interpL);
% % % %     temp = Psnr(im_originalL,im_interpL);
% % % %     PSNR = [PSNR,temp];
% % % % % xlabel(['The Left Interpolated ' ,num2str(ii-1), ' Frame, PSNR = ',num2str(temp),' dB']);
% % % % 
% % % % MVF = motionEstESjgwallc4(im_prev,im_next,mbSize,p);
% % % % % % MVF = FME(im_interp_pad,im_next_pad,params);
% % % % % MVF = median_smoothMVF(MVF);
% % % %   MVF = BiMErefine(im_prev_pad,im_next_pad,MVF,2,params);
% % % % MVF = WM_smoothMVF(im_prev_pad,im_next_pad,MVF,params);
% % % % im_interpR = MCIR(im_interp_pad,im_next_pad,MVF,params);
% % % % % figure;imshow(mat2gray(im_interpR));
% % % % % PSNR = Psnr(im_originalR,im_interpR);
% % % % temp = Psnr(im_originalR,im_interpR);
% % % %     PSNR = [PSNR,temp];
% % % % % xlabel(['The Right Interpolated ',num2str(ii+1), ' Frame, PSNR = ',num2str(temp),' dB']);

end
toc
PSNR
%Compute average PSNR
PSNR_avg = mean(PSNR);
% time_avg = time/50;
disp(['The Avg PSNR = ',num2str(PSNR_avg),' dB']);
% disp(['The Avg TIME = ',num2str(time_avg),' s']);


    
    


