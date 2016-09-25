function [ bboxA ] = calbox(point,imw,imh)

	meanpoint=mean(point(1:5,:));
	dis=(point(4,:)-meanpoint).^2;
	deta=mean(point(1:2,1))-point(3,1);
	meanpoint(1,1)=meanpoint(1,1)+deta;
	dis=dis(:,1)+dis(:,2);
	dis=mean(dis.^(1/2))*1.3;
	x=meanpoint(1,1)-dis;
	y=meanpoint(1,2)-dis;
	w=2.6*dis;
	w=fix(w);
	x=fix(x);
	y=fix(y);
	w=1.1*w;
	x=x-0.05*w;
	y=y-0.1*w;
	if x<1
		dis=meanpoint(1,1);
		x=meanpoint(1,1)-dis;
		y=meanpoint(1,2)-dis;
		w=2*dis;
	end
	if y<1
		dis=meanpoint(1,2);
		x=meanpoint(1,1)-dis;
		y=meanpoint(1,2)-dis;
		w=2*dis;
	end
	w=fix(w);
	x=fix(x);
	y=fix(y);
	if x<1
	   x=1; 
	end
	if y<1
	   y=1; 
	end
	if x+w>imw
		dis=imw-meanpoint(1,1);
		   x=meanpoint(1,1)-dis;
		y=meanpoint(1,2)-dis;
		w=2*dis;
	end
	if y+w>imh
		dis=imh-meanpoint(1,2);
		x=meanpoint(1,1)-dis;
		y=meanpoint(1,2)-dis;
		w=2*dis;
	end
	w=fix(w);
	x=fix(x);
	y=fix(y);
	if x<1
		w=w-ceil(1-x);
		x=1; 
	end
	if y<1
		w=w-ceil(1-y);
		y=1; 
    end
    bboxA=[x y w w];

end

