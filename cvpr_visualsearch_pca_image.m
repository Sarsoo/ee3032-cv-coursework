%% EEE3032 - Computer Vision and Pattern Recognition (ee3.cvpr)
%%
%% cvpr_visualsearch.m
%% Skeleton code provided as part of the coursework assessment
%%
%% This code will load in all descriptors pre-computed (by the
%% function cvpr_computedescriptors) from the images in the MSRCv2 dataset.
%%
%% It will pick a descriptor at random and compare all other descriptors to
%% it - by calling cvpr_compare.  In doing so it will rank the images by
%% similarity to the randomly picked descriptor.  Note that initially the
%% function cvpr_compare returns a random number - you need to code it
%% so that it returns the Euclidean distance or some other distance metric
%% between the two descriptors it is passed.
%%
%% (c) John Collomosse 2010  (J.Collomosse@surrey.ac.uk)
%% Centre for Vision Speech and Signal Processing (CVSSP)
%% University of Surrey, United Kingdom

close all;
clear all;

%% Edit the following line to the folder you unzipped the MSRCv2 dataset to
DATASET_FOLDER = 'dataset';

%% Folder that holds the results...
DESCRIPTOR_FOLDER = 'descriptors';
%% and within that folder, another folder to hold the descriptors
%% we are interested in working with
% DESCRIPTOR_SUBFOLDER='avgRGB';
% DESCRIPTOR_SUBFOLDER='globalRGBhisto';
% DESCRIPTOR_SUBFOLDER='spatialColour';
% DESCRIPTOR_SUBFOLDER='spatialTexture';
DESCRIPTOR_SUBFOLDER='spatialColourTexture';

CATEGORIES = ["Farm Animal" 
    "Tree"
    "Building"
    "Plane"
    "Cow"
    "Face"
    "Car"
    "Bike"
    "Sheep"
    "Flower"
    "Sign"
    "Bird"
    "Book Shelf"
    "Bench"
    "Cat"
    "Dog"
    "Road"
    "Water Features"
    "Human Figures"
    "Coast"
    ];

QUERY_INDEXES=[301 358 384 436 447 476 509 537 572 5 61 80 97 127 179 181 217 266 276 333];

% 1_10 2_16 3_12 4_4 5_15 6_14 7_17 8_15 9_1 10_14 11_8 12_26 13_10 14_10
% 15_8 16_10 17_16 18_5 19_15 20_12


%% 1) Load all the descriptors into "ALLFEAT"
%% each row of ALLFEAT is a descriptor (is an image)

ALLFEAT=[];
ALLFILES=cell(1,0);
ALLCATs=[];
ctr=1;
allfiles=dir (fullfile([DATASET_FOLDER,'/Images/*.bmp']));
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    
    %identify photo category for PR calculation
    split_string = split(fname, '_');
    ALLCATs(filenum) = str2double(split_string(1));
    
    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);
    img=double(imread(imgfname_full))./255;
    thesefeat=[];
    featfile=[DESCRIPTOR_FOLDER,'/',DESCRIPTOR_SUBFOLDER,'/',fname(1:end-4),'.mat'];%replace .bmp with .mat
    load(featfile,'F');
    ALLFILES{ctr}=imgfname_full;
    ALLFEAT=[ALLFEAT ; F];
    ctr=ctr+1;
end

% get counts for each category for PR calculation
CAT_HIST = histogram(ALLCATs).Values;
CAT_TOTAL = length(CAT_HIST);

NIMG=size(ALLFEAT,1);           % number of images in collection



map=[];
deflate_energy = [0:0.001:0.3];
for var_iter=1:size(deflate_energy, 2)
    
descriptor_list = ALLFEAT;

confusion_matrix = zeros(CAT_TOTAL);

all_precision = [];
all_recall = [];

