function multiObjectTracking_yzbx(path)

% create system objects used for reading video, detecting moving objects,
% and displaying the results
% path='D:\firefoxDownload\matlab\dataset2012\dataset\baseline\PETS2006';
% path='D:\firefoxDownload\matlab\dataset2012\dataset\dynamicBackground\fall';
% path='D:\firefoxDownload\matlab\dataset2012\dataset\shadow\backdoor';
path='D:\firefoxDownload\matlab\dataset2012\dataset\intermittentObjectMotion\sofa';
obj = setupSystemObjects();

tracks = initializeTracks(); % create an empty array of tracks
roiframeNum=load([path,'\temporalROI.txt']);
roiframeNum=[1,360];
nextId = 1; % ID of the next track
frameNum=0;
layer=[];

h=figure;
frame=readFrame();
[a,b,c]=size(frame);
frameNum=0;
% detect moving objects, and track them across video frames
while frameNum+roiframeNum(1)<=roiframeNum(2)
    frame = readFrame();
    [centroids, bboxes, mask] = detectObjects(frame);
    predictNewLocationsOfTracks();
    [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment();

    updateAssignedTracks();
    updateUnassignedTracks();
    deleteLostTracks();
    createNewTracks();

    displayTrackingResults();
end
frameNum

%% Create System Objects
% Create System objects used for reading the video frames, detecting
% foreground objects, and displaying results.

    function obj = setupSystemObjects()
        % Initialize Video I/O
        % Create objects for reading a video from a file, drawing the tracked
        % objects in each frame, and playing the video.

        % create a video file reader
%         obj.reader = vision.VideoFileReader('atrium.avi');
        pathlist=dir([path,'\input']);
        obj.reader={pathlist.name};

        % create two video players, one to display the video,
        % and one to display the foreground mask
        obj.videoPlayer = vision.VideoPlayer('Position', [20, 200, 700, 400]);
        obj.maskPlayer = vision.VideoPlayer('Position', [740, 200, 700, 400]);

        % Create system objects for foreground detection and blob analysis

        % The foreground detector is used to segment moving objects from
        % the background. It outputs a binary mask, where the pixel value
        % of 1 corresponds to the foreground and the value of 0 corresponds
        % to the background.

        obj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);

        % Connected groups of foreground pixels are likely to correspond to moving
        % objects.  The blob analysis system object is used to find such groups
        % (called 'blobs' or 'connected components'), and compute their
        % characteristics, such as area, centroid, and the bounding box.

        obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 400);
    end


    function tracks = initializeTracks()
        % create an empty array of tracks
        tracks = struct(...
            'id', {}, ...
            'bbox', {}, ...
            'kalmanFilter', {}, ...
            'age', {}, ...
            'totalVisibleCount', {}, ...
            'consecutiveInvisibleCount', {});
    end

%% Read a Video Frame
% Read the next video frame from the video file.
    function frame = readFrame()
