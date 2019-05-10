function rotated_image = rotate(angle, image)
bw_image = im2bw(image, 0.01);      	%#ok<IM2BW>

boundingbox = regionprops(bw_image,'boundingbox');
rotated_image = uint8(zeros(600,1000,3));

for index = 1:numel(boundingbox)
    % gets the image properties for each individual character
    bound = boundingbox(index);
    x = bound.BoundingBox;
    xmin = x(1,1);
    ymin = x(1,2);
    width = x(1,3);
    height = x(1,4);
    rect = [xmin ymin width height];
    
    % crops the segmented image using coordinates from boundingbox
    old_j = imcrop(image, rect);
    
    % converts character to binary, clean up image
    gray_j = im2bw(old_j,0.01);             %#ok<IM2BW>
    gray_j = bwareaopen(gray_j, 2500);
    j = uint8(zeros(size(old_j)));
    
    % colour the cropped image back and rotate by angle
    for a = 1:size(old_j,1)
        for b = 1:size(old_j,2)
            for c = 1:size(old_j,3)
                if gray_j(a,b) == 1
                    j(a,b,c) = old_j(a,b,c);
                end
            end
        end
    end
    rot_j = imrotate(j, angle, 'bilinear', 'loose');
    
    % get offsets to align the centroids
    rot_yc = floor(size(rot_j,1)/2);
    rot_xc = floor(size(rot_j,2)/2);
    cen_x = xmin + round(width/2);
    cen_y = ymin + round(height/2);
    
    for a = 1:size(rot_j,1)
        for b = 1:size(rot_j,2)
            for c = 1:size(rot_j,3)
                if rotated_image(round(a-rot_yc+cen_y),round(b-rot_xc+cen_x),c) == 0
                    rotated_image(round(a-rot_yc+cen_y),round(b-rot_xc+cen_x),c) = rot_j(a,b,c);
                end
            end
        end
    end
end

% crop image to fit the original image
rotated_image = rotated_image(1:size(image,1), 1:size(image,2), 1:3);

end