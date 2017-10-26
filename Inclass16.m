% Inclass16

%The folder in this repository contains code implementing a Tracking
%algorithm to match cells (or anything else) between successive frames. 
% It is an implemenation of the algorithm described in this paper: 
%
% Sbalzarini IF, Koumoutsakos P (2005) Feature point tracking and trajectory analysis 
% for video imaging in cell biology. J Struct Biol 151:182?195.
%
%The main function for the code is called MatchFrames.m and it takes three
%arguments: 
% 1. A cell array of data called peaks. Each entry of peaks is data for a
% different time point. Each row in this data should be a different object
% (i.e. a cell) and the columns should be x-coordinate, y-coordinate,
% object area, tracking index, fluorescence intensities (could be multiple
% columns). The tracking index can be initialized to -1 in every row. It will
% be filled in by MatchFrames so that its value gives the row where the
% data on the same cell can be found in the next frame. 
%2. a frame number (frame). The function will fill in the 4th column of the
% array in peaks{frame-1} with the row number of the corresponding cell in
% peaks{frame} as described above.
%3. A single parameter for the matching (L). In the current implementation of the algorithm, 
% the meaning of this parameter is that objects further than L pixels apart will never be matched. 

% Continue working with the nfkb movie you worked with in hw4. 

% Part 1. Use the first 2 frames of the movie. Segment them any way you
% like and fill the peaks cell array as described above so that each of the two cells 
% has 6 column matrix with x,y,area,-1,chan1 intensity, chan 2 intensity

reader = bfGetReader('nfkb_movie1.tif');
z = 1; c = 1; t = 1;
ind = reader.getIndex(z-1, c-1, t-1) + 1;
img_t1 = bfGetPlane(reader, ind);
ind = reader.getIndex(z-1, c-1, t)+1;
img_t2 = bfGetPlane(reader, ind);

lims = [100 2000];
figure;
subplot(1, 2, 1); imshow(img_t1,lims);
subplot(1, 2, 2); imshow(img_t2,lims);

figure; imshowpair(imadjust(img_t1), imadjust(img_t2));

mask_t1 = img_t1 > 800; mask_t2 = img_t2 > 800; imshowpair(mask_t1, mask_t2);

stats_t1 = regionprops(mask_t1, img_t1, 'Centroid', 'Area', 'MeanIntensity');
stats_t2 = regionprops(mask_t2, img_t2, 'Centroid', 'Area', 'MeanIntensity');

xy1 = cat(1, stats_t1.Centroid);
a1 = cat(1, stats_t1.Area);
mi1 = cat(1, stats_t1.MeanIntensity);
tmp = -1*ones(size(a1));
peaks{1} = [xy1, a1, -1, tmp, mi1];

xy2 = cat(1, stats_t2.Centroid);
a2 = cat(1, stats_t2.Area);
mi2 = cat(1, stats_t2.MeanIntensity);
tmp = -1*ones(size(a2));
peaks{2} = [xy2, a2, -1, tmp, mi2];

% Part 2. Run match frames on this peaks array. ensure that it has filled
% the entries in peaks as described above. 

peaks_matched = MatchFrames(peaks, 1, 50);

% Part 3. Display the image from the second frame. For each cell that was
% matched, plot its position in frame 2 with a blue square, its position in
% frame 1 with a red star, and connect these two with a green line. 

figure; imshow(img_t2, lims); hold on;
plot(peaks{1}(:,1),peaks{1}(:,2), 'r*', 'MarkerSize',5)
plot(peaks{2}(:,1),peaks{2}(:,2), 'cs', 'MarkerSize',5)