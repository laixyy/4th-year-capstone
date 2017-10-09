

function [] = draw(redThresh)
    if nargin < 1
        redThresh = 0.15;   
        greenThresh = 0.05; % Threshold for green detection

end

drawStruct.color = [1 0 0];  % Default Color: Red
drawStruct.listOfColor = {[],[0 0 1],[1 0 0],[0 1 0],[1 1 0],[1,0,1],[0,1,1],[0 0 0]};  % List of other colors: Blue, Red, Green, Yellow, Black
drawStruct.format = {[],'jpg','png','bmp'};  % List of Image formats
drawStruct.figh = figure('Units','pixels',...  % Main GUI Page
              'Position',[10 50 600 650],...
              'Menubar','none',...
              'Name','Capstone',...
              'NumberTitle','off',...
              'Resize','on');
drawStruct.axs = axes('Units','pixels',...  % Axis property
            'Position',[5 5 590 640],...
            'Xlim',[-6 0],...
            'YLim',[-4.5 0],...
            'DrawMode','fast');
set(drawStruct.axs,'xTickLabel',[],'yTickLabel',[],'xTick',[],'yTick',[]);  % Remove Axis marks
drawStruct.conMenu = uicontextmenu;  % Menu Items
    drawStruct.uMenuColor(1) = uimenu(drawStruct.figh,'label','Color');
    drawStruct.uMenuColor(2) = uimenu(drawStruct.uMenuColor(1),'label','Blue');
    drawStruct.uMenuColor(3) = uimenu(drawStruct.uMenuColor(1),'label','Red');
    drawStruct.uMenuColor(4) = uimenu(drawStruct.uMenuColor(1),'label','Green'); 
    drawStruct.uMenuColor(5) = uimenu(drawStruct.uMenuColor(1),'label','Yellow');
    drawStruct.uMenuColor(6) = uimenu(drawStruct.uMenuColor(1),'label','Magenta');
    drawStruct.uMenuColor(7) = uimenu(drawStruct.uMenuColor(1),'label','Cyan');
    drawStruct.uMenuColor(8) = uimenu(drawStruct.uMenuColor(1),'label','Black');
    drawStruct.uMenuColor(9) = uimenu(drawStruct.uMenuColor(1),'label','Erase');
    set(drawStruct.uMenuColor(2:6),'callback',@uMenuColor_call)
    %drawStruct.uMenuColor(7) = uimenu(drawStruct.uMenuColor(1),'label','Select Other Colors','callback',{@uMenuColorOther_call});
    %drawStruct.uMenuFile(1) = uimenu(drawStruct.figh,'label','Save As');
    %drawStruct.uMenuFile(2) = uimenu(drawStruct.uMenuFile(1),'label','<.jpg>');
    %drawStruct.uMenuFile(3) = uimenu(drawStruct.uMenuFile(1),'label','<.png>');
    %drawStruct.uMenuFile(4) = uimenu(drawStruct.uMenuFile(1),'label','<.bmp>');
    %set(drawStruct.uMenuFile(2:4),'callback',{@uMenuFile_call})

vidDevice = imaq.VideoDevice('winvideo', 1, 'YUY2_640x480', ...
                    'ROI', [1 1 640 480], ...
                    'ReturnedColorSpace', 'rgb');  % Input Video from current adapter
vidInfo = imaqhwinfo(vidDevice);  % Acquire video information
hblob = vision.BlobAnalysis('AreaOutputPort', false, ... 
                                'CentroidOutputPort', true, ... 
                                'BoundingBoxOutputPort', true', ...
                                'MaximumBlobArea', 3000, ...
                                'MaximumCount', 1);  % Make system object for blob analysis
hshapeinsRedBox = vision.ShapeInserter('BorderColor', 'Custom', ...
                                    'CustomBorderColor', [1 0 0], ...
                                    'Fill', true, ...
                                    'FillColor', 'Custom', ...
                                    'CustomFillColor', [1 0 0], ...
                                    'Opacity', 0.4);  % Make system object for Red Filled Box
