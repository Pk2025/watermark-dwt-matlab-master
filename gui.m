classdef gui < matlab.apps.AppBase

    properties (Access = public)
        UIFigure matlab.ui.Figure

        SourcePanel matlab.ui.container.Panel
        WatermarkPanel matlab.ui.container.Panel
        ResultsPanel matlab.ui.container.Panel

        SourceAxes matlab.ui.control.UIAxes
        WatermarkAxes matlab.ui.control.UIAxes
        WatermarkedAxes matlab.ui.control.UIAxes
        ExtractedAxes matlab.ui.control.UIAxes

        BrowseSourceButton matlab.ui.control.Button
        BrowseWMButton matlab.ui.control.Button

        EmbedButton matlab.ui.control.Button
        ExtractButton matlab.ui.control.Button
        SaveButton matlab.ui.control.Button

        AttackDropDown matlab.ui.control.DropDown
        ApplyAttackButton matlab.ui.control.Button

        AlphaField matlab.ui.control.NumericEditField

        PSNRLabel matlab.ui.control.Label
        SSIMLabel matlab.ui.control.Label
        NCLabel matlab.ui.control.Label

        Logic
    end


    methods (Access = private)

        function BrowseSource(app, ~)
            % Prevent re-entrancy and ensure app/axes valid
            if ~isvalid(app) || ~isgraphics(app.SourceAxes)
                return
            end

            prevState = app.BrowseSourceButton.Enable;
            app.BrowseSourceButton.Enable = 'off';
            cleanupObj = onCleanup(@() setButtonEnableSafe(app, 'BrowseSourceButton', prevState));

            try
                [f,p] = uigetfile({'*.jpg;*.png;*.bmp'});
                if isequal(f,0), return; end

                app.Logic.initializeSource(fullfile(p,f),'');
                img = app.Logic.SourceImage;

                if ~isempty(img) && isnumeric(img) && isgraphics(app.SourceAxes)
                    imshow(img, 'Parent', app.SourceAxes);
                end
            catch ME
                warning('BrowseSource failed: %s', ME.message);
            end
        end


        function BrowseWM(app, ~)
            if ~isvalid(app) || ~isgraphics(app.WatermarkAxes)
                return
            end

            prevState = app.BrowseWMButton.Enable;
            app.BrowseWMButton.Enable = 'off';
            cleanupObj = onCleanup(@() setButtonEnableSafe(app, 'BrowseWMButton', prevState));

            try
                [f,p] = uigetfile({'*.jpg;*.png;*.bmp'});
                if isequal(f,0), return; end

                app.Logic.initializeWM(fullfile(p,f),'');
                img = app.Logic.WMImage;

                if ~isempty(img) && isnumeric(img) && isgraphics(app.WatermarkAxes)
                    imshow(img, 'Parent', app.WatermarkAxes);
                    app.EmbedButton.Enable = 'on';
                end
            catch ME
                warning('BrowseWM failed: %s', ME.message);
            end
        end


        function Embed(app, ~)
            if ~isvalid(app) || ~isgraphics(app.WatermarkedAxes)
                return
            end

            prevEmbed = app.EmbedButton.Enable;
            app.EmbedButton.Enable = 'off';
            cleanupObj = onCleanup(@() setButtonEnableSafe(app, 'EmbedButton', prevEmbed));

            try
                alphaVal = app.AlphaField.Value;
                app.Logic.embed(alphaVal);

                wmImg = app.Logic.WatermarkedImage;
                if ~isempty(wmImg) && isnumeric(wmImg) && isgraphics(app.WatermarkedAxes)
                    imshow(wmImg, 'Parent', app.WatermarkedAxes);
                end

                app.PSNRLabel.Text = sprintf('PSNR: %.2f', app.Logic.PSNRValue);
                app.SSIMLabel.Text = sprintf('SSIM: %.4f', app.Logic.SSIMValue);
                app.NCLabel.Text = 'NC: -';

                app.ExtractButton.Enable = 'on';
            catch ME
                warning('Embed failed: %s', ME.message);
            end
        end


        function Extract(app, ~)
            if ~isvalid(app) || ~isgraphics(app.ExtractedAxes)
                return
            end

            prevExt = app.ExtractButton.Enable;
            app.ExtractButton.Enable = 'off';
            cleanupObj = onCleanup(@() setButtonEnableSafe(app, 'ExtractButton', prevExt));

            try
                W = app.Logic.extract();

                if ~isempty(W) && isnumeric(W) && isgraphics(app.ExtractedAxes)
                    imshow(W, 'Parent', app.ExtractedAxes);
                end

                app.NCLabel.Text = sprintf('NC: %.4f', app.Logic.NCValue);
            catch ME
                warning('Extract failed: %s', ME.message);
            end
        end


        function ApplyAttack(app, ~)
            if ~isvalid(app) || ~isgraphics(app.WatermarkedAxes)
                return
            end

            prevBtn = app.ApplyAttackButton.Enable;
            app.ApplyAttackButton.Enable = 'off';
            cleanupObj = onCleanup(@() setButtonEnableSafe(app, 'ApplyAttackButton', prevBtn));

            try
                type = app.AttackDropDown.Value;
                app.Logic.applyAttack(type);

                attacked = app.Logic.WatermarkedImage;
                if ~isempty(attacked) && isnumeric(attacked) && isgraphics(app.WatermarkedAxes)
                    imshow(attacked, 'Parent', app.WatermarkedAxes);
                end

                app.PSNRLabel.Text = sprintf('PSNR: %.2f', app.Logic.PSNRValue);
                app.SSIMLabel.Text = sprintf('SSIM: %.4f', app.Logic.SSIMValue);
            catch ME
                warning('ApplyAttack failed: %s', ME.message);
            end
        end

        function setButtonEnableSafe(app, propName, value)
            % Safe setter used by onCleanup to restore button state
            try
                if isvalid(app) && isprop(app, propName) && isgraphics(app.(propName))
                    app.(propName).Enable = value;
                end
            catch
                % ignore errors during cleanup
            end
        end

    end


    methods (Access = private)

        function createComponents(app)
            app.UIFigure = uifigure('Name','Watermarking Tool');
            app.UIFigure.WindowState = 'maximized';

            mainGrid = uigridlayout(app.UIFigure,[3 1]);
            mainGrid.RowHeight = {'1x','1x','2.5x'};

            % Source
            app.SourcePanel = uipanel(mainGrid,'Title','Source');
            srcGrid = uigridlayout(app.SourcePanel,[1 2]);

            app.BrowseSourceButton = uibutton(srcGrid,'Text','Load Source',...
                'ButtonPushedFcn',@(s,e)BrowseSource(app));
            app.SourceAxes = uiaxes(srcGrid);
            app.SourceAxes.XTick = []; app.SourceAxes.YTick = [];

            % Watermark
            app.WatermarkPanel = uipanel(mainGrid,'Title','Watermark');
            wmGrid = uigridlayout(app.WatermarkPanel,[1 2]);

            app.BrowseWMButton = uibutton(wmGrid,'Text','Load WM',...
                'ButtonPushedFcn',@(s,e)BrowseWM(app));
            app.WatermarkAxes = uiaxes(wmGrid);
            app.WatermarkAxes.XTick = []; app.WatermarkAxes.YTick = [];

            % Results
            app.ResultsPanel = uipanel(mainGrid,'Title','Results');
            resGrid = uigridlayout(app.ResultsPanel,[2 3]);
            resGrid.RowHeight = {'1x',50};

            % Controls
            controlGrid = uigridlayout(resGrid,[8 1]);

            uilabel(controlGrid,'Text','Alpha');
            app.AlphaField = uieditfield(controlGrid,'numeric','Value',0.08);

            app.EmbedButton = uibutton(controlGrid,'Text','Embed',...
                'Enable','off','ButtonPushedFcn',@(s,e)Embed(app));

            app.ExtractButton = uibutton(controlGrid,'Text','Extract',...
                'Enable','off','ButtonPushedFcn',@(s,e)Extract(app));

            uilabel(controlGrid,'Text','Attack');

            app.AttackDropDown = uidropdown(controlGrid,...
                'Items',{'blur','sharpen','resize','gaussian','saltpepper','crop','rotate'});

            app.ApplyAttackButton = uibutton(controlGrid,'Text','Apply Attack',...
                'ButtonPushedFcn',@(s,e)ApplyAttack(app));

            % Images
            app.WatermarkedAxes = uiaxes(resGrid);
            app.WatermarkedAxes.Layout.Row = 1;
            app.WatermarkedAxes.Layout.Column = 2;
            app.WatermarkedAxes.XTick = []; app.WatermarkedAxes.YTick = [];

            app.ExtractedAxes = uiaxes(resGrid);
            app.ExtractedAxes.Layout.Row = 1;
            app.ExtractedAxes.Layout.Column = 3;
            app.ExtractedAxes.XTick = []; app.ExtractedAxes.YTick = [];

            % Metrics
            metricGrid = uigridlayout(resGrid,[1 3]);
            metricGrid.Layout.Row = 2;
            metricGrid.Layout.Column = [1 3];

            app.PSNRLabel = uilabel(metricGrid,'Text','PSNR: -');
            app.SSIMLabel = uilabel(metricGrid,'Text','SSIM: -');
            app.NCLabel = uilabel(metricGrid,'Text','NC: -');
        end

    end


    methods (Access = public)

        function app = gui
            createComponents(app);
            app.Logic = logic; % create logic after UI is ready

            % Ensure clean shutdown: disable controls and delete figure
            app.UIFigure.CloseRequestFcn = @(src,event)closeApp(app,src,event);
        end

        function delete(app)
            if isgraphics(app.UIFigure)
                delete(app.UIFigure);
            end
        end

        function closeApp(app, ~, ~)
            try
                if isvalid(app)
                    % disable UI to avoid callbacks after close begins
                    uiProps = {'BrowseSourceButton','BrowseWMButton','EmbedButton','ExtractButton','ApplyAttackButton'};
                    for k = 1:numel(uiProps)
                        if isprop(app, uiProps{k}) && isgraphics(app.(uiProps{k}))
                            app.(uiProps{k}).Enable = 'off';
                        end
                    end
                end
            catch
            end
            if isgraphics(app.UIFigure)
                delete(app.UIFigure);
            end
        end
    end

end
