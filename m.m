% Aircraft Recognition in Satellite Images

% Step 1: Read the Satellite Image
[filename1,pathname1]=uigetfile('*.*','select the 1st image');
filewithpath1=strcat(pathname1,filename1);
satellite_img=imread(filewithpath1);


% Step 2: Preprocess the Image
gray_img = rgb2gray(satellite_img); % Convert to grayscale if it's an RGB image
filtered_img = medfilt2(gray_img, [3, 3]); % Apply median filter to reduce noise

% Step 3: Image Segmentation using Thresholding
binary_img = imbinarize(filtered_img, 'adaptive', 'ForegroundPolarity', 'bright', 'Sensitivity', 0.4);

% Step 4: Extract Connected Components
connected_components = bwconncomp(binary_img);
props = regionprops(connected_components, 'BoundingBox', 'Area', 'Eccentricity', 'Solidity');

% Initialize variables to store features and bounding boxes
features = [];
bounding_boxes = [];

% Step 5: Extract Features from each Component
for i = 1:length(props)
    % Extract relevant properties
    area = props(i).Area;
    eccentricity = props(i).Eccentricity;
    solidity = props(i).Solidity;
    
    % Define feature vector
    feature_vector = [area, eccentricity, solidity];
    
    % Append to features list
    features = [features; feature_vector];
    
    % Store bounding box
    bounding_boxes = [bounding_boxes; props(i).BoundingBox];
end

% Step 6: Classify the Features (Aircraft/Non-Aircraft)
% Here, we use a simple rule-based classifier. Replace with a trained model for better results.
is_aircraft = (features(:, 1) > 500) & (features(:, 2) < 0.9) & (features(:, 3) > 0.5);

% Step 7: Display Results
figure;
imshow(satellite_img);
hold on;

for i = 1:length(is_aircraft)
    if is_aircraft(i)
        rectangle('Position', bounding_boxes(i, :), 'EdgeColor', 'r', 'LineWidth', 2);
    end
end
title('Detected Aircraft');
hold off;