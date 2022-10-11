# MTCNN_face_detection_alignment
Joint Face Detection and Alignment using Multi-task Cascaded Convolutional Neural Networks

### Requirement
1. Caffe: Linux OS: https://github.com/BVLC/caffe. Windows OS: https://github.com/BVLC/caffe/tree/windows or https://github.com/happynear/caffe-windows 
2. Pdollar toolbox: https://github.com/pdollar/toolbox
3. Matlab 2014b or later
4. Cuda (if use nvidia gpu)

### Results
![image](https://kpzhang93.github.io/MTCNN_face_detection_alignment/paper/examples.png)
![image](https://kpzhang93.github.io/MTCNN_face_detection_alignment/paper/result.png)

### Other implementation
[C++ & caffe ](https://github.com/happynear/MTCNN_face_detection_alignment)<br>
[Python & mxnet](https://github.com/pangyupo/mxnet_mtcnn_face_detection)<br>
[Python & caffe](https://github.com/DuinoDu/mtcnn)<br>
[Python & Pytorch](https://modelscope.cn/models/damo/cv_manual_face-detection_mtcnn/summary)

### Face Recognition 
Here we strongly recommend [Center Face](https://github.com/ydwen/caffe-face), which is an effective and efficient open-source tool for face recognition.

### Citation
    @article{7553523,
        author={K. Zhang and Z. Zhang and Z. Li and Y. Qiao}, 
        journal={IEEE Signal Processing Letters}, 
        title={Joint Face Detection and Alignment Using Multitask Cascaded Convolutional Networks}, 
        year={2016}, 
        volume={23}, 
        number={10}, 
        pages={1499-1503}, 
        keywords={Benchmark testing;Computer architecture;Convolution;Detectors;Face;Face detection;Training;Cascaded convolutional neural network (CNN);face alignment;face detection}, 
        doi={10.1109/LSP.2016.2603342}, 
        ISSN={1070-9908}, 
        month={Oct}
    }
    @inproceedings{zhang2017detecting,
        title={Detecting faces using inside cascaded contextual cnn},
        author={Zhang, Kaipeng and Zhang, Zhanpeng and Wang, Hao and Li, Zhifeng and Qiao, Yu and Liu, Wei},
        booktitle={Proceedings of the IEEE International Conference on Computer Vision},
        pages={3171--3179},
        year={2017}
    }

### License
This code is distributed under MIT LICENSE

### Contact
Yu Qiao
yu.qiao@siat.ac.cn<br>
Kaipeng Zhang
zhangkaipeng@pjlab.org.cn