AP_values = zeros([1, CAT_TOTAL]);
for iteration=1:CAT_TOTAL
    
    %% 2) Pick an image at random to be the query
    queryimg=QUERY_INDEXES(iteration);    % index of a random image
    
    %% 3) Compute EigenModel
    E = getEigenModel(descriptor_list);
    E = deflateEigen(E, 1-deflate_energy(var_iter));
    
    %% 4) Project data to lower dimensionality
    descriptor_list=descriptor_list-repmat(E.org,size(descriptor_list,1),1);
    descriptor_list=((E.vct')*(descriptor_list'))';

    %% 3) Compute the distance of image to the query
    dst=[];
    for i=1:NIMG
        candidate=descriptor_list(i,:);
        query=descriptor_list(queryimg,:);

        category=ALLCATs(i);

        %% COMPARE FUNCTION
        thedst=compareMahalanobis(E, query, candidate);
        dst=[dst ; [thedst i category]];
    end
    dst=sortrows(dst,1);  % sort the results

    %% 4) Calculate PR
    precision_values=zeros([1, NIMG-1]);
    recall_values=zeros([1, NIMG-1]);

    correct_at_n=zeros([1, NIMG-1]);

    query_row = dst(1,:);
    query_category = query_row(1,3);
%     if query_category ~= iteration
%         dst
%     end
    fprintf('category was %s\n', CATEGORIES(query_category))
    
    dst = dst(2:NIMG, :);
    
    %calculate PR for each n
    for i=1:size(dst, 1)
        % NIMG-1 and j iterator variable is in order to skip calculating for query image
        
        rows = dst(1:i, :);

        correct_results = 0;
        incorrect_results = 0;

        if i > 1    
            for n=1:i - 1
                row = rows(n, :);
                category = row(3);

                if category == iteration
                    correct_results = correct_results + 1;
                else
                    incorrect_results = incorrect_results + 1;
                end

            end
        end

        % LAST ROW
        row = rows(i, :);
        category = row(3);

        if category == iteration
            correct_results = correct_results + 1;
            correct_at_n(i) = 1;
        else
            incorrect_results = incorrect_results + 1;
        end

        precision = correct_results / i;
        recall = correct_results / (CAT_HIST(1,iteration) - 1);

        precision_values(i) = precision;
        recall_values(i) = recall;
    end


    %% 5) calculate AP
    average_precision = sum(precision_values .* correct_at_n) / CAT_HIST(1,iteration);
    AP_values(iteration) = average_precision;
    
 
    all_precision = [all_precision ; precision_values];
    all_recall = [all_recall ; recall_values];
    

    %% 6) plot PR curve
%     figure(1)
%     plot(recall_values, precision_values,'LineWidth',1.5);
%     hold on;
%     title('PR Curve');
%     xlabel('Recall');
%     ylabel('Precision');
%     xlim([0 1]);
%     ylim([0 1]);
    
    
    %% 7) Visualise the results
    %% These may be a little hard to see using imgshow
    %% If you have access, try using imshow(outdisplay) or imagesc(outdisplay)
    
%     SHOW=25; % Show top 25 results
%     dst=dst(1:SHOW,:);
%     outdisplay=[];
%     for i=1:size(dst,1)
%        img=imread(ALLFILES{dst(i,2)});
%        img=img(1:2:end,1:2:end,:); % make image a quarter size
%        img=img(1:81,:,:); % crop image to uniform size vertically (some MSVC images are different heights)
%        outdisplay=[outdisplay img];
%        
%        %populate confusion matrix
%        confusion_matrix(query_category, dst(i,3)) = confusion_matrix(query_category, dst(i,3)) + 1;
%     end
%     figure(3)
%     imgshow(outdisplay);
%     axis off;

end

%% Plot average PR curve
% figure(4)
% mean_precision = mean(all_precision);
% mean_recall = mean(all_recall);
% plot(mean_recall, mean_precision,'LineWidth',5);
% title('PR Curve');
% xlabel('Average Recall');
% ylabel('Average Precision');
% xlim([0 1]);
% ylim([0 1]);

% normalise confusion matrix
% norm_confusion_matrix = confusion_matrix ./ sum(confusion_matrix, 'all');

%% 8 Calculate MAP
% figure(4)
% histogram(AP_values);
% title('Average Precision Distribution');
% ylabel('Count');
% xlabel('Average Precision');
% xlim([0, 1]);

MAP = mean(AP_values)
% AP_sd = std(AP_values);

% figure(2)
% plot(1:CAT_TOTAL, AP_values);
% title('Average Precision Per Run');
% xlabel('Run');
% ylabel('Average Precision');

map(var_iter) = MAP;

end
