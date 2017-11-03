Path = 'F:/Data/data20171101/img_calib/';
%posDir = './database/positive/';
posDir = './database/negative/';

path_list = dir(strcat(Path, '*.bmp'));

list_length = length(path_list);

for i = 1:list_length
    imName = path_list(i).name;
    image = imread(strcat(Path,imName));
    [pathSrc, name, ext] = fileparts(path_list(i).name);
    %r = cat(3,image,image,image); % for gray
    r = image; % for color
    imwrite(r, [posDir name '.jpg']);
end
