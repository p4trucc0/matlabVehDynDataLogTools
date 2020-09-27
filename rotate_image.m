function im_out = rotate_image(im_in, deg)

h_old = size(im_in, 1);
w_old = size(im_in, 2);

z = size(im_in, 3);

switch(deg)
    case -90
        im_out = uint8(zeros(w_old, h_old, z));
        for ii = 1:z
            for i_row = 1:w_old
                im_out(i_row, :, ii) = im_in(:, w_old + 1 - i_row, ii)';
            end
        end
    case 90
        im_out = uint8(zeros(w_old, h_old, z));
        for ii = 1:z
            for i_row = 1:w_old
                im_out(i_row, :, ii) = im_in(h_old:-1:1, i_row, ii)';
            end
        end
    case 180
        im_out = uint8(zeros(h_old, w_old, z));
        for ii = 1:z
            for i_row = 1:w_old
                im_out(:, i_row, ii) = im_in(h_old:-1:1, w_old + 1 - i_row, ii);
            end
        end
%     case 360 % flip horizontal
%         im_out = uint8(zeros(h_old, w_old, z));
%         for ii = 1:z
%             for i_row = 1:w_old
%                 im_out(:, i_row, ii) = im_in(h_old:-1:1, w_old + 1 - i_row, ii);
%             end
%         end
end

