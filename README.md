%
% SGR/WSGR: (weighted) sparse graph regularization DEMO.
%        Version: 1.0
%        Date   : Apr 2021
%
%    This demo shows the SGR/WSGR methods for hyperspectral image classification.
%
%    fun_SGR.m ....... A function implementing the SGR model
%    sunsal.m ..........A function conducting SR using sunsal algorithm
%    calcError.m .......A function for computing confusion matrix
%    soft.m ............A soft thresholding function
%    IP_WSGR.m ............. A main code to run SGR/WSGR on IP data sets
%    PU_WSGR.m ................... A main code to run SGR/WSGR on PU data sets
%    /data ................ The folder contains the IP and PU data sets
%    /GCmex2.0 .............The folder contains the Graph cuts codes
%
%
%   --------------------------------------
%   Cite:
%   --------------------------------------
%
%   [1]Z. Xue, P. Du, J. Li, H. Su. Sparse graph regularization for hyperspectral remote sensing image classification[J].
%      IEEE Transactions on Geoscience Remote Sensing, 2017, 55(4): 2351-2366.
%   [2]Z. Xue, S. Yang and L. Zhang. Weighted Sparse Graph Regularization for Spectral-Spatial Classification of Hyperspectral Images[J].
%      IEEE Geoscience and Remote Sensing Letters, 2021, doi: 10.1109/LGRS.2020.3005168.
%
%   --------------------------------------
%   Copyright & Disclaimer
%   --------------------------------------
%
%   The programs contained in this package are granted free of charge for
%   research and education purposes only. %
%
% Copyright (c) 2021 by Zhaohui Xue
% zhaohui.xue@hhu.edu.cn
% https://sites.google.com/site/zhaohuixuers/
