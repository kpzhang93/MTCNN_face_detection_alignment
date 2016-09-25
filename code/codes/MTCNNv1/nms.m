function pick = nms(boxes,threshold,type)
	%NMS
	if isempty(boxes)
	  pick = [];
	  return;
	end
	x1 = boxes(:,1);
	y1 = boxes(:,2);
	x2 = boxes(:,3);
	y2 = boxes(:,4);
	s = boxes(:,5);
	area = (x2-x1+1) .* (y2-y1+1);
	[vals, I] = sort(s);
	pick = s*0;
	counter = 1;
	while ~isempty(I)
		last = length(I);
		i = I(last);
		pick(counter) = i;
		counter = counter + 1;  
		xx1 = max(x1(i), x1(I(1:last-1)));
		yy1 = max(y1(i), y1(I(1:last-1)));
		xx2 = min(x2(i), x2(I(1:last-1)));
		yy2 = min(y2(i), y2(I(1:last-1)));  
		w = max(0.0, xx2-xx1+1);
		h = max(0.0, yy2-yy1+1); 
		inter = w.*h;
		if strcmp(type,'Min')
			o = inter ./ min(area(i),area(I(1:last-1)));
		else
			o = inter ./ (area(i) + area(I(1:last-1)) - inter);
		end
		I = I(find(o<=threshold));
	end
	pick = pick(1:(counter-1));
end