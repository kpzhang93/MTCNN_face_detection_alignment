function [bboxA] = rerec(bboxA)
	%convert bboxA to square
	bboxB=bboxA(:,1:4);
    h=bboxA(:,4)-bboxA(:,2);
	w=bboxA(:,3)-bboxA(:,1);
    l=max([w h]')';
    bboxA(:,1)=bboxA(:,1)+w.*0.5-l.*0.5;
    bboxA(:,2)=bboxA(:,2)+h.*0.5-l.*0.5;
    bboxA(:,3:4)=bboxA(:,1:2)+repmat(l,[1 2]);
end

