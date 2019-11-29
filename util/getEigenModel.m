function [eig_vct, eig_val, model_mean]=getEigenModel(model_descriptors)

model_size = size(model_descriptors, 1);

model_mean = mean(model_descriptors);
model_data_min_mean = model_descriptors - repmat(model_mean, model_size, 1);

C = (model_data_min_mean' * model_data_min_mean) ./ model_size;

[eig_vct, eig_val] = eig(C);

return;