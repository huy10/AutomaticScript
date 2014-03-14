%% clean up
clear all;
close all;
clc;

%% arguments


% 输入文件名
addpath('..\sample_data_0\workspace');
data_filename   = 'data.mat';
video_filename      = 'data.avi';

%% input variables

video_fps           = [];

audio_fs            = [];

audio_nbits         = [];

actor_number        = [];


video_data          = [];
audio_data          = [];

actor_name          = [];

actor_portrait      = [];

%% output variables


line_number         = 0;

line_head           = [];
line_tail           = [];

speaker             = [];

lines               = [];

%% data input


load(data_filename);
video_in = VideoReader(video_filename);
video_data = read(video_in);

processing_start_time = tic;
global processing_parsing_time;
processing_parsing_time = 0;

%% processing
addpath([cd, '\GoogleSpeechAPI_tool']);
addpath([cd, '\mexopencv-master']);
numFrames = get(video_in, 'numberOfFrames');

% the first step is to extract audio and image

%plot(audio_data(:,1));
numOfLines = 1;
numOfSilence = 0;
pre_m = 1;
step = 0.01*audio_fs;
numOfSteps = length(audio_data(:,1))/step;
means = zeros(numOfSteps,1);

vars = zeros(numOfSteps,1);
stat = 0;
silence_cnt = 0;
voice_cnt = 0;
for m = 1: numOfSteps 
    means(m,1) = mean(audio_data((m-1)*step+1:m*step,1));
    data = audio_data((m-1)*step+1:m*step,1);
    vars(m,1) = sum((data(:,1) - means(m,1)).^2);
end
threshold_low = max(vars)*0.004;
threshold_high = max(vars)*0.1;
for m = 1: numOfSteps 
    if (vars(m,1)) > threshold_high && stat == 0
       
       voice_cnt = voice_cnt + 1;
    end
    if voice_cnt >=  1 % round(numOfSteps/1000)  %  it is 3 in data 0 ,  1 in data 1
        stat = 1;
       line_head = [line_head m];  % *step
       voice_cnt = 0;      
    end
    
    if (vars(m,1)) < threshold_low && stat == 1
       silence_cnt = silence_cnt + 1;
    end
    if silence_cnt > round(numOfSteps/60)
        line_tail = [line_tail m];   % *step
        silence_cnt = 0;
        stat = 0;
    end
end


% listen to the audio for debug, when testing, comment this
%for t = 1: length(line_tail)
    %data = audio_data(line_head(t)*step - 15 :line_tail(t)*step + 15,:);
    %framelength = audio_fs;
   % slow_data = speechproc(data(:,1), framelength);
    %wavplay(data);
    %wavplay(audio_data(line_head(t)*step - 15 :line_tail(t)*step + 15,:));
   % pause(1);
%end
%wavplay(audio_data( line_tail(size(line_tail,2)) * step: length(audio_data(:,1)),:));
%figure; 
%for t = 1: length(line_tail)   
   %figure; plot( audio_data(line_head(t)*step:line_tail(t)*step,:));
   %plot(abs(fft(audio_data(line_head(t)*step:line_tail(t)*step,:)))); hold on;
   
%end

%G = randi(2,numOfSteps,1);
%figure,gscatter(means,vars,G);
%disp(numOfLines);
%figure,plot(means,'r*'),hold on,plot(vars);
%[coeff,score, latent] = princomp(audio_data(line));

% 2nd, parse image


%for i = 1 : round(video_fps) : size(video_data, 4)
line_number = length(line_tail);
speaker = ones(line_number,1);

filename = 'haarcascades/haarcascade_frontalface_default.xml';
cls = cv.CascadeClassifier(filename);

mouth_filename = 'haarcascades/Mouth.xml';
mouth = cv.CascadeClassifier(mouth_filename);

