 close all, clc;

video_in = VideoReader('..\test.avi');
video_data = read(video_in);
figure;


actor_name{1} = '郭德纲' ;
actor_name{2} = '于谦' ;

 filename = 'haarcascades/haarcascade_frontalface_alt.xml';
cls = cv.CascadeClassifier(filename);

     data =video_data(:,:,:,40);
     dst = cv.cvtColor(data,'RGB2GRAY');
     boxes = cls.detect(dst);
      for facei = 1: size(boxes,2)
          dst_show = cv.rectangle(data,boxes{facei},'Color',[255 0 0 ]);
      end
      figure; imshow(data);
      
      faceroi  = boxes{1};
     face_data = data(faceroi(2):(faceroi(2)+faceroi(4)), faceroi(1):(faceroi(1)+faceroi(3)), :);
     face_roi = cv.resize(face_data,[320 320]);
     actor_portrait = [];
     actor_portrait{1} = face_roi;
     
     
     data =video_data(:,:,:,120);
     dst = cv.cvtColor(data,'RGB2GRAY');
     boxes = cls.detect(dst);
      for facei = 1: size(boxes,2)
          dst_show = cv.rectangle(data,boxes{facei},'Color',[255 0 0 ]);
      end

      faceroi  = boxes{1};
     face_data = data(faceroi(2):(faceroi(2)+faceroi(4)), faceroi(1):(faceroi(1)+faceroi(3)), :);
     face_roi = cv.resize(face_data,[320 320]);
   
     actor_portrait{2} = face_roi;
     
  actor_number = 2;
  audio_nbits = 16;
  video_fps = 30;
  save('data.mat','audio_data','audio_fs','actor_name','actor_portrait','audio_nbits','video_fps');
