json_path = 'index.json';
json_data = json.read(json_path);

output_json = {};
figure
for i = 1:length(json_data)
    [~, image_name, ext] = fileparts(json_data(i).output_path);
    im = imread([image_name, ext]);

    imshow(im)
    [~, ~, button] = ginput(1);

    if button == 'f'
        output_json(end + 1) = {json_data(i)};
    end
end

json.write(output_json, 'filtered_index.json')
    
