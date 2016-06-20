function annotate_training_data()

    % load index containing image metadata
    index = json.read('index.json');

    % load keys
    keys = fields(index);
    
    figure()
    for i = 1:numel(keys)
        i
        % load image data and metadata
        elem = index.(keys{i})
        im = imread(elem.output_path);

        % display image and open interactive session
        imshow(im)
        if isfield(elem, 'label')
            try
                mask = uint8(imread(elem.label));
            catch
                mask = zeros(size(im(:,:,1)), 'uint8');
            end

        else
            mask = zeros(size(im(:,:,1)), 'uint8');
        end

        mask = fhroi(im, mask);

        % save mask as an image
        [~, im_name] = fileparts(elem.output_path);
        mask_name = [im_name, '_mask.tiff'];
        imwrite(mask, mask_name)

        % update metadata
        elem.label = mask_name;
        index.(keys{i}) = elem;
        json.write(index, 'index.json')
    end

    disp('its over!')
