function return_index=getRandomCategoryImage(category)

if category > 20
    error('number greater than category count');
end

DATASET_FOLDER = 'dataset';

allfiles=dir (fullfile([DATASET_FOLDER,'/Images/*.bmp']));
number_of_images = length(allfiles);

ALLCATs=zeros([1 number_of_images]);
for filenum=1:number_of_images
    fname=allfiles(filenum).name;
    
    split_string = split(fname, '_');
    ALLCATs(filenum) = str2double(split_string(1));
end

return_index = 0;
while return_index == 0
    index = floor(rand() * number_of_images);
    if index == 0
        index = 1;
    end
    
    if ALLCATs(index) == category
        return_index = index;
    end
end

return;