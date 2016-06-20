function mask = fhroi(im_data, mask, axHandle)
% FHROI:  Interactively specify 2D freehand ROI
%
% Overlays an imfreehand ROI on an image.
% Gives the ability to tweak the ROI by adding and
%   subtracting regions as needed, while updating
%   the ROI boundaries as an overlay on the image.
% Returns a logical matrix of the same size as the
%   overlain image.
%
% Requires alphamask:
%   http://www.mathworks.com/matlabcentral/fileexchange/34936
%
% Usage:
%   bwMask = fhroi([axHandle])
%     axHandle: handle to axes on which to operate (optional)
%       bwMask: ROI mask as logical matrix
%
% Example:
%   figure;
%   I = rand(20) + eye(20);
%   imshow(I, [], 'Colormap', hot, 'initialMagnification', 1000);
%   bwMask = fhroi;
%
% See also IMFREEHAND, CREATEMASK

% v0.6 (Feb 2012) by Andrew Davis -- addavis@gmail.com


% Check input and set up variables
if ~exist('axHandle', 'var'), axHandle = gca; end;
imHandle = imhandles(axHandle);
imHandle = imHandle(1);             % First image on the axes
hOVM = [];                          % no overlay mask yet

% User instructions and initial area
disp('1. Use zoom and pan tools if desired');
disp('2. Make sure no tools are selected')
disp('3. Left click and drag to add closed loop');


if exist('mask', 'var')
    bwMask = mask == 1;
    faintMask = mask == 2;
else
    bwMask = zeros([size(imHandle.CData, 1), size(imHandle.CData, 2)], 'logical');
    faintMask = zeros([size(imHandle.CData, 1), size(imHandle.CData, 2)], 'logical');
end
 


% Await user input to determine if the ROI needs tweaking
displayOverlay = true;
roiLoop = 1;
while(roiLoop),
   if exist('hOVM', 'var')
      delete(hOVM);                       % delete old overlay mask
   end

   if displayOverlay
      hOVM = show_masks(bwMask, faintMask);           % overlay image with mask
   end
   [~, ~, nextAction] = ginput(1);

   if nextAction == 'a',                 % draw with imfreehand and add to roi
      fhAdd = imfreehand;
      bwAdd = createMask(fhAdd, imHandle);
      bwMask = bwMask | bwAdd;         % logical 'bwMask or bwAdd'
      delete(fhAdd);

   elseif nextAction == 'q',
      fhAdd = imfreehand;
      bwAdd = createMask(fhAdd, imHandle);
      faintMask = faintMask | bwAdd;         % logical 'faintMask or bwAdd'
      delete(fhAdd);
      

   elseif nextAction == 's',             % draw with imfreehand and subtract from roi
      fhSub = imfreehand;
      bwSub = createMask(fhSub, imHandle);
      bwMask = bwMask & ~bwSub;        % logical 'bwMask and not bwSub'
      faintMask = faintMask & ~bwSub;        % logical 'bwMask and not bwSub'
      delete(fhSub);

   elseif nextAction == 'd',             % delete roi
      bwMask = bwMask & 0;             % logical 'bwMask and 0'

   elseif nextAction == 'x',             % user is happy with ROI
      roiLoop = 0;

   elseif nextAction == 'c',           % adjust image contrast
      im_data = adjust_contrast(im_data, 2);
      set(imHandle, 'CData', im_data)

   elseif nextAction == 'v',           % adjust image contrast
      im_data = adjust_contrast(im_data, 3);
      set(imHandle, 'CData', im_data)

   elseif nextAction == 't',
      displayOverlay = ~displayOverlay;
        
   end;

end;

mask = zeros(size(mask), 'uint8');
mask(faintMask) = 2;
mask(bwMask) = 1;


function im_data = adjust_contrast(im_data, channel)
    % Adjusts the contrast of the data in the chosen channel
    h = figure();
    imshow(im_data(:,:,channel))
    uiwait(imcontrast())
    imh = findobj(h, 'Type', 'image');
    im_data(:,:,channel) = get(imh, 'CData');
    delete(h)


function hOVM = show_masks(bwMask, faintMask)
    mask = zeros([size(bwMask), 3]);
    transparency = 0.4;

    orange = [255, 165, 0];
    red = [255, 0, 0];

    for i = 1:3
        mplane = mask(:,:,i);
        mplane(faintMask) = orange(i);
        mplane(bwMask) = red(i);
        mask(:,:,i) = mplane;
    end

    hold on
    hOVM = imshow(mask, 'Parent', gca);
    set(hOVM, 'AlphaData', (bwMask | faintMask)*transparency)
    hold off