hshapeinsGreenBox = vision.ShapeInserter('BorderColor', 'Custom', ... % Set Green box handling
                                    'CustomBorderColor', [0 1 0], ...
                                    'Fill', true, ...
                                    'FillColor', 'Custom', ...
                                    'CustomFillColor', [0 1 0], ...
                                    'Opacity', 0.4);
htextinsCent = vision.TextInserter('Text', '+      X:%5.2f, Y:%5.2f', ...
                                    'LocationSource', 'Input port', ...
                                    'Color', [1 1 0], ...
                                    'FontSize', 14);  % Make system object for Text: Centroid Infication
                           
hVideoIn = vision.VideoPlayer('Name', 'Final Video', ...
                                'Position', [60+vidInfo.MaxWidth 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);   % Make system object for output video stream
% hMarker = vision.MarkerInserter('Shape','Circle','Fill','true','FillColor','Black');
   hold on; box on;

centX = 1; centY = 1;  % Feature Centroid initialization
%% Processing Iteration
while 1
    
    rgbFrame = step(vidDevice);  % Extract Single Frame
    diffFrame = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame));  % Extract Red component
    diffFrame = medfilt2(diffFrame, [3 3]);  % Applying Medial Filter for denoising
    binFrame = im2bw(diffFrame, redThresh);  % Convert to binary image using red threshold
    binFrame = bwareaopen(binFrame,800);  % Discard small areas

%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%green
    diffFrameGreen = imsubtract(rgbFrame(:,:,2), rgb2gray(rgbFrame)); % Get green component of the image
    diffFrameGreen = medfilt2(diffFrameGreen, [3 3]); % Filter out the noise by using median filter
    binFrameGreen = im2bw(diffFrameGreen, greenThresh); % Convert the image into binary image with the green objects as white
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(sum(binFrame(:))>0)
    
        [centroid, bbox] = step(hblob, binFrame);  % Get the reqired statistics of remaining blobs
        
        if ~isempty(bbox)  %  Get the centroid of remaining blobs
            centX = centroid(1); 
            centY = centroid(2);
        end
        vidIn = step(hshapeinsRedBox, rgbFrame, bbox);  % Put a Red bounding box in input video stream   
        %vidIn = step(hshapeinsGreenBox, vidIn, bboxGreen); % Instert the green box
        vidIn = step(htextinsCent, vidIn, [centX centY], [uint16(centX)-6 uint16(centY)-9]);  % Write centroid
        step(hVideoIn, vidIn);  % Show the output video stream
        plot(-centX/100, -centY/100, '.', ...
                   'LineWidth', 5, ...
                'color', drawStruct.color, ...
                'MarkerSize',40);

elseif(sum(binFrameGreen(:))>0)
         [centroidGreen, bboxGreen] = step(hblob, binFrameGreen);  
         if ~isempty(bboxGreen)  
             centX = centroidGreen(1); 
             centY = centroidGreen(2);
         end
         vidIn = step(hshapeinsGreenBox, rgbFrame, bboxGreen);  
         vidIn = step(htextinsCent, vidIn, [centX centY], [uint16(centX)-6 uint16(centY)-9]);  
         step(hVideoIn, vidIn);   
         plot(-centX/100, -centY/100, 's', ...
                 'LineWidth', 5, ...
                 'MarkerSize',100,...
                 'MarkerEdgeColor','w',...
                 'MarkerFaceColor',[1,1,1]);
        
        %set(red,'Visible','off');
else
    vidIn = step(vidDevice);
    step(hVideoIn,vidIn);
    
end

    axis([-6,0,-4.5,0])
    set(drawStruct.axs,'xticklabel',[],'yticklabel',[],'xtick',[],'ytick',[]); 
    %hold on; 
    box on;
end

    function [] = uMenuColor_call(varargin)  % Call for List of Color
        drawStruct.color = drawStruct.listOfColor{varargin{1}==drawStruct.uMenuColor};
    end


end