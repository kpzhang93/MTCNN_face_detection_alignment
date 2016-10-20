function [boundingbox reg] = generateBoundingBox(map,reg,scale,t)
	%use heatmap to generate bounding boxes
    stride=2;
    cellsize=12;
    boundingbox=[];
	map=map;
	dx1=reg(:,:,1);
	dy1=reg(:,:,2);
	dx2=reg(:,:,3);
	dy2=reg(:,:,4);
    [y x]=find(map>=t);
	a=find(map>=t); 
	score=map(a);
	reg=[dx1(a) dy1(a) dx2(a) dy2(a)];
	if isempty(reg)
		reg=reshape([],[0 3]);
	end
    boundingbox=[x y];
    boundingbox=[fix((stride*(boundingbox-1)+1)/scale) fix((stride*(boundingbox-1)+cellsize-1+1)/scale) score reg];
end
