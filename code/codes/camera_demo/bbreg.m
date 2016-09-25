function [boundingbox] = bbreg(boundingbox,reg)
	%calibrate bouding boxes
	if size(reg,2)==1
		reg=reshape(reg,[size(reg,3) size(reg,4)])';
	end
	w=[boundingbox(:,3)-boundingbox(:,1)]+1;
	h=[boundingbox(:,4)-boundingbox(:,2)]+1;
	boundingbox(:,1:4)=[boundingbox(:,1)+reg(:,1).*w boundingbox(:,2)+reg(:,2).*h boundingbox(:,3)+reg(:,3).*w boundingbox(:,4)+reg(:,4).*h];
end