smile_filename = 'haarcascades/haarcascade_smile.xml';
smile = cv.CascadeClassifier(smile_filename);

 eye_filename = 'haarcascades/haarcascade_eye.xml';
 eye = cv.CascadeClassifier(eye_filename);
 
load('data60_256.mat');
R = 320;
C = R;
ROTATION = -0.80;
tform.offsetr = ROTATION;
x = 0.6*C;
y = 0.5*R;
tform.offsetx = -x; 
tform.offsety = -y;          
options.nsearch = [10, 5]; 
options.ns = [10, 15];  
options.nscales = 2;
actor_hist =cell(size(actor_name,1),1);
for t = 1:size(actor_name,1)
dst_roi = actor_portrait{t};
%dst_roi = NormalizeIntensities(dst_roi, intensities);
dst_roi = im2double(dst_roi);
[mask1, tf1] = ASM_ApplyModel(dst_roi, tform, ShapeData, AppearanceData, options, 1);
ap = actor_portrait{t};
for m = 1: size(dst_roi,1)
                     for n = 1: size(dst_roi,2)
                         if mask1(m,n) == 1
                              ap(m,n,:) =  ap(m,n,:);
                         else
                              ap(m,n,:) = [0 0 0];
                         end
                     end
end
 figure; imshow(ap);
ap_gray = cv.cvtColor(ap,'RGB2GRAY');
actor_hist{t} = imhist(ap_gray);
actor_hist{t}(1) = 0;
end

 for i = 1: length(line_tail)     
      %index = randi(line_tail(i)-line_head(i),1);
      index = round(0.2*(line_tail(i)-line_head(i)));
      index = index + line_head(i);
      index = round(index/ numOfSteps * size(video_data,4));
      dst = video_data(:, :, :, index);    
     boxes = cls.detect(dst); 
    smile_boxes = smile.detect(dst);   
    for facei = 1: size(boxes,2)
         eye_boxes = eye.detect(dst);
         isFace = false;
         for eyei = 1:size(eye_boxes,2)
         %dst_show = cv.rectangle(dst,eye_boxes{eyei},'Color',[255 0 0 ]);
           if Containing(boxes{facei},eye_boxes{eyei}) == true
               isFace = true;
           end
         end
    
      if isFace == true
         faceRoi = boxes{facei};
         faceRegion =  dst(faceRoi(2):(faceRoi(2)+faceRoi(4)), faceRoi(1):(faceRoi(1)+faceRoi(3)), :);
         %dst_show = cv.rectangle(dst, faceRoi,'Color',[255 0 0 ]);figure;imshow(dst_show);
        % imshow(faceRegion);
         faceRegion = cv.cvtColor(faceRegion,'RGB2GRAY');
         mouth_boxes = mouth.detect(dst,'ScaleFactor',1.1,'MinNeighbors',3,'MaxSize',[faceRoi(3),0.5*faceRoi(4)]);  %'MaxSize',[faceRoi(3),0.5*faceRoi(4)]
         
        Y = zeros(size(mouth_boxes,2),1);
         mouthOpen = zeros(size(boxes,2),size(mouth_boxes,2));
         sumPixels = zeros(size(boxes,2),size(actor_portrait,1));
        for mouthi = 1:size(mouth_boxes,2)
           isContained = Containing(boxes{facei},mouth_boxes{mouthi}) ;
            
            % match with the portrait database
            if isContained == true  %&& isMouth(mouthi) == 1
             mouthRoi = mouth_boxes{mouthi};
             framedis0 = abs(video_data(:, :, :, index) - video_data(:, :, :, index-5));
             mouthRegion0 = framedis0(mouthRoi(2):(mouthRoi(2)+mouthRoi(4)), mouthRoi(1):(mouthRoi(1)+mouthRoi(3)), :);
             
             framedis1 = abs(video_data(:, :, :, index) - video_data(:, :, :, index+5));
             mouthRegion1 = framedis1(mouthRoi(2):(mouthRoi(2)+mouthRoi(4)), mouthRoi(1):(mouthRoi(1)+mouthRoi(3)), :);
             faceRegion = framedis1( faceRoi(2):( faceRoi(2)+ faceRoi(4)),  faceRoi(1):( faceRoi(1)+ faceRoi(3)), :);
             THRESHOLD1 = 0.35 * sum(sum(sum( faceRegion ))) ;
            
             if  sum(sum(sum(mouthRegion0))) > THRESHOLD1 && sum(sum(sum(mouthRegion1))) > THRESHOLD1
                    mouthOpen(facei,mouthi) = sum(sum(sum(mouthRegion0)));
                    dst_show = cv.rectangle(dst, mouthRoi,'Color',[255 0 0 ]);figure;imshow(dst_show);
                    faceroi  = boxes{facei};
             
                     face_data = dst(faceroi(2):(faceroi(2)+faceroi(4)), faceroi(1):(faceroi(1)+faceroi(3)), :);
                     portsize = size(actor_portrait{1});
                    face_roi = cv.resize(face_data,[portsize(1) portsize(2)]);
               %ASM
                dst_roi = imresize(face_data, [portsize(1) portsize(2)]);
                ap = dst_roi;
               % dst_roi = NormalizeIntensities(dst_roi, intensities);
                dst_roi = im2double(dst_roi);
                [mask, tf] = ASM_ApplyModel(dst_roi, tform, ShapeData, AppearanceData, options, 1);   
                    for m = 1: size(dst_roi,1)
                                         for n = 1: size(dst_roi,2)
                                             if mask(m,n) == 1
                                                  ap(m,n,:) =  ap(m,n,:);
                                             else
                                                  ap(m,n,:) = [0 0 0];
                                             end
                                         end
                    end
                     figure; imshow(ap);
                    ap_gray = cv.cvtColor(ap,'RGB2GRAY');
                    face_hist = imhist(ap_gray);
                    face_hist(1) = 0;
                   %compare two faces, who is speaking
                   for actori = 1: size(actor_name,1)
                       % sumPixels(facei,actori) = dot(actor_hist{actori},face_hist);
                       sumPixels(facei,actori) = sum((actor_hist{actori}-face_hist).^2);
                   end  
                    [Y I] = min(sumPixels(facei,:));                  
                     speaker(i) = I;   
             end
            end
        end
      end
    end
 end           

