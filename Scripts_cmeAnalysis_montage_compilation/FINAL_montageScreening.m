%Consolidated script for generating montages of tracks specified by their
%id. These ID's are generated through code found within the post-processing
%python notebooks. 

%This script requires cmeAnalysis and export_fig packages to be in the
%matlab path. Additionally, ghostscript must be installed on your computer.

%Written by Yuichiro Iwamoto, Hurley and Drubin lab, 20210628

%Designate experimental folder for tracks specified by the track address
basePath = "E:\Analysis\NA7NefCme\AP2DNM2NA7Nef_mutant_segment_good_1\20211111\";

%Set destination for outputting generated montage
outPath = "C:\Users\yuyu2\Desktop\montage_test\pval_and_distance_filter_test\fail_pval_distance_1_25_montage\";


%read in CSV file to generate table of track addresses.
[fileName, pathName] = uigetfile('*.txt');
addressList = readtable(fullfile(pathName,fileName),'PreserveVariableNames',false);
pat = digitsPattern;

addressPath = cell(height(addressList),1);
trackNum = zeros(height(addressList),1);

for i = 1:height(addressList)
    address = string(addressList{i,1});
    addressExtract = extract(address, pat);
    addressPath{i,1} = strcat(basePath + "cell" + addressExtract(1) + "-" ...
        + addressExtract(2) + "_2s\");
    trackNum(i,1) = addressExtract(3);
end

%initializing path strings
current_path = strings;
last_path = strings;

for i = 1:height(addressList)
    current_path = string(addressPath(i,1));
    %disp(current_path);
    %disp(last_path);
    if i > 1
        last_path = string(addressPath(i-1,1));
    end
    
    if ~strcmp(current_path, last_path)
        %disp('condition_pass');
        data_path = convertStringsToChars(current_path);
        data = loadConditionData(data_path, ...
            {'Ch1', 'Ch2', 'Ch3'},...
            {'rfp', 'gfp', 'cy5'},...
            'Parameters', [1.49, 60, 6.68e-6]);
    end
    
    create_track_montage(trackNum(i,1), current_path, data);
    export_fig(strcat(outPath, string(addressList{i,1})), '-pdf'); 
    
    delete(gcf);
end

%appending generated montage PDF's into one large PDF.
listing = dir(fullfile(outPath, '*.pdf'));
append_pdfs(fullfile(outPath, 'pooled.pdf'), fullfile(outPath, {listing.name}));

function create_track_montage(track_index, cell_path, data)

    %Function for generating montage of desired track by specifying the cell
    %folder directory and track number. Written by Yuichiro Iwamoto
    %20210617.
    
    %define the main channel for tracking (default is channel 1)
    mCh = find(strcmp(data.source, data.channels));

    %define the number of channels
    nCh = length(data.channels);
    if nCh>4
        error('Max. 4 channels supported.');
    end

    %define image size
    nx = data.imagesize(2);
    ny = data.imagesize(1);

    %track to load
    t = track_index;

    %noise floor? whatever w means
    w = 6; %default

    %Focus for montage. Either a 'frame' that doesn't move or the 'track'
    %itself
    reference = 'track';

    %loading stack of tiff images per channel
    stack = cell(1,nCh);

    for c = 1:nCh
                stack{c} = readtiff(data.framePaths{c});
    end
    
    %load frameInfo and tracks files from the cell directory
    detection_path = strcat(cell_path + "Ch1\Detection\detection_v2.mat");
    tracks_path = strcat(cell_path + "Ch1\Tracking\ProcessedTracks.mat");
    
    frameInfo = load(detection_path, 'frameInfo');
    tracks = load(tracks_path, 'tracks');
    tracks = tracks.tracks;
    
    %code for reordering tracks in descending lifetimes
    tracks = struct2table(tracks);

    sortedTracks = sortrows(tracks, 'lifetime_s', 'descend');
    
    sortedTracks = table2struct(sortedTracks);
    
    %run getTrackStack function. This is usually in cmeDataViewer but I
    %have made a modified version that must exist in same folder with this
    %create_track_montage function.
    
    [tstack, xa, ya] = getTrackStack(t, w, frameInfo.frameInfo, sortedTracks, reference, stack, mCh, nCh, nx, ny);

    plotTrackMontage(sortedTracks(t), tstack, xa, ya, 'Labels', data.markers,...
                    'ShowMarkers', false,...
                    'ShowDetection', false);
end

function [tstack, xa, ya] = getTrackStack(t, w, frameInfo, tracks, reference, stack, mCh, nCh, nx, ny)

        sigma = frameInfo(1).s;
        w = ceil(w*sigma);
        
        % coordinate matrices
        x0 = tracks(t).x;
        y0 = tracks(t).y;
        
        % start and end buffer sizes
        if ~isempty(tracks(t).startBuffer)
            sb = numel(tracks(t).startBuffer.t);
            x0 = [tracks(t).startBuffer.x x0];
            y0 = [tracks(t).startBuffer.y y0];
        else
            sb = 0;
        end
        if ~isempty(tracks(t).endBuffer)
            eb = numel(tracks(t).endBuffer.t);
            x0 = [x0 tracks(t).endBuffer.x];
            y0 = [y0 tracks(t).endBuffer.y];
        else
            eb = 0;
        end
        
        % frame index
        % when tracks structure is converted to table and back, .end field
        % is converted to .xEnd. Only works with the create_track_montage
        % function. 
        tfi = tracks(t).start-sb:tracks(t).xEnd+eb;
        tnf = length(tfi);
        
        
        if tracks(t).nSeg==1 && strcmpi(reference, 'track') % align frames to track
            xi = round(x0(mCh,:));
            yi = round(y0(mCh,:));
            % ensure that window falls within frame bounds
            x0 = xi - min([xi-1 w]);
            x1 = xi + min([nx-xi w]);
            y0 = yi - min([yi-1 w]);
            y1 = yi + min([ny-yi w]);
            % axes for each frame
            xa = arrayfun(@(i) x0(i):x1(i), 1:tnf, 'unif', 0);
            ya = arrayfun(@(i) y0(i):y1(i), 1:tnf, 'unif', 0);
        else
            % window around track mean
            mu_x = round(nanmean(x0,2));
            mu_y = round(nanmean(y0,2));
            x0 = max(1, min(mu_x)-w);
            x1 = min(data.imagesize(2), max(mu_x)+w);
            y0 = max(1, min(mu_y)-w);
            y1 = min(data.imagesize(1), max(mu_y)+w);
            xa = repmat({x0:x1}, [tnf 1]);
            ya = repmat({y0:y1}, [tnf 1]);
        end
        
        tstack = cell(nCh,tnf);
        for ci = 1:nCh
            for k = 1:tnf
                tstack{ci,k} = stack{ci}(ya{k}, xa{k}, tfi(k));
            end
        end
end
