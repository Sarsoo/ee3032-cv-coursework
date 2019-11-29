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
DESCRIPTOR_SUBFOLDER='avgRGB';
% DESCRIPTOR_SUBFOLDER='globalRGBhisto';
% DESCRIPTOR_SUBFOLDER='spatialColour';
% DESCRIPTOR_SUBFOLDER='spatialColourTexture';

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
MODEL_SIZE = 10;

confusion_matrix = zeros(CAT_TOTAL);

AP_values = zeros([1, CAT_TOTAL]);
for iterating_category=1:CAT_TOTAL
    
    %% 2) Select descriptors for category and training data
    category_training_descriptors = [];
    test_descriptors = [];
    for i=1:NIMG
        if iterating_category == ALLCATs(i)
            category_training_descriptors = [ category_training_descriptors ; ALLFEAT(i,:) ];
        else
            test_descriptors = [ test_descriptors ; ALLFEAT(i,:) ];
        end
    end
    
    model_descriptors = category_training_descriptors(1:MODEL_SIZE, :);
    
    model_mean = mean(model_descriptors);
    model_data_min_mean = model_descriptors - repmat(model_mean, MODEL_SIZE, 1);

    C = (model_data_min_mean' * model_data_min_mean) ./ MODEL_SIZE;
    
    [eig_vct, eig_val] = eig(C);
    
    
    TEST_SIZE = size(test_descriptors,1);
    
    %% 3) Compute the distance of image to the query
    dst=[];
    for i=1:TEST_SIZE
        candidate=test_descriptors(i,:);
        query=ALLFEAT(queryimg,:);

        category=ALLCATs(i);

        %% COMPARE FUNCTION
        thedst=compareEuclidean(query, candidate);
        dst=[dst ; [thedst i category]];
    end
    dst=sortrows(dst,1);  % sort the results

    %% 4) Calculate PR
    precision_values=zeros([1, NIMG]);
    recall_values=zeros([1, NIMG]);

    correct_at_n=zeros([1, NIMG]);

    query_row = dst(1,:);
    query_category = query_row(1,3);
    fprintf('category was %s, %i, %i\n', CATEGORIES(query_category), query_category, iterating_category)
    
    
    %calculate PR for each n
    for i=1:NIMG

        rows = dst(1:i, :);

        correct_results = 0;
        incorrect_results = 0;

        if i > 1    
            for n=1:i - 1
                row = rows(n, :);
                category = row(3);

                if category == query_category
                    correct_results = correct_results + 1;
                else
                    incorrect_results = incorrect_results + 1;
                end

            end
        end

        % LAST ROW
        row = rows(i, :);
        category = row(3);

        if category == query_category
            correct_results = correct_results + 1;
            correct_at_n(i) = 1;
        else
            incorrect_results = incorrect_results + 1;
        end

        precision = correct_results / i;
        recall = correct_results / CAT_HIST(1,query_category);

        precision_values(i) = precision;
        recall_values(i) = recall;
    end


    %% 5) calculate AP
    P_rel_n = zeros([1, NIMG]);
    for i = 1:NIMG
        precision = precision_values(i);
        i_result_relevant = correct_at_n(i);

        P_rel_n(i) = precision * i_result_relevant;
    end

    sum_P_rel_n = sum(P_rel_n);
    average_precision = sum_P_rel_n / CAT_HIST(1,query_category);
    
    AP_values(iterating_category) = average_precision;
    


    %% 6) plot PR curve
    figure(1)
    plot(recall_values, precision_values);
    hold on;
    title('PR Curve');
    xlabel('Recall');
    ylabel('Precision');
    
    
    %% 7) Visualise the results
    %% These may be a little hard to see using imgshow
    %% If you have access, try using imshow(outdisplay) or imagesc(outdisplay)
    
    SHOW=20; % Show top 15 results
    dst=dst(1:SHOW,:);
    outdisplay=[];
    for i=1:size(dst,1)
       img=imread(ALLFILES{dst(i,2)});
       img=img(1:2:end,1:2:end,:); % make image a quarter size
       img=img(1:81,:,:); % crop image to uniform size vertically (some MSVC images are different heights)
       outdisplay=[outdisplay img];
       
       %populate confusion matrix
       confusion_matrix(query_category, dst(i,3)) = confusion_matrix(query_category, dst(i,3)) + 1;
    end
%     figure(3)
%     imgshow(outdisplay);
%     axis off;

end

% normalise confusion matrix
norm_confusion_matrix = confusion_matrix ./ sum(confusion_matrix, 'all');

%% 8 Calculate MAP
% figure(4)
% histogram(AP_values);
% title('Average Precision Distribution');
% ylabel('Count');
% xlabel('Average Precision');
% xlim([0, 1]);

MAP = mean(AP_values)
AP_sd = std(AP_values)

% figure(2)
% plot(1:CAT_TOTAL, AP_values);
% title('Average Precision Per Run');
% xlabel('Run');
% ylabel('Average Precision');
