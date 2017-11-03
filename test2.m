%I=imread('database/positive/10405146_1.jpg'); tic, [data, bbs]=acfDetect(I,detector); toc
%bbs=bbs(1:length(bbs(:,5)>40),:);
%figure(1); im(I); bbApply('draw',bbs); pause(.1);

posDir = './database/positive/';
path_list = dir(strcat(posDir, '*.jpg'));
list_length = length(path_list);

for i = 1:list_length
    imName = path_list(i).name;
    I = imread(strcat(posDir,imName));
    tic, [data, bbs]=acfDetect(I,detector); toc
    bbs_max = bbs(1,:);
    figure(1), im(I), bbApply('draw',bbs_max);
    pause(2);
end