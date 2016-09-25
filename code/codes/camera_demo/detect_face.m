function [total_boxes points] = detect_face(img,minsize,PNet,RNet,ONet,threshold,fastresize,factor)
	%im: input image
	%minsize: minimum of faces' size
	%pnet, rnet, onet: caffemodel
	%threshold: threshold=[th1 th2 th3], th1-3 are three steps's threshold
	%fastresize: resize img from last scale (using in high-resolution images) if fastresize==true
	factor_count=0;
	total_boxes=[];
	points=[];
	h=size(img,1);
	w=size(img,2);
	minl=min([w h]);
    img=single(img);
	if fastresize
		im_data=(single(img)-127.5)*0.0078125;
    end
    m=12/minsize;
	minl=minl*m;
	%creat scale pyramid
    scales=[];
	while (minl>=12)
		scales=[scales m*factor^(factor_count)];
		minl=minl*factor;
		factor_count=factor_count+1;
	end
	%first stage
	for j = 1:size(scales,2)
		scale=scales(j);
		hs=ceil(h*scale);
		ws=ceil(w*scale);
		if fastresize
			im_data=imResample(im_data,[hs ws],'bilinear');
		else 
			im_data=(imResample(img,[hs ws],'bilinear')-127.5)*0.0078125;
		end
		PNet.blobs('data').reshape([hs ws 3 1]);
		out=PNet.forward({im_data});
		boxes=generateBoundingBox(out{2}(:,:,2),out{1},scale,threshold(1));
		%inter-scale nms
		pick=nms(boxes,0.5,'Union');
		boxes=boxes(pick,:);
		if ~isempty(boxes)
			total_boxes=[total_boxes;boxes];
		end
	end
	numbox=size(total_boxes,1);
	if ~isempty(total_boxes)
		pick=nms(total_boxes,0.7,'Union');
		total_boxes=total_boxes(pick,:);
		regw=total_boxes(:,3)-total_boxes(:,1);
		regh=total_boxes(:,4)-total_boxes(:,2);
		total_boxes=[total_boxes(:,1)+total_boxes(:,6).*regw total_boxes(:,2)+total_boxes(:,7).*regh total_boxes(:,3)+total_boxes(:,8).*regw total_boxes(:,4)+total_boxes(:,9).*regh total_boxes(:,5)];	
		total_boxes=rerec(total_boxes);
		total_boxes(:,1:4)=fix(total_boxes(:,1:4));
		[dy edy dx edx y ey x ex tmpw tmph]=pad(total_boxes,w,h);
	end
	numbox=size(total_boxes,1);
	if numbox>0
		%second stage
 		tempimg=zeros(24,24,3,numbox);
		for k=1:numbox
			tmp=zeros(tmph(k),tmpw(k),3);
			tmp(dy(k):edy(k),dx(k):edx(k),:)=img(y(k):ey(k),x(k):ex(k),:);
			tempimg(:,:,:,k)=imResample(tmp,[24 24],'bilinear');
		end
        tempimg=(tempimg-127.5)*0.0078125;
		RNet.blobs('data').reshape([24 24 3 numbox]);
		out=RNet.forward({tempimg});
		score=squeeze(out{2}(2,:));
		pass=find(score>threshold(2));
		total_boxes=[total_boxes(pass,1:4) score(pass)'];
		mv=out{1}(:,pass);
		if size(total_boxes,1)>0		
			pick=nms(total_boxes,0.7,'Union');
			total_boxes=total_boxes(pick,:);     
            total_boxes=bbreg(total_boxes,mv(:,pick)');	
            total_boxes=rerec(total_boxes);
		end
		numbox=size(total_boxes,1);
		if numbox>0
			%third stage
			total_boxes=fix(total_boxes);
			[dy edy dx edx y ey x ex tmpw tmph]=pad(total_boxes,w,h);
            tempimg=zeros(48,48,3,numbox);
			for k=1:numbox
				tmp=zeros(tmph(k),tmpw(k),3);
				tmp(dy(k):edy(k),dx(k):edx(k),:)=img(y(k):ey(k),x(k):ex(k),:);
				tempimg(:,:,:,k)=imResample(tmp,[48 48],'bilinear');
			end
			tempimg=(tempimg-127.5)*0.0078125;
			ONet.blobs('data').reshape([48 48 3 numbox]);
			out=ONet.forward({tempimg});
			score=squeeze(out{3}(2,:));
			points=out{2};
			pass=find(score>threshold(3));
			points=points(:,pass);
			total_boxes=[total_boxes(pass,1:4) score(pass)'];
			mv=out{1}(:,pass);
			w=total_boxes(:,3)-total_boxes(:,1)+1;
            h=total_boxes(:,4)-total_boxes(:,2)+1;
            points(1:5,:)=repmat(w',[5 1]).*points(1:5,:)+repmat(total_boxes(:,1)',[5 1])-1;
            points(6:10,:)=repmat(h',[5 1]).*points(6:10,:)+repmat(total_boxes(:,2)',[5 1])-1;
			if size(total_boxes,1)>0				
				total_boxes=bbreg(total_boxes,mv(:,:)');	
                pick=nms(total_boxes,0.7,'Min');
				total_boxes=total_boxes(pick,:);  				
                points=points(:,pick);
			end
		end
    end 	
end

