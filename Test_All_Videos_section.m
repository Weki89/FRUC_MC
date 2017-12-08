%test_video.m
clear;clc;close all;
addpath('D:\fruc\code\paper and code2\Codes\Codes\Videos');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Analysis');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Compensation');
addpath('D:\fruc\code\paper and code2\Codes\Codes\Motion Estimation');

% yuvfilename = 'highway_cif.yuv';
yuvfilename = 'waterfall_cif.yuv';
% yuvfilename = 'news_cif.yuv';
% yuvfilename = 'foreman_cif_30fps.yuv';
% yuvfilename = 'silent_cif.yuv';
% yuvfilename = 'container_cif.yuv';
format = 'cif';
%ok for +++> 9,18,29,93,253,161=120, 281-210
%Not ok for +++> 28,92,152
init2last = [1,241];
Y = ReadMultiFrames(yuvfilename,format,init2last);
%Params setting
[im_rows,im_cols] = size(Y(:,:,1));
params.block_size = 8;
params.search_range = 16;
params.step_size = 1;
params.im_rows = im_rows;
params.im_cols = im_cols;

%Interpolation Frame
PSNR1 = [];
PSNR2 = [];
PSNR3 = [];
S_SIM1 = [];
S_SIM2 = [];
S_SIM3 = [];
tic
x= 0
for ii = 3:4:size(Y,3)
    x=x+1;
    disp(['The ',num2str(ii),'-th Frame.']);
    im_prev = Y(:,:,ii-2);
    im_org = Y(:,:,ii);
    im_next = Y(:,:,ii+2);
    im_prev_pad = padarray(im_prev,params.search_range*[1,1],'replicate');
    im_next_pad = padarray(im_next,params.search_range*[1,1],'replicate');
    mbSize=8;p=7;
%     MVF = motionEstESjgwallccc4(im_prev,im_next,mbSize,p);
    %--------------------Bi-directional Motion Estimation------------------
%     MVF = FME(im_prev_pad,im_next_pad,params);
     MVF = motionEstES(im_next,im_prev,mbSize,p)
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
     tempS1 = ssim(Y(:,:,ii),im_interp);
 S_SIM1 =   [S_SIM1,tempS1];
    temp1 = Psnr(Y(:,:,ii),im_interp);
    PSNR1 = [PSNR1,temp1];
% %     Y(:,:,ii) = im_interp;
% PSNR = Psnr(im_org,im_interp);
% figure;imshow(mat2gray(im_interp));xlabel(['The ',num2str(ii),'-th Interpolated Frame, PSNR = ',num2str(temp),' dB']);
% time = toc;
im_originalL = Y(:,:,ii-1);
im_originalR = Y(:,:,ii+1);
im_interp_pad = padarray(im_interp,params.search_range*[1,1],'replicate');
% size(im_prev_pad)
% size(im_interp)
% size(im_interp_pad)
x=x+1;
 disp(['The ',num2str(ii-1),'-th Frame.']);
% % % % % % 
mbSize=8;p=7;
MVF = motionEstESjgwallccc4(im_prev,im_interp,mbSize,p);
% MVF = FME(im_prev_pad,im_interp_pad,params);
% MVF = median_smoothMVF(MVF);
MVF = WM_smoothMVF(im_prev_pad,im_interp_pad,MVF,params);
im_interpL = OBMC_8JL(im_prev_pad,im_next_pad,MVF,0.25,params);
% im_interpL = MCIL(im_prev_pad,im_interp_pad,MVF,params);
% figure;imshow(mat2gray(im_interpL));
% PSNR = Psnr(im_originalL,im_interpL);
    temp2 = Psnr(im_originalL,im_interpL);
    PSNR2 = [PSNR2,temp2];
    tempS2 = ssim(im_originalL,im_interpL);
 S_SIM2 =   [S_SIM2,tempS2];
% xlabel(['The Left Interpolated ' ,num2str(ii-1), ' Frame, PSNR = ',num2str(temp),' dB']);
 disp(['The ',num2str(ii+1),'-th Frame.']);
%%%%
x=x+1;
MVF = motionEstESjgwallccc4(im_interp,im_next,mbSize,p);
% MVF = FME(im_interp_pad,im_next_pad,params);
% MVF = median_smoothMVF(MVF);
MVF = WM_smoothMVF(im_prev_pad,im_next_pad,MVF,params);
im_interpR = OBMC_8JR(im_prev_pad,im_next_pad,MVF,0.25,params);
% im_interpR = MCIR(im_interp_pad,im_next_pad,MVF,params);
% figure;imshow(mat2gray(im_interpR));
% PSNR = Psnr(im_originalR,im_interpR);
  tempS3 = ssim(im_originalR,im_interpR);
 S_SIM3 =   [S_SIM3,tempS3];
temp3 = Psnr(im_originalR,im_interpR);
    PSNR3 = [PSNR3,temp3];
% xlabel(['The Right Interpolated ',num2str(ii+1), ' Frame, PSNR = ',num2str(temp),' dB']);

end
toc
% PSNR1
% PSNR2
% PSNR3
%Compute average PSNR
PSNR_avg = mean(PSNR1);
PSNR_avgL = mean(PSNR2);
PSNR_avgR = mean(PSNR3);
SSIM_avg = mean(S_SIM1);
SSIM_avgL = mean(S_SIM2);
SSIM_avgR = mean(S_SIM3);
% time_avg = time/50;
disp(['The Avg PSNR_M = ',num2str(PSNR_avg),' dB']);
disp(['The Avg PSNR_L = ',num2str(PSNR_avgL),' dB']);
disp(['The Avg PSNR_R = ',num2str(PSNR_avgR),' dB']);
disp(['The Avg SSIM_M = ',num2str(SSIM_avg)]);
disp(['The Avg SSIM_L = ',num2str(SSIM_avgL)]);
disp(['The Avg SSIM_R = ',num2str(SSIM_avgR)]);
% disp(['The Avg TIME = ',num2str(time_avg),' s']);

x
    
    


