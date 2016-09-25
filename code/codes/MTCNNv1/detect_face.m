function [total_boxes points] = detect_face(img,minsize,PNet,RNet,ONet,LNet,threshold,fastresize,factor)
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
		bbw=total_boxes(:,3)-total_boxes(:,1);
		bbh=total_boxes(:,4)-total_boxes(:,2);
		total_boxes=[total_boxes(:,1)+total_boxes(:,6).*bbw total_boxes(:,2)+total_boxes(:,7).*bbh total_boxes(:,3)+total_boxes(:,8).*bbw total_boxes(:,4)+total_boxes(:,9).*bbh total_boxes(:,5)];	
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
			bbw=total_boxes(:,3)-total_boxes(:,1)+1;
            bbh=total_boxes(:,4)-total_boxes(:,2)+1;
            points(1:5,:)=repmat(bbw',[5 1]).*points(1:5,:)+repmat(total_boxes(:,1)',[5 1])-1;
            points(6:10,:)=repmat(bbh',[5 1]).*points(6:10,:)+repmat(total_boxes(:,2)',[5 1])-1;
			if size(total_boxes,1)>0				
				total_boxes=bbreg(total_boxes,mv(:,:)');	
                pick=nms(total_boxes,0.7,'Min');
				total_boxes=total_boxes(pick,:);  				
                points=points(:,pick);
			end
		end
		numbox=size(total_boxes,1);
		%extended stage
		if numbox>0 
			tempimg=zeros(24,24,15,numbox);
			patchw=max([total_boxes(:,3)-total_boxes(:,1)+1 total_boxes(:,4)-total_boxes(:,2)+1]');
			patchw=fix(0.25*patchw);	
			tmp=find(mod(patchw,2)==1);
			patchw(tmp)=patchw(tmp)+1;
			pointx=ones(numbox,5);
			pointy=ones(numbox,5);
			for k=1:5
				tmp=[points(k,:);points(k+5,:)];
				x=fix(tmp(1,:)-0.5*patchw);
				y=fix(tmp(2,:)-0.5*patchw);
				[dy edy dx edx y ey x ex tmpw tmph]=pad([x' y' x'+patchw' y'+patchw'],w,h);
				for j=1:numbox
					tmpim=zeros(tmpw(j),tmpw(j),3);
					tmpim(dy(j):edy(j),dx(j):edx(j),:)=img(y(j):ey(j),x(j):ex(j),:);
					tempimg(:,:,(k-1)*3+1:(k-1)*3+3,j)=imResample(tmpim,[24 24],'bilinear');
				end
			end
			LNet.blobs('data').reshape([24 24 15 numbox]);
			tempimg=(tempimg-127.5)*0.0078125;
			out=LNet.forward({tempimg});
			score=squeeze(out{3}(2,:));
			for k=1:5
				tmp=[points(k,:);points(k+5,:)];
				%do not make a large movement
				temp=find(abs(out{k}(1,:)-0.5)>0.35);
				if ~isempty(temp)
					l=length(temp);
					out{k}(:,temp)=ones(2,l)*0.5;
				end
				temp=find(abs(out{k}(2,:)-0.5)>0.35);  
				if ~isempty(temp)
					l=length(temp);
					out{k}(:,temp)=ones(2,l)*0.5;
				end
				pointx(:,k)=(tmp(1,:)-0.5*patchw+out{k}(1,:).*patchw)';
				pointy(:,k)=(tmp(2,:)-0.5*patchw+out{k}(2,:).*patchw)';
			end
			for j=1:numbox
				points(:,j)=[pointx(j,:)';pointy(j,:)'];
			end
		end
    end 	
end

