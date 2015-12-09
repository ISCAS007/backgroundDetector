## Copyright (C) 2015 yzbx
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## bgs_seven

## Author: yzbx <yzbx@PC--20140424WEG>
## Created: 2015-11-26

function bgs_seven()
frameNum=6900;
model={};
% model is background 
% 0,50=background, 170,255=foreground, 85=out roi
input0=getInput(frameNum-1);
[height,width,channel]=size(input0);
seven=zeros(height,width,channel+4);
for i=1:30
	disp(['frameNum=',num2str(frameNum)]);
	input=getInput(frameNum);
	foreground=getForeground(frameNum);
	% subplot(2,2,1),imshow(input);
	% subplot(2,2,2),imshow(foreground);
	% subplot(2,2,3),imshow(foreground==0);
	
	% title(num2str(frameNum,'%06d'));
	% unique(foreground)
	% sleep(1);
	
	frameNum=frameNum+1;
	[vx,vy]=getVxVy(input0,input);
	input0=input;
	gray=rgb2gray(input);
	[dx,dy]=getDxDy(gray);
	seven(:,:,1:channel)=input;
	% set dx=rgb2gray(input), then use matlab's gradientxy()
	seven(:,:,channel+1)=dx;
	% seven(:,:,channel+2)=dy;
	seven(:,:,channel+3)=vx;
	seven(:,:,channel+4)=vy;
	model{i}=seven;
end

train={};
label={};

frameNum=7000;
input0=getInput(frameNum-1);
for i=1:30
	disp(['frameNum=',num2str(frameNum)]);
	input=getInput(frameNum);
	foreground=getForeground(frameNum);
	
	% subplot(2,2,1),imshow(input);
	% subplot(2,2,2),imshow(foreground);
	% subplot(2,2,3),imshow(foreground==0);
	% title(num2str(frameNum,'%06d'));
	% sleep(1);
	
	frameNum=frameNum+1;
	[vx,vy]=getVxVy(input0,input);
	input0=input;
	gray=rgb2gray(input);
	[dx,dy]=getDxDy(gray);
	seven(:,:,1:channel)=input;
	% set dx=rgb2gray(input), then use matlab's gradientxy()
	seven(:,:,channel+1)=dx;
	% seven(:,:,channel+2)=dy;
	seven(:,:,channel+3)=vx;
	seven(:,:,channel+4)=vy;
	
	train{i}=seven;
	label{i}=foreground;
end

save -mat-binary bgs_seven_octave.mat model train label;

end

function input=getInput(frameNum)
	root='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\boats\input';
	strnum=num2str(frameNum,'%06d');
	input=imread([root,'\in',strnum,'.jpg']);
end

function foreground=getForeground(frameNum)
	root='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\boats\groundtruth';
	strnum=num2str(frameNum,'%06d');
	foreground=imread([root,'\gt',strnum,'.png']);
end

function [ux,uy]=getVxVy(input0,input)
	im1=double(rgb2gray(input0))/256.0;
	im2=double(rgb2gray(input))/256.0;
	winSize = 21;
	% load vars1.mat
	[ux, uy, l1, l2] = LucasKanade(im1, im2, winSize);
	% close;
	% subplot(2, 2, 1);
	% imshow(ux);
	% subplot(2, 2, 2);
	% imshow(uy);
	% subplot(2, 2, 3);
	% imshow(l1);
	% subplot(2, 2, 4);
	% imshow(l2);
	% save vars2.mat im1 im2 ux uy l1 l2;
end

function [dx,dy]=getDxDy(gray)
% use matlab gradientxy to compute dx,dy
	dx=gray;
	dy=gray;
end