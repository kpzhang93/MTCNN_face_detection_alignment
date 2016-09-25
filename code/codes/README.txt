Requirement
1. Caffe: Linux OS: https://github.com/BVLC/caffe. Windows OS: https://github.com/BVLC/caffe/tree/windows or https://github.com/happynear/caffe-windows 
2. Pdollar toolbox: https://github.com/pdollar/toolbox
3. Matlab 2014b or later
4. Cuda (if use nvidia gpu)

'MTCNNv1' is an implementation of our 'Joint Face Detection and Alignment using Multi-task Cascaded Convolutional Neural Networks' paper.
'MTCNNv2' is an extended version (using iamge patch around each landmark outputted from stage 3 to make a precise regression).
'camera_demo' is a camera face detection demo based on MTCNNv2

If you want to reproduce our results on WIDER FACE in our paper, please set minsize as 10, scale factor as 0.79 and threshold as [0.5 0.5 0.3].

Contact:
Yu Qiao
yu.qiao@siat.ac.cn
Kaipeng Zhang
kpzhang@cmlab.csie.ntu.edu.tw