classdef logic < handle

    properties
        SourceFile
        SourceImage
        OriginalImageForPSNR

        WMFile
        WMImage

        Psize
        Alpha

        Sy
        Uw
        Vw
        Uy
        Vy

        WatermarkedImage

        PSNRValue
        SSIMValue
        NCValue

        Channel = 2
    end

    methods

        % ------------------ INITIALIZE SOURCE ------------------
        function initializeSource(this, SourceFile, ~)
            if nargin < 2 || isempty(SourceFile)
                return
            end

            this.SourceFile = SourceFile;

            src = imread(SourceFile);
            this.SourceImage = src;

            if size(src,3) == 3
                host = double(src(:,:,this.Channel));
            else
                host = double(src);
            end

            [LL1,~,~,~] = dwt2(host,'haar');
            [~,HL2,~,~] = dwt2(LL1,'haar');

            this.Psize = size(HL2);
        end


        % ------------------ INITIALIZE WATERMARK ------------------
        function initializeWM(this, WMFile, ~)
            if nargin < 2 || isempty(WMFile)
                return
            end

            this.WMFile = WMFile;
            wm = imread(WMFile);

            if size(wm,3) == 3
                wm = rgb2gray(wm);
            end

            if isempty(this.Psize)
                this.WMImage = imresize(wm, [64 64]);
            else
                this.WMImage = imresize(wm, this.Psize);
            end
        end


        % ------------------ EMBEDDING ------------------
        function embed(this, Alpha)
            if isempty(this.SourceImage) || isempty(this.WMImage)
                return
            end

            this.Alpha = Alpha;

            src = double(this.SourceImage);

            if size(src,3) == 3
                host = src(:,:,this.Channel);
            else
                host = src;
            end

            % DWT
            [LL1,HL1,LH1,HH1] = dwt2(host,'haar');
            [LL2,HL2,LH2,HH2] = dwt2(LL1,'haar');

            % SVD Host
            [Uy,Sy,Vy] = svd(HL2);
            this.Sy = Sy; this.Uy = Uy; this.Vy = Vy;

            % SVD Watermark
            wm = double(this.WMImage);
            [Uw,Sw,Vw] = svd(wm);
            this.Uw = Uw; this.Vw = Vw;

            % Resize Sw to match Sy
            Sw = Sw(1:size(Sy,1),1:size(Sy,2));

            % Embedding
            Smark = Sy + Alpha*Sw;
            HL2m = Uy*Smark*Vy';

            % Inverse DWT
            LL1m = idwt2(LL2,HL2m,LH2,HH2,'haar');
            LL1m = imresize(LL1m,size(HL1));

            I1 = idwt2(LL1m,HL1,LH1,HH1,'haar');
            I1 = I1(1:size(src,1),1:size(src,2));

            if size(src,3) == 3
                src(:,:,this.Channel) = I1;
                this.WatermarkedImage = uint8(min(max(round(src),0),255));
            else
                this.WatermarkedImage = uint8(min(max(round(I1),0),255));
            end

            % Metrics
            orig = im2uint8(this.SourceImage);
            dist = im2uint8(this.WatermarkedImage);

            try
                this.PSNRValue = psnr(dist,orig);
                this.SSIMValue = ssim(dist,orig);
            catch
                this.PSNRValue = 0;
                this.SSIMValue = 0;
            end
        end


        % ------------------ ATTACKS ------------------
        function applyAttack(this,type)
            if isempty(this.WatermarkedImage)
                return
            end

            img = this.WatermarkedImage;
            [h, w, ~] = size(img);

            switch type
                case 'blur'
                    attacked = imgaussfilt(img,2);
                case 'sharpen'
                    attacked = imsharpen(img);
                case 'resize'
                    temp = imresize(img,0.5);
                    attacked = imresize(temp, [h w]);
                case 'gaussian'
                    attacked = imnoise(img,'gaussian',0,0.01);
                case 'saltpepper'
                    attacked = imnoise(img,'salt & pepper',0.02);
                case 'crop'
                    crop_size = min(50, floor(min(h,w)/4));
                    cimg = img(crop_size+1:end-crop_size, crop_size+1:end-crop_size, :);
                    if isempty(cimg)
                        attacked = img;
                    else
                        attacked = imresize(cimg, [h w]);
                    end
                case 'rotate'
                    attacked = imrotate(img,10,'bilinear','crop');
                otherwise
                    attacked = img;
            end

            attacked = im2uint8(attacked);
            this.WatermarkedImage = attacked;

            orig = im2uint8(this.SourceImage);
            try
                this.PSNRValue = psnr(attacked,orig);
                this.SSIMValue = ssim(attacked,orig);
            catch
                this.PSNRValue = 0;
                this.SSIMValue = 0;
            end
        end


        % ------------------ EXTRACTION ------------------
        function W = extract(this)
            W = [];
            if isempty(this.WatermarkedImage) || isempty(this.Sy) || isempty(this.Uw) || isempty(this.Vw) || isempty(this.Alpha)
                return
            end

            img = double(this.WatermarkedImage);

            if size(img,3) == 3
                img = img(:,:,this.Channel);
            end

            % DWT
            [LL1,~,~,~] = dwt2(img,'haar');
            [~,HL2,~,~] = dwt2(LL1,'haar');

            % SVD
            [~,Syw,~] = svd(HL2);

            % Recover watermark
            Swrec = (Syw - this.Sy) / this.Alpha;

            W = this.Uw * Swrec * this.Vw';
            W = uint8(min(max(round(W),0),255));

            % NC Calculation
            Worig = double(this.WMImage);
            Wext = double(W);

            num = sum(Worig(:).*Wext(:));
            den = sqrt(sum(Worig(:).^2) * sum(Wext(:).^2));
            this.NCValue = num / (den + eps);
        end


        % ------------------ CONSTRUCTOR ------------------
        function this = logic
            this.PSNRValue = 0;
            this.SSIMValue = 0;
            this.NCValue = 0;
            this.Psize = [];
            this.SourceImage = [];
            this.WMImage = [];
            this.WatermarkedImage = [];
        end

    end

end