%         frame = obj.reader.step();
        k=frameNum+roiframeNum(1)+2;
        frameNum=frameNum+1;
        frame=imread([path,'\input\',obj.reader{k}]);
    end

%% Detect Objects

    function [centroids, bboxes, mask] = detectObjects(frame)

        if(frameNum==1)
%           layer=layerInit(frame);
%           mask=false(a,b);
            [layer,mask]=mixtureSubstraction(layer,frame);
        else
%           [layer,mask]=layerStep(layer,frame);
            [layer,mask]=mixtureSubstraction(layer,frame);
        end

        % detect foreground
        % mask = obj.detector.step(frame);

        % apply morphological operations to remove noise and fill in holes
        mask = imopen(mask, strel('rectangle', [3,3]));
        mask = imclose(mask, strel('rectangle', [15, 15]));
        mask = imfill(mask, 'holes');

        % perform blob analysis to find connected components
        [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
    end

%% Predict New Locations of Existing Tracks
% Use the Kalman filter to predict the centroid of each track in the
% current frame, and update its bounding box accordingly.

    function predictNewLocationsOfTracks()
        for i = 1:length(tracks)
            bbox = tracks(i).bbox;

            % predict the current location of the track
            predictedCentroid = predict(tracks(i).kalmanFilter);

            % shift the bounding box so that its center is at
            % the predicted location
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
    end

    function [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment()

        nTracks = length(tracks);
        nDetections = size(centroids, 1);

        % compute the cost of assigning each detection to each track
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        end

        % solve the assignment problem
        costOfNonAssignment = 20;
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end

%% Update Assigned Tracks

    function updateAssignedTracks()
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            trackIdx = assignments(i, 1);
            detectionIdx = assignments(i, 2);
            centroid = centroids(detectionIdx, :);
            bbox = bboxes(detectionIdx, :);

            % correct the estimate of the object's location
            % using the new detection
            correct(tracks(trackIdx).kalmanFilter, centroid);

            % replace predicted bounding box with detected
            % bounding box
            tracks(trackIdx).bbox = bbox;

            % update track's age
            tracks(trackIdx).age = tracks(trackIdx).age + 1;

            % update visibility
            tracks(trackIdx).totalVisibleCount = ...
                tracks(trackIdx).totalVisibleCount + 1;
            tracks(trackIdx).consecutiveInvisibleCount = 0;
        end
    end

%% Update Unassigned Tracks
% Mark each unassigned track as invisible, and increase its age by 1.

    function updateUnassignedTracks()
        for i = 1:length(unassignedTracks)
            ind = unassignedTracks(i);
            tracks(ind).age = tracks(ind).age + 1;
            tracks(ind).consecutiveInvisibleCount = ...
                tracks(ind).consecutiveInvisibleCount + 1;
        end
    end

%% Delete Lost Tracks


    function deleteLostTracks()
        if isempty(tracks)
            return;
        end

        invisibleForTooLong = 10;
        ageThreshold = 8;

        % compute the fraction of the track's age for which it was visible
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;

        % find the indices of 'lost' tracks
        lostInds = (ages < ageThreshold & visibility < 0.6) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;

        % delete lost tracks
        tracks = tracks(~lostInds);
    end

%% Create New Tracks


    function createNewTracks()
        centroids = centroids(unassignedDetections, :);
        bboxes = bboxes(unassignedDetections, :);

        for i = 1:size(centroids, 1)

            centroid = centroids(i,:);
            bbox = bboxes(i, :);

            % create a Kalman filter object
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                centroid, [200, 50], [100, 25], 100);

            % create a new track
            newTrack = struct(...
                'id', nextId, ...
                'bbox', bbox, ...
                'kalmanFilter', kalmanFilter, ...
                'age', 1, ...
                'totalVisibleCount', 1, ...
                'consecutiveInvisibleCount', 0);

            % add it to the array of tracks
            tracks(end + 1) = newTrack;

            % increment the next id
            nextId = nextId + 1;
        end
    end

%% Display Tracking Results

    function displayTrackingResults()
        % convert the frame and the mask to uint8 RGB
        frame = im2uint8(frame);
        mask = uint8(repmat(mask, [1, 1, 3])) .* 255;

        minVisibleCount = 8;
        if ~isempty(tracks)

            % noisy detections tend to result in short-lived tracks
            % only display tracks that have been visible for more than
            % a minimum number of frames.
            reliableTrackInds = ...
                [tracks(:).totalVisibleCount] > minVisibleCount;
            reliableTracks = tracks(reliableTrackInds);

            % display the objects. If an object has not been detected
            % in this frame, display its predicted bounding box.
            if ~isempty(reliableTracks)
                % get bounding boxes
                bboxes = cat(1, reliableTracks.bbox);

                % get ids
                ids = int32([reliableTracks(:).id]);

                % create labels for objects indicating the ones for
                % which we display the predicted rather than the actual
                % location
                labels = cellstr(int2str(ids'));
                predictedTrackInds = ...
                    [reliableTracks(:).consecutiveInvisibleCount] > 0;
                isPredicted = cell(size(labels));
                isPredicted(predictedTrackInds) = {' predicted'};
                labels = strcat(labels, isPredicted);

                % draw on the frame
                frame = insertObjectAnnotation(frame, 'rectangle', ...
                    bboxes, labels);

                % draw on the mask
                mask = insertObjectAnnotation(mask, 'rectangle', ...
                    bboxes, labels);
            end
        end

        % display the mask and the frame
        obj.maskPlayer.step(mask);
        obj.videoPlayer.step(frame);
    end

%% Summary
% This example created a motion-based system for detecting and
% tracking multiple moving objects. Try using a different video to see if
% you are able to detect and track objects. Try modifying the parameters
% for the detection, assignment, and deletion steps.
%
% The tracking in this example was solely based on motion with the
% assumption that all objects move in a straight line with constant speed.
% When the motion of an object significantly deviates from this model, the
% example may produce tracking errors. Notice the mistake in tracking the
% person labeled #12, when he is occluded by the tree.
%
% The likelihood of tracking errors can be reduced by using a more complex
% motion model, such as constant acceleration, or by using multiple Kalman
% filters for every object. Also, you can incorporate other cues for
% associating detections over time, such as size, shape, and color.

displayEndOfDemoMessage(mfilename)
end