line_number = length(line_tail);
lines       = cell(line_number, 1);
pad = zeros(12000,2);
for i = 1 : line_number
    auto = 8000;
    if line_head(i) * step - auto > 0 && line_tail(i) * step + auto < numOfSteps
        sample_wav_slice = audio_data((line_head(i) * step - auto) : (line_tail(i) * step + auto), :);
    else
        sample_wav_slice = audio_data((line_head(i) * step ) : (line_tail(i) * step ), :);
    end
    sample_wav_slice = [pad; sample_wav_slice ;pad];
    
    [lines{i}, ~, ~] = fun_parsing(sample_wav_slice, audio_fs, audio_nbits);
   if speaker(i) == 0
         speaker(i) = 2;
   end
end
seconds = round( size(video_data,4)/ video_fps);
line_head = line_head ./ numOfSteps .* seconds;
line_tail = line_tail  ./ numOfSteps .* seconds;



%% result output



processing_elapsed_time = toc(processing_start_time);

disp(['The processing time is ', num2str(processing_elapsed_time - processing_parsing_time), 'seconds']);

fout = fopen('result.dat', 'w', 'n', 'UTF-8');
fprintf(fout, '%8.2f \r\n', processing_elapsed_time - processing_parsing_time);
fprintf(fout, '%8d \r\n', line_number);
for i = 1 : line_number
    fprintf(fout, '%8.2f %8.2f %s %s\r\n', line_head(i), line_tail(i), actor_name{speaker(i)}, lines{i});
end
fclose(fout);
