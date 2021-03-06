function v3d2tif(inpath, cropthr, rescale_ratio, nthread)
% V3DTIF Convert V3Draw files to 3D tiff. At the same time do some cropping and resizing
%   v3d2tif(path2v3draw, cropthr, rescale_ratio) convert every *.v3draw in path2v3draw to .v3draw
%   the boundary with voxels smaller than cropthr will be cropped
%   the image will be resized to IMGSIZE1 * rescale_ratio X IMGSIZE2 * rescale_ratio X IMGSIZE3 * rescale_ratio X 
%   It will also look for an *.swc file with the same name root as the v3draw file, then crop and resize that swc file accordingly
%   It will also create an *.ano that can be dragged into vaa3d to go directly to 3D visualisation
%   We use matlab for preprocessing v3draw file, because now *.v3draw is only supported with Vaa3D and matlab (with V3D-Matlab-IO)

    % Load and convert the v3draw file
    if nthread ~= 1
        fprintf('Using %d threads\n', nthread);
        parpool(nthread)
    end

    fprintf('inpath: %s\n', inpath);

    if isdir(inpath)
        outdir = fullfile(inpath, 'tif');
        if exist(outdir, 'dir')
            rmdir(outdir, 's')
            mkdir(outdir)
        else
            mkdir(outdir)
        end

        % Search for v3draw files in this folder
        v3drawlist = dir(fullfile(inpath, '*.v3draw'));
        if nthread == 1 
            % Convert each v3draw file - parfor is too memory consuming
            for i = 1 : numel(v3drawlist) 
                fprintf('Converting %d/%d', i, numel(v3drawlist))
                name = v3drawlist(i).name
                outputFileName = fullfile(inpath, 'tif', [name, '.tif']);
                v3drawpath = fullfile(inpath, name);
                convertfile(v3drawpath, cropthr, rescale_ratio, outputFileName);
            end % End of loop of processing 1 file
        else
            % Convert each v3draw file - parfor is too memory consuming
            parfor i = 1 : numel(v3drawlist) 
                fprintf('Converting %d/%d', i, numel(v3drawlist))
                name = v3drawlist(i).name
                outputFileName = fullfile(inpath, 'tif', [name, '.tif']);
                v3drawpath = fullfile(inpath, name);
                convertfile(v3drawpath, cropthr, rescale_ratio, outputFileName);
            end % End of loop of processing 1 file
        end

        disp('== Done ==')
    else
        outputFileName = strcat(inpath, '.tif');
        convertfile(inpath, cropthr, rescale_ratio, outputFileName);
    end
end


function convertfile(v3drawpath, cropthr, rescale_ratio, outputFileName)
        [pathstr, name, ext] = fileparts(v3drawpath);
        v3dvol = load_v3d_raw_img_file(v3drawpath);

        % Crop the v3draw volume
        [v3dvol, cropregion] = imagecrop(v3dvol, cropthr);

        % Resize the 3D volume
        if rescale_ratio ~= 1
            v3dvol = rescale3D(v3dvol, rescale_ratio);
        end


        if exist(outputFileName, 'file') == 2
            fprintf('Found an existing %s. The old file is deleted.\n', outputFileName);
            delete(outputFileName);
        end

        fprintf('Writing the tif image into %s\n', outputFileName)
        for z = 1:size(v3dvol, 3)
            imwrite(rot90(v3dvol(:, :, z)), outputFileName, 'WriteMode', 'append');
        end

        % Look for the swc
        swcpath = fullfile(pathstr, [name, '.swc']);

        if exist(swcpath, 'file')
            fprintf('Found swc for %s\n', v3drawpath);
            swc = load_v3d_swc_file(swcpath);

            % Crop the swc
            swc(:, 3) = swc(:, 3) - cropregion(1, 1) + 1;
            swc(:, 4) = swc(:, 4) - cropregion(2, 1) + 1;
            swc(:, 5) = swc(:, 5) - cropregion(3, 1) + 1;

            % Resize the swc
            swc(:, 3:5) = swc(:, 3:5) * rescale_ratio;

            % Save swc
            disp('outputFileName:')
            disp(outputFileName)
            [pathstr, name, ~] = fileparts(outputFileName);
            swcpath2save = fullfile(pathstr, [name, '.swc']);
            disp('swcpath2save')
            disp(swcpath2save)
            saveswc(swc, swcpath2save);
            % fprintf(anofid, 'SWCFILE=%s\n', [name, '.swc']);
        end

end


function [croped, cropregion] = imagecrop(srcimg, threshold)
% Adapted from Rivulet-Matlab-Toolbox on github
    srcimg = squeeze(srcimg);
    ind = find(srcimg > threshold);
    if numel(ind) == 0
        croped = [];
        cropregion = [];
        return
    end
    [M, N, Z] = ind2sub(size(srcimg), ind);
    cropregion = [min(M), max(M); min(N), max(N); min(Z), max(Z)];
    croped = srcimg(cropregion(1, 1) : cropregion(1, 2), ...
                    cropregion(2, 1) : cropregion(2, 2), ...
                    cropregion(3, 1) : cropregion(3, 2));
end


function img = rescale3D(img, scale)
% Adapted from Rivulet-Matlab-Toolbox on github
% RESCALE Rescale image with matlab imresize
% cropedimg = rescale3D(img, 0.5)
    if scale ~= 1
        img = imresize(img, scale);
        img = permute(img, [3, 1, 2]);
        img = imresize(img, [size(img, 1) * scale, size(img, 2)]);
        img = permute(img, [2, 3, 1]);
    end
end


function saveswc(swc, outfilename)
% Adapted from Rivulet-Matlab-Toolbox on github
%SAVESWC Summary of this function goes here
%   Detailed explanation goes here

    if isempty(swc),
        return;
    end

    if size(swc,2)<7,
        error('The first variable must have at least 7 columns.'),
    end

    f = fopen(outfilename, 'wt');
    if f<=0,
        error('Fail to open file to write');
    end

    for i=1:size(swc,1),
        fprintf(f, '%d %d %5.3f %5.3f %5.3f %5.3f %d\n',...
            swc(i,1), swc(i,2), swc(i,3), swc(i,4), swc(i,5), swc(i,6), swc(i,7));
    end

    fclose(f);
end

