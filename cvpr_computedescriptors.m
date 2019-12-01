%% EEE3032 - Computer Vision and Pattern Recognition (ee3.cvpr)
%%
%% cvpr_computedescriptors.m
%% Skeleton code provided as part of the coursework assessment
%% This code will iterate through every image in the MSRCv2 dataset
%% and call a function 'extractRandom' to extract a descriptor from the
%% image.  Currently that function returns just a random vector so should
%% be changed as part of the coursework exercise.
%%
%% (c) John Collomosse 2010  (J.Collomosse@surrey.ac.uk)
%% Centre for Vision Speech and Signal Processing (CVSSP)
%% University of Surrey, United Kingdom

close all;
clear all;

%% Edit the following line to the folder you unzipped the MSRCv2 dataset to
DATASET_FOLDER = 'dataset';

%% Create a folder to hold the results...
OUT_FOLDER = 'descriptors';
%% and within that folder, create another folder to hold these descriptors
%% the idea is all your descriptors are in individual folders - within
%% the folder specified as 'OUT_FOLDER'.
% OUT_SUBFOLDER='avgRGB';
OUT_SUBFOLDER='globalRGBhisto';
% OUT_SUBFOLDER='spatialColour';
% DESCRIPTOR_SUBFOLDER='spatialTexture';
% OUT_SUBFOLDER='spatialColourTexture';

allfiles=dir (fullfile([DATASET_FOLDER,'/Images/*.bmp']));
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    fprintf('Processing file %d/%d - %s\n',filenum,length(allfiles),fname);
    tic;
    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
    img=double(imread(imgfname_full))./255;
    fout=[OUT_FOLDER,'/',OUT_SUBFOLDER,'/',fname(1:end-4),'.mat'];%replace .bmp with .mat
    
    %% EXTRACT FUNCTION
%     F=extractAvgRGB(img);
    F=extractGlobalColHist(img, 2, 1, 8, 0.05);
%     F=extractSpatialColour(img, 2, 1);
%     F=extractSpatialTexture(img, 2, 1, 8, 0.05);
%     F=extractSpatialColourTexture(img);
    save(fout,'F');
    toc
end
