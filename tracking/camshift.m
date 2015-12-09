% Adam Kukucka
% Zach Clay
% Marcelo Molina    
% CSE 486 Project 3

function [ trackmov probmov centers ] = camshift 

% ******************************************************************
% initialize vari   ables
% ******************************************************************

rmin = 0; %min row value for search window
rmax = 0; %max row value for search window
cmin = 0; %min col value for search window
cmax = 0; %max col value for search window
numofframes = 0; %number of frames in the avi
threshold = 1; %threshold for convergence
centerold = [0 0]; %for convergence... previous center of window
centernew = [0 0]; %for convergence... new center of window

% ******************************************************************
% Pre code... load movie and select initial frame
% ******************************************************************

% prompt user for avi file name
user_entry = input('Please enter an avi filename: ','s');
% load the avi file... handle is M 
% M = aviread(user_entry);
M=videoReader(user_entry);

% get number of frames
[dontneed numberofframes] = size(M);

% initialize matrix to hold center coordinates
imagecenters = zeros(numberofframes, 2);

% extract the first frame from the avi
Frame1 = M(1,1);
Image1 = frame2im(Frame1);

%%% ********** images(:, :, numberofframes) = G(:,:);

% get search window for first frame
[ cmin, cmax, rmin, rmax ] = select( Image1 );
cmin = round(cmin);
cmax = round(cmax);
rmin = round(rmin);
rmax = round(rmax);
wsize(1) = abs(rmax - rmin);
wsize(2) = abs(cmax - cmin);

% create histogram
% translate to hsv
hsvimage = rgb2hsv(Image1);
% pull out the h
huenorm = hsvimage(:,:,1);

% scale to 0 to 255
hue = huenorm*255;
% set unit type
hue=uint8(hue);

% Getting Histogram of Image:
histogram = zeros(256);

for i=rmin:rmax
    for j=cmin:cmax
        index = uint8(hue(i,j)+1);   
        %count number of each pixel
        histogram(index) = histogram(index) + 1;
    end
end

% ******************************************************************
% Algorithm from pdf
% ******************************************************************
aviobj1 = videoWriter('example3.avi');
aviobj2 = videoWriter('example4.avi');
open(aviobj1);
open(aviobj2);
% for each frame
for i = 1:200
    disp('Processing frame');
    disp(i);
    Frame = M(1, i);
    I = frame2im(Frame);
    
    % translate to hsv
    hsvimage = rgb2hsv(I);
    % pull out the h
    huenorm = hsvimage(:,:,1);

    % scale to 0 to 255
    hue = huenorm*255;
    % set unit type
    hue=uint8(hue);
    
    
    
    [rows cols] = size(hue);
    
    % choose initial search window
    % the search window is (cmin, rmin) to (cmax, rmax)

    
    
    % create a probability map
    probmap = zeros(rows, cols);
    for r=1:rows
        for c=1:cols
            if(hue(r,c) ~= 0)
                probmap(r,c)= histogram(hue(r,c));   
            end
        end  
    end
    probmap = probmap/max(max(probmap));
    probmap = probmap*255;
    
    count = 0;
    
    rowcenter = 0;  % any number just so it runs through at least twice
    colcenter = 0;
    rowcenterold = 30;
    colcenterold = 30;
    % Mean Shift for 15 iterations or until convergence(the center doesnt
    % change)
    while (((abs(rowcenter - rowcenterold) > 2) && (abs(colcenter - colcenterold) > 2)) || (count < 15) )
    %for j = 1:5
        %disp('meanshift');
       % disp(j);
        rmin = rmin - 7;  %increase window size and check for center
        rmax = rmax + 7;
        cmin = cmin - 7;
        cmax = cmax + 7;
        
        rowcenterold = rowcenter; %save old center for convergence check
        colcenterold = colcenter;
        
        [ rowcenter colcenter M00 ] = meanshift(I, rmin, rmax, cmin,...
            cmax, probmap);
        % given image (I), search window(rmin rmax cmin cmax)
        % returns new center (colcenter, rowcenter) for window and 
        % zeroth moment (Moo)
        
        % redetermine window around new center
        rmin = round(rowcenter - wsize(1)/2);
        rmax = round(rowcenter + wsize(1)/2);
        cmin = round(colcenter - wsize(2)/2);
        cmax = round(colcenter + wsize(2)/2);
        wsize(1) = abs(rmax - rmin);
        wsize(2) = abs(cmax - cmin);
        
        count = count + 1;
    end
    
    % mark center on image    
    
    %save image
    G = .2989*I(:,:,1)...
    +.5870*I(:,:,2)...
    +.1140*I(:,:,3);
    trackim=G;
    
    %make box of current search window on saved image
    for r= rmin:rmax
        trackim(r, cmin) = 255;
        trackim(r, cmax) = 255;
    end
    for c= cmin:cmax
        trackim(rmin, c) = 255;
        trackim(rmax, c) = 255;
    end
%    aviobj1 = addframe(aviobj1,trackim);
%      aviobj2 = addframe(aviobj2,probmap);
writeVideo(aviobj1,trackim);
writeVideo(aviobj2.probmap);
%     count_yzbx=count_yzbx+1;
%     imwrite(trackim,['\output\trackim',num2str(count_yzbx)],'jpg');
%     imwrite(trackim,['\output\probmap',num2str(count_yzbx)],'jpg');
%    
    %create image movie, and probability map movie
    trackmov(:,:,i)= trackim(:,:);
    probmov(:,:,i) = probmap(:,:);
    
    
    % save center coordinates as an x, y by doing col, row
    centers(i,:) = [colcenter rowcenter];
    % Set window size = 2 * (Moo/256)^1/2
    windowsize = 2 * (M00/256)^.5;
    
    % get side length ... window size is an area so sqrt(Area)=sidelength
    sidelength = sqrt(windowsize);
    
    % determine rmin, rmax, cmin, cmax    
    rmin = round(rowcenter-sidelength/2);
    rmax = round(rowcenter+sidelength/2);
    cmin = round(colcenter-sidelength/2);
    cmax = round(colcenter+sidelength/2);
    wsize(1) = abs(rmax - rmin);
    wsize(2) = abs(cmax - cmin);
end
% end for loop
 