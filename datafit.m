function datafit(filename)
% load data from the .mat file extracted by function dataExtract
% run algrithm to fit the data
data=load(filename);
rgb=data.rgb;
class=data.class;

